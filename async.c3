module uv::async;
import uv;

struct UVAsync {
    inline UVHandleFields handleFields;
    UVAsyncCb async_cb;                                                       
    UVQueue queue;                                                     
    CInt pending; 
}

def UVAsyncCb = fn void(UVHandle*);
def Async_unused = fn void();

extern fn CInt uv_async_init(UVLoop *loop, UVAsync *async, UVAsyncCb async_cb) @extern("uv_async_init");
extern fn CInt uv_async_send(UVAsync *async) @extern("uv_async_send");
// The UVHandle API functions also apply.