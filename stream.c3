module uv::stream;
import uv;

struct UVStream @if(!env::WIN32) {
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
    // void* select; // todo: only for darwin, check if needed
}

struct UVStream @if(env::WIN32) {
    inline UVHandleFields handleFields;
    usz write_queue_size;
    UVAllocCb alloc_cb;
    UVReadCb read_cb;
    CUInt reqs_pending;
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
}

struct UVConnect @if(env::WIN32) {
  inline UVRequiredFields requiredFields;
  UVConnectCb cb;
  UVStream* handle;
}

struct UVConnect @if(!env::WIN32) {
  inline UVRequiredFields requiredFields;
  UVConnectCb cb;
  UVStream* handle;
  UVQueue queue;
}

struct UVShutdown {
  inline UVRequiredFields requiredFields;
  UVStream* handle;
  UVShutdownCb cb;
  /* UV_SHUTDOWN_PRIVATE_FIELDS */ // empty for all targets in libuv :p
}

struct UVWrite @if(env::WIN32) {
    inline UVRequiredFields requiredFields;
    UVWriteCb cb;
    UVStream* send_handle;
    UVStream* handle;
    CInt coalesced;
    UVBuf write_buffer;
    Win32_HANDLE event_handle;
    Win32_HANDLE wait_handle;
}

struct UVWrite @if(!env::WIN32) {
    inline UVRequiredFields requiredFields;
    UVWriteCb cb;
    UVStream* send_handle;
    UVStream* handle;

    UVQueue queue;
    CUInt write_index;
    UVBuf* bufs;
    CUInt nbufs;
    CInt error;
    UVBuf[4] bufsml;
}

def UVWriteCb = fn void(UVWrite*, CInt);
def UVConnectCb = fn void(UVHandle*, CInt);
def UVShutdownCb = fn void(UVHandle*, CInt);
def UVConnectionCb = fn void(UVStream*, CInt);

extern fn CInt uv_listen(UVStream* stream, CInt backlog, UVConnectionCb cb) @extern("uv_listen");
extern fn CInt uv_accept(UVStream* server, UVStream* client) @extern("uv_accept");
extern fn CInt uv_read_start(UVStream* stream, UVAllocCb alloc_cb, UVReadCb read_cb) @extern("uv_read_start");
extern fn CInt uv_read_stop(UVStream* stream) @extern("uv_read_stop");
extern fn CInt uv_write(UVWrite* req, UVStream* handle, CArray(<UVBuf>) bufs, CUInt nbufs, UVWriteCb cb) @extern("uv_write");
extern fn CInt uv_write2(UVWrite* req, UVStream* handle, CArray(<UVBuf>) bufs, CUInt nbufs, UVStream* send_handle, UVWriteCb cb) @extern("uv_write2");
extern fn CInt uv_try_write(UVStream* handle, CArray(<UVBuf>) bufs, CUInt nbufs) @extern("uv_try_write");
extern fn CInt uv_try_write2(UVStream* handle, CArray(<UVBuf>) bufs, CUInt nbufs, UVStream* send_handle) @extern("uv_try_write2");
extern fn CInt uv_is_readable(UVStream* handle) @extern("uv_is_readable");
extern fn CInt uv_is_writable(UVStream* handle) @extern("uv_is_writable");
extern fn CInt uv_stream_set_blocking(UVStream* handle, CInt blocking) @extern("uv_stream_set_blocking");
extern fn usz uv_stream_get_write_queue_size(UVStream* stream) @extern("uv_stream_get_write_queue_size");