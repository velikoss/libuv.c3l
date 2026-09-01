<*
 Unix platform layer: primitive typedefs, socket address structs and the per
 handle private field blocks that libuv appends after the public ones.

 Every layout here mirrors `include/uv/unix.h` plus the per OS header it pulls
 in. The pthread primitives are taken from `std::thread::os` so that there is a
 single place where those sizes are maintained.
*>
module libuv @feat(!WIN32);
import std::net::os;
import std::thread::os;
import std::os::posix;
import libc;

// Primitive types

<* C `uv_buf_t`. May be cast to `struct iovec`, see writev(2). *>
struct Buf
{
	char* base;
	usz len;
}

<*
 C `uv_file`: a file descriptor, which is what the `fs` family works on. The
 same as `OsFd` on unix, but not on Windows, so keep them apart.
*>
alias Fd = CInt;

<* C `uv_os_sock_t`, a native socket. *>
alias OsSock = CInt;

<* C `uv_os_fd_t`, a native handle. *>
alias OsFd = CInt;
alias Pid = CInt;
alias Uid = CUInt;
alias Gid = CUInt;

<* C `mode_t`. *>
alias Mode @feat(DARWIN, BSD) = CUShort;
alias Mode @feat(!DARWIN) @feat(!BSD) = CUInt;

<* C `off_t`, always 64 bit in the configurations libuv supports. *>
alias Off = long;

typedef Once = Pthread_once_t;
typedef Thread = Pthread_t;
typedef Mutex = Pthread_mutex_t;
typedef RwLock = Pthread_rwlock_t;
typedef Cond = Pthread_cond_t;
typedef Key = Pthread_key_t;

<*
 C `uv_sem_t`.

 A Mach semaphore port on Darwin, a POSIX `sem_t` everywhere else.
*>
typedef Sem @feat(DARWIN) = CUInt;
typedef Sem @feat(!DARWIN) = Sem_t;

<*
 C `uv_barrier_t`.

 Platforms with a usable `pthread_barrier_t` store it inline; the rest store a
 pointer to a libuv allocated fallback. Not embedded in any other libuv type,
 so a wrong size here can only affect direct barrier use.
*>
typedef Barrier @feat(DARWIN, BSD) = void*;
typedef Barrier @feat(!DARWIN) @feat(!BSD) = ulong[4];

// Socket addresses

<*
 C `struct sockaddr`.

 The BSDs and Darwin put a length byte in front of the family; Linux does not.
*>
struct SockAddr
{
	char sa_len @if(env::DARWIN || env::BSD_FAMILY);
	char sa_family @if(env::DARWIN || env::BSD_FAMILY);
	CUShort sa_family_ @if(!env::DARWIN && !env::BSD_FAMILY);
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
	char sin_len @if(env::DARWIN || env::BSD_FAMILY);
	char sin_family @if(env::DARWIN || env::BSD_FAMILY);
	CUShort sin_family_ @if(!env::DARWIN && !env::BSD_FAMILY);
	CUShort sin_port;
	InAddr sin_addr;
	char[8] sin_zero;
}

<* C `struct sockaddr_in6`. Fill it with `libuv::ip6_addr`. *>
struct SockAddrIn6
{
	char sin6_len @if(env::DARWIN || env::BSD_FAMILY);
	char sin6_family @if(env::DARWIN || env::BSD_FAMILY);
	CUShort sin6_family_ @if(!env::DARWIN && !env::BSD_FAMILY);
	CUShort sin6_port;
	uint sin6_flowinfo;
	In6Addr sin6_addr;
	uint sin6_scope_id;
}

<* C `struct sockaddr_storage`, large enough for any address family. *>
struct SockAddrStorage
{
	char ss_len @if(env::DARWIN || env::BSD_FAMILY);
	char ss_family @if(env::DARWIN || env::BSD_FAMILY);
	CUShort ss_family_ @if(!env::DARWIN && !env::BSD_FAMILY);
	char[118] __ss_padding;
	ulong __ss_align;
}

<* C `struct addrinfo`, shared with `std::net::os`. *>
alias AddrInfo = os::AddrInfo;

// The unix I/O watcher

alias IoCallback @private = fn void(Loop* loop, Io* w, CUInt events);

<* C `uv__io_t`. Internal to libuv. *>
struct Io
{
	IoCallback cb;
	Queue pending_queue;
	Queue watcher_queue;
	<* Pending event mask, that is, the mask at the next tick. *>
	CUInt pevents;
	<* Current event mask. *>
	CUInt events;
	CInt fd;
	CInt rcount @if(env::DARWIN || env::BSD_FAMILY);
	CInt wcount @if(env::DARWIN || env::BSD_FAMILY);
}

// Private field blocks

<* C `UV_HANDLE_PRIVATE_FIELDS`. *>
struct HandlePrivate
{
	Handle* next_closing;
	CUInt flags;
}

<* C `UV_WRITE_PRIVATE_FIELDS`. *>
struct WritePrivate
{
	Queue queue;
	CUInt write_index;
	Buf* bufs;
	CUInt nbufs;
	CInt error;
	Buf[4] bufsml;
}

<* C `UV_CONNECT_PRIVATE_FIELDS`. *>
struct ConnectPrivate
{
	Queue queue;
}

<* C `UV_UDP_SEND_PRIVATE_FIELDS`. *>
struct UdpSendPrivate
{
	Queue queue;
	union u
	{
		SockAddr addr;
		SockAddrStorage storage;
	}
	CUInt nbufs;
	Buf* bufs;
	sz status;
	UdpSendCallback send_cb;
	Buf[4] bufsml;
}

<* C `UV_STREAM_PRIVATE_FIELDS`. *>
struct StreamPrivate
{
	Connect* connect_req;
	Shutdown* shutdown_req;
	Io io_watcher;
	Queue write_queue;
	Queue write_completed_queue;
	ConnectionCallback connection_cb;
	CInt delayed_error;
	CInt accepted_fd;
	void* queued_fds;
	// UV_STREAM_PRIVATE_PLATFORM_FIELDS
	void* select @if(env::DARWIN);
}

<* C `UV_UDP_PRIVATE_FIELDS`. *>
struct UdpPrivate
{
	AllocCallback alloc_cb;
	UdpRecvCallback recv_cb;
	Io io_watcher;
	Queue write_queue;
	Queue write_completed_queue;
}

<* C `UV_PIPE_PRIVATE_FIELDS`. *>
struct PipePrivate
{
	<* Null, or a libuv owned copy of the bound path. *>
	ZString pipe_fname;
}

<* C `UV_TTY_PRIVATE_FIELDS`. *>
struct TtyPrivate
{
	Termios orig_termios;
	CInt mode;
}

<* C `UV_POLL_PRIVATE_FIELDS`. *>
struct PollPrivate
{
	Io io_watcher;
}

<* C `UV_TIMER_PRIVATE_FIELDS`. *>
struct TimerPrivate
{
	TimerCallback timer_cb;
	union node
	{
		void*[3] heap;
		Queue queue;
	}
	ulong timeout;
	ulong repeat;
	ulong start_id;
}

<* C `UV_ASYNC_PRIVATE_FIELDS`. *>
struct AsyncPrivate
{
	AsyncCallback async_cb;
	Queue queue;
	CInt pending;
}

<* C `UV_PREPARE_PRIVATE_FIELDS`. *>
struct PreparePrivate
{
	PrepareCallback prepare_cb;
	Queue queue;
}

<* C `UV_CHECK_PRIVATE_FIELDS`. *>
struct CheckPrivate
{
	CheckCallback check_cb;
	Queue queue;
}

<* C `UV_IDLE_PRIVATE_FIELDS`. *>
struct IdlePrivate
{
	IdleCallback idle_cb;
	Queue queue;
}

<* C `UV_PROCESS_PRIVATE_FIELDS`. *>
struct ProcessPrivate
{
	Queue queue;
	CInt status;
}

<*
 C `UV_FS_EVENT_PRIVATE_FIELDS` plus `UV_PLATFORM_FS_EVENT_FIELDS`.
*>
struct FsEventPrivate
{
	FsEventCallback cb;

	// Linux
	Queue watchers @if(env::LINUX || env::ANDROID);
	CInt wd @if(env::LINUX || env::ANDROID);

	// Darwin
	Io event_watcher @if(env::DARWIN);
	char* realpath @if(env::DARWIN);
	CInt realpath_len @if(env::DARWIN);
	CInt cf_flags @if(env::DARWIN);
	Async* cf_cb @if(env::DARWIN);
	Queue cf_events @if(env::DARWIN);
	Queue cf_member @if(env::DARWIN);
	CInt cf_error @if(env::DARWIN);
	Mutex cf_mutex @if(env::DARWIN);

	// BSD family
	Io event_watcher_bsd @if(env::BSD_FAMILY);
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
	CUInt caught_signals;
	CUInt dispatched_signals;
}

<* C `UV_GETADDRINFO_PRIVATE_FIELDS`. *>
struct GetAddrInfoPrivate
{
	InternalWork work_req;
	GetAddrInfoCallback cb;
	AddrInfo* hints;
	char* hostname;
	char* service;
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
	ZString new_path;
	Fd file;
	CInt flags;
	Mode mode;
	CUInt nbufs;
	Buf* bufs;
	Off off;
	Uid uid;
	Gid gid;
	double atime;
	double mtime;
	InternalWork work_req;
	Buf[4] bufsml;
}

<* C `UV_DIR_PRIVATE_FIELDS`. *>
struct DirPrivate
{
	<* C `DIR*`. *>
	void* dir;
}

<* C `UV_LOOP_PRIVATE_FIELDS` plus `UV_PLATFORM_LOOP_FIELDS`. *>
struct LoopPrivate
{
	CULong flags;
	CInt backend_fd;
	Queue pending_queue;
	Queue watcher_queue;
	Io** watchers;
	CUInt nwatchers;
	CUInt nfds;
	Queue wq;
	Mutex wq_mutex;
	Async wq_async;
	RwLock cloexec_lock;
	Handle* closing_handles;
	Queue process_handles;
	Queue prepare_handles;
	Queue check_handles;
	Queue idle_handles;
	Queue async_handles;
	<* Retained by libuv for ABI compatibility, unused. *>
	OnceCallback async_unused;
	Io async_io_watcher;
	CInt async_wfd;
	struct timer_heap
	{
		void* min;
		CUInt nelts;
	}
	ulong timer_counter;
	ulong time;
	CInt[2] signal_pipefd;
	Io signal_io_watcher;
	Signal child_watcher;
	CInt emfile_fd;

	// Linux: UV_PLATFORM_LOOP_FIELDS
	Io inotify_read_watcher @if(env::LINUX || env::ANDROID);
	void* inotify_watchers @if(env::LINUX || env::ANDROID);
	CInt inotify_fd @if(env::LINUX || env::ANDROID);

	// Darwin: UV_PLATFORM_LOOP_FIELDS
	Thread cf_thread @if(env::DARWIN);
	void* _cf_reserved @if(env::DARWIN);
	void* cf_state @if(env::DARWIN);
	Mutex cf_mutex @if(env::DARWIN);
	Sem cf_sem @if(env::DARWIN);
	Queue cf_signals @if(env::DARWIN);
}
