module libuv @if(env::OS_TYPE == OsType.SOLARIS);

import std::net::os;

/* For the sake of convenience and reduced #ifdef-ery in src/unix/sunos.c,
* add the fs_event fields even when this version of SunOS doesn't support
* file watching.
*/
struct UV_PLATFORM_LOOP_FIELDS_t {
    UV__Io fs_event_watcher;
    CInt fs_fd;
}