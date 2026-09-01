<*
 UDP sockets and the address helpers shared with TCP.
*>
module libuv;

// Addresses

<*
 Parses a dotted quad and a port into a `sockaddr_in`.

 @param [out] addr
*>
fn void? ip4_addr(String ip, CInt port, SockAddrIn* addr) => @pool()
{
	return check(api::uv_ip4_addr(ip.zstr_tcopy(), port, addr));
}

<*
 Parses an IPv6 literal and a port into a `sockaddr_in6`.

 @param [out] addr
*>
fn void? ip6_addr(String ip, CInt port, SockAddrIn6* addr) => @pool()
{
	return check(api::uv_ip6_addr(ip.zstr_tcopy(), port, addr));
}

<*
 Formats any socket address as text, without the port.

 @param [out] dst : "receives a NUL terminated address; 46 bytes always suffice"
 @require dst.len > 0
*>
fn void? ip_name(SockAddr* src, char[] dst) => check(api::uv_ip_name(src, dst.ptr, dst.len));

<*
 Formats an IPv4 address as text.

 @param [out] dst
 @require dst.len > 0
*>
fn void? ip4_name(SockAddrIn* src, char[] dst) => check(api::uv_ip4_name(src, dst.ptr, dst.len));

<*
 Formats an IPv6 address as text.

 @param [out] dst
 @require dst.len > 0
*>
fn void? ip6_name(SockAddrIn6* src, char[] dst) => check(api::uv_ip6_name(src, dst.ptr, dst.len));

<*
 Formats a raw address of family `af` as text.

 @param af : "an address family constant, for example `(CInt)os::AF_INET`"
 @param [out] dst
 @require dst.len > 0
*>
fn void? inet_ntop(CInt af, void* src, char[] dst) => check(api::uv_inet_ntop(af, src, dst.ptr, dst.len));

<*
 Parses a textual address of family `af` into its raw form.

 @param af : "an address family constant, for example `(CInt)os::AF_INET`"
 @param [out] dst : "receives 4 bytes for IPv4 or 16 for IPv6"
*>
fn void? inet_pton(CInt af, String src, void* dst) => @pool()
{
	return check(api::uv_inet_pton(af, src.zstr_tcopy(), dst));
}

<*
 Name of the network interface with the given index.

 @param [out] buffer
 @param [&inout] size : "in, the buffer size; out, the length written, or the size needed when it fails with `ENOBUFS`"
*>
fn void? if_indextoname(CUInt ifindex, char* buffer, usz* size) => check(api::uv_if_indextoname(ifindex, buffer, size));

<*
 IPv6 scope id of the network interface with the given index.

 @param [out] buffer
 @param [&inout] size : "in, the buffer size; out, the length written, or the size needed when it fails with `ENOBUFS`"
*>
fn void? if_indextoiid(CUInt ifindex, char* buffer, usz* size) => check(api::uv_if_indextoiid(ifindex, buffer, size));

// UDP

<*
 @param [&out] self
 @param [&inout] loop
*>
fn void? Udp.init(&self, Loop* loop) => check(api::uv_udp_init(loop, self));

<*
 Initialises the handle and creates the socket right away.

 @param flags : "the address family in the low 8 bits, optionally ored with `libuv::UDP_RECVMMSG`"
 @param [&out] self
 @param [&inout] loop
*>
fn void? Udp.init_ex(&self, Loop* loop, CUInt flags) => check(api::uv_udp_init_ex(loop, self, flags));

<*
 Adopts an already open socket.

 @param [&inout] self
*>
fn void? Udp.open(&self, OsSock sock) => check(api::uv_udp_open(self, sock));

<*
 Binds the socket to a local address.

 @param flags : "bitwise or of `UDP_IPV6ONLY`, `UDP_REUSEADDR`, `UDP_REUSEPORT` and `UDP_LINUX_RECVERR`"
 @param [&inout] self
*>
fn void? Udp.bind(&self, SockAddr* addr, CUInt flags = 0) => check(api::uv_udp_bind(self, addr, flags));

<*
 Fixes the peer this socket talks to, so that `Udp.send` may omit the address.

 Pass a null `addr` to undo it.

 @param [&inout] self
*>
fn void? Udp.connect(&self, SockAddr* addr) => check(api::uv_udp_connect(self, addr));

<*
 Copies the local address of the socket into `name`.

 @param [out] name
 @param [&inout] namelen : "in, the size of `name`; out, the length written"
*>
fn void? Udp.getsockname(&self, SockAddr* name, CInt* namelen) => check(api::uv_udp_getsockname(self, name, namelen));

<*
 Copies the peer address of a connected socket into `name`.

 @param [out] name
 @param [&inout] namelen : "in, the size of `name`; out, the length written"
*>
fn void? Udp.getpeername(&self, SockAddr* name, CInt* namelen) => check(api::uv_udp_getpeername(self, name, namelen));

<*
 Joins or leaves a multicast group.

 @param interface_addr : "the local interface to use, or the empty string to let the OS choose"
 @param [&inout] self
*>
fn void? Udp.set_membership(&self, String multicast_addr, String interface_addr, Membership membership) => @pool()
{
	ZString iface = interface_addr.len ? interface_addr.zstr_tcopy() : (ZString)null;
	return check(api::uv_udp_set_membership(self, multicast_addr.zstr_tcopy(), iface, membership));
}

<*
 Joins or leaves a source specific multicast group.

 @param interface_addr : "the local interface to use, or the empty string to let the OS choose"
 @param [&inout] self
*>
fn void? Udp.set_source_membership(&self, String multicast_addr, String interface_addr, String source_addr, Membership membership) => @pool()
{
	ZString iface = interface_addr.len ? interface_addr.zstr_tcopy() : (ZString)null;
	return check(api::uv_udp_set_source_membership(self, multicast_addr.zstr_tcopy(), iface, source_addr.zstr_tcopy(), membership));
}

<*
 Whether multicast packets sent by this socket loop back to the local host.

 @param [&inout] self
*>
fn void? Udp.set_multicast_loop(&self, bool on) => check(api::uv_udp_set_multicast_loop(self, (CInt)on));

<*
 Hop limit for outgoing multicast packets.

 @require ttl >= 1 && ttl <= 255
 @param [&inout] self
*>
fn void? Udp.set_multicast_ttl(&self, CInt ttl) => check(api::uv_udp_set_multicast_ttl(self, ttl));

<*
 Local interface to send multicast packets from.

 @param interface_addr : "the local interface address, or the empty string to let the OS choose"
 @param [&inout] self
*>
fn void? Udp.set_multicast_interface(&self, String interface_addr) => @pool()
{
	ZString iface = interface_addr.len ? interface_addr.zstr_tcopy() : (ZString)null;
	return check(api::uv_udp_set_multicast_interface(self, iface));
}

<*
 Whether the socket may send broadcast packets.

 @param [&inout] self
*>
fn void? Udp.set_broadcast(&self, bool on) => check(api::uv_udp_set_broadcast(self, (CInt)on));

<*
 Hop limit for outgoing unicast packets.

 @require ttl >= 1 && ttl <= 255
 @param [&inout] self
*>
fn void? Udp.set_ttl(&self, CInt ttl) => check(api::uv_udp_set_ttl(self, ttl));

<*
 Queues a datagram.

 `req` and every buffer must stay alive and unmoved until `send_cb` runs. Pass a
 null `addr` on a socket that was given a peer with `Udp.connect`.

 @require bufs.len > 0
 @require bufs.len <= CUInt::max
 @param [&inout] self
 @param [&inout] req
*>
fn void? Udp.send(&self, UdpSend* req, Buf[] bufs, SockAddr* addr, UdpSendCallback send_cb)
	=> check(api::uv_udp_send(req, self, bufs.ptr, (CUInt)bufs.len, addr, send_cb));

<*
 Sends a datagram without queueing.

 Fails with `EAGAIN` when the kernel buffer is full.

 @require bufs.len > 0
 @require bufs.len <= CUInt::max
 @return "the number of bytes sent"
 @param [&inout] self
*>
fn CInt? Udp.try_send(&self, Buf[] bufs, SockAddr* addr)
	=> check_value(api::uv_udp_try_send(self, bufs.ptr, (CUInt)bufs.len, addr));

<*
 Sends several datagrams without queueing.

 Each entry of `bufs` is one datagram's buffer vector, `nbufs` gives its length
 and `addrs` its destination.

 @require bufs.len == nbufs.len && bufs.len == addrs.len : "the three arrays describe the same datagrams"
 @require bufs.len > 0
 @require bufs.len <= CUInt::max
 @return "the number of datagrams sent"
 @param [&inout] self
*>
fn CInt? Udp.try_send2(&self, Buf*[] bufs, CUInt[] nbufs, SockAddr*[] addrs, CUInt flags = 0)
	=> check_value(api::uv_udp_try_send2(self, (CUInt)bufs.len, bufs.ptr, nbufs.ptr, addrs.ptr, flags));

<*
 Starts receiving datagrams.

 @require alloc_cb != null
 @require recv_cb != null
 @param [&inout] self
*>
fn void? Udp.recv_start(&self, AllocCallback alloc_cb, UdpRecvCallback recv_cb)
	=> check(api::uv_udp_recv_start(self, alloc_cb, recv_cb));

<*
 Stops receiving datagrams.

 @param [&inout] self
*>
fn void? Udp.recv_stop(&self) => check(api::uv_udp_recv_stop(self));

<* True when the socket is using `recvmmsg` to batch reads. *>
fn bool Udp.using_recvmmsg(&self) => api::uv_udp_using_recvmmsg(self) != 0;

<* Bytes queued for sending. Equivalent to reading `udp.send_queue_size`. *>
fn usz Udp.get_send_queue_size(&self) => api::uv_udp_get_send_queue_size(self);

<* Send requests still queued. Equivalent to reading `udp.send_queue_count`. *>
fn usz Udp.get_send_queue_count(&self) => api::uv_udp_get_send_queue_count(self);
