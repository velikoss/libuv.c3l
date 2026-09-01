<*
 Handles are plain values. Keep it alive until its `CloseCallback` has run.
*>
module libuv;

alias InternalWorkFn @private = fn void(InternalWork* w);
alias InternalWorkDoneFn @private = fn void(InternalWork* w, CInt status);

<*
 C `struct uv__work`. Internal to libuv.
*>
struct InternalWork
{
	InternalWorkFn work;
	InternalWorkDoneFn done;
	Loop* loop;
	Queue wq;
}

<*
 The event loop, C `uv_loop_t`.

 Either use `libuv::default_loop()` or zero initialise one and call `Loop.init`.
*>
struct Loop
{
	<* Free for the user. *>
	void* data;
	// read-only
	CUInt active_handles;
	Queue handle_queue;
	union active_reqs
	{
		void* unused;
		CUInt count;
	}
	void* internal_fields;
	CUInt stop_flag;
	LoopPrivate _private;
}

<*
 C `uv_handle_t`.

 `data` is the only field meant to be written by user code; `loop` and `type`
 are read only.
*>
struct Handle
{
	<* Free for the user. *>
	void* data;
	// read-only
	Loop* loop;
	HandleType type;
	// private
	CloseCallback close_cb;
	Queue handle_queue;
	union u
	{
		CInt fd;
		void*[4] reserved;
	}
	HandlePrivate _private;
}

<*
 C `uv_stream_t`.

 Never instantiate one. `Tcp`, `Pipe` and `Tty` derive from it.
*>
struct Stream
{
	inline Handle handle;
	<* Bytes queued for writing. Read only. *>
	usz write_queue_size;
	// private
	AllocCallback alloc_cb;
	ReadCallback read_cb;
	StreamPrivate _private;
}

<* A TCP stream or TCP server, C `uv_tcp_t`. *>
struct Tcp
{
	inline Stream stream;
	TcpPrivate _private @if(env::WIN32);
}

<* A UDP socket, C `uv_udp_t`. *>
struct Udp
{
	inline Handle handle;
	<* Bytes queued for sending. Read only. *>
	usz send_queue_size;
	<* Send requests waiting to be processed. Read only. *>
	usz send_queue_count;
	UdpPrivate _private;
}

<*
 A pipe stream or pipe server, C `uv_pipe_t`.

 A named pipe on Windows, a unix domain socket elsewhere.
*>
struct Pipe
{
	inline Stream stream;
	<* Non-zero if this pipe is used for passing handles. Read only. *>
	CInt ipc;
	PipePrivate _private;
}

<* A console stream, C `uv_tty_t`. *>
struct Tty
{
	inline Stream stream;
	TtyPrivate _private;
}

<* A file descriptor watcher, C `uv_poll_t`. *>
struct Poll
{
	inline Handle handle;
	// private
	PollCallback poll_cb;
	PollPrivate _private;
}

<* A timer, C `uv_timer_t`. *>
struct Timer
{
	inline Handle handle;
	TimerPrivate _private;
}

<* Runs its callback right before the loop blocks for I/O, C `uv_prepare_t`. *>
struct Prepare
{
	inline Handle handle;
	PreparePrivate _private;
}

<* Runs its callback right after the loop returns from I/O, C `uv_check_t`. *>
struct Check
{
	inline Handle handle;
	CheckPrivate _private;
}

<* Runs its callback once per loop iteration, C `uv_idle_t`. *>
struct Idle
{
	inline Handle handle;
	IdlePrivate _private;
}

<*
 Wakes the loop from another thread, C `uv_async_t`.

 `Async.send` is the only libuv call that is safe from a thread other than the
 one running the loop.
*>
struct Async
{
	inline Handle handle;
	AsyncPrivate _private;
}

<* A child process, C `uv_process_t`. *>
struct Process
{
	inline Handle handle;
	<* Invoked after the child exits. *>
	ExitCallback exit_cb;
	<* Process id of the child. Read only. *>
	CInt pid;
	ProcessPrivate _private;
}

<* A filesystem watcher, C `uv_fs_event_t`. *>
struct FsEvent
{
	inline Handle handle;
	// private
	char* path;
	FsEventPrivate _private;
}

<* A stat based polling file watcher, C `uv_fs_poll_t`. *>
struct FsPoll
{
	inline Handle handle;
	<* Private, do not touch. *>
	void* poll_ctx;
}

<* A signal watcher, C `uv_signal_t`. *>
struct Signal
{
	inline Handle handle;
	<* Invoked when the watched signal arrives. *>
	SignalCallback signal_cb;
	<* Signal number being watched. Read only. *>
	CInt signum;
	SignalPrivate _private;
}

<*
 An open directory stream, C `uv_dir_t`.

 You never declare one of these yourself. `libuv::fs_opendir` allocates it and
 leaves it in the request's `Fs.get_ptr`; `libuv::fs_closedir` is the only thing
 that frees it, and cleaning up the opendir request does not.

 Reading it involves two buffers, which is the part that trips people up. The
 array of `Dirent` slots is **yours**: you declare it, you decide how big it is,
 and entries are copied into it. The name inside each filled slot is **libuv's**:
 it points into the request and dies when that request is cleaned up.

 So before every `libuv::fs_readdir` call point
 `dirents` at your array and set `nentries` to how many slots it has. libuv
 reads both fields on entry and fills in at most that many:

     Fs open_req;
     libuv::fs_opendir(&loop, &open_req, "/some/path")!;
     Dir* dir = (Dir*)open_req.get_ptr();
     open_req.cleanup();

     Dirent[32] slots;
     while (true)
     {
         dir.dirents = &slots[0];
         dir.nentries = slots.len;

         Fs read_req;
         CInt n = libuv::fs_readdir(&loop, &read_req, dir)!;
         if (!n) { read_req.cleanup(); break; }   // directory exhausted

         foreach (e : slots[:(usz)n]) use(e.name.str_view());

         read_req.cleanup();                      // the names die here
     }

     Fs close_req;
     libuv::fs_closedir(&loop, &close_req, dir)!;
     close_req.cleanup();

 `examples/readdir.c3` is that loop as a program you can run, next to the
 simpler `fs_scandir` alternative.

 `nentries` is a maximum, not a demand: a batch may come back short without
 meaning the directory has ended. Only a count of 0 means that.
*>
struct Dir
{
	<* Your array of slots. Set it before every `libuv::fs_readdir` call. *>
	Dirent* dirents;
	<* How many slots `dirents` has. Set it before every `libuv::fs_readdir` call. *>
	usz nentries;
	void*[4] reserved;
	DirPrivate _private;
}
