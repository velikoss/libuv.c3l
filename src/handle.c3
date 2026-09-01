<*
 Operations shared by every handle and every request, plus buffers and
 descriptors. The structs themselves are in handle_types.c3 and req_types.c3.

 Because each handle type starts with `inline Handle`, these methods are
 reachable from a `Timer*`, a `Tcp*` and so on without a cast.
*>
module libuv;

<*
 Wraps a byte slice for the scatter/gather calls. Does not copy.

 The buffer must stay alive and unmoved until libuv is done with it, which for
 `Stream.write` means until the `WriteCallback` runs.

 @require bytes.len <= CUInt::max : "a single Buf cannot describe more than 4 GiB"
*>
macro Buf buf(char[] bytes)
{
	Buf b;
	b.base = bytes.ptr;
	b.len = ($Typeof(b.len))bytes.len;
	return b;
}

<* The bytes a `Buf` points at. Empty when `base` is null. *>
macro char[] Buf.bytes(&self) => self.base ? self.base[:(usz)self.len] : (char[]){};

<*
 Closes the handle.

 The handle stops generating events immediately, but its memory must stay valid
 until `close_cb` runs. Calling it twice on the same handle aborts the process.

 @param [&inout] self
*>
fn void Handle.close(&self, CloseCallback close_cb = null) => api::uv_close(self, close_cb);

<* True while the handle is doing something the loop must wait for. *>
fn bool Handle.is_active(&self) => api::uv_is_active(self) != 0;

<* True once `Handle.close` has been called, whether or not `close_cb` has run. *>
fn bool Handle.is_closing(&self) => api::uv_is_closing(self) != 0;

<*
 Marks the handle as one that keeps the loop alive.

 Handles start referenced, so this only undoes a previous `Handle.unref`.
*>
fn void Handle.ref(&self) => api::uv_ref(self);

<*
 Marks the handle as one that does not keep the loop alive.

 An unreferenced timer, for instance, still fires while other work keeps the
 loop running, but will not by itself prevent `Loop.run` from returning.
*>
fn void Handle.unref(&self) => api::uv_unref(self);

<* True while the handle counts towards keeping the loop alive. *>
fn bool Handle.has_ref(&self) => api::uv_has_ref(self) != 0;

<* The kind of this handle. Equivalent to reading `handle.type`. *>
fn HandleType Handle.get_type(&self) => api::uv_handle_get_type(self);

<* The loop this handle belongs to. Equivalent to reading `handle.loop`. *>
fn Loop* Handle.get_loop(&self) => api::uv_handle_get_loop(self);

<* User pointer stored in the handle. Equivalent to reading `handle.data`. *>
fn void* Handle.get_data(&self) => api::uv_handle_get_data(self);

<* Stores a user pointer in the handle. Equivalent to writing `handle.data`. *>
fn void Handle.set_data(&self, void* data) => api::uv_handle_set_data(self, data);

<*
 Reads, or sets when `value` is non-zero, the send buffer size of the socket.

 Works on `Tcp`, `Pipe` and `Udp` handles. On Linux the kernel doubles the value
 you set and reports the doubled figure back.

 @param [&inout] self
 @param [&inout] value : "receives the current size, or carries the new one in"
*>
fn void? Handle.send_buffer_size(&self, CInt* value) => check(api::uv_send_buffer_size(self, value));

<*
 Reads, or sets when `value` is non-zero, the receive buffer size of the socket.

 @param [&inout] self
 @param [&inout] value : "receives the current size, or carries the new one in"
*>
fn void? Handle.recv_buffer_size(&self, CInt* value) => check(api::uv_recv_buffer_size(self, value));

<*
 The operating system descriptor backing the handle.

 @param [out] fd
*>
fn void? Handle.fileno(&self, OsFd* fd) => check(api::uv_fileno(self, fd));

<*
 Size of the given handle kind as the linked libuv sees it.

 Returns `(usz)-1` for `HandleType.FILE`, which has no struct.
*>
fn usz handle_size(HandleType type) => api::uv_handle_size(type);

<* Lower case name of the handle kind, for example "tcp". *>
fn String handle_type_name(HandleType type) => api::uv_handle_type_name(type).str_view();

// Requests

<*
 Cancels a pending request.

 Only `Fs`, `Work`, `GetAddrInfo`, `GetNameInfo` and `Random` requests can be
 cancelled, and only while they are still queued. A cancelled request still
 runs its callback, with a status of `ECANCELED`.

 @param [&inout] self
*>
fn void? Req.cancel(&self) => check(api::uv_cancel(self));

<* The kind of this request. Equivalent to reading `req.type`. *>
fn ReqType Req.get_type(&self) => api::uv_req_get_type(self);

<* User pointer stored in the request. Equivalent to reading `req.data`. *>
fn void* Req.get_data(&self) => api::uv_req_get_data(self);

<* Stores a user pointer in the request. Equivalent to writing `req.data`. *>
fn void Req.set_data(&self, void* data) => api::uv_req_set_data(self, data);

<* Size of the given request kind as the linked libuv sees it. *>
fn usz req_size(ReqType type) => api::uv_req_size(type);

<* Lower case name of the request kind, for example "write". *>
fn String req_type_name(ReqType type) => api::uv_req_type_name(type).str_view();

// Descriptors

<*
 Creates a pipe pair suitable for handing to a child process.

 @param [out] fds : "receives the read end in `fds[0]` and the write end in `fds[1]`"
 @param read_flags : "0 or `libuv::NONBLOCK_PIPE`"
 @param write_flags : "0 or `libuv::NONBLOCK_PIPE`"
*>
fn void? pipe(Fd[2]* fds, CInt read_flags = 0, CInt write_flags = 0)
	=> check(api::uv_pipe(fds, read_flags, write_flags));

<*
 Creates a connected socket pair.

 @param [out] socket_vector : "receives the two connected sockets"
*>
fn void? socketpair(CInt type, CInt protocol, OsSock[2]* socket_vector, CInt flags0 = 0, CInt flags1 = 0)
	=> check(api::uv_socketpair(type, protocol, socket_vector, flags0, flags1));

<*
 Guesses which handle kind fits an already open descriptor.

 Returns `HandleType.UNKNOWN` when it cannot tell.
*>
fn HandleType guess_handle(Fd file) => api::uv_guess_handle(file);
