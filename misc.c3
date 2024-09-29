module uv::misc;
import uv;
import std::os::win32;

const BSD_LIKE = env::FREEBSD || env::OPENBSD || env::DARWIN;

def UVFSCb = fn void(UVHandle*);
def UVReadCb = fn void(UVStream*, CInt, UVBuf*);
def UVIOCb = fn void(UVHandle*);

struct UVQueue {
  UVQueue* next;
  UVQueue* prev;
}

struct UVBuf {
  char* base;
  usz len;
}

import std::thread::os;
import std::os::posix;

def UVThread = Pthread_t @if(!env::WIN32);
def UVMutex = Pthread_mutex_t @if(!env::WIN32);
def UVMutex = Win32_CRITICAL_SECTION @if(env::WIN32);
def UVRWLock = Pthread_rwlock_t @if(!env::WIN32);
struct UVRWLock @if(env::WIN32) {
    void* read_write_lock_;
    CUChar[72] padding_;
}

struct UVRead @if(env::WIN32) {
    inline UVRequiredFields requiredFields;
    Win32_HANDLE event_handle;
    Win32_HANDLE wait_handle;
}

struct UVIOPrivatePlatformFields @if(BSD_LIKE) {
    CInt rcount;
    CInt wcount;
}

struct UVIOPrivatePlatformFields @if(!BSD_LIKE) {
    bool _empty;
}

struct UVIo {
    inline UVIOPrivatePlatformFields fields;
    UVIOCb cb;
    UVQueue pending_queue;
    UVQueue watcher_queue;
    CUInt pevents; /* Pending event mask i.e. mask at next tick. */
    CUInt events;  /* Current event mask. */
    CInt fd;
}

extern fn CInt uv_ip4_addr(char* ip, CInt port, Sockaddr_in* addr) @extern("uv_ip4_addr");
//extern fn CInt uv_ip6_addr(char* ip, CInt port, Sockaddr_in6* addr) @extern("uv_ip6_addr");
extern fn CInt uv_ip4_name(Sockaddr_in* src, char* dst, usz size) @extern("uv_ip4_name");
//extern fn CInt uv_ip6_name(Sockaddr_in6* src, char* dst, usz size) @extern("uv_ip6_name");
extern fn CInt uv_ip_name(Sockaddr* src, char* dst, usz size) @extern("uv_ip_name");
extern fn CInt uv_inet_ntop(CInt af, void* src, char* dst, usz size) @extern("uv_inet_ntop");
extern fn CInt uv_inet_pton(CInt af, char* src, void* dst) @extern("uv_inet_pton");

extern fn char* uv_strerror(CInt err) @extern("uv_strerror");
extern fn char* uv_err_name(CInt err) @extern("uv_err_name");
extern fn UVBuf uv_buf_init(char* base, usz len) @extern("uv_buf_init");
extern fn void uv_sleep(CUInt msec);

module uv::tree(<TreeType>);

struct RB_Entry {
    TreeType *rbe_left;        /* left element */                            
    TreeType *rbe_right;       /* right element */                           
    TreeType *rbe_parent;      /* parent element */                          
    CInt rbe_color;
}
