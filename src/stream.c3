<*
 Streams and their three concrete kinds: TCP, pipes and TTYs.

 Since `Tcp`, `Pipe` and `Tty` all start with `inline Stream`, the methods on
 `Stream` are reachable from any of them without a cast.
*>
module libuv;

// Stream

<*
 Starts listening for incoming connections.

 `cb` runs once per pending connection; call `Stream.accept` from inside it.

 @param backlog : "how many connections the kernel may queue"
 @require backlog > 0
 @require cb != null
 @param [&inout] self
*>
fn void? Stream.listen(&self, CInt backlog, ConnectionCallback cb) => check(api::uv_listen(self, backlog, cb));

<*
 Moves one pending connection into `client`.

 Call it exactly once per `ConnectionCallback` invocation, from inside the
 callback. `client` must already be initialised on the same loop.

 @param [&inout] self
 @param [&inout] client
*>
fn void? Stream.accept(&self, Stream* client) => check(api::uv_accept(self, client));

<*
 Starts reading.

 `alloc_cb` is asked for a buffer before every read and `read_cb` receives the
 result. A negative `nread` is an `ErrorCode`; `libuv::EOF_CODE` means the peer
 closed its side.

 @require alloc_cb != null
 @require read_cb != null
 @param [&inout] self
*>
fn void? Stream.read_start(&self, AllocCallback alloc_cb, ReadCallback read_cb)
	=> check(api::uv_read_start(self, alloc_cb, read_cb));

<*
 Stops reading. Harmless on a stream that is not reading.

 @param [&inout] self
*>
fn void? Stream.read_stop(&self) => check(api::uv_read_stop(self));

<*
 Queues a write.

 `req` and every buffer must stay alive and unmoved until `cb` runs.

 @require bufs.len > 0 : "a write needs at least one buffer"
 @require bufs.len <= CUInt::max
 @param [&inout] self
 @param [&inout] req
*>
fn void? Stream.write(&self, Write* req, Buf[] bufs, WriteCallback cb)
	=> check(api::uv_write(req, self, bufs.ptr, (CUInt)bufs.len, cb));

<*
 Queues a write that also hands `send_handle` to the peer over an IPC pipe.

 `self` must be a `Pipe` created with `ipc` set.

 @require bufs.len > 0
 @require bufs.len <= CUInt::max
 @require send_handle != null : "use Stream.write when there is no handle to pass"
 @param [&inout] self
 @param [&inout] req
*>
fn void? Stream.write2(&self, Write* req, Buf[] bufs, Stream* send_handle, WriteCallback cb)
	=> check(api::uv_write2(req, self, bufs.ptr, (CUInt)bufs.len, send_handle, cb));

<*
 Writes without queueing, returning what fit.

 Never blocks. Fails with `EAGAIN` when nothing could be written at all.

 @require bufs.len > 0
 @require bufs.len <= CUInt::max
 @return "the number of bytes written"
 @param [&inout] self
*>
fn CInt? Stream.try_write(&self, Buf[] bufs) => check_value(api::uv_try_write(self, bufs.ptr, (CUInt)bufs.len));

<*
 `Stream.try_write` that also passes a handle over an IPC pipe.

 @require bufs.len > 0
 @require bufs.len <= CUInt::max
 @require send_handle != null
 @return "the number of bytes written"
 @param [&inout] self
*>
fn CInt? Stream.try_write2(&self, Buf[] bufs, Stream* send_handle)
	=> check_value(api::uv_try_write2(self, bufs.ptr, (CUInt)bufs.len, send_handle));

<*
 Half closes the write side once the queued writes have drained.

 `req` must stay alive until `cb` runs.

 @param [&inout] self
 @param [&inout] req
*>
fn void? Stream.shutdown(&self, Shutdown* req, ShutdownCallback cb) => check(api::uv_shutdown(req, self, cb));

<* True when the stream may still be read from. *>
fn bool Stream.is_readable(&self) => api::uv_is_readable(self) != 0;

<* True when the stream may still be written to. *>
fn bool Stream.is_writable(&self) => api::uv_is_writable(self) != 0;

<*
 Switches the stream between blocking and non-blocking writes.

 Only fully supported for pipes on Windows and for pipes and TTYs on unix.
 Blocking mode makes `Stream.write` complete before it returns, which trades
 throughput for never queueing.

 @param [&inout] self
*>
fn void? Stream.set_blocking(&self, bool blocking) => check(api::uv_stream_set_blocking(self, (CInt)blocking));

<* Bytes queued for writing. Equivalent to reading `stream.write_queue_size`. *>
fn usz Stream.get_write_queue_size(&self) => api::uv_stream_get_write_queue_size(self);

// TCP

<*
 @param [&out] self
 @param [&inout] loop
*>
fn void? Tcp.init(&self, Loop* loop) => check(api::uv_tcp_init(loop, self));

<*
 Initialises the handle and creates the socket right away.

 Needed when you want to set socket options before binding.

 @param flags : "the address family to create the socket for, for example `(CUInt)os::AF_INET` from `std::net::os`"
 @param [&out] self
 @param [&inout] loop
*>
fn void? Tcp.init_ex(&self, Loop* loop, CUInt flags) => check(api::uv_tcp_init_ex(loop, self, flags));

<*
 Adopts an already open socket.

 The socket must not have any pending operations on it.

 @param [&inout] self
*>
fn void? Tcp.open(&self, OsSock sock) => check(api::uv_tcp_open(self, sock));

<*
 Turns Nagle's algorithm off or on.

 @param [&inout] self
*>
fn void? Tcp.nodelay(&self, bool enable) => check(api::uv_tcp_nodelay(self, (CInt)enable));

<*
 Turns TCP keepalive off or on.

 @param delay : "seconds of idleness before the first probe; ignored when disabling"
 @require !enable || delay > 0 : "an enabled keepalive needs a non-zero delay"
 @param [&inout] self
*>
fn void? Tcp.keepalive(&self, bool enable, CUInt delay = 0) => check(api::uv_tcp_keepalive(self, (CInt)enable, delay));

<*
 Turns simultaneous accepts off or on. Windows only, ignored elsewhere.

 Off spreads incoming connections more evenly across processes listening on the
 same port, at the cost of accept latency.

 @param [&inout] self
*>
fn void? Tcp.simultaneous_accepts(&self, bool enable) => check(api::uv_tcp_simultaneous_accepts(self, (CInt)enable));

<*
 Binds the handle to a local address.

 @param flags : "0, `libuv::TCP_IPV6ONLY` or `libuv::TCP_REUSEPORT`"
 @param [&inout] self
*>
fn void? Tcp.bind(&self, SockAddr* addr, CUInt flags = 0) => check(api::uv_tcp_bind(self, addr, flags));

<*
 Copies the local address of the socket into `name`.

 @param [out] name
 @param [&inout] namelen : "in, the size of `name`; out, the length written"
*>
fn void? Tcp.getsockname(&self, SockAddr* name, CInt* namelen) => check(api::uv_tcp_getsockname(self, name, namelen));

<*
 Copies the peer address of the socket into `name`.

 @param [out] name
 @param [&inout] namelen : "in, the size of `name`; out, the length written"
*>
fn void? Tcp.getpeername(&self, SockAddr* name, CInt* namelen) => check(api::uv_tcp_getpeername(self, name, namelen));

<*
 Starts connecting to `addr`.

 `req` must stay alive until `cb` runs.

 @param [&inout] self
 @param [&inout] req
*>
fn void? Tcp.connect(&self, Connect* req, SockAddr* addr, ConnectCallback cb)
	=> check(api::uv_tcp_connect(req, self, addr, cb));

<*
 Resets the connection with an RST and closes the handle.

 @param [&inout] self
*>
fn void? Tcp.close_reset(&self, CloseCallback close_cb = null) => check(api::uv_tcp_close_reset(self, close_cb));

// Pipe

<*
 @param ipc : "true to allow handles to be passed over this pipe with `Stream.write2`"
 @param [&out] self
 @param [&inout] loop
*>
fn void? Pipe.init(&self, Loop* loop, bool ipc = false) => check(api::uv_pipe_init(loop, self, (CInt)ipc));

<*
 Adopts an already open descriptor.

 @param [&inout] self
*>
fn void? Pipe.open(&self, Fd file) => check(api::uv_pipe_open(self, file));

<*
 Binds the pipe to a name.

 A path on unix, a `\\?\pipe\...` name on Windows. Paths longer than the
 platform limit are truncated unless `PIPE_NO_TRUNCATE` is passed.

 @param flags : "0 or `libuv::PIPE_NO_TRUNCATE`"
 @param [&inout] self
*>
fn void? Pipe.bind(&self, String name, CUInt flags = 0)
	=> check(api::uv_pipe_bind2(self, (ZString)name.ptr, name.len, flags));

<*
 Starts connecting to a named pipe.

 `req` must stay alive until `cb` runs.

 @param flags : "0 or `libuv::PIPE_NO_TRUNCATE`"
 @param [&inout] self
 @param [&inout] req
*>
fn void? Pipe.connect(&self, Connect* req, String name, ConnectCallback cb, CUInt flags = 0)
	=> check(api::uv_pipe_connect2(req, self, (ZString)name.ptr, name.len, flags, cb));

<*
 Copies the name this pipe is bound to into `buffer`.

 @param [&out] buffer
 @param [&inout] size : "in, the buffer size; out, the length written, or the size needed when it fails with `ENOBUFS`"
*>
fn void? Pipe.getsockname(&self, char* buffer, usz* size) => check(api::uv_pipe_getsockname(self, buffer, size));

<*
 Copies the name of the peer this pipe is connected to into `buffer`.

 @param [&out] buffer
 @param [&inout] size : "in, the buffer size; out, the length written, or the size needed when it fails with `ENOBUFS`"
*>
fn void? Pipe.getpeername(&self, char* buffer, usz* size) => check(api::uv_pipe_getpeername(self, buffer, size));

<*
 Sets how many pipe instances a named pipe server keeps waiting. Windows only.

 Must be called before `Pipe.bind`, otherwise it is ignored.
*>
fn void Pipe.pending_instances(&self, CInt count) => api::uv_pipe_pending_instances(self, count);

<* How many handles the peer has queued for this pipe to receive. *>
fn CInt Pipe.pending_count(&self) => api::uv_pipe_pending_count(self);

<*
 The kind of the next handle waiting to be accepted from the peer.

 Only meaningful while `Pipe.pending_count` is non-zero.
*>
fn HandleType Pipe.pending_type(&self) => api::uv_pipe_pending_type(self);

<*
 Grants read, write or both to everyone on the pipe. Unix only.

 @param flags : "bitwise or of `libuv::READABLE` and `libuv::WRITABLE`"
 @require flags != 0
 @param [&inout] self
*>
fn void? Pipe.chmod(&self, CInt flags) => check(api::uv_pipe_chmod(self, flags));

// TTY

<*
 Wraps a terminal descriptor.

 `readable` must reflect what the descriptor actually is: true for stdin, false
 for stdout and stderr.

 @param [&out] self
 @param [&inout] loop
*>
fn void? Tty.init(&self, Loop* loop, Fd fd, bool readable) => check(api::uv_tty_init(loop, self, fd, (CInt)readable));

<*
 Switches the terminal mode.

 @param [&inout] self
*>
fn void? Tty.set_mode(&self, TtyMode mode) => check(api::uv_tty_set_mode(self, mode));

<*
 Restores the terminal to the state it was in before the first `Tty.init`.

 Safe to call from a signal handler or an exit handler.
*>
fn void? tty_reset_mode() => check(api::uv_tty_reset_mode());

<*
 Reads the terminal size in character cells.

 @param [out] width
 @param [out] height
*>
fn void? Tty.get_winsize(&self, CInt* width, CInt* height) => check(api::uv_tty_get_winsize(self, width, height));

<*
 Overrides libuv's idea of whether the console understands virtual terminal
 sequences. Windows only.
*>
fn void tty_set_vterm_state(TtyVtermState state) => api::uv_tty_set_vterm_state(state);

<*
 Whether the console understands virtual terminal sequences. Windows only.

 @param [out] state
*>
fn void? tty_get_vterm_state(TtyVtermState* state) => check(api::uv_tty_get_vterm_state(state));
