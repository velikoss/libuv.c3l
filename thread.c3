module uv::thread;
import uv;

struct UVWork {
  UVLoop* loop;
  UVQueue wq;
}

def UVWork_Work = fn void(UVWork *w);
def UVWork_Done = fn void(UVWork *w, CInt status);

def UVWorkCb = UVWork_Work;
def UVAfterWorkCb = UVWork_Done;

extern fn CInt uv_queue_work(UVLoop* loop, UVWork* req, UVWorkCb work_cb, UVAfterWorkCb after_work_cb) @extern("uv_queue_work");
//The UVReq API functions also apply.