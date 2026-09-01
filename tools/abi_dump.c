#include <stdio.h>
#include <stddef.h>
#include "uv.h"

#define T(ty)        printf("%s|%zu|%zu\n", #ty, sizeof(ty), _Alignof(ty))
#define F(ty, f)     printf("%s.%s|%zu\n", #ty, #f, offsetof(ty, f))

int main(void)
{
	printf("#libuv|%s\n", uv_version_string());

	T(uv_buf_t);       F(uv_buf_t, base);   F(uv_buf_t, len);
	T(uv_timespec_t);  F(uv_timespec_t, tv_sec);  F(uv_timespec_t, tv_nsec);
	T(uv_timespec64_t);F(uv_timespec64_t, tv_sec); F(uv_timespec64_t, tv_nsec);
	T(uv_timeval_t);   F(uv_timeval_t, tv_sec);   F(uv_timeval_t, tv_usec);
	T(uv_timeval64_t); F(uv_timeval64_t, tv_sec); F(uv_timeval64_t, tv_usec);
	T(uv_stat_t);
	F(uv_stat_t, st_dev);   F(uv_stat_t, st_mode);  F(uv_stat_t, st_nlink);
	F(uv_stat_t, st_uid);   F(uv_stat_t, st_gid);   F(uv_stat_t, st_rdev);
	F(uv_stat_t, st_ino);   F(uv_stat_t, st_size);  F(uv_stat_t, st_blksize);
	F(uv_stat_t, st_blocks);F(uv_stat_t, st_flags); F(uv_stat_t, st_gen);
	F(uv_stat_t, st_atim);  F(uv_stat_t, st_mtim);  F(uv_stat_t, st_ctim);
	F(uv_stat_t, st_birthtim);
	T(uv_statfs_t);
	F(uv_statfs_t, f_type); F(uv_statfs_t, f_bsize); F(uv_statfs_t, f_blocks);
	F(uv_statfs_t, f_bfree);F(uv_statfs_t, f_bavail);F(uv_statfs_t, f_files);
	F(uv_statfs_t, f_ffree);F(uv_statfs_t, f_spare);
	T(uv_dirent_t);    F(uv_dirent_t, name); F(uv_dirent_t, type);
	T(uv_rusage_t);    F(uv_rusage_t, ru_utime); F(uv_rusage_t, ru_stime);
	F(uv_rusage_t, ru_maxrss); F(uv_rusage_t, ru_nivcsw);
	T(uv_cpu_info_t);  F(uv_cpu_info_t, model); F(uv_cpu_info_t, speed); F(uv_cpu_info_t, cpu_times);
	T(struct uv_cpu_times_s);
	F(struct uv_cpu_times_s, user); F(struct uv_cpu_times_s, nice);
	F(struct uv_cpu_times_s, sys);  F(struct uv_cpu_times_s, idle);
	F(struct uv_cpu_times_s, irq);
	T(uv_interface_address_t);
	F(uv_interface_address_t, name); F(uv_interface_address_t, phys_addr);
	F(uv_interface_address_t, is_internal); F(uv_interface_address_t, address);
	F(uv_interface_address_t, netmask);
	T(uv_passwd_t);  F(uv_passwd_t, username); F(uv_passwd_t, uid);
	F(uv_passwd_t, gid); F(uv_passwd_t, shell); F(uv_passwd_t, homedir);
	T(uv_group_t);   F(uv_group_t, groupname); F(uv_group_t, gid); F(uv_group_t, members);
	T(uv_utsname_t); F(uv_utsname_t, sysname); F(uv_utsname_t, release);
	F(uv_utsname_t, version); F(uv_utsname_t, machine);
	T(uv_env_item_t);F(uv_env_item_t, name); F(uv_env_item_t, value);
	T(uv_metrics_t); F(uv_metrics_t, loop_count); F(uv_metrics_t, events);
	F(uv_metrics_t, events_waiting); F(uv_metrics_t, reserved);
	T(uv_lib_t);
	T(uv_thread_options_t); F(uv_thread_options_t, flags); F(uv_thread_options_t, stack_size);
	T(uv_stdio_container_t); F(uv_stdio_container_t, flags); F(uv_stdio_container_t, data);
	T(uv_process_options_t);
	F(uv_process_options_t, exit_cb); F(uv_process_options_t, file);
	F(uv_process_options_t, args);    F(uv_process_options_t, env);
	F(uv_process_options_t, cwd);     F(uv_process_options_t, flags);
	F(uv_process_options_t, stdio_count); F(uv_process_options_t, stdio);
	F(uv_process_options_t, uid);     F(uv_process_options_t, gid);

	// threading primitives 
	T(uv_once_t); T(uv_thread_t); T(uv_mutex_t); T(uv_rwlock_t);
	T(uv_sem_t);  T(uv_cond_t);   T(uv_key_t);   T(uv_barrier_t);

	// handles 
	T(uv_loop_t);
	F(uv_loop_t, data); F(uv_loop_t, active_handles); F(uv_loop_t, handle_queue);
	F(uv_loop_t, active_reqs); F(uv_loop_t, internal_fields); F(uv_loop_t, stop_flag);

	T(uv_handle_t);
	F(uv_handle_t, data); F(uv_handle_t, loop); F(uv_handle_t, type);
	F(uv_handle_t, close_cb); F(uv_handle_t, handle_queue); F(uv_handle_t, u);

	T(uv_stream_t);
	F(uv_stream_t, write_queue_size); F(uv_stream_t, alloc_cb); F(uv_stream_t, read_cb);
	T(uv_tcp_t);
	T(uv_udp_t);   F(uv_udp_t, send_queue_size); F(uv_udp_t, send_queue_count);
	T(uv_pipe_t);  F(uv_pipe_t, ipc);
	T(uv_tty_t);
	T(uv_poll_t);  F(uv_poll_t, poll_cb);
	T(uv_timer_t);
	T(uv_prepare_t);
	T(uv_check_t);
	T(uv_idle_t);
	T(uv_async_t);
	T(uv_process_t); F(uv_process_t, exit_cb); F(uv_process_t, pid);
	T(uv_fs_event_t); F(uv_fs_event_t, path);
	T(uv_fs_poll_t);  F(uv_fs_poll_t, poll_ctx);
	T(uv_signal_t);   F(uv_signal_t, signal_cb); F(uv_signal_t, signum);
	T(uv_dir_t);      F(uv_dir_t, dirents); F(uv_dir_t, nentries); F(uv_dir_t, reserved);

	// requests 
	T(uv_req_t);   F(uv_req_t, data); F(uv_req_t, type); F(uv_req_t, reserved);
	T(uv_shutdown_t); F(uv_shutdown_t, handle); F(uv_shutdown_t, cb);
	T(uv_write_t); F(uv_write_t, cb); F(uv_write_t, send_handle); F(uv_write_t, handle);
	T(uv_connect_t); F(uv_connect_t, cb); F(uv_connect_t, handle);
	T(uv_udp_send_t); F(uv_udp_send_t, handle); F(uv_udp_send_t, cb);
	T(uv_getaddrinfo_t); F(uv_getaddrinfo_t, loop);
	T(uv_getnameinfo_t); F(uv_getnameinfo_t, loop);
	T(uv_work_t);  F(uv_work_t, loop); F(uv_work_t, work_cb); F(uv_work_t, after_work_cb);
	T(uv_random_t);F(uv_random_t, loop);
	T(uv_fs_t);
	F(uv_fs_t, fs_type); F(uv_fs_t, loop); F(uv_fs_t, cb); F(uv_fs_t, result);
	F(uv_fs_t, ptr); F(uv_fs_t, path); F(uv_fs_t, statbuf);


	// socket addresses 
	T(struct sockaddr);       F(struct sockaddr, sa_data);
	T(struct sockaddr_in);    F(struct sockaddr_in, sin_port); F(struct sockaddr_in, sin_addr);
	T(struct sockaddr_in6);   F(struct sockaddr_in6, sin6_port); F(struct sockaddr_in6, sin6_flowinfo);
	F(struct sockaddr_in6, sin6_addr); F(struct sockaddr_in6, sin6_scope_id);
	T(struct sockaddr_storage);
	T(struct addrinfo);

	// enum sanity 
	printf("$UV_UNKNOWN_HANDLE|%d\n", (int)UV_UNKNOWN_HANDLE);
	printf("$UV_FILE|%d\n", (int)UV_FILE);
	printf("$UV_HANDLE_TYPE_MAX|%d\n", (int)UV_HANDLE_TYPE_MAX);
	printf("$UV_UNKNOWN_REQ|%d\n", (int)UV_UNKNOWN_REQ);
	printf("$UV_REQ_TYPE_MAX|%d\n", (int)UV_REQ_TYPE_MAX);
	printf("$UV_RANDOM|%d\n", (int)UV_RANDOM);
	printf("$UV_FS_UNKNOWN|%d\n", (int)UV_FS_UNKNOWN);
	printf("$UV_FS_LUTIME|%d\n", (int)UV_FS_LUTIME);
	printf("$UV_RUN_NOWAIT|%d\n", (int)UV_RUN_NOWAIT);
	printf("$UV_DIRENT_BLOCK|%d\n", (int)UV_DIRENT_BLOCK);
	printf("$UV_TTY_MODE_RAW_VT|%d\n", (int)UV_TTY_MODE_RAW_VT);
	printf("$UV_METRICS_IDLE_TIME|%d\n", (int)UV_METRICS_IDLE_TIME);
	printf("$UV_LOOP_USE_IO_URING_SQPOLL|%d\n", (int)UV_LOOP_USE_IO_URING_SQPOLL);
	printf("$UV_JOIN_GROUP|%d\n", (int)UV_JOIN_GROUP);
	printf("$UV_EOF|%d\n", (int)UV_EOF);
	printf("$UV_UNKNOWN|%d\n", (int)UV_UNKNOWN);
	printf("$UV_EAI_ADDRFAMILY|%d\n", (int)UV_EAI_ADDRFAMILY);
	printf("$UV_MAXHOSTNAMESIZE|%d\n", (int)UV_MAXHOSTNAMESIZE);

#define FL(n) printf("&UV_FS_O_%s|%d\n", #n, (int)UV_FS_O_##n)
	FL(APPEND); FL(CREAT); FL(EXCL); FL(FILEMAP); FL(RANDOM); FL(RDONLY);
	FL(RDWR); FL(SEQUENTIAL); FL(SHORT_LIVED); FL(TEMPORARY); FL(TRUNC); FL(WRONLY);
	FL(DIRECT); FL(DIRECTORY); FL(DSYNC); FL(EXLOCK); FL(NOATIME); FL(NOCTTY);
	FL(NOFOLLOW); FL(NONBLOCK); FL(SYMLINK); FL(SYNC);
#undef FL
	printf("&F_OK|%d\n", (int)F_OK);
	printf("&R_OK|%d\n", (int)R_OK);
	printf("&W_OK|%d\n", (int)W_OK);
	printf("&X_OK|%d\n", (int)X_OK);

	printf("@uv_loop_size|%zu\n", uv_loop_size());
	printf("@uv_handle_size_TCP|%zu\n", uv_handle_size(UV_TCP));
	printf("@uv_req_size_WRITE|%zu\n", uv_req_size(UV_WRITE));
	return 0;
}
