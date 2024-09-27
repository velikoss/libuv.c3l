module uv::handle;
import uv;

struct UVHandleFields @if(env::WIN32) {
    void* data;
    UVLoop* loop;
    UVHandleType type;
    UVCloseCb close_cb;
    UVQueue handle_queue;
    union u {
        CInt fd;
        void*[4] reserved;
    }
    UVHandle* endgame_next;
    CUInt flags;
}

struct UVHandleFields @if(!env::WIN32) {
    void* data;
    UVLoop* loop;
    UVHandleType type;
    UVCloseCb close_cb;
    UVQueue handle_queue;
    union u {
        CInt fd;
        void*[4] reserved;
    }
    UVHandle* next_closing;                                                  
    CUInt flags;                                                         
}

struct UVHandle {
    inline UVHandleFields handleFields;
}

enum UVHandleType {
  UV_UNKNOWN_HANDLE,
  UV_ASYNC,
  UV_CHECK,
  UV_FS_EVENT,
  UV_FS_POLL,
  UV_HANDLE,
  UV_IDLE,
  UV_NAMED_PIPE,
  UV_POLL,
  UV_PREPARE,
  UV_PROCESS,
  UV_STREAM,
  UV_TCP,
  UV_TIMER,
  UV_TTY,
  UV_UDP,
  UV_SIGNAL,
  UV_FILE,
  UV_HANDLE_TYPE_MAX
}

def UVAllocCb = fn void(UVHandle*, usz, UVBuf*);
def UVCloseCb = fn void(UVHandle*);

extern fn CInt uv_is_active(UVHandle* handle) @extern("uv_is_active");
extern fn CInt uv_is_closing(UVHandle* handle) @extern("uv_is_closing");
extern fn void uv_close(UVHandle* handle, UVCloseCb close_cb) @extern("uv_close");
extern fn void uv_ref(UVHandle* handle) @extern("uv_ref");
extern fn void uv_unref(UVHandle* handle) @extern("uv_unref");
extern fn CInt uv_has_ref(UVHandle* handle) @extern("uv_has_ref");
extern fn usz uv_handle_size(UVHandleType type) @extern("uv_handle_size");

extern fn CInt uv_send_buffer_size(UVHandle* handle, CInt* value) @extern("uv_send_buffer_size");
extern fn CInt uv_recv_buffer_size(UVHandle* handle, CInt* value) @extern("uv_send_buffer_size");
extern fn CInt uv_fileno(UVHandle* handle, UVOSFd* fd) @extern("uv_fileno");
extern fn UVLoop* uv_handle_get_loop(UVHandle* handle) @extern("uv_handle_get_loop");
extern fn void* uv_handle_get_data(UVHandle* handle) @extern("uv_handle_get_data");
extern fn void* uv_handle_set_data(UVHandle* handle, void* data) @extern("uv_handle_set_data");
extern fn UVHandleType uv_handle_get_type(UVHandle* handle) @extern("uv_handle_get_type");
extern fn CChar* uv_handle_type_name(UVHandleType type) @extern("uv_handle_type_name");
