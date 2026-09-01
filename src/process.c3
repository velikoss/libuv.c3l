<*
 Child processes.
*>
module libuv;

<*
 Spawns a child process.

 On success the handle is active and `options.exit_cb` runs once the child
 exits. `options` and everything it points at only has to survive the call.

 @param [&out] self
 @param [&inout] loop
*>
fn void? Process.spawn(&self, Loop* loop, ProcessOptions* options) => check(api::uv_spawn(loop, self, options));

<*
 Sends a signal to the child.

 @param [&inout] self
*>
fn void? Process.kill(&self, CInt signum) => check(api::uv_process_kill(self, signum));

<* Process id of the child. Equivalent to reading `process.pid`. *>
fn Pid Process.get_pid(&self) => api::uv_process_get_pid(self);

<*
 Sends a signal to an arbitrary process id.

 On Windows only `SIGTERM`, `SIGKILL` and `SIGINT` do anything; a signal of 0
 tests whether the process exists.
*>
fn void? kill(CInt pid, CInt signum) => check(api::uv_kill(pid, signum));

<*
 Stops children from inheriting this process's stdio handles.

 Call it before spawning anything. Handles opened after this call still leak
 into children unless you set them non-inheritable yourself.
*>
fn void disable_stdio_inheritance() => api::uv_disable_stdio_inheritance();
