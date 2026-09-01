module libuv_udp_test;
import std::core::test;
import libuv;

const String DATAGRAM = "one datagram, please";

Loop loop @local;
Udp receiver @local;
Udp sender @local;
UdpSend send_req @local;

char[256] recv_buf @local;
char[256] received @local;
usz received_len @local;
int send_status @local;
int recv_errors @local;
bool had_addr @local;

fn void on_alloc(libuv::Handle* h, usz suggested, libuv::Buf* buf) @local
{
	*buf = libuv::buf(&recv_buf);
}

fn void on_recv(libuv::Udp* h, sz nread, libuv::Buf* buf, libuv::SockAddr* addr, CUInt flags) @local
{
	if (nread < 0)
	{
		recv_errors++;
		h.close();
		sender.close();
		return;
	}
	if (nread == 0 && addr == null) return;

	had_addr = addr != null;
	usz n = (usz)nread;
	if (n <= received.len)
	{
		received[:n] = buf.base[:n];
		received_len = n;
	}
	h.close();
	sender.close();
}

fn void on_send(libuv::UdpSend* req, CInt status) @local
{
	send_status = status;
}

fn void udp_round_trip() @test
{
	received_len = 0;
	send_status = 0;
	recv_errors = 0;
	had_addr = false;

	loop.init()!!;

	libuv::SockAddrIn bind_addr;
	libuv::ip4_addr("127.0.0.1", 0, &bind_addr)!!;

	receiver.init(&loop)!!;
	receiver.bind((libuv::SockAddr*)&bind_addr)!!;

	libuv::SockAddrStorage bound;
	CInt bound_len = libuv::SockAddrStorage::size;
	receiver.getsockname((libuv::SockAddr*)&bound, &bound_len)!!;
	libuv::SockAddrIn* bound4 = (libuv::SockAddrIn*)&bound;
	CInt port = (CInt)((bound4.sin_port >> 8) | (bound4.sin_port << 8));
	test::@check(port != 0, "the kernel should have assigned a port");

	receiver.recv_start(&on_alloc, &on_recv)!!;

	libuv::SockAddrIn target;
	libuv::ip4_addr("127.0.0.1", port, &target)!!;

	sender.init(&loop)!!;
	libuv::Buf[1] out = { libuv::buf(DATAGRAM.ptr[:DATAGRAM.len]) };
	sender.send(&send_req, &out, (libuv::SockAddr*)&target, &on_send)!!;

	loop.run()!!;

	test::@check(recv_errors == 0, "%d receive errors", recv_errors);
	char[libuv::NAME_BUFSIZE] name;
	test::@check(send_status == 0, "send finished with %s", ((libuv::ErrorCode)send_status).name_to(&name));
	test::@check(received_len == DATAGRAM.len, "received %d bytes, expected %d", received_len, DATAGRAM.len);
	test::@check(received[:received_len] == DATAGRAM, "the datagram came back changed");
	test::@check(had_addr, "the sender address was not reported");

	loop.close()!!;
}

fn void udp_options_are_accepted() @test
{
	Loop l;
	l.init()!!;

	Udp u;
	u.init(&l)!!;

	libuv::SockAddrIn addr;
	libuv::ip4_addr("127.0.0.1", 0, &addr)!!;
	u.bind((libuv::SockAddr*)&addr)!!;

	u.set_broadcast(true)!!;
	u.set_ttl(4)!!;
	u.set_multicast_loop(false)!!;
	u.set_multicast_ttl(1)!!;

	test::@check(u.get_send_queue_size() == 0);
	test::@check(u.get_send_queue_count() == 0);

	u.close();
	l.run()!!;
	l.close()!!;
}
