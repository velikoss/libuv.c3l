<*
 Name resolution.
*>
module libuv;

<*
 Resolves a host name, a service name, or both.

 Pass an empty string for either to leave it out. `hints` may be null. The
 result reaches the callback as an `AddrInfo*` that you must release with
 `libuv::freeaddrinfo`.

 Runs synchronously when `getaddrinfo_cb` is null, in which case the result is
 left in the request rather than passed to a callback.

 @require node.len > 0 || service.len > 0 : "at least one of node and service is required"
 @param [&inout] req
*>
fn void? getaddrinfo(Loop* loop, GetAddrInfo* req, GetAddrInfoCallback getaddrinfo_cb, String node, String service, AddrInfo* hints = null) => @pool()
{
	ZString n = node.len ? node.zstr_tcopy() : (ZString)null;
	ZString s = service.len ? service.zstr_tcopy() : (ZString)null;
	return check(api::uv_getaddrinfo(loop, req, getaddrinfo_cb, n, s, hints));
}

<* Releases an `AddrInfo` chain produced by `libuv::getaddrinfo`. *>
fn void freeaddrinfo(AddrInfo* ai) => api::uv_freeaddrinfo(ai);

<*
 Resolves an address back to a host and service name.

 Runs synchronously when `getnameinfo_cb` is null.

 @param flags : "`NI_*` flags from the platform's netdb.h, or 0"
 @param [&inout] req
*>
fn void? getnameinfo(Loop* loop, GetNameInfo* req, GetNameInfoCallback getnameinfo_cb, SockAddr* addr, CInt flags = 0)
	=> check(api::uv_getnameinfo(loop, req, getnameinfo_cb, addr, flags));

