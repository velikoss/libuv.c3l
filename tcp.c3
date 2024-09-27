module uv::tcp;
import uv;
import std::os::win32;

enum UVTcpFlags : int (int code) {
  UV_TCP_IPV6ONLY = 1,
  UV_TCP_REUSEPORT = 2,
}

struct UVTcp @if(env::WIN32) {
    inline UVHandleFields handleFields;
    usz write_queue_size;
    UVAllocCb alloc_cb;
    UVReadCb read_cb;
    CUInt reqs_pending; // UV_STREAM_PRIVATE_FIELDS
    CInt activecnt;
    UVRead read_req;
    union stream {
        struct conn {
            inline UVStreamConnectionFields fields;
        }
        struct serv {
            inline UVStreamServerFields fields;
        }
    }
    Win32_SOCKET socket;
    int delayed_error;
    union tcp {
        struct serv { inline UVTcpServerFields tcpServerFields; }
        struct conn { inline UVTcpConnectionFields tcpConnectionFields; }
    }
}

struct UVTcp @if(!env::WIN32) {
    inline UVHandleFields handleFields;
    usz write_queue_size;
    UVAllocCb alloc_cb;
    UVReadCb read_cb;
    UVConnect *connect_req;
    UVShutdown *shutdown_req;
    UVIo io_watcher;
    UVQueue write_queue;
    UVQueue write_completed_queue;
    UVConnectionCb connection_cb;
    CInt delayed_error;
    CInt accepted_fd;
    void* queued_fds;
    void* select; // todo: only for darwin, check if needed
}

struct Sockaddr {
   CUShort sa_family;
   CChar[14] sa_data;
}

def LPFn_CONNECTEX = fn bool
                          (Win32_SOCKET,
                           Sockaddr*,
                           CInt,
                           Win32_PVOID,
                           Win32_DWORD,
                           Win32_LPDWORD,
                           void*);

def LPFn_ACCEPTEX = fn bool
                          (Win32_SOCKET,
                           Win32_SOCKET,
                           Win32_PVOID,
                           Win32_DWORD,
                           Win32_DWORD,
                           Win32_DWORD,
                           Win32_LPDWORD,
                           void*);

const usz _SS_PAD1SIZE = 6;
const usz _SS_PAD2SIZE = 112;


struct Sockaddr_storage {
    CUShort  ss_family;
    CChar[_SS_PAD1SIZE]      __ss_pad1;
    CLongLong __ss_align;
    CChar[_SS_PAD2SIZE]      __ss_pad2;
}

struct InAddr {
  union {
    bitstruct s_un_b : char[16] @bigendian {
      char s_b1 : 0 .. 7;
      char s_b2 : 8 .. 15;
      char s_b3 : 16 .. 23;
      char s_b4 : 24 .. 31;
    }
    bitstruct s_un_w : char[16] @bigendian {
      ushort s_w1 : 32 .. 47;
      ushort s_w2 : 48 .. 63;
    }
    ulong s_addr;
  }
}

struct Sockaddr_in {
    short sin_family;
    ushort sin_port;
    InAddr sin_addr;
    char[8] sin_zero;
}

struct UVTcpAccept {
    inline UVRequiredFields requiredFields;
    Win32_SOCKET accept_socket;
    CChar[Sockaddr_storage.sizeof * 2 + 32] accept_buffer;
    Win32_HANDLE event_handle;
    Win32_HANDLE wait_handle;
    UVTcpAccept* next_pending;
}

struct UVStreamConnectionFields @if(env::WIN32) {
    CUInt write_reqs_pending;
    UVShutdown* shutdown_req;
}

struct UVTcpServerFields @if(env::WIN32) {
    UVTcpAccept* accept_reqs;
    CUInt processed_accepts;
    UVTcpAccept* pending_accepts;
    LPFn_ACCEPTEX func_acceptex;
}

struct UVStreamServerFields @if(env::WIN32) {
    UVConnectionCb connection_cb;
}

struct UVTcpConnectionFields @if(env::WIN32) {
     UVBuf read_buffer;
     LPFn_CONNECTEX func_connectex;
}

extern fn CInt uv_tcp_init(UVLoop*, UVTcp* handle) @extern("uv_tcp_init");
extern fn CInt uv_tcp_init_ex(UVLoop*, UVTcp* handle, CUInt flags) @extern("uv_tcp_init_ex");
extern fn CInt uv_tcp_open(UVTcp* handle, UVOSSock sock) @extern("uv_tcp_open");
extern fn CInt uv_tcp_nodelay(UVTcp* handle, CInt enable) @extern("uv_tcp_nodelay");
extern fn CInt uv_tcp_keepalive(UVTcp* handle, CInt enable, CUInt delay) @extern("uv_tcp_keepalive");
extern fn CInt uv_tcp_simultaneous_accepts(UVTcp* handle, CInt enable) @extern("uv_tcp_simultaneous_accepts");
extern fn CInt uv_tcp_bind(UVTcp* handle, Sockaddr* addr, CUInt flags) @extern("uv_tcp_bind");
extern fn CInt uv_tcp_getsockname(UVTcp* handle, Sockaddr* name, CInt* namelen) @extern("uv_tcp_getsockname");
extern fn CInt uv_tcp_getpeername(UVTcp* handle, Sockaddr* name, CInt* namelen) @extern("uv_tcp_getpeername");
extern fn CInt uv_tcp_connect(UVConnect* req, UVTcp* handle, Sockaddr* addr, UVConnectCb cb) @extern("uv_tcp_connect");
extern fn CInt uv_tcp_close_reset(UVTcp* handle, UVCloseCb close_cb) @extern("uv_tcp_close_reset");
extern fn CInt uv_socketpair(CInt type, CInt protocol, UVOSSock[2] socket_vector, CInt flags0, CInt flags1) @extern("uv_socketpair");