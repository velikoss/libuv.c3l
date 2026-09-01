<*
 Request struct definitions: `Req` and every `uv_*_t` request.

 The operations on them live elsewhere -- `Req` methods in handle.c3, the rest
 in the file for their area.

 Every request starts with the `Req` field block, so `inline Req req` as the
 first member gives both the C layout and an implicit upcast to `Req*`, which
 is what `Req.cancel` and the `Req` methods work on.

 A request must stay alive until its callback has run.
*>
module libuv;

<*
 The base class of every request, C `uv_req_t`.

 `data` is the only field meant to be written by user code; `type` is read only.
*>
struct Req
{
	<* Free for the user. *>
	void* data;
	// read-only
	ReqType type;
	// private
	void*[6] reserved;
	ReqPrivate _private @if(env::WIN32);
}

<* Half closes the write side of a stream, C `uv_shutdown_t`. *>
struct Shutdown
{
	inline Req req;
	<* The stream being shut down. Read only. *>
	Stream* handle;
	<* Invoked once the shutdown completes. *>
	ShutdownCallback cb;
}

<* A queued stream write, C `uv_write_t`. *>
struct Write
{
	inline Req req;
	<* Invoked once the write completes. *>
	WriteCallback cb;
	<* Handle passed along by `libuv::write2`, otherwise null. *>
	Stream* send_handle;
	<* The stream being written to. Read only. *>
	Stream* handle;
	WritePrivate _private;
}

<* A pending connect, C `uv_connect_t`. *>
struct Connect
{
	inline Req req;
	<* Invoked once the connect completes. *>
	ConnectCallback cb;
	<* The stream being connected. Read only. *>
	Stream* handle;
	ConnectPrivate _private @if(!env::WIN32);
}

<* A queued datagram send, C `uv_udp_send_t`. *>
struct UdpSend
{
	inline Req req;
	<* The socket sending the datagram. Read only. *>
	Udp* handle;
	<* Invoked once the send completes. *>
	UdpSendCallback cb;
	UdpSendPrivate _private @if(!env::WIN32);
}

<* An address resolution request, C `uv_getaddrinfo_t`. *>
struct GetAddrInfo
{
	inline Req req;
	<* The loop the request runs on. Read only. *>
	Loop* loop;
	GetAddrInfoPrivate _private;
}

<* A reverse resolution request, C `uv_getnameinfo_t`. *>
struct GetNameInfo
{
	inline Req req;
	<* The loop the request runs on. Read only. *>
	Loop* loop;
	GetNameInfoPrivate _private;
}

<* A threadpool job, C `uv_work_t`. *>
struct Work
{
	inline Req req;
	<* The loop the completion callback runs on. Read only. *>
	Loop* loop;
	<* Runs on a threadpool thread. *>
	WorkCallback work_cb;
	<* Runs on the loop thread once `work_cb` returned. *>
	AfterWorkCallback after_work_cb;
	WorkPrivate _private;
}

<* A request for entropy, C `uv_random_t`. *>
struct Random
{
	inline Req req;
	<* The loop the request runs on. Read only. *>
	Loop* loop;
	// private
	CInt status;
	void* buf;
	usz buflen;
	RandomCallback cb;
	InternalWork work_req;
}

<*
 A filesystem request, C `uv_fs_t`.

 Always pass the request to `Fs.cleanup` once you are done with it, whether the
 call was synchronous or asynchronous.
*>
struct Fs
{
	inline Req req;
	<* Which operation this request ran. Read only. *>
	FsType fs_type;
	<* The loop the request runs on. Read only. *>
	Loop* loop;
	<* Invoked on completion, null for a synchronous call. *>
	FsCallback cb;
	<* Result of the operation: a count, or a negative `ErrorCode`. Read only. *>
	sz result;
	<* Operation specific result pointer. Read only. *>
	void* ptr;
	<* Path the operation ran on, if any. Read only. *>
	ZString path;
	<* Filled in by the `stat` family. Read only. *>
	Stat statbuf;
	FsPrivate _private;
}
