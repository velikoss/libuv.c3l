module uv::idle;
import uv;

struct UVIdle {
    inline UVHandleFields handleFields;
    UVIdle* idle_prev;
    UVIdle* idle_next;
    UVIdleCb idle_cb;
}

def UVIdleCb = fn void(UVHandle*);

extern fn CInt uv_idle_init(UVLoop* loop, UVIdle* idler) @extern("uv_idle_init");
extern fn CInt uv_idle_start(UVIdle* idle, UVIdleCb cb) @extern("uv_idle_start");
extern fn CInt uv_idle_stop(UVIdle* idle) @extern("uv_idle_stop");