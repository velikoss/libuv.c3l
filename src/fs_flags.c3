<*
 Flags for `libuv::fs_open`, C `UV_FS_O_*`.
*>
module libuv;

// Windows MSVCRT _O_* values, plus the flags libuv maps onto CreateFile behaviour. See include/uv/win.h.
const CInt O_APPEND @feat(WIN32) = 0x0008;
const CInt O_CREAT @feat(WIN32) = 0x0100;
const CInt O_EXCL @feat(WIN32) = 0x0400;
const CInt O_FILEMAP @feat(WIN32) = 0x20000000;
const CInt O_RANDOM @feat(WIN32) = 0x0010;
const CInt O_RDONLY @feat(WIN32) = 0x0000;
const CInt O_RDWR @feat(WIN32) = 0x0002;
const CInt O_SEQUENTIAL @feat(WIN32) = 0x0020;
const CInt O_SHORT_LIVED @feat(WIN32) = 0x1000;
const CInt O_TEMPORARY @feat(WIN32) = 0x0040;
const CInt O_TRUNC @feat(WIN32) = 0x0200;
const CInt O_WRONLY @feat(WIN32) = 0x0001;
const CInt O_DIRECT @feat(WIN32) = 0x02000000;
const CInt O_DIRECTORY @feat(WIN32) = 0;
const CInt O_DSYNC @feat(WIN32) = 0x04000000;
const CInt O_EXLOCK @feat(WIN32) = 0x10000000;
const CInt O_NOATIME @feat(WIN32) = 0;
const CInt O_NOCTTY @feat(WIN32) = 0;
const CInt O_NOFOLLOW @feat(WIN32) = 0;
const CInt O_NONBLOCK @feat(WIN32) = 0;
const CInt O_SYMLINK @feat(WIN32) = 0;
const CInt O_SYNC @feat(WIN32) = 0x08000000;

// include/uv/unix.h.
const CInt O_APPEND @feat(LINUX, ANDROID) = 0o2000;
const CInt O_CREAT @feat(LINUX, ANDROID) = 0o100;
const CInt O_EXCL @feat(LINUX, ANDROID) = 0o200;
const CInt O_FILEMAP @feat(LINUX, ANDROID) = 0;
const CInt O_RANDOM @feat(LINUX, ANDROID) = 0;
const CInt O_RDONLY @feat(LINUX, ANDROID) = 0;
const CInt O_RDWR @feat(LINUX, ANDROID) = 0o2;
const CInt O_SEQUENTIAL @feat(LINUX, ANDROID) = 0;
const CInt O_SHORT_LIVED @feat(LINUX, ANDROID) = 0;
const CInt O_TEMPORARY @feat(LINUX, ANDROID) = 0;
const CInt O_TRUNC @feat(LINUX, ANDROID) = 0o1000;
const CInt O_WRONLY @feat(LINUX, ANDROID) = 0o1;
const CInt O_DIRECT @feat(LINUX, ANDROID) = 0o40000;
const CInt O_DIRECTORY @feat(LINUX, ANDROID) = 0o200000;
const CInt O_DSYNC @feat(LINUX, ANDROID) = 0o10000;
const CInt O_EXLOCK @feat(LINUX, ANDROID) = 0;
const CInt O_NOATIME @feat(LINUX, ANDROID) = 0o1000000;
const CInt O_NOCTTY @feat(LINUX, ANDROID) = 0o400;
const CInt O_NOFOLLOW @feat(LINUX, ANDROID) = 0o400000;
const CInt O_NONBLOCK @feat(LINUX, ANDROID) = 0o4000;
const CInt O_SYMLINK @feat(LINUX, ANDROID) = 0;
const CInt O_SYNC @feat(LINUX, ANDROID) = 0o4010000;

//  Darwin, BSD
const CInt O_APPEND @feat(DARWIN, FREEBSD, OPENBSD, NETBSD) = 0x0008;
const CInt O_CREAT @feat(DARWIN, FREEBSD, OPENBSD, NETBSD) = 0x0200;
const CInt O_EXCL @feat(DARWIN, FREEBSD, OPENBSD, NETBSD) = 0x0800;
const CInt O_FILEMAP @feat(DARWIN, FREEBSD, OPENBSD, NETBSD) = 0;
const CInt O_RANDOM @feat(DARWIN, FREEBSD, OPENBSD, NETBSD) = 0;
const CInt O_RDONLY @feat(DARWIN, FREEBSD, OPENBSD, NETBSD) = 0x0000;
const CInt O_RDWR @feat(DARWIN, FREEBSD, OPENBSD, NETBSD) = 0x0002;
const CInt O_SEQUENTIAL @feat(DARWIN, FREEBSD, OPENBSD, NETBSD) = 0;
const CInt O_SHORT_LIVED @feat(DARWIN, FREEBSD, OPENBSD, NETBSD) = 0;
const CInt O_TEMPORARY @feat(DARWIN, FREEBSD, OPENBSD, NETBSD) = 0;
const CInt O_TRUNC @feat(DARWIN, FREEBSD, OPENBSD, NETBSD) = 0x0400;
const CInt O_WRONLY @feat(DARWIN, FREEBSD, OPENBSD, NETBSD) = 0x0001;
const CInt O_EXLOCK @feat(DARWIN, FREEBSD, OPENBSD, NETBSD) = 0x0020;
const CInt O_NONBLOCK @feat(DARWIN, FREEBSD, OPENBSD, NETBSD) = 0x0004;
const CInt O_NOFOLLOW @feat(DARWIN, FREEBSD, OPENBSD, NETBSD) = 0x0100;
const CInt O_NOATIME @feat(DARWIN, FREEBSD, OPENBSD, NETBSD) = 0;

const CInt O_DIRECT @feat(DARWIN) = 0;
const CInt O_DIRECTORY @feat(DARWIN) = 0x100000;
const CInt O_DSYNC @feat(DARWIN) = 0x400000;
const CInt O_NOCTTY @feat(DARWIN) = 0x20000;
const CInt O_SYMLINK @feat(DARWIN) = 0x200000;
const CInt O_SYNC @feat(DARWIN) = 0x0080;

const CInt O_DIRECT @feat(FREEBSD, NETBSD) = 0x00010000;
const CInt O_DIRECT @feat(OPENBSD) = 0;
const CInt O_DIRECTORY @feat(FREEBSD) = 0x00020000;
const CInt O_DIRECTORY @feat(OPENBSD, NETBSD) = 0x00200000;
const CInt O_DSYNC @feat(FREEBSD) = 0x01000000;
const CInt O_DSYNC @feat(OPENBSD, NETBSD) = 0x00010000;
const CInt O_NOCTTY @feat(FREEBSD, OPENBSD, NETBSD) = 0x8000;
const CInt O_SYMLINK @feat(FREEBSD, OPENBSD, NETBSD) = 0;
const CInt O_SYNC @feat(FREEBSD, OPENBSD, NETBSD) = 0x0080;

//  Access modes for libuv::fs_access.
const CInt F_OK = 0;
const CInt X_OK = 1;
const CInt W_OK = 2;
const CInt R_OK = 4;

<*
 Passed as an atime or mtime to the `utime` family to mean "right now".
*>
const double FS_UTIME_NOW = double::inf;

<*
 Passed as an atime or mtime to the `utime` family to leave that stamp alone.
*>
const double FS_UTIME_OMIT = double::nan;
