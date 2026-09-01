<*
 Timers, loop phase watchers, the cross thread wakeup, descriptor polling and
 signal handling.
*>
module libuv;

// Timer

<*
 Attaches the timer to a loop. It does not start ticking yet.

 @param [&out] self
 @param [&inout] loop
*>
fn void? Timer.init(&self, Loop* loop) => check(api::uv_timer_init(loop, self));

<*
 Starts the timer.

 @param cb : "invoked on the loop thread each time the timer fires"
 @param timeout : "milliseconds before the first call"
 @param repeat : "milliseconds between later calls, 0 for a one shot timer"
 @require cb != null : "a timer without a callback would fire into nothing"
 @param [&inout] self
*>
fn void? Timer.start(&self, TimerCallback cb, ulong timeout, ulong repeat = 0)
	=> check(api::uv_timer_start(self, cb, timeout, repeat));

<*
 Stops the timer. Harmless on a timer that is not running.

 @param [&inout] self
*>
fn void? Timer.stop(&self) => check(api::uv_timer_stop(self));

<*
 Restarts a repeating timer from now.

 Fails with `EINVAL` when the repeat interval is 0.

 @param [&inout] self
*>
fn void? Timer.again(&self) => check(api::uv_timer_again(self));

<*
 Sets the repeat interval in milliseconds.

 Changing it from inside the callback applies to the next tick; changing it from
 outside only takes effect after the next `Timer.again`.
*>
fn void Timer.set_repeat(&self, ulong repeat) => api::uv_timer_set_repeat(self, repeat);

<* The repeat interval in milliseconds. *>
fn ulong Timer.get_repeat(&self) => api::uv_timer_get_repeat(self);

<* Milliseconds until the timer fires next, or 0 when it is not running. *>
fn ulong Timer.get_due_in(&self) => api::uv_timer_get_due_in(self);

// Prepare, check, idle

<*
 @param [&out] self
 @param [&inout] loop
*>
fn void? Prepare.init(&self, Loop* loop) => check(api::uv_prepare_init(loop, self));

<*
 Runs `cb` once per iteration, right before the loop blocks for I/O.

 @require cb != null
 @param [&inout] self
*>
fn void? Prepare.start(&self, PrepareCallback cb) => check(api::uv_prepare_start(self, cb));

<* @param [&inout] self *>
fn void? Prepare.stop(&self) => check(api::uv_prepare_stop(self));

<*
 @param [&out] self
 @param [&inout] loop
*>
fn void? Check.init(&self, Loop* loop) => check(api::uv_check_init(loop, self));

<*
 Runs `cb` once per iteration, right after the loop returns from I/O.

 @require cb != null
 @param [&inout] self
*>
fn void? Check.start(&self, CheckCallback cb) => check(api::uv_check_start(self, cb));

<* @param [&inout] self *>
fn void? Check.stop(&self) => check(api::uv_check_stop(self));

<*
 @param [&out] self
 @param [&inout] loop
*>
fn void? Idle.init(&self, Loop* loop) => check(api::uv_idle_init(loop, self));

<*
 Runs `cb` once per iteration.

 An active idle handle stops the loop from ever blocking, so it will spin the
 CPU. Use it for short lived work only.

 @require cb != null
 @param [&inout] self
*>
fn void? Idle.start(&self, IdleCallback cb) => check(api::uv_idle_start(self, cb));

<* @param [&inout] self *>
fn void? Idle.stop(&self) => check(api::uv_idle_stop(self));

// Async

<*
 Attaches the wakeup handle to a loop and arms it.

 Unlike every other init, the callback is given here because the handle is armed
 from the moment it exists.

 @require async_cb != null
 @param [&out] self
 @param [&inout] loop
*>
fn void? Async.init(&self, Loop* loop, AsyncCallback async_cb) => check(api::uv_async_init(loop, self, async_cb));

<*
 Wakes the loop and schedules the callback.

 The one libuv call that is safe from a thread other than the loop's own.
 Several sends may be coalesced into a single callback invocation.

 @param [&inout] self
*>
fn void? Async.send(&self) => check(api::uv_async_send(self));

// Poll

<*
 Watches an already open file descriptor.

 The descriptor must be non-blocking. Do not also read or write it through a
 `Tcp` or `Pipe` handle; pick one.

 @param [&out] self
 @param [&inout] loop
*>
fn void? Poll.init(&self, Loop* loop, CInt fd) => check(api::uv_poll_init(loop, self, fd));

<*
 Watches an already open socket. Use this rather than `Poll.init` on Windows.

 @param [&out] self
 @param [&inout] loop
*>
fn void? Poll.init_socket(&self, Loop* loop, OsSock socket) => check(api::uv_poll_init_socket(loop, self, socket));

<*
 Starts watching for the given events.

 Calling it again replaces the event mask and the callback.

 @param events : "bitwise or of `libuv::READABLE`, `WRITABLE`, `DISCONNECT` and `PRIORITIZED`"
 @require events != 0 : "watching for no events would never fire"
 @require cb != null
 @param [&inout] self
*>
fn void? Poll.start(&self, CInt events, PollCallback cb) => check(api::uv_poll_start(self, events, cb));

<* @param [&inout] self *>
fn void? Poll.stop(&self) => check(api::uv_poll_stop(self));

// Signal

<*
 @param [&out] self
 @param [&inout] loop
*>
fn void? Signal.init(&self, Loop* loop) => check(api::uv_signal_init(loop, self));

<*
 Watches for a signal, calling `signal_cb` every time it arrives.

 On Windows libuv emulates `SIGINT`, `SIGBREAK`, `SIGHUP` and `SIGWINCH`.

 @require signal_cb != null
 @param [&inout] self
*>
fn void? Signal.start(&self, SignalCallback signal_cb, CInt signum)
	=> check(api::uv_signal_start(self, signal_cb, signum));

<*
 Watches for a signal, then stops itself after the first delivery.

 @require signal_cb != null
 @param [&inout] self
*>
fn void? Signal.start_oneshot(&self, SignalCallback signal_cb, CInt signum)
	=> check(api::uv_signal_start_oneshot(self, signal_cb, signum));

<* @param [&inout] self *>
fn void? Signal.stop(&self) => check(api::uv_signal_stop(self));

// Filesystem watchers

<*
 @param [&out] self
 @param [&inout] loop
*>
fn void? FsEvent.init(&self, Loop* loop) => check(api::uv_fs_event_init(loop, self));

<*
 Watches a path for changes.

 @param flags : "bitwise or of `FS_EVENT_WATCH_ENTRY`, `FS_EVENT_STAT` and `FS_EVENT_RECURSIVE`"
 @require cb != null
 @param [&inout] self
*>
fn void? FsEvent.start(&self, FsEventCallback cb, String path, CUInt flags = 0) => @pool()
{
	return check(api::uv_fs_event_start(self, cb, path.zstr_tcopy(), flags));
}

<* @param [&inout] self *>
fn void? FsEvent.stop(&self) => check(api::uv_fs_event_stop(self));

<*
 Copies the watched path into `buffer`.

 @param [out] buffer
 @param [&inout] size : "in, the buffer size; out, the length written, or the size needed when it fails with `ENOBUFS`"
*>
fn void? FsEvent.getpath(&self, char* buffer, usz* size) => check(api::uv_fs_event_getpath(self, buffer, size));

<*
 @param [&out] self
 @param [&inout] loop
*>
fn void? FsPoll.init(&self, Loop* loop) => check(api::uv_fs_poll_init(loop, self));

<*
 Polls a path by calling `stat` on it every `interval` milliseconds.

 The callback only runs when the result differs from the previous one.

 @require poll_cb != null
 @require interval > 0 : "a zero interval would spin the loop"
 @param [&inout] self
*>
fn void? FsPoll.start(&self, FsPollCallback poll_cb, String path, CUInt interval) => @pool()
{
	return check(api::uv_fs_poll_start(self, poll_cb, path.zstr_tcopy(), interval));
}

<* @param [&inout] self *>
fn void? FsPoll.stop(&self) => check(api::uv_fs_poll_stop(self));

<*
 Copies the polled path into `buffer`.

 @param [out] buffer
 @param [&inout] size : "in, the buffer size; out, the length written, or the size needed when it fails with `ENOBUFS`"
*>
fn void? FsPoll.getpath(&self, char* buffer, usz* size) => check(api::uv_fs_poll_getpath(self, buffer, size));
