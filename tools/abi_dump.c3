module abi_dump;
import std::io;
import libuv;

macro dump_type($Type, String cname)
{
	io::printfn("%s|%d|%d", cname, $Type::size, $Type::alignment);
}

macro @dump_field(String cname, #field)
{
	io::printfn("%s|%d", cname, $reflect(#field).offset);
}

fn int main(String[] args)
{
	io::printfn("#libuv|%s", libuv::api::uv_version_string());

	Buf buf;
	dump_type(Buf, "uv_buf_t");
	@dump_field("uv_buf_t.base", buf.base);
	@dump_field("uv_buf_t.len", buf.len);

	TimeSpec ts;
	dump_type(TimeSpec, "uv_timespec_t");
	@dump_field("uv_timespec_t.tv_sec", ts.tv_sec);
	@dump_field("uv_timespec_t.tv_nsec", ts.tv_nsec);

	TimeSpec64 ts64;
	dump_type(TimeSpec64, "uv_timespec64_t");
	@dump_field("uv_timespec64_t.tv_sec", ts64.tv_sec);
	@dump_field("uv_timespec64_t.tv_nsec", ts64.tv_nsec);

	TimeVal tv;
	dump_type(TimeVal, "uv_timeval_t");
	@dump_field("uv_timeval_t.tv_sec", tv.tv_sec);
	@dump_field("uv_timeval_t.tv_usec", tv.tv_usec);

	TimeVal64 tv64;
	dump_type(TimeVal64, "uv_timeval64_t");
	@dump_field("uv_timeval64_t.tv_sec", tv64.tv_sec);
	@dump_field("uv_timeval64_t.tv_usec", tv64.tv_usec);

	Stat st;
	dump_type(Stat, "uv_stat_t");
	@dump_field("uv_stat_t.st_dev", st.st_dev);
	@dump_field("uv_stat_t.st_mode", st.st_mode);
	@dump_field("uv_stat_t.st_nlink", st.st_nlink);
	@dump_field("uv_stat_t.st_uid", st.st_uid);
	@dump_field("uv_stat_t.st_gid", st.st_gid);
	@dump_field("uv_stat_t.st_rdev", st.st_rdev);
	@dump_field("uv_stat_t.st_ino", st.st_ino);
	@dump_field("uv_stat_t.st_size", st.st_size);
	@dump_field("uv_stat_t.st_blksize", st.st_blksize);
	@dump_field("uv_stat_t.st_blocks", st.st_blocks);
	@dump_field("uv_stat_t.st_flags", st.st_flags);
	@dump_field("uv_stat_t.st_gen", st.st_gen);
	@dump_field("uv_stat_t.st_atim", st.st_atim);
	@dump_field("uv_stat_t.st_mtim", st.st_mtim);
	@dump_field("uv_stat_t.st_ctim", st.st_ctim);
	@dump_field("uv_stat_t.st_birthtim", st.st_birthtim);

	StatFs sfs;
	dump_type(StatFs, "uv_statfs_t");
	@dump_field("uv_statfs_t.f_type", sfs.f_type);
	@dump_field("uv_statfs_t.f_bsize", sfs.f_bsize);
	@dump_field("uv_statfs_t.f_blocks", sfs.f_blocks);
	@dump_field("uv_statfs_t.f_bfree", sfs.f_bfree);
	@dump_field("uv_statfs_t.f_bavail", sfs.f_bavail);
	@dump_field("uv_statfs_t.f_files", sfs.f_files);
	@dump_field("uv_statfs_t.f_ffree", sfs.f_ffree);
	@dump_field("uv_statfs_t.f_spare", sfs.f_spare);

	Dirent de;
	dump_type(Dirent, "uv_dirent_t");
	@dump_field("uv_dirent_t.name", de.name);
	@dump_field("uv_dirent_t.type", de.type);

	Rusage ru;
	dump_type(Rusage, "uv_rusage_t");
	@dump_field("uv_rusage_t.ru_utime", ru.ru_utime);
	@dump_field("uv_rusage_t.ru_stime", ru.ru_stime);
	@dump_field("uv_rusage_t.ru_maxrss", ru.ru_maxrss);
	@dump_field("uv_rusage_t.ru_nivcsw", ru.ru_nivcsw);

	CpuInfo ci;
	dump_type(CpuInfo, "uv_cpu_info_t");
	@dump_field("uv_cpu_info_t.model", ci.model);
	@dump_field("uv_cpu_info_t.speed", ci.speed);
	@dump_field("uv_cpu_info_t.cpu_times", ci.cpu_times);

	CpuTimes ct;
	dump_type(CpuTimes, "struct uv_cpu_times_s");
	@dump_field("struct uv_cpu_times_s.user", ct.user);
	@dump_field("struct uv_cpu_times_s.nice", ct.nice);
	@dump_field("struct uv_cpu_times_s.sys", ct.sys);
	@dump_field("struct uv_cpu_times_s.idle", ct.idle);
	@dump_field("struct uv_cpu_times_s.irq", ct.irq);

	InterfaceAddress ia;
	dump_type(InterfaceAddress, "uv_interface_address_t");
	@dump_field("uv_interface_address_t.name", ia.name);
	@dump_field("uv_interface_address_t.phys_addr", ia.phys_addr);
	@dump_field("uv_interface_address_t.is_internal", ia.is_internal);
	@dump_field("uv_interface_address_t.address", ia.address);
	@dump_field("uv_interface_address_t.netmask", ia.netmask);

	Passwd pw;
	dump_type(Passwd, "uv_passwd_t");
	@dump_field("uv_passwd_t.username", pw.username);
	@dump_field("uv_passwd_t.uid", pw.uid);
	@dump_field("uv_passwd_t.gid", pw.gid);
	@dump_field("uv_passwd_t.shell", pw.shell);
	@dump_field("uv_passwd_t.homedir", pw.homedir);

	Group gr;
	dump_type(Group, "uv_group_t");
	@dump_field("uv_group_t.groupname", gr.groupname);
	@dump_field("uv_group_t.gid", gr.gid);
	@dump_field("uv_group_t.members", gr.members);

	Utsname un;
	dump_type(Utsname, "uv_utsname_t");
	@dump_field("uv_utsname_t.sysname", un.sysname);
	@dump_field("uv_utsname_t.release", un.release);
	@dump_field("uv_utsname_t.version", un.version);
	@dump_field("uv_utsname_t.machine", un.machine);

	EnvItem ei;
	dump_type(EnvItem, "uv_env_item_t");
	@dump_field("uv_env_item_t.name", ei.name);
	@dump_field("uv_env_item_t.value", ei.value);

	Metrics me;
	dump_type(Metrics, "uv_metrics_t");
	@dump_field("uv_metrics_t.loop_count", me.loop_count);
	@dump_field("uv_metrics_t.events", me.events);
	@dump_field("uv_metrics_t.events_waiting", me.events_waiting);
	@dump_field("uv_metrics_t.reserved", me.reserved);

	dump_type(Lib, "uv_lib_t");

	ThreadOptions to;
	dump_type(ThreadOptions, "uv_thread_options_t");
	@dump_field("uv_thread_options_t.flags", to.flags);
	@dump_field("uv_thread_options_t.stack_size", to.stack_size);

	StdioContainer sc;
	dump_type(StdioContainer, "uv_stdio_container_t");
	@dump_field("uv_stdio_container_t.flags", sc.flags);
	@dump_field("uv_stdio_container_t.data", sc.data);

	ProcessOptions po;
	dump_type(ProcessOptions, "uv_process_options_t");
	@dump_field("uv_process_options_t.exit_cb", po.exit_cb);
	@dump_field("uv_process_options_t.file", po.file);
	@dump_field("uv_process_options_t.args", po.args);
	@dump_field("uv_process_options_t.env", po.env);
	@dump_field("uv_process_options_t.cwd", po.cwd);
	@dump_field("uv_process_options_t.flags", po.flags);
	@dump_field("uv_process_options_t.stdio_count", po.stdio_count);
	@dump_field("uv_process_options_t.stdio", po.stdio);
	@dump_field("uv_process_options_t.uid", po.uid);
	@dump_field("uv_process_options_t.gid", po.gid);

	dump_type(Once, "uv_once_t");
	dump_type(Thread, "uv_thread_t");
	dump_type(Mutex, "uv_mutex_t");
	dump_type(RwLock, "uv_rwlock_t");
	dump_type(Sem, "uv_sem_t");
	dump_type(Cond, "uv_cond_t");
	dump_type(Key, "uv_key_t");
	dump_type(Barrier, "uv_barrier_t");

	Loop lo;
	dump_type(Loop, "uv_loop_t");
	@dump_field("uv_loop_t.data", lo.data);
	@dump_field("uv_loop_t.active_handles", lo.active_handles);
	@dump_field("uv_loop_t.handle_queue", lo.handle_queue);
	@dump_field("uv_loop_t.active_reqs", lo.active_reqs);
	@dump_field("uv_loop_t.internal_fields", lo.internal_fields);
	@dump_field("uv_loop_t.stop_flag", lo.stop_flag);

	Handle ha;
	dump_type(Handle, "uv_handle_t");
	@dump_field("uv_handle_t.data", ha.data);
	@dump_field("uv_handle_t.loop", ha.loop);
	@dump_field("uv_handle_t.type", ha.type);
	@dump_field("uv_handle_t.close_cb", ha.close_cb);
	@dump_field("uv_handle_t.handle_queue", ha.handle_queue);
	@dump_field("uv_handle_t.u", ha.u);

	Stream sr;
	dump_type(Stream, "uv_stream_t");
	@dump_field("uv_stream_t.write_queue_size", sr.write_queue_size);
	@dump_field("uv_stream_t.alloc_cb", sr.alloc_cb);
	@dump_field("uv_stream_t.read_cb", sr.read_cb);

	dump_type(Tcp, "uv_tcp_t");

	Udp ud;
	dump_type(Udp, "uv_udp_t");
	@dump_field("uv_udp_t.send_queue_size", ud.send_queue_size);
	@dump_field("uv_udp_t.send_queue_count", ud.send_queue_count);

	Pipe pi;
	dump_type(Pipe, "uv_pipe_t");
	@dump_field("uv_pipe_t.ipc", pi.ipc);

	dump_type(Tty, "uv_tty_t");

	Poll pl;
	dump_type(Poll, "uv_poll_t");
	@dump_field("uv_poll_t.poll_cb", pl.poll_cb);

	dump_type(Timer, "uv_timer_t");
	dump_type(Prepare, "uv_prepare_t");
	dump_type(Check, "uv_check_t");
	dump_type(Idle, "uv_idle_t");
	dump_type(Async, "uv_async_t");

	Process pr;
	dump_type(Process, "uv_process_t");
	@dump_field("uv_process_t.exit_cb", pr.exit_cb);
	@dump_field("uv_process_t.pid", pr.pid);

	FsEvent fe;
	dump_type(FsEvent, "uv_fs_event_t");
	@dump_field("uv_fs_event_t.path", fe.path);

	FsPoll fp;
	dump_type(FsPoll, "uv_fs_poll_t");
	@dump_field("uv_fs_poll_t.poll_ctx", fp.poll_ctx);

	Signal si;
	dump_type(Signal, "uv_signal_t");
	@dump_field("uv_signal_t.signal_cb", si.signal_cb);
	@dump_field("uv_signal_t.signum", si.signum);

	Dir di;
	dump_type(Dir, "uv_dir_t");
	@dump_field("uv_dir_t.dirents", di.dirents);
	@dump_field("uv_dir_t.nentries", di.nentries);
	@dump_field("uv_dir_t.reserved", di.reserved);

	Req rq;
	dump_type(Req, "uv_req_t");
	@dump_field("uv_req_t.data", rq.data);
	@dump_field("uv_req_t.type", rq.type);
	@dump_field("uv_req_t.reserved", rq.reserved);

	Shutdown sd;
	dump_type(Shutdown, "uv_shutdown_t");
	@dump_field("uv_shutdown_t.handle", sd.handle);
	@dump_field("uv_shutdown_t.cb", sd.cb);

	Write wr;
	dump_type(Write, "uv_write_t");
	@dump_field("uv_write_t.cb", wr.cb);
	@dump_field("uv_write_t.send_handle", wr.send_handle);
	@dump_field("uv_write_t.handle", wr.handle);

	Connect co;
	dump_type(Connect, "uv_connect_t");
	@dump_field("uv_connect_t.cb", co.cb);
	@dump_field("uv_connect_t.handle", co.handle);

	UdpSend us;
	dump_type(UdpSend, "uv_udp_send_t");
	@dump_field("uv_udp_send_t.handle", us.handle);
	@dump_field("uv_udp_send_t.cb", us.cb);

	GetAddrInfo ga;
	dump_type(GetAddrInfo, "uv_getaddrinfo_t");
	@dump_field("uv_getaddrinfo_t.loop", ga.loop);

	GetNameInfo gn;
	dump_type(GetNameInfo, "uv_getnameinfo_t");
	@dump_field("uv_getnameinfo_t.loop", gn.loop);

	Work wo;
	dump_type(Work, "uv_work_t");
	@dump_field("uv_work_t.loop", wo.loop);
	@dump_field("uv_work_t.work_cb", wo.work_cb);
	@dump_field("uv_work_t.after_work_cb", wo.after_work_cb);

	Random ra;
	dump_type(Random, "uv_random_t");
	@dump_field("uv_random_t.loop", ra.loop);

	Fs fs;
	dump_type(Fs, "uv_fs_t");
	@dump_field("uv_fs_t.fs_type", fs.fs_type);
	@dump_field("uv_fs_t.loop", fs.loop);
	@dump_field("uv_fs_t.cb", fs.cb);
	@dump_field("uv_fs_t.result", fs.result);
	@dump_field("uv_fs_t.ptr", fs.ptr);
	@dump_field("uv_fs_t.path", fs.path);
	@dump_field("uv_fs_t.statbuf", fs.statbuf);

	SockAddr sa;
	dump_type(SockAddr, "struct sockaddr");
	@dump_field("struct sockaddr.sa_data", sa.sa_data);
	SockAddrIn s4;
	dump_type(SockAddrIn, "struct sockaddr_in");
	@dump_field("struct sockaddr_in.sin_port", s4.sin_port);
	@dump_field("struct sockaddr_in.sin_addr", s4.sin_addr);
	SockAddrIn6 s6;
	dump_type(SockAddrIn6, "struct sockaddr_in6");
	@dump_field("struct sockaddr_in6.sin6_port", s6.sin6_port);
	@dump_field("struct sockaddr_in6.sin6_flowinfo", s6.sin6_flowinfo);
	@dump_field("struct sockaddr_in6.sin6_addr", s6.sin6_addr);
	@dump_field("struct sockaddr_in6.sin6_scope_id", s6.sin6_scope_id);
	dump_type(SockAddrStorage, "struct sockaddr_storage");
	dump_type(AddrInfo, "struct addrinfo");

	io::printfn("$UV_UNKNOWN_HANDLE|%d", (CInt)HandleType.UNKNOWN.ordinal);
	io::printfn("$UV_FILE|%d", (CInt)HandleType.FILE.ordinal);
	io::printfn("$UV_HANDLE_TYPE_MAX|%d", (CInt)HandleType::len);
	io::printfn("$UV_UNKNOWN_REQ|%d", (CInt)ReqType.UNKNOWN.ordinal);
	io::printfn("$UV_REQ_TYPE_MAX|%d", (CInt)ReqType::len);
	io::printfn("$UV_RANDOM|%d", (CInt)ReqType.RANDOM.ordinal);
	io::printfn("$UV_FS_UNKNOWN|%d", (CInt)libuv::FS_UNKNOWN);
	io::printfn("$UV_FS_LUTIME|%d", (CInt)libuv::FS_LUTIME);
	io::printfn("$UV_RUN_NOWAIT|%d", (CInt)RunMode.NOWAIT.ordinal);
	io::printfn("$UV_DIRENT_BLOCK|%d", (CInt)DirentType.BLOCK.ordinal);
	io::printfn("$UV_TTY_MODE_RAW_VT|%d", (CInt)TtyMode.RAW_VT.ordinal);
	io::printfn("$UV_METRICS_IDLE_TIME|%d", (CInt)LoopOption.METRICS_IDLE_TIME.ordinal);
	io::printfn("$UV_LOOP_USE_IO_URING_SQPOLL|%d", (CInt)LoopOption.USE_IO_URING_SQPOLL.ordinal);
	io::printfn("$UV_JOIN_GROUP|%d", (CInt)Membership.JOIN_GROUP.ordinal);
	io::printfn("$UV_EOF|%d", (CInt)libuv::EOF_CODE);
	io::printfn("$UV_UNKNOWN|%d", (CInt)libuv::UNKNOWN_CODE);
	io::printfn("$UV_EAI_ADDRFAMILY|%d", (CInt)libuv::EAI_ADDRFAMILY_CODE);
	io::printfn("$UV_MAXHOSTNAMESIZE|%d", (CInt)libuv::MAXHOSTNAMESIZE);

	$foreach $f : {
		{"APPEND", libuv::O_APPEND}, {"CREAT", libuv::O_CREAT}, {"EXCL", libuv::O_EXCL},
		{"FILEMAP", libuv::O_FILEMAP}, {"RANDOM", libuv::O_RANDOM}, {"RDONLY", libuv::O_RDONLY},
		{"RDWR", libuv::O_RDWR}, {"SEQUENTIAL", libuv::O_SEQUENTIAL},
		{"SHORT_LIVED", libuv::O_SHORT_LIVED}, {"TEMPORARY", libuv::O_TEMPORARY},
		{"TRUNC", libuv::O_TRUNC}, {"WRONLY", libuv::O_WRONLY}, {"DIRECT", libuv::O_DIRECT},
		{"DIRECTORY", libuv::O_DIRECTORY}, {"DSYNC", libuv::O_DSYNC}, {"EXLOCK", libuv::O_EXLOCK},
		{"NOATIME", libuv::O_NOATIME}, {"NOCTTY", libuv::O_NOCTTY}, {"NOFOLLOW", libuv::O_NOFOLLOW},
		{"NONBLOCK", libuv::O_NONBLOCK}, {"SYMLINK", libuv::O_SYMLINK}, {"SYNC", libuv::O_SYNC} }:
		io::printfn("&UV_FS_O_%s|%d", $f[0], $f[1]);
	$endforeach
	io::printfn("&F_OK|%d", libuv::F_OK);
	io::printfn("&R_OK|%d", libuv::R_OK);
	io::printfn("&W_OK|%d", libuv::W_OK);
	io::printfn("&X_OK|%d", libuv::X_OK);

	io::printfn("@uv_loop_size|%d", libuv::api::uv_loop_size());
	io::printfn("@uv_handle_size_TCP|%d", libuv::api::uv_handle_size(HandleType.TCP));
	io::printfn("@uv_req_size_WRITE|%d", libuv::api::uv_req_size(ReqType.WRITE));
	return 0;
}
