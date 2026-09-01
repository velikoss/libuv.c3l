<*
 The C entry points.

 Use it when the API does not expose something you need.
*>
module libuv::api;

// Version, allocator, loop
extern fn CUInt uv_version();
extern fn ZString uv_version_string();
extern fn void uv_library_shutdown();
extern fn CInt uv_replace_allocator(MallocFunc malloc_func, ReallocFunc realloc_func, CallocFunc calloc_func, FreeFunc free_func);

extern fn Loop* uv_default_loop();
extern fn CInt uv_loop_init(Loop* loop);
extern fn CInt uv_loop_close(Loop* loop);
extern fn usz uv_loop_size();
extern fn CInt uv_loop_alive(Loop* loop);
extern fn CInt uv_loop_configure(Loop* loop, LoopOption option, ...);
extern fn CInt uv_loop_fork(Loop* loop);
extern fn void* uv_loop_get_data(Loop* loop);
extern fn void uv_loop_set_data(Loop* loop, void* data);

extern fn CInt uv_run(Loop* loop, RunMode mode);
extern fn void uv_stop(Loop* loop);
extern fn void uv_update_time(Loop* loop);
extern fn ulong uv_now(Loop* loop);
extern fn CInt uv_backend_fd(Loop* loop);
extern fn CInt uv_backend_timeout(Loop* loop);
extern fn void uv_walk(Loop* loop, WalkCallback walk_cb, void* arg);
extern fn CInt uv_metrics_info(Loop* loop, Metrics* metrics);
extern fn ulong uv_metrics_idle_time(Loop* loop);

// Errors
extern fn CInt uv_translate_sys_error(CInt sys_errno);
extern fn ZString uv_strerror(CInt err);
extern fn char* uv_strerror_r(CInt err, char* buf, usz buflen);
extern fn ZString uv_err_name(CInt err);
extern fn char* uv_err_name_r(CInt err, char* buf, usz buflen);

// Handles and requests
extern fn usz uv_handle_size(HandleType type);
extern fn HandleType uv_handle_get_type(Handle* handle);
extern fn ZString uv_handle_type_name(HandleType type);
extern fn void* uv_handle_get_data(Handle* handle);
extern fn Loop* uv_handle_get_loop(Handle* handle);
extern fn void uv_handle_set_data(Handle* handle, void* data);

extern fn usz uv_req_size(ReqType type);
extern fn void* uv_req_get_data(Req* req);
extern fn void uv_req_set_data(Req* req, void* data);
extern fn ReqType uv_req_get_type(Req* req);
extern fn ZString uv_req_type_name(ReqType type);
extern fn CInt uv_cancel(Req* req);

extern fn CInt uv_is_active(Handle* handle);
extern fn CInt uv_is_closing(Handle* handle);
extern fn void uv_close(Handle* handle, CloseCallback close_cb);
extern fn void uv_ref(Handle* handle);
extern fn void uv_unref(Handle* handle);
extern fn CInt uv_has_ref(Handle* handle);
extern fn CInt uv_send_buffer_size(Handle* handle, CInt* value);
extern fn CInt uv_recv_buffer_size(Handle* handle, CInt* value);
extern fn CInt uv_fileno(Handle* handle, OsFd* fd);

<* Takes a C `FILE*`. *>
extern fn void uv_print_all_handles(Loop* loop, void* stream);
extern fn void uv_print_active_handles(Loop* loop, void* stream);

// Buffers and descriptors
extern fn Buf uv_buf_init(char* base, CUInt len);
extern fn CInt uv_pipe(Fd[2]* fds, CInt read_flags, CInt write_flags);
extern fn CInt uv_socketpair(CInt type, CInt protocol, OsSock[2]* socket_vector, CInt flags0, CInt flags1);
extern fn HandleType uv_guess_handle(Fd file);

// Streams
extern fn usz uv_stream_get_write_queue_size(Stream* stream);
extern fn CInt uv_listen(Stream* stream, CInt backlog, ConnectionCallback cb);
extern fn CInt uv_accept(Stream* server, Stream* client);
extern fn CInt uv_read_start(Stream* stream, AllocCallback alloc_cb, ReadCallback read_cb);
extern fn CInt uv_read_stop(Stream* stream);
extern fn CInt uv_write(Write* req, Stream* handle, Buf* bufs, CUInt nbufs, WriteCallback cb);
extern fn CInt uv_write2(Write* req, Stream* handle, Buf* bufs, CUInt nbufs, Stream* send_handle, WriteCallback cb);
extern fn CInt uv_try_write(Stream* handle, Buf* bufs, CUInt nbufs);
extern fn CInt uv_try_write2(Stream* handle, Buf* bufs, CUInt nbufs, Stream* send_handle);
extern fn CInt uv_is_readable(Stream* handle);
extern fn CInt uv_is_writable(Stream* handle);
extern fn CInt uv_stream_set_blocking(Stream* handle, CInt blocking);
extern fn CInt uv_shutdown(Shutdown* req, Stream* handle, ShutdownCallback cb);

// TCP
extern fn CInt uv_tcp_init(Loop* loop, Tcp* handle);
extern fn CInt uv_tcp_init_ex(Loop* loop, Tcp* handle, CUInt flags);
extern fn CInt uv_tcp_open(Tcp* handle, OsSock sock);
extern fn CInt uv_tcp_nodelay(Tcp* handle, CInt enable);
extern fn CInt uv_tcp_keepalive(Tcp* handle, CInt enable, CUInt delay);
extern fn CInt uv_tcp_simultaneous_accepts(Tcp* handle, CInt enable);
extern fn CInt uv_tcp_bind(Tcp* handle, SockAddr* addr, CUInt flags);
extern fn CInt uv_tcp_getsockname(Tcp* handle, SockAddr* name, CInt* namelen);
extern fn CInt uv_tcp_getpeername(Tcp* handle, SockAddr* name, CInt* namelen);
extern fn CInt uv_tcp_close_reset(Tcp* handle, CloseCallback close_cb);
extern fn CInt uv_tcp_connect(Connect* req, Tcp* handle, SockAddr* addr, ConnectCallback cb);

// UDP
extern fn CInt uv_udp_init(Loop* loop, Udp* handle);
extern fn CInt uv_udp_init_ex(Loop* loop, Udp* handle, CUInt flags);
extern fn CInt uv_udp_open(Udp* handle, OsSock sock);
extern fn CInt uv_udp_bind(Udp* handle, SockAddr* addr, CUInt flags);
extern fn CInt uv_udp_connect(Udp* handle, SockAddr* addr);
extern fn CInt uv_udp_getpeername(Udp* handle, SockAddr* name, CInt* namelen);
extern fn CInt uv_udp_getsockname(Udp* handle, SockAddr* name, CInt* namelen);
extern fn CInt uv_udp_set_membership(Udp* handle, ZString multicast_addr, ZString interface_addr, Membership membership);
extern fn CInt uv_udp_set_source_membership(Udp* handle, ZString multicast_addr, ZString interface_addr, ZString source_addr, Membership membership);
extern fn CInt uv_udp_set_multicast_loop(Udp* handle, CInt on);
extern fn CInt uv_udp_set_multicast_ttl(Udp* handle, CInt ttl);
extern fn CInt uv_udp_set_multicast_interface(Udp* handle, ZString interface_addr);
extern fn CInt uv_udp_set_broadcast(Udp* handle, CInt on);
extern fn CInt uv_udp_set_ttl(Udp* handle, CInt ttl);
extern fn CInt uv_udp_send(UdpSend* req, Udp* handle, Buf* bufs, CUInt nbufs, SockAddr* addr, UdpSendCallback send_cb);
extern fn CInt uv_udp_try_send(Udp* handle, Buf* bufs, CUInt nbufs, SockAddr* addr);
extern fn CInt uv_udp_try_send2(Udp* handle, CUInt count, Buf** bufs, CUInt* nbufs, SockAddr** addrs, CUInt flags);
extern fn CInt uv_udp_recv_start(Udp* handle, AllocCallback alloc_cb, UdpRecvCallback recv_cb);
extern fn CInt uv_udp_using_recvmmsg(Udp* handle);
extern fn CInt uv_udp_recv_stop(Udp* handle);
extern fn usz uv_udp_get_send_queue_size(Udp* handle);
extern fn usz uv_udp_get_send_queue_count(Udp* handle);

// Pipe
extern fn CInt uv_pipe_init(Loop* loop, Pipe* handle, CInt ipc);
extern fn CInt uv_pipe_open(Pipe* handle, Fd file);
extern fn CInt uv_pipe_bind(Pipe* handle, ZString name);
extern fn CInt uv_pipe_bind2(Pipe* handle, ZString name, usz namelen, CUInt flags);
extern fn void uv_pipe_connect(Connect* req, Pipe* handle, ZString name, ConnectCallback cb);
extern fn CInt uv_pipe_connect2(Connect* req, Pipe* handle, ZString name, usz namelen, CUInt flags, ConnectCallback cb);
extern fn CInt uv_pipe_getsockname(Pipe* handle, char* buffer, usz* size);
extern fn CInt uv_pipe_getpeername(Pipe* handle, char* buffer, usz* size);
extern fn void uv_pipe_pending_instances(Pipe* handle, CInt count);
extern fn CInt uv_pipe_pending_count(Pipe* handle);
extern fn HandleType uv_pipe_pending_type(Pipe* handle);
extern fn CInt uv_pipe_chmod(Pipe* handle, CInt flags);

// TTY
extern fn CInt uv_tty_init(Loop* loop, Tty* handle, Fd fd, CInt readable);
extern fn CInt uv_tty_set_mode(Tty* handle, TtyMode mode);
extern fn CInt uv_tty_reset_mode();
extern fn CInt uv_tty_get_winsize(Tty* handle, CInt* width, CInt* height);
extern fn void uv_tty_set_vterm_state(TtyVtermState state);
extern fn CInt uv_tty_get_vterm_state(TtyVtermState* state);

// Poll, timer, prepare, check, idle, async, signal
extern fn CInt uv_poll_init(Loop* loop, Poll* handle, CInt fd);
extern fn CInt uv_poll_init_socket(Loop* loop, Poll* handle, OsSock socket);
extern fn CInt uv_poll_start(Poll* handle, CInt events, PollCallback cb);
extern fn CInt uv_poll_stop(Poll* handle);

extern fn CInt uv_timer_init(Loop* loop, Timer* handle);
extern fn CInt uv_timer_start(Timer* handle, TimerCallback cb, ulong timeout, ulong repeat);
extern fn CInt uv_timer_stop(Timer* handle);
extern fn CInt uv_timer_again(Timer* handle);
extern fn void uv_timer_set_repeat(Timer* handle, ulong repeat);
extern fn ulong uv_timer_get_repeat(Timer* handle);
extern fn ulong uv_timer_get_due_in(Timer* handle);

extern fn CInt uv_prepare_init(Loop* loop, Prepare* prepare);
extern fn CInt uv_prepare_start(Prepare* prepare, PrepareCallback cb);
extern fn CInt uv_prepare_stop(Prepare* prepare);

extern fn CInt uv_check_init(Loop* loop, Check* check);
extern fn CInt uv_check_start(Check* check, CheckCallback cb);
extern fn CInt uv_check_stop(Check* check);

extern fn CInt uv_idle_init(Loop* loop, Idle* idle);
extern fn CInt uv_idle_start(Idle* idle, IdleCallback cb);
extern fn CInt uv_idle_stop(Idle* idle);

extern fn CInt uv_async_init(Loop* loop, Async* async, AsyncCallback async_cb);
extern fn CInt uv_async_send(Async* async);

extern fn CInt uv_signal_init(Loop* loop, Signal* handle);
extern fn CInt uv_signal_start(Signal* handle, SignalCallback signal_cb, CInt signum);
extern fn CInt uv_signal_start_oneshot(Signal* handle, SignalCallback signal_cb, CInt signum);
extern fn CInt uv_signal_stop(Signal* handle);

// Name resolution
extern fn CInt uv_getaddrinfo(Loop* loop, GetAddrInfo* req, GetAddrInfoCallback getaddrinfo_cb, ZString node, ZString service, AddrInfo* hints);
extern fn void uv_freeaddrinfo(AddrInfo* ai);
extern fn CInt uv_getnameinfo(Loop* loop, GetNameInfo* req, GetNameInfoCallback getnameinfo_cb, SockAddr* addr, CInt flags);

extern fn CInt uv_ip4_addr(ZString ip, CInt port, SockAddrIn* addr);
extern fn CInt uv_ip6_addr(ZString ip, CInt port, SockAddrIn6* addr);
extern fn CInt uv_ip4_name(SockAddrIn* src, char* dst, usz size);
extern fn CInt uv_ip6_name(SockAddrIn6* src, char* dst, usz size);
extern fn CInt uv_ip_name(SockAddr* src, char* dst, usz size);
extern fn CInt uv_inet_ntop(CInt af, void* src, char* dst, usz size);
extern fn CInt uv_inet_pton(CInt af, ZString src, void* dst);
extern fn CInt uv_if_indextoname(CUInt ifindex, char* buffer, usz* size);
extern fn CInt uv_if_indextoiid(CUInt ifindex, char* buffer, usz* size);

// Processes
extern fn CInt uv_spawn(Loop* loop, Process* handle, ProcessOptions* options);
extern fn CInt uv_process_kill(Process* handle, CInt signum);
extern fn CInt uv_kill(CInt pid, CInt signum);
extern fn Pid uv_process_get_pid(Process* handle);
extern fn void uv_disable_stdio_inheritance();

// Threadpool
extern fn CInt uv_queue_work(Loop* loop, Work* req, WorkCallback work_cb, AfterWorkCallback after_work_cb);
extern fn CInt uv_random(Loop* loop, Random* req, void* buf, usz buflen, CUInt flags, RandomCallback cb);

// Filesystem
extern fn FsType uv_fs_get_type(Fs* req);
extern fn sz uv_fs_get_result(Fs* req);
extern fn CInt uv_fs_get_system_error(Fs* req);
extern fn void* uv_fs_get_ptr(Fs* req);
extern fn ZString uv_fs_get_path(Fs* req);
extern fn Stat* uv_fs_get_statbuf(Fs* req);
extern fn void uv_fs_req_cleanup(Fs* req);

extern fn CInt uv_fs_close(Loop* loop, Fs* req, Fd file, FsCallback cb);
extern fn CInt uv_fs_open(Loop* loop, Fs* req, ZString path, CInt flags, CInt mode, FsCallback cb);
extern fn CInt uv_fs_read(Loop* loop, Fs* req, Fd file, Buf* bufs, CUInt nbufs, long offset, FsCallback cb);
extern fn CInt uv_fs_write(Loop* loop, Fs* req, Fd file, Buf* bufs, CUInt nbufs, long offset, FsCallback cb);
extern fn CInt uv_fs_unlink(Loop* loop, Fs* req, ZString path, FsCallback cb);
extern fn CInt uv_fs_copyfile(Loop* loop, Fs* req, ZString path, ZString new_path, CInt flags, FsCallback cb);
extern fn CInt uv_fs_mkdir(Loop* loop, Fs* req, ZString path, CInt mode, FsCallback cb);
extern fn CInt uv_fs_mkdtemp(Loop* loop, Fs* req, ZString tpl, FsCallback cb);
extern fn CInt uv_fs_mkstemp(Loop* loop, Fs* req, ZString tpl, FsCallback cb);
extern fn CInt uv_fs_rmdir(Loop* loop, Fs* req, ZString path, FsCallback cb);
extern fn CInt uv_fs_scandir(Loop* loop, Fs* req, ZString path, CInt flags, FsCallback cb);
extern fn CInt uv_fs_scandir_next(Fs* req, Dirent* ent);
extern fn CInt uv_fs_opendir(Loop* loop, Fs* req, ZString path, FsCallback cb);
extern fn CInt uv_fs_readdir(Loop* loop, Fs* req, Dir* dir, FsCallback cb);
extern fn CInt uv_fs_closedir(Loop* loop, Fs* req, Dir* dir, FsCallback cb);
extern fn CInt uv_fs_stat(Loop* loop, Fs* req, ZString path, FsCallback cb);
extern fn CInt uv_fs_fstat(Loop* loop, Fs* req, Fd file, FsCallback cb);
extern fn CInt uv_fs_lstat(Loop* loop, Fs* req, ZString path, FsCallback cb);
extern fn CInt uv_fs_statfs(Loop* loop, Fs* req, ZString path, FsCallback cb);
extern fn CInt uv_fs_rename(Loop* loop, Fs* req, ZString path, ZString new_path, FsCallback cb);
extern fn CInt uv_fs_fsync(Loop* loop, Fs* req, Fd file, FsCallback cb);
extern fn CInt uv_fs_fdatasync(Loop* loop, Fs* req, Fd file, FsCallback cb);
extern fn CInt uv_fs_ftruncate(Loop* loop, Fs* req, Fd file, long offset, FsCallback cb);
extern fn CInt uv_fs_sendfile(Loop* loop, Fs* req, Fd out_fd, Fd in_fd, long in_offset, usz length, FsCallback cb);
extern fn CInt uv_fs_access(Loop* loop, Fs* req, ZString path, CInt mode, FsCallback cb);
extern fn CInt uv_fs_chmod(Loop* loop, Fs* req, ZString path, CInt mode, FsCallback cb);
extern fn CInt uv_fs_fchmod(Loop* loop, Fs* req, Fd file, CInt mode, FsCallback cb);
extern fn CInt uv_fs_utime(Loop* loop, Fs* req, ZString path, double atime, double mtime, FsCallback cb);
extern fn CInt uv_fs_futime(Loop* loop, Fs* req, Fd file, double atime, double mtime, FsCallback cb);
extern fn CInt uv_fs_lutime(Loop* loop, Fs* req, ZString path, double atime, double mtime, FsCallback cb);
extern fn CInt uv_fs_link(Loop* loop, Fs* req, ZString path, ZString new_path, FsCallback cb);
extern fn CInt uv_fs_symlink(Loop* loop, Fs* req, ZString path, ZString new_path, CInt flags, FsCallback cb);
extern fn CInt uv_fs_readlink(Loop* loop, Fs* req, ZString path, FsCallback cb);
extern fn CInt uv_fs_realpath(Loop* loop, Fs* req, ZString path, FsCallback cb);
extern fn CInt uv_fs_chown(Loop* loop, Fs* req, ZString path, Uid uid, Gid gid, FsCallback cb);
extern fn CInt uv_fs_fchown(Loop* loop, Fs* req, Fd file, Uid uid, Gid gid, FsCallback cb);
extern fn CInt uv_fs_lchown(Loop* loop, Fs* req, ZString path, Uid uid, Gid gid, FsCallback cb);

extern fn CInt uv_fs_event_init(Loop* loop, FsEvent* handle);
extern fn CInt uv_fs_event_start(FsEvent* handle, FsEventCallback cb, ZString path, CUInt flags);
extern fn CInt uv_fs_event_stop(FsEvent* handle);
extern fn CInt uv_fs_event_getpath(FsEvent* handle, char* buffer, usz* size);

extern fn CInt uv_fs_poll_init(Loop* loop, FsPoll* handle);
extern fn CInt uv_fs_poll_start(FsPoll* handle, FsPollCallback poll_cb, ZString path, CUInt interval);
extern fn CInt uv_fs_poll_stop(FsPoll* handle);
extern fn CInt uv_fs_poll_getpath(FsPoll* handle, char* buffer, usz* size);

// System information
extern fn ZString* uv_setup_args(CInt argc, ZString* argv);
extern fn CInt uv_get_process_title(char* buffer, usz size);
extern fn CInt uv_set_process_title(ZString title);
extern fn CInt uv_resident_set_memory(usz* rss);
extern fn CInt uv_uptime(double* uptime);
extern fn OsFd uv_get_osfhandle(CInt fd);
extern fn CInt uv_open_osfhandle(OsFd os_fd);
extern fn CInt uv_getrusage(Rusage* rusage);
extern fn CInt uv_getrusage_thread(Rusage* rusage);
extern fn CInt uv_os_homedir(char* buffer, usz* size);
extern fn CInt uv_os_tmpdir(char* buffer, usz* size);
extern fn CInt uv_os_get_passwd(Passwd* pwd);
extern fn void uv_os_free_passwd(Passwd* pwd);
extern fn CInt uv_os_get_passwd2(Passwd* pwd, Uid uid);
extern fn CInt uv_os_get_group(Group* grp, Uid gid);
extern fn void uv_os_free_group(Group* grp);
extern fn Pid uv_os_getpid();
extern fn Pid uv_os_getppid();
extern fn CInt uv_os_getpriority(Pid pid, CInt* priority);
extern fn CInt uv_os_setpriority(Pid pid, CInt priority);
extern fn CUInt uv_available_parallelism();
extern fn CInt uv_cpu_info(CpuInfo** cpu_infos, CInt* count);
extern fn void uv_free_cpu_info(CpuInfo* cpu_infos, CInt count);
extern fn CInt uv_cpumask_size();
extern fn CInt uv_interface_addresses(InterfaceAddress** addresses, CInt* count);
extern fn void uv_free_interface_addresses(InterfaceAddress* addresses, CInt count);
extern fn CInt uv_os_environ(EnvItem** envitems, CInt* count);
extern fn void uv_os_free_environ(EnvItem* envitems, CInt count);
extern fn CInt uv_os_getenv(ZString name, char* buffer, usz* size);
extern fn CInt uv_os_setenv(ZString name, ZString value);
extern fn CInt uv_os_unsetenv(ZString name);
extern fn CInt uv_os_gethostname(char* buffer, usz* size);
extern fn CInt uv_os_uname(Utsname* buffer);
extern fn CInt uv_exepath(char* buffer, usz* size);
extern fn CInt uv_cwd(char* buffer, usz* size);
extern fn CInt uv_chdir(ZString dir);
extern fn ulong uv_get_free_memory();
extern fn ulong uv_get_total_memory();
extern fn ulong uv_get_constrained_memory();
extern fn ulong uv_get_available_memory();
extern fn CInt uv_clock_gettime(ClockId clock_id, TimeSpec64* ts);
extern fn ulong uv_hrtime();
extern fn void uv_sleep(CUInt msec);
extern fn CInt uv_gettimeofday(TimeVal64* tv);
extern fn void uv_loadavg(double[3]* avg);

// Dynamic loading
extern fn CInt uv_dlopen(ZString filename, Lib* lib);
extern fn void uv_dlclose(Lib* lib);
extern fn CInt uv_dlsym(Lib* lib, ZString name, void** ptr);
extern fn ZString uv_dlerror(Lib* lib);

// Threads and synchronisation
extern fn CInt uv_mutex_init(Mutex* handle);
extern fn CInt uv_mutex_init_recursive(Mutex* handle);
extern fn void uv_mutex_destroy(Mutex* handle);
extern fn void uv_mutex_lock(Mutex* handle);
extern fn CInt uv_mutex_trylock(Mutex* handle);
extern fn void uv_mutex_unlock(Mutex* handle);

extern fn CInt uv_rwlock_init(RwLock* rwlock);
extern fn void uv_rwlock_destroy(RwLock* rwlock);
extern fn void uv_rwlock_rdlock(RwLock* rwlock);
extern fn CInt uv_rwlock_tryrdlock(RwLock* rwlock);
extern fn void uv_rwlock_rdunlock(RwLock* rwlock);
extern fn void uv_rwlock_wrlock(RwLock* rwlock);
extern fn CInt uv_rwlock_trywrlock(RwLock* rwlock);
extern fn void uv_rwlock_wrunlock(RwLock* rwlock);

extern fn CInt uv_sem_init(Sem* sem, CUInt value);
extern fn void uv_sem_destroy(Sem* sem);
extern fn void uv_sem_post(Sem* sem);
extern fn void uv_sem_wait(Sem* sem);
extern fn CInt uv_sem_trywait(Sem* sem);

extern fn CInt uv_cond_init(Cond* cond);
extern fn void uv_cond_destroy(Cond* cond);
extern fn void uv_cond_signal(Cond* cond);
extern fn void uv_cond_broadcast(Cond* cond);
extern fn void uv_cond_wait(Cond* cond, Mutex* mutex);
extern fn CInt uv_cond_timedwait(Cond* cond, Mutex* mutex, ulong timeout);

extern fn CInt uv_barrier_init(Barrier* barrier, CUInt count);
extern fn void uv_barrier_destroy(Barrier* barrier);
extern fn CInt uv_barrier_wait(Barrier* barrier);

extern fn void uv_once(Once* guard, OnceCallback callback);

extern fn CInt uv_key_create(Key* key);
extern fn void uv_key_delete(Key* key);
extern fn void* uv_key_get(Key* key);
extern fn void uv_key_set(Key* key, void* value);

extern fn CInt uv_thread_create(Thread* tid, ThreadCallback entry, void* arg);
extern fn CInt uv_thread_create_ex(Thread* tid, ThreadOptions* params, ThreadCallback entry, void* arg);
extern fn CInt uv_thread_detach(Thread* tid);
extern fn CInt uv_thread_setaffinity(Thread* tid, char* cpumask, char* oldmask, usz mask_size);
extern fn CInt uv_thread_getaffinity(Thread* tid, char* cpumask, usz mask_size);
extern fn CInt uv_thread_getcpu();
extern fn Thread uv_thread_self();
extern fn CInt uv_thread_join(Thread* tid);
extern fn CInt uv_thread_equal(Thread* t1, Thread* t2);
extern fn CInt uv_thread_setname(ZString name);
extern fn CInt uv_thread_getname(Thread* tid, char* name, usz size);
extern fn CInt uv_thread_getpriority(Thread tid, CInt* priority);
extern fn CInt uv_thread_setpriority(Thread tid, CInt priority);

// WTF-8 conversion, needed when dealing with Windows paths
extern fn usz uv_utf16_length_as_wtf8(ushort* utf16, sz utf16_len);
extern fn CInt uv_utf16_to_wtf8(ushort* utf16, sz utf16_len, char** wtf8_ptr, usz* wtf8_len_ptr);
extern fn sz uv_wtf8_length_as_utf16(ZString wtf8);
extern fn void uv_wtf8_to_utf16(ZString wtf8, ushort* utf16, usz utf16_len);
