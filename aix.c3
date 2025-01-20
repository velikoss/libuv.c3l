module libuv @if(env::OS_TYPE == OsType.AIX);

struct UV_PLATFORM_LOOP_FIELDS_t {
    CInt fs_fd;
}