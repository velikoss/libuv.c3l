module uv::thread;
import uv;
import std::os::win32;

struct UVWork {
  UVLoop* loop;
  UVQueue wq;
}

def UVWork_Work = fn void(UVWork *w);
def UVWork_Done = fn void(UVWork *w, CInt status);

def UVWorkCb = UVWork_Work;
def UVAfterWorkCb = UVWork_Done;
def UVThreadCb = fn void(void* arg);

def UVThread = Win32_HANDLE @if(env::WIN32);
def UVThread = Pthread_t @if(!env::WIN32);

extern fn CInt uv_queue_work(UVLoop* loop, UVWork* req, UVWorkCb work_cb, UVAfterWorkCb after_work_cb) @extern("uv_queue_work");
extern fn CInt uv_thread_create(UVThread *tid, UVThreadCb entry, void *arg) @extern("uv_thread_create");
extern fn CInt uv_thread_create_ex(UVThread *tid, void* params, UVThreadCb entry, void *arg) @extern("uv_thread_create_ex");
extern fn CInt uv_thread_setaffinity(UVThread *tid, char* cpumask, char* oldmask, usz mask_size) @extern("uv_thread_setaffinity");
extern fn CInt uv_thread_getaffinity(UVThread *tid, char* cpumask, usz mask_size) @extern("uv_thread_getaffinity");
extern fn CInt uv_thread_getcpu() @extern("uv_thread_getcpu");
extern fn UVThread uv_thread_self() @extern("uv_thread_self");
extern fn CInt uv_thread_join(UVThread *tid) @extern("uv_thread_join");
//The UVReq API functions also apply.
