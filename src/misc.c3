<*
 Clocks, system information, environment access and dynamic loading.

 The functions that fill a caller supplied buffer follow libuv's convention:
 pass the buffer size in `size`, and on success it is overwritten with the
 length written. When the buffer is too small they fail with `ENOBUFS` and leave
 the required size in `size`.
*>
module libuv;

// Clocks

<*
 A monotonic high resolution timestamp in nanoseconds.

 Only differences between two readings are meaningful; the origin is arbitrary.
*>
fn ulong hrtime() => api::uv_hrtime();

<*
 Reads one of the system clocks.

 @param [out] ts
*>
fn void? clock_gettime(ClockId clock_id, TimeSpec64* ts) => check(api::uv_clock_gettime(clock_id, ts));

<*
 Reads the wall clock.

 @param [out] tv
*>
fn void? gettimeofday(TimeVal64* tv) => check(api::uv_gettimeofday(tv));

<*
 Blocks the calling thread.

 Blocking the loop thread stalls every handle on it; prefer a `Timer`.
*>
fn void sleep(CUInt msec) => api::uv_sleep(msec);

// Process and system information

<*
 Stores the argument vector so that `libuv::set_process_title` can overwrite it.

 On Linux and the BSDs the title lives in the memory `argv` points at, so libuv
 has to take a copy first. Call it once, at the top of `main`, and use the
 vector it returns from then on.

 @return "the relocated argument vector"
*>
fn ZString* setup_args(CInt argc, ZString* argv) => api::uv_setup_args(argc, argv);

<*
 Copies the process title into `buffer`.

 @param [out] buffer
 @require buffer.len > 0
*>
fn void? get_process_title(char[] buffer) => check(api::uv_get_process_title(buffer.ptr, buffer.len));

<* Sets the process title. Needs `libuv::setup_args` to have run first. *>
fn void? set_process_title(String title) => @pool()
{
	return check(api::uv_set_process_title(title.zstr_tcopy()));
}

<*
 Resident set size of this process in bytes.

 @param [out] rss
*>
fn void? resident_set_memory(usz* rss) => check(api::uv_resident_set_memory(rss));

<*
 System uptime in seconds.

 @param [out] uptime
*>
fn void? uptime(double* uptime) => check(api::uv_uptime(uptime));

<*
 Resource usage of this process.

 @param [out] rusage
*>
fn void? getrusage(Rusage* rusage) => check(api::uv_getrusage(rusage));

<*
 Resource usage of the calling thread.

 @param [out] rusage
*>
fn void? getrusage_thread(Rusage* rusage) => check(api::uv_getrusage_thread(rusage));

<*
 How many threads this process can usefully run at once.

 Respects cgroup and affinity limits, unlike a raw CPU count.
*>
fn CUInt available_parallelism() => api::uv_available_parallelism();

<*
 Describes every CPU in the machine.

 @param [out] cpu_infos : "receives an array libuv owns; release it with `libuv::free_cpu_info`"
 @param [out] count
*>
fn void? cpu_info(CpuInfo** cpu_infos, CInt* count) => check(api::uv_cpu_info(cpu_infos, count));

<* Releases what `libuv::cpu_info` returned. *>
fn void free_cpu_info(CpuInfo* cpu_infos, CInt count) => api::uv_free_cpu_info(cpu_infos, count);

<*
 Describes every configured network interface address.

 @param [out] addresses : "receives an array libuv owns; release it with `libuv::free_interface_addresses`"
 @param [out] count
*>
fn void? interface_addresses(InterfaceAddress** addresses, CInt* count)
	=> check(api::uv_interface_addresses(addresses, count));

<* Releases what `libuv::interface_addresses` returned. *>
fn void free_interface_addresses(InterfaceAddress* addresses, CInt count)
	=> api::uv_free_interface_addresses(addresses, count);

<* Total physical memory in bytes, or 0 when it cannot be determined. *>
fn ulong get_total_memory() => api::uv_get_total_memory();

<* Free physical memory in bytes, or 0 when it cannot be determined. *>
fn ulong get_free_memory() => api::uv_get_free_memory();

<*
 Memory limit this process is held to, for example by a cgroup.

 0 when there is no limit or it cannot be determined.
*>
fn ulong get_constrained_memory() => api::uv_get_constrained_memory();

<* Memory still available within `libuv::get_constrained_memory`. *>
fn ulong get_available_memory() => api::uv_get_available_memory();

<*
 One, five and fifteen minute load averages.

 All zeroes on Windows, which has no equivalent.

 @param [out] avg
*>
fn void loadavg(double[3]* avg) => api::uv_loadavg(avg);

<*
 System name, release, version and machine.

 @param [out] buffer
*>
fn void? os_uname(Utsname* buffer) => check(api::uv_os_uname(buffer));

<*
 Copies the host name into `buffer`.

 `libuv::MAXHOSTNAMESIZE` bytes are always enough.

 @param [out] buffer
 @param [&inout] size : "in, the buffer size; out, the length written"
*>
fn void? os_gethostname(char* buffer, usz* size) => check(api::uv_os_gethostname(buffer, size));

<* Process id of this process. *>
fn Pid os_getpid() => api::uv_os_getpid();

<* Process id of the parent process. *>
fn Pid os_getppid() => api::uv_os_getppid();

<*
 Reads the scheduling priority of a process.

 @param [out] priority
*>
fn void? os_getpriority(Pid pid, CInt* priority) => check(api::uv_os_getpriority(pid, priority));

<*
 Sets the scheduling priority of a process.

 @param priority : "one of the `PRIORITY_*` values; lower means more favourable"
*>
fn void? os_setpriority(Pid pid, CInt priority) => check(api::uv_os_setpriority(pid, priority));

<*
 Describes the current user.

 @param [out] pwd : "receives strings libuv owns; release them with `libuv::os_free_passwd`"
*>
fn void? os_get_passwd(Passwd* pwd) => check(api::uv_os_get_passwd(pwd));

<*
 Describes the user with the given id.

 @param [out] pwd : "receives strings libuv owns; release them with `libuv::os_free_passwd`"
*>
fn void? os_get_passwd2(Passwd* pwd, Uid uid) => check(api::uv_os_get_passwd2(pwd, uid));

<* Releases the strings in a `Passwd`. *>
fn void os_free_passwd(Passwd* pwd) => api::uv_os_free_passwd(pwd);

<*
 Describes the group with the given id.

 @param [out] grp : "receives strings libuv owns; release them with `libuv::os_free_group`"
*>
fn void? os_get_group(Group* grp, Uid gid) => check(api::uv_os_get_group(grp, gid));

<* Releases the strings in a `Group`. *>
fn void os_free_group(Group* grp) => api::uv_os_free_group(grp);

// Paths and the environment

<*
 Copies the path of the running executable into `buffer`.

 @param [out] buffer
 @param [&inout] size : "in, the buffer size; out, the length written"
*>
fn void? exepath(char* buffer, usz* size) => check(api::uv_exepath(buffer, size));

<*
 Copies the current working directory into `buffer`.

 @param [out] buffer
 @param [&inout] size : "in, the buffer size; out, the length written"
*>
fn void? cwd(char* buffer, usz* size) => check(api::uv_cwd(buffer, size));

<* Changes the current working directory. *>
fn void? chdir(String dir) => @pool()
{
	return check(api::uv_chdir(dir.zstr_tcopy()));
}

<*
 Copies the current user's home directory into `buffer`.

 @param [out] buffer
 @param [&inout] size : "in, the buffer size; out, the length written"
*>
fn void? os_homedir(char* buffer, usz* size) => check(api::uv_os_homedir(buffer, size));

<*
 Copies the temporary directory into `buffer`.

 @param [out] buffer
 @param [&inout] size : "in, the buffer size; out, the length written"
*>
fn void? os_tmpdir(char* buffer, usz* size) => check(api::uv_os_tmpdir(buffer, size));

<*
 Copies the value of an environment variable into `buffer`.

 Fails with `ENOENT` when the variable is not set.

 @param [out] buffer
 @param [&inout] size : "in, the buffer size; out, the length written"
*>
fn void? os_getenv(String name, char* buffer, usz* size) => @pool()
{
	return check(api::uv_os_getenv(name.zstr_tcopy(), buffer, size));
}

<* Sets an environment variable for this process. *>
fn void? os_setenv(String name, String value) => @pool()
{
	return check(api::uv_os_setenv(name.zstr_tcopy(), value.zstr_tcopy()));
}

<* Removes an environment variable from this process. *>
fn void? os_unsetenv(String name) => @pool()
{
	return check(api::uv_os_unsetenv(name.zstr_tcopy()));
}

<*
 Lists the whole environment.

 @param [out] envitems : "receives an array libuv owns; release it with `libuv::os_free_environ`"
 @param [out] count
*>
fn void? os_environ(EnvItem** envitems, CInt* count) => check(api::uv_os_environ(envitems, count));

<* Releases what `libuv::os_environ` returned. *>
fn void os_free_environ(EnvItem* envitems, CInt count) => api::uv_os_free_environ(envitems, count);

// Descriptor conversion, Windows only in practice

<* The OS handle behind a C runtime file descriptor. *>
fn OsFd get_osfhandle(CInt fd) => api::uv_get_osfhandle(fd);

<*
 A C runtime file descriptor for an OS handle.

 The descriptor takes ownership: close it with `close`, not with the OS call.

 @return "the new file descriptor"
*>
fn CInt? open_osfhandle(OsFd os_fd) => check_value(api::uv_open_osfhandle(os_fd));

<*
 Translates a platform error into a libuv one.

 An `errno` value on unix, a `GetLastError` value on Windows.
*>
fn ErrorCode translate_sys_error(CInt sys_errno) => (ErrorCode)api::uv_translate_sys_error(sys_errno);

// Dynamic loading

<*
 Opens a shared library.

 On failure `libuv::dlerror` describes what went wrong. Release it with
 `libuv::dlclose` either way.

 @param [out] lib
*>
fn void? dlopen(String filename, Lib* lib) => @pool()
{
	if (api::uv_dlopen(filename.zstr_tcopy(), lib)) return ENOENT~;
	return;
}

<* Closes a shared library and frees any error message it holds. *>
fn void dlclose(Lib* lib) => api::uv_dlclose(lib);

<*
 Looks up a symbol.

 @param [out] ptr
*>
fn void? dlsym(Lib* lib, String name, void** ptr) => @pool()
{
	if (api::uv_dlsym(lib, name.zstr_tcopy(), ptr)) return NOT_FOUND~;
	return;
}

<* The last error from `libuv::dlopen` or `libuv::dlsym` on this library. *>
fn String dlerror(Lib* lib) => api::uv_dlerror(lib).str_view();
