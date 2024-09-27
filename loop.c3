module uv::loop;
import uv;

struct UVLoop {
    void* data;
    CUInt active_handles;
    UVQueue handle_queue;
    union active_reqs {
        void* unused;
        CUInt count;
    }
    void* internal_fields;
    CUInt stop_flag;

    CULong flags;                                                         
    CInt backend_fd;                                                              
    UVQueue pending_queue;                                              
    UVQueue watcher_queue;                                              
    UVIo** watchers;                                                         
    CUInt nwatchers;                                                      
    CUInt nfds;                                                           
    UVQueue wq;                                                         
    UVMutex wq_mutex;                                                         
    UVAsync wq_async;                                                         
    UVRWLock cloexec_lock;                                                    
    UVHandle* closing_handles;                                                
    UVQueue process_handles;                                            
    UVQueue prepare_handles;                                            
    UVQueue check_handles;                                              
    UVQueue idle_handles;                                               
    UVQueue async_handles;                                                   
    UVIo async_io_watcher;                                                   
    CInt async_wfd;                                                               
    struct timer_heap {                                                                     
        void* min;                                                                 
        CUInt nelts;                                                        
    }                                                             
    CULongLong timer_counter;                                                      
    CULongLong time;                                                               
    CInt[2] signal_pipefd;                                                        
    UVIo signal_io_watcher;                                                  
    UVSignal child_watcher;                                                   
    CInt emfile_fd;
}

enum UVRunMode : int (int code) {
  UV_RUN_DEFAULT = 0,
  UV_RUN_ONCE = 1,
  UV_RUN_NOWAIT = 2
}

enum UVLoopOption : int (int code) {
  UV_LOOP_BLOCK_SIGNAL = 0,
  UV_METRICS_IDLE_TIME = 1
}

def UVWalkCb = fn void(UVHandle*, void*);

extern fn CInt uv_loop_init(UVLoop* loop) @extern("uv_loop_init");
extern fn CInt uv_loop_configure(UVLoop* loop, UVLoopOption option, ...) @extern("uv_loop_configure");
extern fn CInt uv_loop_close(UVLoop* loop) @extern("uv_loop_close");
extern fn UVLoop* uv_default_loop() @extern("uv_default_loop");
extern fn CInt uv_run(UVLoop* loop, UVRunMode mode) @extern("uv_run");
extern fn CInt uv_loop_alive(UVLoop* loop) @extern("uv_loop_alive");
extern fn void uv_stop(UVLoop* loop) @extern("uv_stop");
extern fn usz uv_loop_size() @extern("uv_loop_size");
extern fn CInt uv_backend_fd(UVLoop* loop) @extern("uv_backend_fd");
extern fn CInt uv_backend_timeout(UVLoop* loop) @extern("uv_backend_timeout");
extern fn CULongLong uv_now(UVLoop* loop) @extern("uv_now");
extern fn void uv_update_time(UVLoop* loop) @extern("uv_update_time");
extern fn void uv_walk(UVLoop* loop, UVWalkCb walk_cb, void* arg) @extern("uv_walk");
extern fn CInt uv_loop_fork(UVLoop* loop) @extern("uv_loop_fork");
extern fn void* uv_loop_get_data(UVLoop* loop) @extern("uv_loop_get_data");
extern fn void* uv_loop_set_data(UVLoop* loop, void* data) @extern("uv_loop_set_data");