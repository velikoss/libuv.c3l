<*
 The shared threadpool.

 libuv keeps one pool per process, four threads by default. Everything that
 cannot be done with non-blocking I/O queues onto it: the whole `uv_fs_*`
 family, `getaddrinfo` and `getnameinfo`, `uv_random`, and whatever you submit
 with `queue_work`. They all compete for the same threads, so a slow resolver
 delays filesystem work and vice versa.

 Resize it by setting `UV_THREADPOOL_SIZE` in the environment before the first
 call that touches the pool. libuv reads it once and caps it at 1024.
*>
module libuv;

<*
 Runs `work_cb` on the threadpool, then `after_work_cb` on the loop thread.

 `req` must stay alive until `after_work_cb` runs. `work_cb` runs on a thread
 that is not the loop's, so it must not touch any handle except through
 `Async.send`.

 A request cancelled with `Req.cancel` before it starts still calls
 `after_work_cb`, with a status of `ECANCELED`.

 @require work_cb != null
 @param [&inout] req
*>
fn void? queue_work(Loop* loop, Work* req, WorkCallback work_cb, AfterWorkCallback after_work_cb = null)
	=> check(api::uv_queue_work(loop, req, work_cb, after_work_cb));

<*
 Fills `buf` with entropy from the operating system.

 Runs synchronously on the calling thread when `cb` is null, otherwise on the
 threadpool. The asynchronous form needs `req` and `buf` to stay alive until
 `cb` runs.

 @param flags : "reserved by libuv, must be 0"
 @require flags == 0 : "libuv reserves the flags argument"
 @require buf.len > 0
 @param [&inout] req
 @param [out] buf
*>
fn void? random(Loop* loop, Random* req, char[] buf, CUInt flags = 0, RandomCallback cb = null)
	=> check(api::uv_random(loop, req, buf.ptr, buf.len, flags, cb));
