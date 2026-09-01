<*
 The event loop and library wide entry points.
*>
module libuv;

<* Version of the linked libuv, encoded as `(major << 16) | (minor << 8) | patch`. *>
fn CUInt version_packed() => api::uv_version();

<* Version of the linked libuv as text, for example "1.51.0". *>
fn String version_string() => api::uv_version_string().str_view();

<*
 Releases every resource libuv still holds, after which no libuv function may
 be called again. Only useful right before the process exits.
*>
fn void library_shutdown() => api::uv_library_shutdown();

<*
 Installs replacement allocation functions.

 Must be called before any other libuv function, and never again afterwards.
 All four functions are required.

 @require malloc_func != null && realloc_func != null : "all four hooks are required"
 @require calloc_func != null && free_func != null : "all four hooks are required"
*>
fn void? replace_allocator(MallocFunc malloc_func, ReallocFunc realloc_func, CallocFunc calloc_func, FreeFunc free_func)
	=> check(api::uv_replace_allocator(malloc_func, realloc_func, calloc_func, free_func));

<*
 The process wide default loop.

 It is created on first use and lives until `Loop.close` is called on it. Prefer
 an explicitly initialised `Loop` in a library.
*>
fn Loop* default_loop() => api::uv_default_loop();

<*
 Size of a `Loop` as the linked libuv sees it. Use `libuv::check_abi` rather
 than comparing this by hand.
*>
fn usz loop_size() => api::uv_loop_size();

<*
 Initialises the loop.

 @param [&inout] self
*>
fn void? Loop.init(&self) => check(api::uv_loop_init(self));

<*
 Releases the loop's resources.

 Fails with `EBUSY` while any handle or request is still referencing the loop,
 so close every handle and run the loop once more before calling this.

 @param [&inout] self
*>
fn void? Loop.close(&self) => check(api::uv_loop_close(self));

<* True while the loop still has active and referenced handles or requests. *>
fn bool Loop.alive(&self) => api::uv_loop_alive(self) != 0;

<*
 Runs the loop.

 @param mode : "`DEFAULT` runs until nothing is left, `ONCE` polls once and blocks, `NOWAIT` polls once without blocking"
 @return "true when handles or requests are still active, which only `ONCE` and `NOWAIT` can report"
*>
fn bool? Loop.run(&self, RunMode mode = RunMode.DEFAULT) => check_value(api::uv_run(self, mode))! != 0;

<*
 Asks the loop to stop as soon as it can.

 Takes effect before the loop blocks for I/O again. It does not close handles.
*>
fn void Loop.stop(&self) => api::uv_stop(self);

<*
 Reloads the loop's cached notion of "now".

 The loop caches the current time once per iteration; call this when a long
 running callback needs a fresh reading.
*>
fn void Loop.update_time(&self) => api::uv_update_time(self);

<* The loop's cached time in milliseconds. *>
fn ulong Loop.now(&self) => api::uv_now(self);

<*
 Backend file descriptor of the loop, for embedding it in another event loop.

 Only meaningful on Linux, macOS and the BSDs; returns `-1` on Windows.
*>
fn CInt Loop.backend_fd(&self) => api::uv_backend_fd(self);

<*
 Milliseconds the loop may block for I/O, or `-1` for "as long as it takes" and
 `0` for "do not block".
*>
fn CInt Loop.backend_timeout(&self) => api::uv_backend_timeout(self);

<*
 Calls `walk_cb` once for every handle attached to the loop.

 Handles that are already closing are included, so check `Handle.is_closing`
 before touching one.
*>
fn void Loop.walk(&self, WalkCallback walk_cb, void* arg = null) => api::uv_walk(self, walk_cb, arg);

<*
 Reinitialises the loop's kernel state after `fork(2)` in the child.

 Unsupported on Windows and on macOS, where it fails with `ENOSYS`.

 @param [&inout] self
*>
fn void? Loop.fork(&self) => check(api::uv_loop_fork(self));

<*
 Blocks the given signal for the duration of a poll.

 Only `SIGPROF` is accepted; anything else fails with `EINVAL`.

 @param [&inout] self
*>
fn void? Loop.block_signal(&self, CInt signum) => check(api::uv_loop_configure(self, LoopOption.BLOCK_SIGNAL, signum));

<*
 Starts accumulating the idle time reported by `Loop.metrics_idle_time`.

 Off by default because the extra timing calls cost a little on every
 iteration.

 @param [&inout] self
*>
fn void? Loop.track_idle_time(&self) => check(api::uv_loop_configure(self, LoopOption.METRICS_IDLE_TIME));

<*
 Asks the io_uring backend to use kernel side polling. Linux only, ignored
 elsewhere.

 @param [&inout] self
*>
fn void? Loop.use_io_uring_sqpoll(&self) => check(api::uv_loop_configure(self, LoopOption.USE_IO_URING_SQPOLL));

<*
 Fills in the loop's event counters.

 @param [out] metrics
*>
fn void? Loop.metrics_info(&self, Metrics* metrics) => check(api::uv_metrics_info(self, metrics));

<*
 Nanoseconds the loop spent waiting for I/O since it started.

 Returns 0 unless `Loop.track_idle_time` was called first.
*>
fn ulong Loop.metrics_idle_time(&self) => api::uv_metrics_idle_time(self);

<* User pointer stored in the loop. Equivalent to reading `loop.data`. *>
fn void* Loop.get_data(&self) => api::uv_loop_get_data(self);

<* Stores a user pointer in the loop. Equivalent to writing `loop.data`. *>
fn void Loop.set_data(&self, void* data) => api::uv_loop_set_data(self, data);
