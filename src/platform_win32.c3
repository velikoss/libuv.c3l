<*
 Windows platform layer: primitive typedefs, socket address structs and the
 per handle private field blocks that libuv appends after the public ones.
*>
module libuv @feat(WIN32);
import std::os::win32;
import std::net::os;

// Primitive types

<* C `uv_buf_t`. On Windows this is a `WSABUF`, so `len` comes first. *>
struct Buf
{
	Win32_ULONG len;
	char* base;
}

<*
 C `uv_file`: a C runtime file descriptor, which is what the `fs` family works
 on. Distinct from `OsFd`, the native handle -- on Windows those are different
 things, and `libuv::open_osfhandle` converts between them.
*>
alias Fd = CInt;

<* C `uv_os_sock_t`, a native socket. *>
alias OsSock = Win32_SOCKET;

<* C `uv_os_fd_t`, a native handle. Not the same as `Fd`. *>
alias OsFd = Win32_HANDLE;
alias Pid = CInt;
alias Uid = CUChar;
alias Gid = CUChar;

<* C `uv_thread_t`. *>
typedef Thread = Win32_HANDLE;
<* C `uv_sem_t`. *>
typedef Sem = Win32_HANDLE;
<* C `uv_mutex_t`, a `CRITICAL_SECTION`. *>
typedef Mutex = Win32_CRITICAL_SECTION;

<* C `uv_once_t`. Zero initialise, then pass to `libuv::once`. *>
struct Once
{
	char unused;
	Win32_INIT_ONCE init_once;
}

<* C `uv_rwlock_t`. The padding is retained by libuv for ABI compatibility. *>
struct RwLock
{
	Win32_SRWLOCK read_write_lock_;
	char[72] padding_;
}

<* C `uv_cond_t`. *>
union Cond
{
	Win32_CONDITION_VARIABLE cond_var;
	struct unused_
	{
		CUInt waiters_count;
		Mutex waiters_count_lock;
		Win32_HANDLE signal_event;
		Win32_HANDLE broadcast_event;
	}
}

<* C `uv_barrier_t`. *>
struct Barrier
{
	CUInt threshold;
	CUInt in;
	Mutex mutex;
	Win32_CONDITION_VARIABLE cond;
	CUInt out;
}

<* C `uv_key_t`, a TLS slot index. *>
struct Key
{
	Win32_DWORD tls_index;
}

// Socket addresses
//
// libuv takes and fills plain BSD socket addresses. The standard library models
// them opaquely as `SockAddrPtr`, so the concrete layouts are declared here.

<* C `struct sockaddr`. *>
struct SockAddr
{
	CUShort sa_family;
	char[14] sa_data;
}

<* C `struct in_addr`, an IPv4 address in network byte order. *>
struct InAddr
{
	uint s_addr;
}

<* C `struct in6_addr`, an IPv6 address in network byte order. *>
struct In6Addr
{
	char[16] s6_addr;
}

<* C `struct sockaddr_in`. Fill it with `libuv::ip4_addr`. *>
struct SockAddrIn
{
	CShort sin_family;
	CUShort sin_port;
	InAddr sin_addr;
	char[8] sin_zero;
}

<* C `struct sockaddr_in6`. Fill it with `libuv::ip6_addr`. *>
struct SockAddrIn6
{
	CShort sin6_family;
	CUShort sin6_port;
	Win32_ULONG sin6_flowinfo;
	In6Addr sin6_addr;
	Win32_ULONG sin6_scope_id;
}

<* C `struct sockaddr_storage`, large enough for any address family. *>
struct SockAddrStorage
{
	CShort ss_family;
	char[6] __ss_pad1;
	long __ss_align;
	char[112] __ss_pad2;
}

<* C `struct addrinfo`, shared with `std::net::os`. *>
alias AddrInfo = os::AddrInfo;

// Winsock and NT plumbing referenced by the private blocks

alias LpfnAcceptEx @private = fn Win32_BOOL(Win32_SOCKET, Win32_SOCKET, void*, Win32_DWORD,
	Win32_DWORD, Win32_DWORD, Win32_LPDWORD, Win32_OVERLAPPED*);

alias LpfnConnectEx @private = fn Win32_BOOL(Win32_SOCKET, SockAddr*, CInt, void*,
	Win32_DWORD, Win32_LPDWORD, Win32_OVERLAPPED*);

alias LpwsaOverlappedCompletionRoutine @private = fn void(Win32_DWORD, Win32_DWORD,
	Win32_OVERLAPPED*, Win32_DWORD);

alias LpfnWsaRecv @private = fn CInt(Win32_SOCKET, Buf*, Win32_DWORD, Win32_LPDWORD,
	Win32_LPDWORD, Win32_OVERLAPPED*, LpwsaOverlappedCompletionRoutine);

alias LpfnWsaRecvFrom @private = fn CInt(Win32_SOCKET, Buf*, Win32_DWORD, Win32_LPDWORD,
	Win32_LPDWORD, SockAddr*, Win32_LPINT, Win32_OVERLAPPED*,
	LpwsaOverlappedCompletionRoutine);

struct AfdPollHandleInfo @private
{
	Win32_HANDLE handle;
	Win32_ULONG events;
	Win32_LONG status;
}

struct AfdPollInfo @private
{
	Win32_LARGE_INTEGER timeout;
	Win32_ULONG number_of_handles;
	Win32_ULONG exclusive;
	AfdPollHandleInfo[1] handles;
}

// Private request kinds
//
// C `UV_PRIVATE_REQ_TYPES`. Embedded by value in the private blocks below.

<* C `uv_pipe_accept_t`. *>
struct PipeAccept
{
	inline Req req;
	Win32_HANDLE pipe_handle;
	PipeAccept* next_pending;
}

<* C `uv_tcp_accept_t`. *>
struct TcpAccept
{
	inline Req req;
	Win32_SOCKET accept_socket;
	char[SockAddrStorage::size * 2 + 32] accept_buffer;
	Win32_HANDLE event_handle;
	Win32_HANDLE wait_handle;
	TcpAccept* next_pending;
}

<* C `uv_read_t`. *>
struct Read
{
	inline Req req;
	Win32_HANDLE event_handle;
	Win32_HANDLE wait_handle;
}

// Private field blocks

<* C `UV_HANDLE_PRIVATE_FIELDS`. *>
struct HandlePrivate
{
	Handle* endgame_next;
	CUInt flags;
}

<* C `UV_REQ_PRIVATE_FIELDS`. *>
struct ReqPrivate
{
	union u
	{
		struct io
		{
			Win32_OVERLAPPED overlapped;
			usz queued_bytes;
		}
		struct connect
		{
			Win32_ULONG_PTR result;
			Win32_HANDLE pipe_handle;
			Win32_DWORD duplex_flags;
			Win32_WCHAR* name;
		}
	}
	Req* next_req;
}

<* C `UV_WRITE_PRIVATE_FIELDS`. *>
struct WritePrivate
{
	CInt coalesced;
	Buf write_buffer;
	Win32_HANDLE event_handle;
	Win32_HANDLE wait_handle;
}

<* C `UV_STREAM_PRIVATE_FIELDS`. *>
struct StreamPrivate
{
	CUInt reqs_pending;
	CInt activecnt;
	Read read_req;
	union stream
	{
		struct conn
		{
			CUInt write_reqs_pending;
			Shutdown* shutdown_req;
		}
		struct serv
		{
			ConnectionCallback connection_cb;
		}
	}
}

<* C `UV_TCP_PRIVATE_FIELDS`. *>
struct TcpPrivate
{
	Win32_SOCKET socket;
	CInt delayed_error;
	union tcp
	{
		struct serv
		{
			TcpAccept* accept_reqs;
			CUInt processed_accepts;
			TcpAccept* pending_accepts;
			LpfnAcceptEx func_acceptex;
		}
		struct conn
		{
			Buf read_buffer;
			LpfnConnectEx func_connectex;
		}
	}
}

<* C `UV_UDP_PRIVATE_FIELDS`. *>
struct UdpPrivate
{
	Win32_SOCKET socket;
	CUInt reqs_pending;
	CInt activecnt;
	Req recv_req;
	Buf recv_buffer;
	SockAddrStorage recv_from;
	CInt recv_from_len;
	UdpRecvCallback recv_cb;
	AllocCallback alloc_cb;
	LpfnWsaRecv func_wsarecv;
	LpfnWsaRecvFrom func_wsarecvfrom;
}

<* C `UV_PIPE_PRIVATE_FIELDS`. *>
struct PipePrivate
{
	Win32_HANDLE handle;
	Win32_WCHAR* name;
	union pipe
	{
		struct serv
		{
			CInt pending_instances;
			PipeAccept* accept_reqs;
			PipeAccept* pending_accepts;
		}
		struct conn
		{
			Timer* eof_timer;
			Write dummy;
			Win32_DWORD ipc_remote_pid;
			union ipc_data_frame
			{
				uint payload_remaining;
				ulong dummy;
			}
			Queue ipc_xfer_queue;
			CInt ipc_xfer_queue_length;
			Write* non_overlapped_writes_tail;
			Mutex readfile_thread_lock;
			Win32_HANDLE readfile_thread_handle;
		}
	}
}

<* C `UV_TTY_PRIVATE_FIELDS`. *>
struct TtyPrivate
{
	Win32_HANDLE handle;
	union tty
	{
		struct rd
		{
			union mode
			{
				Win32_HANDLE unused_;
				CInt mode;
			}
			Buf read_line_buffer;
			Win32_HANDLE read_raw_wait;
			char[8] last_key;
			char last_key_offset;
			char last_key_len;
			Win32_WCHAR last_utf16_high_surrogate;
			InputRecord last_input_record;
		}
		struct wr
		{
			CUInt utf8_codepoint;
			char utf8_bytes_left;
			char previous_eol;
			ushort ansi_parser_state;
			char ansi_csi_argc;
			ushort[4] ansi_csi_argv;
			Coord saved_position;
			Win32_WORD saved_attributes;
		}
	}
}

<* C `UV_POLL_PRIVATE_FIELDS`. *>
struct PollPrivate
{
	Win32_SOCKET socket;
	Win32_SOCKET peer_socket;
	AfdPollInfo afd_poll_info_1;
	AfdPollInfo afd_poll_info_2;
	Req poll_req_1;
	Req poll_req_2;
	char submitted_events_1;
	char submitted_events_2;
	char mask_events_1;
	char mask_events_2;
	char events;
}

<* C `UV_TIMER_PRIVATE_FIELDS`. *>
struct TimerPrivate
{
	union node
	{
		void*[3] heap;
		Queue queue;
	}
	CInt unused;
	ulong timeout;
	ulong repeat;
	ulong start_id;
	TimerCallback timer_cb;
}

<* C `UV_ASYNC_PRIVATE_FIELDS`. *>
struct AsyncPrivate
{
	Req async_req;
	AsyncCallback async_cb;
	char async_sent;
}

<* C `UV_PREPARE_PRIVATE_FIELDS`. *>
struct PreparePrivate
{
	Prepare* prepare_prev;
	Prepare* prepare_next;
	PrepareCallback prepare_cb;
}

<* C `UV_CHECK_PRIVATE_FIELDS`. *>
struct CheckPrivate
{
	Check* check_prev;
	Check* check_next;
	CheckCallback check_cb;
}

<* C `UV_IDLE_PRIVATE_FIELDS`. *>
struct IdlePrivate
{
	Idle* idle_prev;
	Idle* idle_next;
	IdleCallback idle_cb;
}

<* C `UV_PROCESS_PRIVATE_FIELDS`. *>
struct ProcessPrivate
{
	Req exit_req;
	void* unused;
	CInt exit_signal;
	Win32_HANDLE wait_handle;
	Win32_HANDLE process_handle;
	char exit_cb_pending;
}

<* C `UV_FS_EVENT_PRIVATE_FIELDS`. *>
struct FsEventPrivate
{
	Req req;
	Win32_HANDLE dir_handle;
	CInt req_pending;
	FsEventCallback cb;
	Win32_WCHAR* filew;
	Win32_WCHAR* short_filew;
	Win32_WCHAR* dirw;
	char* buffer;
}

<* C `UV_SIGNAL_PRIVATE_FIELDS`. *>
struct SignalPrivate
{
	struct tree_entry
	{
		Signal* rbe_left;
		Signal* rbe_right;
		Signal* rbe_parent;
		CInt rbe_color;
	}
	Req signal_req;
	CULong pending_signum;
}

<* C `UV_GETADDRINFO_PRIVATE_FIELDS`. *>
struct GetAddrInfoPrivate
{
	InternalWork work_req;
	GetAddrInfoCallback getaddrinfo_cb;
	void* alloc;
	Win32_WCHAR* node;
	Win32_WCHAR* service;
	void* addrinfow;
	AddrInfo* addrinfo;
	CInt retcode;
}

<* Longest hostname `libuv::getnameinfo` will store, C `NI_MAXHOST`. *>
const usz NI_MAXHOST = 1025;
<* Longest service name `libuv::getnameinfo` will store, C `NI_MAXSERV`. *>
const usz NI_MAXSERV = 32;

<* C `UV_GETNAMEINFO_PRIVATE_FIELDS`. *>
struct GetNameInfoPrivate
{
	InternalWork work_req;
	GetNameInfoCallback getnameinfo_cb;
	SockAddrStorage storage;
	CInt flags;
	char[NI_MAXHOST] host;
	char[NI_MAXSERV] service;
	CInt retcode;
}

<* C `UV_WORK_PRIVATE_FIELDS`. *>
struct WorkPrivate
{
	InternalWork work_req;
}

<* C `UV_FS_PRIVATE_FIELDS`. *>
struct FsPrivate
{
	InternalWork work_req;
	CInt flags;
	Win32_DWORD sys_errno_;
	union file
	{
		Win32_WCHAR* pathw;
		CInt fd;
	}
	union fs
	{
		struct info
		{
			CInt mode;
			Win32_WCHAR* new_pathw;
			CInt file_flags;
			CInt fd_out;
			CUInt nbufs;
			Buf* bufs;
			long offset;
			Buf[4] bufsml;
		}
		struct time
		{
			double atime;
			double mtime;
		}
	}
}

<* C `UV_DIR_PRIVATE_FIELDS`. *>
struct DirPrivate
{
	Win32_HANDLE dir_handle;
	Win32_WIN32_FIND_DATAW find_data;
	Win32_BOOL need_find_call;
}

<* C `UV_LOOP_PRIVATE_FIELDS`. *>
struct LoopPrivate
{
	<* The loop I/O completion port. *>
	Win32_HANDLE iocp;
	<* Loop time in milliseconds. *>
	ulong time;
	Req* pending_reqs_tail;
	Handle* endgame_handles;
	void* timer_heap;
	Prepare* prepare_handles;
	Check* check_handles;
	Idle* idle_handles;
	Prepare* next_prepare_handle;
	Check* next_check_handle;
	Idle* next_idle_handle;
	Win32_SOCKET[MSAFD_PROVIDER_COUNT] poll_peer_sockets;
	CUInt active_tcp_streams;
	CUInt active_udp_streams;
	ulong timer_counter;
	Queue wq;
	Mutex wq_mutex;
	Async wq_async;
}

const usz MSAFD_PROVIDER_COUNT @private = 4;

// Console records used by TtyPrivate

struct Coord @private
{
	Win32_SHORT x;
	Win32_SHORT y;
}

struct KeyEventRecord @private
{
	Win32_BOOL b_key_down;
	Win32_WORD w_repeat_count;
	Win32_WORD w_virtual_key_code;
	Win32_WORD w_virtual_scan_code;
	union u_char
	{
		Win32_WCHAR unicode_char;
		Win32_CHAR ascii_char;
	}
	Win32_DWORD dw_control_key_state;
}

struct MouseEventRecord @private
{
	Coord dw_mouse_position;
	Win32_DWORD dw_button_state;
	Win32_DWORD dw_control_key_state;
	Win32_DWORD dw_event_flags;
}

struct InputRecord @private
{
	Win32_WORD event_type;
	union event
	{
		KeyEventRecord key_event;
		MouseEventRecord mouse_event;
		Coord window_buffer_size_event;
		Win32_UINT menu_event;
		Win32_BOOL focus_event;
	}
}
