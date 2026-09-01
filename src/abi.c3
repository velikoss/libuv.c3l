<*
 Runtime ABI verification.
*>
module libuv;

faultdef ABI_MISMATCH;

<* One type whose C3 size disagrees with the linked libuv. *>
struct AbiMismatch
{
	<* C name of the type, for example "uv_tcp_t". *>
	String name;
	<* Size this binding compiled in. *>
	usz declared;
	<* Size the linked libuv reports. *>
	usz actual;
}

<*
 Compares every handle, request and loop size against the linked libuv.

 @param [out] mismatches : "receives the first mismatches found; pass an empty slice to only count them"
 @return "the total number of mismatches, which may exceed `mismatches.len`"
*>
fn usz check_abi(AbiMismatch[] mismatches)
{
	usz found = 0;
	record(mismatches, &found, "uv_loop_t", Loop::size, api::uv_loop_size());
	foreach (e : HANDLE_SIZES) record(mismatches, &found, e.name, e.size, api::uv_handle_size(e.type));
	foreach (e : REQ_SIZES) record(mismatches, &found, e.name, e.size, api::uv_req_size(e.type));
	return found;
}

<*
 Fails unless every handle, request and loop size matches the linked libuv.
 @return? ABI_MISMATCH
*>
fn void? assert_abi()
{
	if (check_abi({})) return ABI_MISMATCH~;
}

<*
 True when the linked libuv has the major and minor version these declarations
 were transcribed from. Patch releases never change layout.
*>
fn bool version_matches()
{
	CUInt v = api::uv_version();
	return (v >> 16) == BOUND_VERSION_MAJOR && ((v >> 8) & 0xFF) == BOUND_VERSION_MINOR;
}

<* Version of the linked libuv as a `major`, `minor`, `patch` triple. *>
fn CUInt[3] version()
{
	CUInt v = api::uv_version();
	return { v >> 16, (v >> 8) & 0xFF, v & 0xFF };
}

fn void record(AbiMismatch[] out, usz* found, String name, usz declared, usz actual) @local
{
	if (declared == actual) return;
	if (*found < out.len) out[*found] = { name, declared, actual };
	(*found)++;
}

struct HandleSize @local
{
	HandleType type;
	String name;
	usz size;
}

struct ReqSize @local
{
	ReqType type;
	String name;
	usz size;
}

const HandleSize[16] HANDLE_SIZES @local = {
	{ HandleType.ASYNC, "uv_async_t", Async::size },
	{ HandleType.CHECK, "uv_check_t", Check::size },
	{ HandleType.FS_EVENT, "uv_fs_event_t", FsEvent::size },
	{ HandleType.FS_POLL, "uv_fs_poll_t", FsPoll::size },
	{ HandleType.HANDLE, "uv_handle_t", Handle::size },
	{ HandleType.IDLE, "uv_idle_t", Idle::size },
	{ HandleType.NAMED_PIPE, "uv_pipe_t", Pipe::size },
	{ HandleType.POLL, "uv_poll_t", Poll::size },
	{ HandleType.PREPARE, "uv_prepare_t", Prepare::size },
	{ HandleType.PROCESS, "uv_process_t", Process::size },
	{ HandleType.STREAM, "uv_stream_t", Stream::size },
	{ HandleType.TCP, "uv_tcp_t", Tcp::size },
	{ HandleType.TIMER, "uv_timer_t", Timer::size },
	{ HandleType.TTY, "uv_tty_t", Tty::size },
	{ HandleType.UDP, "uv_udp_t", Udp::size },
	{ HandleType.SIGNAL, "uv_signal_t", Signal::size },
};

const ReqSize[10] REQ_SIZES @local = {
	{ ReqType.REQ, "uv_req_t", Req::size },
	{ ReqType.CONNECT, "uv_connect_t", Connect::size },
	{ ReqType.WRITE, "uv_write_t", Write::size },
	{ ReqType.SHUTDOWN, "uv_shutdown_t", Shutdown::size },
	{ ReqType.UDP_SEND, "uv_udp_send_t", UdpSend::size },
	{ ReqType.FS, "uv_fs_t", Fs::size },
	{ ReqType.WORK, "uv_work_t", Work::size },
	{ ReqType.GETADDRINFO, "uv_getaddrinfo_t", GetAddrInfo::size },
	{ ReqType.GETNAMEINFO, "uv_getnameinfo_t", GetNameInfo::size },
	{ ReqType.RANDOM, "uv_random_t", Random::size },
};
