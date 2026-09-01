<*
 Core type vocabulary shared by every platform.

 Naming: the module path is the namespace, so the `uv_` prefix and the `_t`
 suffix of the C names are dropped. `uv_loop_t` is `libuv::Loop`, `uv_run_mode`
 is `libuv::RunMode`. The untouched C entry points live in `libuv::api`.
*>
module libuv;

<* libuv release these declarations were transcribed from. *>
const CUInt BOUND_VERSION_MAJOR = 1;
const CUInt BOUND_VERSION_MINOR = 51;
const CUInt BOUND_VERSION_PATCH = 0;

<*
 Intrusive doubly linked list node, C `struct uv__queue`.

 Internal to libuv; declared only so that handle layouts match. Never touch it.
*>
struct Queue
{
	Queue* next;
	Queue* prev;
}

// Enumerations

<* Kind tag stored in `Handle.type`. Ordinals match `uv_handle_type`. *>
enum HandleType : CInt
{
	UNKNOWN,
	ASYNC,
	CHECK,
	FS_EVENT,
	FS_POLL,
	HANDLE,
	IDLE,
	NAMED_PIPE,
	POLL,
	PREPARE,
	PROCESS,
	STREAM,
	TCP,
	TIMER,
	TTY,
	UDP,
	SIGNAL,
	FILE,
}

<*
 Kind tag stored in `Req.type`. Ordinals match `uv_req_type`.

 Everything after `RANDOM` is a request kind libuv only has on Windows, so those
 entries exist only there. The ordinals of the shared entries are the same on
 every platform either way.
*>
enum ReqType : CInt
{
	UNKNOWN,
	REQ,
	CONNECT,
	WRITE,
	SHUTDOWN,
	UDP_SEND,
	FS,
	WORK,
	GETADDRINFO,
	GETNAMEINFO,
	RANDOM,
	ACCEPT @feat(WIN32),
	FS_EVENT_REQ @feat(WIN32),
	POLL_REQ @feat(WIN32),
	PROCESS_EXIT @feat(WIN32),
	READ @feat(WIN32),
	UDP_RECV @feat(WIN32),
	WAKEUP @feat(WIN32),
	SIGNAL_REQ @feat(WIN32),
}

<* Argument of `Loop.run`. *>
enum RunMode : CInt
{
	<* Run until no active handles or requests remain. *>
	DEFAULT,
	<* Poll once, blocking if there is nothing to do yet. *>
	ONCE,
	<* Poll once without blocking. *>
	NOWAIT,
}

<* Option selector for `Loop.configure`. *>
enum LoopOption : CInt
{
	BLOCK_SIGNAL,
	METRICS_IDLE_TIME,
	USE_IO_URING_SQPOLL,
}

<* Clock selector for `libuv::clock_gettime`. *>
enum ClockId : CInt
{
	MONOTONIC,
	REALTIME,
}

<* Multicast group operation for `Udp.set_membership`. *>
enum Membership : CInt
{
	LEAVE_GROUP,
	JOIN_GROUP,
}

<* Terminal mode for `Tty.set_mode`. *>
enum TtyMode : CInt
{
	<* Initial, normal terminal mode. *>
	NORMAL,
	<* Raw input mode. On Windows `ENABLE_WINDOW_INPUT` is also enabled. *>
	RAW,
	<* Binary safe I/O mode for IPC. Unix only. *>
	IO,
	<* Raw input mode. On Windows `ENABLE_VIRTUAL_TERMINAL_INPUT` is also set. *>
	RAW_VT,
}

<* Result of `libuv::tty_get_vterm_state`. *>
enum TtyVtermState : CInt
{
	<* The console understands virtual terminal sequences. *>
	SUPPORTED,
	<* Legacy console: virtual terminal sequences are not processed. *>
	UNSUPPORTED,
}

<* Entry kind reported by `libuv::fs_scandir_next` and `libuv::fs_readdir`. *>
enum DirentType : CInt
{
	UNKNOWN,
	FILE,
	DIR,
	LINK,
	FIFO,
	SOCKET,
	CHAR,
	BLOCK,
}

<*
 Operation recorded in `Fs.fs_type`, C `uv_fs_type`.

 A typedef rather than an enum because `FS_UNKNOWN` is -1, outside the ordinal
 range a C3 enum can express.
*>
typedef FsType = inline CInt;

const FsType FS_UNKNOWN   = (FsType)-1;
const FsType FS_CUSTOM    = (FsType)0;
const FsType FS_OPEN      = (FsType)1;
const FsType FS_CLOSE     = (FsType)2;
const FsType FS_READ      = (FsType)3;
const FsType FS_WRITE     = (FsType)4;
const FsType FS_SENDFILE  = (FsType)5;
const FsType FS_STAT      = (FsType)6;
const FsType FS_LSTAT     = (FsType)7;
const FsType FS_FSTAT     = (FsType)8;
const FsType FS_FTRUNCATE = (FsType)9;
const FsType FS_UTIME     = (FsType)10;
const FsType FS_FUTIME    = (FsType)11;
const FsType FS_ACCESS    = (FsType)12;
const FsType FS_CHMOD     = (FsType)13;
const FsType FS_FCHMOD    = (FsType)14;
const FsType FS_FSYNC     = (FsType)15;
const FsType FS_FDATASYNC = (FsType)16;
const FsType FS_UNLINK    = (FsType)17;
const FsType FS_RMDIR     = (FsType)18;
const FsType FS_MKDIR     = (FsType)19;
const FsType FS_MKDTEMP   = (FsType)20;
const FsType FS_RENAME    = (FsType)21;
const FsType FS_SCANDIR   = (FsType)22;
const FsType FS_LINK      = (FsType)23;
const FsType FS_SYMLINK   = (FsType)24;
const FsType FS_READLINK  = (FsType)25;
const FsType FS_CHOWN     = (FsType)26;
const FsType FS_FCHOWN    = (FsType)27;
const FsType FS_REALPATH  = (FsType)28;
const FsType FS_COPYFILE  = (FsType)29;
const FsType FS_LCHOWN    = (FsType)30;
const FsType FS_OPENDIR   = (FsType)31;
const FsType FS_READDIR   = (FsType)32;
const FsType FS_CLOSEDIR  = (FsType)33;
const FsType FS_STATFS    = (FsType)34;
const FsType FS_MKSTEMP   = (FsType)35;
const FsType FS_LUTIME    = (FsType)36;

<* Child stdio slot disposition, see `StdioContainer`. *>
typedef StdioFlags = inline CInt;

const StdioFlags IGNORE         = (StdioFlags)0x00;
const StdioFlags CREATE_PIPE    = (StdioFlags)0x01;
const StdioFlags INHERIT_FD     = (StdioFlags)0x02;
const StdioFlags INHERIT_STREAM = (StdioFlags)0x04;
<* With `CREATE_PIPE`: the child may read from the pipe. *>
const StdioFlags READABLE_PIPE  = (StdioFlags)0x10;
<* With `CREATE_PIPE`: the child may write to the pipe. *>
const StdioFlags WRITABLE_PIPE  = (StdioFlags)0x20;
<* With `CREATE_PIPE`: open the child end non-blocking. *>
const StdioFlags NONBLOCK_PIPE  = (StdioFlags)0x40;

// Flag constants

// uv_tcp_flags, for Tcp.bind.
const CUInt TCP_IPV6ONLY = 1;
const CUInt TCP_REUSEPORT = 2;

// uv_udp_flags, for Udp.bind and the flags argument of UdpRecvCallback.
const CUInt UDP_IPV6ONLY = 1;
const CUInt UDP_PARTIAL = 2;
const CUInt UDP_REUSEADDR = 4;
const CUInt UDP_MMSG_CHUNK = 8;
const CUInt UDP_MMSG_FREE = 16;
const CUInt UDP_LINUX_RECVERR = 32;
const CUInt UDP_REUSEPORT = 64;
const CUInt UDP_RECVMMSG = 256;

// uv_poll_event, for Poll.start.
const CInt READABLE = 1;
const CInt WRITABLE = 2;
const CInt DISCONNECT = 4;
const CInt PRIORITIZED = 8;

// uv_fs_event, reported to FsEventCallback.
const CInt RENAME = 1;
const CInt CHANGE = 2;

// uv_fs_event_flags, for FsEvent.start.
const CUInt FS_EVENT_WATCH_ENTRY = 1;
const CUInt FS_EVENT_STAT = 2;
const CUInt FS_EVENT_RECURSIVE = 4;

// uv_process_flags, for ProcessOptions.flags.
const CUInt PROCESS_SETUID = 1;
const CUInt PROCESS_SETGID = 2;
const CUInt PROCESS_WINDOWS_VERBATIM_ARGUMENTS = 4;
const CUInt PROCESS_DETACHED = 8;
const CUInt PROCESS_WINDOWS_HIDE = 16;
const CUInt PROCESS_WINDOWS_HIDE_CONSOLE = 32;
const CUInt PROCESS_WINDOWS_HIDE_GUI = 64;
const CUInt PROCESS_WINDOWS_FILE_PATH_EXACT_NAME = 128;

// uv_thread_create_flags.
const CUInt THREAD_NO_FLAGS = 0x00;
const CUInt THREAD_HAS_STACK_SIZE = 0x01;

// Thread priorities accepted by libuv::thread_setpriority.
const CInt THREAD_PRIORITY_HIGHEST = 2;
const CInt THREAD_PRIORITY_ABOVE_NORMAL = 1;
const CInt THREAD_PRIORITY_NORMAL = 0;
const CInt THREAD_PRIORITY_BELOW_NORMAL = -1;
const CInt THREAD_PRIORITY_LOWEST = -2;

// Process priorities accepted by libuv::os_setpriority.
const CInt PRIORITY_LOW = 19;
const CInt PRIORITY_BELOW_NORMAL = 10;
const CInt PRIORITY_NORMAL = 0;
const CInt PRIORITY_ABOVE_NORMAL = -7;
const CInt PRIORITY_HIGH = -14;
const CInt PRIORITY_HIGHEST = -20;

// Flags for libuv::fs_copyfile.
const CInt FS_COPYFILE_EXCL = 0x0001;
const CInt FS_COPYFILE_FICLONE = 0x0002;
const CInt FS_COPYFILE_FICLONE_FORCE = 0x0004;

// Flags for libuv::fs_symlink. Windows only.
const CInt FS_SYMLINK_DIR = 0x0001;
const CInt FS_SYMLINK_JUNCTION = 0x0002;

// Flag for Pipe.bind2 and Pipe.connect2.
const CUInt PIPE_NO_TRUNCATE = 1;

<*
 Buffer size that always holds a hostname from `libuv::os_gethostname`.

 C `UV_MAXHOSTNAMESIZE`, which is the platform's `MAXHOSTNAMELEN` plus one, or
 256 where the platform does not define one.
*>
const usz MAXHOSTNAMESIZE @feat(WIN32) = 256;
const usz MAXHOSTNAMESIZE @feat(LINUX, ANDROID) = 65;
const usz MAXHOSTNAMESIZE @feat(DARWIN, BSD) = 257;
const usz MAXHOSTNAMESIZE @feat(!WIN32) @feat(!LINUX) @feat(!ANDROID) @feat(!DARWIN) @feat(!BSD) = 256;

// Callbacks

<*
 Asks you for somewhere to put the bytes of the read that is about to happen.

 libuv calls this before *every* read, not once per handle, and it does not
 allocate anything itself. Write the buffer you want used into `buf`, usually
 with `libuv::buf`:

     fn void on_alloc(libuv::Handle* h, usz suggested, libuv::Buf* buf)
     {
         *buf = libuv::buf(&scratch);
     }

 The memory has to stay put until the matching `ReadCallback` has run, so a
 local variable will not do. One buffer per handle is the usual arrangement,
 since only one read per handle is ever in flight; reach for a pool only when
 you hand the bytes on to something outlives the callback.

 `suggested_size` is a hint, typically 64 KiB, and you are free to ignore it.
 Setting `buf.len` to 0 says you have no memory to spare, and libuv then reports
 `ENOBUFS` through the read callback instead of reading.
*>
alias AllocCallback = fn void(Handle* handle, usz suggested_size, Buf* buf);

<*
 Delivers the result of one read.

 `nread` carries three different things:

 - **positive** -- that many bytes are in `buf.base`. Note that `buf.len` is the
   size your `AllocCallback` handed out, not the size of the data; `nread` is
   the one to slice by.
 - **0** -- nothing arrived this time. Not an error and not end of stream, just
   `EAGAIN` in disguise; libuv will call you again.
 - **negative** -- an `ErrorCode`. `libuv::EOF_CODE` means the peer closed its
   side cleanly, anything else is a real failure. Either way the stream is done:
   close the handle.

 Reads keep coming until you call `Stream.read_stop` or close the handle.
*>
alias ReadCallback = fn void(Stream* stream, sz nread, Buf* buf);

alias WriteCallback = fn void(Write* req, CInt status);
alias ConnectCallback = fn void(Connect* req, CInt status);
alias ShutdownCallback = fn void(Shutdown* req, CInt status);
alias ConnectionCallback = fn void(Stream* server, CInt status);

<* Runs once the handle is fully closed. Only then may its memory be released. *>
alias CloseCallback = fn void(Handle* handle);

alias PollCallback = fn void(Poll* handle, CInt status, CInt events);
alias TimerCallback = fn void(Timer* handle);
alias AsyncCallback = fn void(Async* handle);
alias PrepareCallback = fn void(Prepare* handle);
alias CheckCallback = fn void(Check* handle);
alias IdleCallback = fn void(Idle* handle);
alias ExitCallback = fn void(Process* handle, long exit_status, CInt term_signal);
alias WalkCallback = fn void(Handle* handle, void* arg);
alias FsCallback = fn void(Fs* req);

<* Runs on a threadpool thread. *>
alias WorkCallback = fn void(Work* req);

<* Runs on the loop thread once the matching `WorkCallback` returned. *>
alias AfterWorkCallback = fn void(Work* req, CInt status);

alias GetAddrInfoCallback = fn void(GetAddrInfo* req, CInt status, AddrInfo* res);
alias GetNameInfoCallback = fn void(GetNameInfo* req, CInt status, ZString hostname, ZString service);
alias RandomCallback = fn void(Random* req, CInt status, void* buf, usz buflen);
alias FsEventCallback = fn void(FsEvent* handle, ZString filename, CInt events, CInt status);
alias FsPollCallback = fn void(FsPoll* handle, CInt status, Stat* prev, Stat* curr);
alias SignalCallback = fn void(Signal* handle, CInt signum);
alias UdpSendCallback = fn void(UdpSend* req, CInt status);

<*
 Delivers a datagram. `nread` of 0 with a null `addr` means "no more data for
 now"; a negative `nread` is an `ErrorCode`.
*>
alias UdpRecvCallback = fn void(Udp* handle, sz nread, Buf* buf, SockAddr* addr, CUInt flags);

alias ThreadCallback = fn void(void* arg);
alias OnceCallback = fn void();

// Replacement allocator hooks for libuv::replace_allocator.
alias MallocFunc = fn void*(usz size);
alias ReallocFunc = fn void*(void* ptr, usz size);
alias CallocFunc = fn void*(usz count, usz size);
alias FreeFunc = fn void(void* ptr);

// Plain data structures

<* C `uv_timespec_t`. Not 2038 proof, see libuv issue 3864. *>
struct TimeSpec
{
	CLong tv_sec;
	CLong tv_nsec;
}

<* C `uv_timespec64_t`. *>
struct TimeSpec64
{
	long tv_sec;
	int tv_nsec;
}

<* C `uv_timeval_t`. Not 2038 proof, see libuv issue 3864. *>
struct TimeVal
{
	CLong tv_sec;
	CLong tv_usec;
}

<* C `uv_timeval64_t`. *>
struct TimeVal64
{
	long tv_sec;
	int tv_usec;
}

<* Platform independent stat result, filled in by the stat family. *>
struct Stat
{
	ulong st_dev;
	ulong st_mode;
	ulong st_nlink;
	ulong st_uid;
	ulong st_gid;
	ulong st_rdev;
	ulong st_ino;
	ulong st_size;
	ulong st_blksize;
	ulong st_blocks;
	ulong st_flags;
	ulong st_gen;
	TimeSpec st_atim;
	TimeSpec st_mtim;
	TimeSpec st_ctim;
	TimeSpec st_birthtim;
}

<* Filesystem statistics, filled in by `libuv::fs_statfs`. *>
struct StatFs
{
	ulong f_type;
	ulong f_bsize;
	ulong f_blocks;
	ulong f_bfree;
	ulong f_bavail;
	ulong f_files;
	ulong f_ffree;
	ulong[4] f_spare;
}

<* Directory entry produced by `libuv::fs_scandir_next` and `libuv::fs_readdir`. *>
struct Dirent
{
	ZString name;
	DirentType type;
}

<* Per CPU busy times in milliseconds. *>
struct CpuTimes
{
	ulong user;
	ulong nice;
	ulong sys;
	ulong idle;
	ulong irq;
}

<* One entry of the array returned by `libuv::cpu_info`. *>
struct CpuInfo
{
	ZString model;
	CInt speed;
	CpuTimes cpu_times;
}

<* One entry of the array returned by `libuv::interface_addresses`. *>
struct InterfaceAddress
{
	ZString name;
	char[6] phys_addr;
	CInt is_internal;
	union address
	{
		SockAddrIn address4;
		SockAddrIn6 address6;
	}
	union netmask
	{
		SockAddrIn netmask4;
		SockAddrIn6 netmask6;
	}
}

<* Result of `libuv::os_get_passwd`. Release with `libuv::os_free_passwd`. *>
struct Passwd
{
	ZString username;
	CULong uid;
	CULong gid;
	ZString shell;
	ZString homedir;
}

<* Result of `libuv::os_get_group`. Release with `libuv::os_free_group`. *>
struct Group
{
	ZString groupname;
	CULong gid;
	ZString* members;
}

<* Result of `libuv::os_uname`. Each field is a NUL terminated 256 byte buffer. *>
struct Utsname
{
	char[256] sysname;
	char[256] release;
	char[256] version;
	char[256] machine;
}

<* One entry of the array returned by `libuv::os_environ`. *>
struct EnvItem
{
	ZString name;
	ZString value;
}

<* Event loop statistics, filled in by `Loop.metrics_info`. *>
struct Metrics
{
	ulong loop_count;
	ulong events;
	ulong events_waiting;
	ulong*[13] reserved;
}

<* Resource usage, filled in by `libuv::getrusage`. *>
struct Rusage
{
	TimeVal ru_utime;
	TimeVal ru_stime;
	ulong ru_maxrss;
	ulong ru_ixrss;
	ulong ru_idrss;
	ulong ru_isrss;
	ulong ru_minflt;
	ulong ru_majflt;
	ulong ru_nswap;
	ulong ru_inblock;
	ulong ru_oublock;
	ulong ru_msgsnd;
	ulong ru_msgrcv;
	ulong ru_nsignals;
	ulong ru_nvcsw;
	ulong ru_nivcsw;
}

<* Handle to a shared library opened with `libuv::dlopen`. *>
struct Lib
{
	void* handle;
	ZString errmsg;
}

<* Optional parameters for `libuv::thread_create_ex`. *>
struct ThreadOptions
{
	CUInt flags;
	usz stack_size;
}

<* Describes one child stdio slot, see `ProcessOptions.stdio`. *>
struct StdioContainer
{
	StdioFlags flags;
	union data
	{
		Stream* stream;
		CInt fd;
	}
}

<* Parameters for `libuv::spawn`. *>
struct ProcessOptions
{
	<* Invoked after the child exits. *>
	ExitCallback exit_cb;
	<* Path of the program to run. *>
	ZString file;
	<* NULL terminated argument vector; `args[0]` should repeat `file`. *>
	ZString* args;
	<* NULL terminated KEY=value vector, or null to inherit the parent environment. *>
	ZString* env;
	<* Working directory for the child, or null to inherit the current one. *>
	ZString cwd;
	<* Bitwise or of the `PROCESS_*` constants. *>
	CUInt flags;
	CInt stdio_count;
	StdioContainer* stdio;
	Uid uid;
	Gid gid;
}
