module uv::signal;
import uv;

struct UVSignal @if(env::WIN32) {
    inline UVHandleFields handleFields;
    UVSignalCb signal_cb;
    CInt signum;    
    uv_tree::RB_Entry(<UVSignal>) tree_entry;                                           
    UVReq signal_req;                                                 
    CULong pending_signum;
}

struct UVSignal @if(!env::WIN32) {
    inline UVHandleFields handleFields;
    UVSignalCb signal_cb;
    CInt signum;    
    tree::RB_Entry(<UVSignal>) tree_entry;                                                                   
    /* Use two counters here so we don have to fiddle with atomics. */          
    CUInt caught_signals;                                                
    CUInt dispatched_signals;
}

def UVSignalCb = fn void(UVHandle*, CInt);