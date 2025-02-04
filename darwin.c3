module libuv @if(env::DARWIN);

struct UV_PLATFORM_LOOP_FIELDS_t {
    UVThread cf_thread;
    void* _cf_reserved;
    void* cf_state;
    UVMutex cf_mutex;
    UVSem cf_sem;
    UV__Queue cf_signals;
}

// https://stackoverflow.com/questions/9602685/why-does-mode-t-use-4-byte#comment12181688_9602685
// darwin uses 16 bits for mode_t
def Unix_mode_t = CUShort;