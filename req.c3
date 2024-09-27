module uv::req;
import uv;

struct UVRequiredFields {
    void* data;
    UVReqType type;
    void*[6] reserved;
}

struct UVReq {
    inline UVRequiredFields requiredFields;
}

enum UVReqType {
  UV_UNKNOWN_REQ,
  UV_REQ_TYPE_PRIVATE,
  UV_REQ_TYPE_MAX
}

extern fn CInt uv_cancel(UVReq* req) @extern("uv_cancel");
extern fn usz uv_req_size(UVReqType type) @extern("uv_req_size");
extern fn void* uv_req_get_data(UVReq* type) @extern("uv_req_get_data");
extern fn void* uv_req_set_data(UVReqType type) @extern("uv_req_set_data");
extern fn UVReqType uv_req_get_type(UVReq* req) @extern("uv_req_get_type");
extern fn CChar* uv_req_type_name(UVReqType type) @extern("uv_req_type_name");