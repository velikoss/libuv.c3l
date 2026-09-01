module libuv_tcp_test;
import std::core::test;
import libuv;
import std::net::os;

const String PAYLOAD = "hello over the loopback";

Loop loop @local;
Tcp server @local;
Tcp client @local;
Tcp conn @local;
Connect connect_req @local;
Write client_write @local;
Write server_write @local;
Shutdown shutdown_req @local;

char[256] server_buf @local;
char[256] client_buf @local;
char[256] echoed @local;
usz echoed_len @local;

int connections @local;
int closes @local;
int write_errors @local;
int read_errors @local;

fn void on_close(libuv::Handle* h) @local
{
	closes++;
}

fn void on_alloc(libuv::Handle* h, usz suggested, libuv::Buf* buf) @local
{
	*buf = h == (libuv::Handle*)&conn
		? libuv::buf(&server_buf)
		: libuv::buf(&client_buf);
}

fn void on_server_write(libuv::Write* req, CInt status) @local
{
	if (status < 0) write_errors++;
}

fn void on_server_read(libuv::Stream* s, sz nread, libuv::Buf* buf) @local
{
	if (nread == (sz)libuv::EOF_CODE)
	{
		s.close(&on_close);
		return;
	}
	if (nread < 0)
	{
		read_errors++;
		s.close(&on_close);
		return;
	}
	if (nread == 0) return;

	libuv::Buf[1] out = { libuv::buf(buf.base[:(usz)nread]) };
	(void)s.write(&server_write, &out, &on_server_write);
}

fn void on_client_read(libuv::Stream* s, sz nread, libuv::Buf* buf) @local
{
	if (nread < 0)
	{
		if (nread != (sz)libuv::EOF_CODE) read_errors++;
		s.close(&on_close);
		conn.close(&on_close);
		server.close(&on_close);
		return;
	}
	if (nread == 0) return;

	usz n = (usz)nread;
	if (echoed_len + n <= echoed.len)
	{
		echoed[echoed_len:n] = buf.base[:n];
		echoed_len += n;
	}
	if (echoed_len >= PAYLOAD.len)
	{
		s.close(&on_close);
		conn.close(&on_close);
		server.close(&on_close);
	}
}

fn void on_client_write(libuv::Write* req, CInt status) @local
{
	if (status < 0)
	{
		write_errors++;
		return;
	}
	(void)req.handle.read_start(&on_alloc, &on_client_read);
}

fn void on_connect(libuv::Connect* req, CInt status) @local
{
	if (status < 0)
	{
		write_errors++;
		return;
	}
	libuv::Buf[1] out = { libuv::buf(PAYLOAD.ptr[:PAYLOAD.len]) };
	(void)req.handle.write(&client_write, &out, &on_client_write);
}

fn void on_connection(libuv::Stream* srv, CInt status) @local
{
	if (status < 0)
	{
		read_errors++;
		return;
	}
	connections++;
	if (catch conn.init(&loop))
	{
		read_errors++;
		return;
	}
	if (catch srv.accept(&conn))
	{
		read_errors++;
		return;
	}
	(void)conn.read_start(&on_alloc, &on_server_read);
}

fn void tcp_echo_round_trip() @test
{
	connections = 0;
	closes = 0;
	write_errors = 0;
	read_errors = 0;
	echoed_len = 0;

	loop.init()!!;

	libuv::SockAddrIn bind_addr;
	libuv::ip4_addr("127.0.0.1", 0, &bind_addr)!!;

	server.init(&loop)!!;
	server.bind((libuv::SockAddr*)&bind_addr)!!;

	libuv::SockAddrStorage bound;
	CInt bound_len = libuv::SockAddrStorage::size;
	server.getsockname((libuv::SockAddr*)&bound, &bound_len)!!;
	test::@check(bound_len >= libuv::SockAddrIn::size, "getsockname wrote %d bytes", bound_len);

	libuv::SockAddrIn* bound4 = (libuv::SockAddrIn*)&bound;
	CInt port = (CInt)bswap_16(bound4.sin_port);
	test::@check(port != 0, "the kernel should have assigned a port");

	server.listen(1, &on_connection)!!;

	libuv::SockAddrIn target;
	libuv::ip4_addr("127.0.0.1", port, &target)!!;
	client.init(&loop)!!;
	client.connect(&connect_req, (libuv::SockAddr*)&target, &on_connect)!!;

	loop.run()!!;

	test::@check(write_errors == 0, "%d write or connect errors", write_errors);
	test::@check(read_errors == 0, "%d read or accept errors", read_errors);
	test::@check(connections == 1, "the server accepted %d connections", connections);
	test::@check(echoed_len == PAYLOAD.len, "got %d bytes back, expected %d", echoed_len, PAYLOAD.len);
	test::@check(echoed[:echoed_len] == PAYLOAD, "the echoed bytes differ from what was sent");
	test::@check(closes == 3, "%d of 3 handles reported closed", closes);

	loop.close()!!;
}

fn ushort bswap_16(ushort v) @local => (ushort)((v >> 8) | (v << 8));

fn void tcp_options_are_accepted() @test
{
	Loop l;
	l.init()!!;
	Tcp t;
	t.init_ex(&l, (CUInt)(CInt)os::AF_INET)!!;
	t.nodelay(true)!!;
	t.keepalive(true, 60)!!;
	t.keepalive(false)!!;
	t.simultaneous_accepts(true)!!;

	CInt sndbuf = 0;
	t.send_buffer_size(&sndbuf)!!;
	test::@check(sndbuf > 0, "send buffer size came back as %d", sndbuf);

	t.close();
	l.run()!!;
	l.close()!!;
}

fn void getpeername_on_an_unconnected_socket_fails() @test
{
	Loop l;
	l.init()!!;
	Tcp t;
	t.init(&l)!!;

	libuv::SockAddrStorage ss;
	CInt len = libuv::SockAddrStorage::size;
	if (catch err = t.getpeername((libuv::SockAddr*)&ss, &len))
	{
		test::@check(err == libuv::ENOTCONN || err == libuv::EINVAL || err == libuv::EBADF,
			"unexpected fault from getpeername on an unconnected socket");
	}
	else
	{
		test::@check(false, "getpeername should fail before connect");
	}

	t.close();
	l.run()!!;
	l.close()!!;
}

fn void ip4_addr_round_trips_through_ip4_name() @test
{
	libuv::SockAddrIn addr;
	libuv::ip4_addr("192.0.2.7", 8080, &addr)!!;
	test::@check(bswap_16(addr.sin_port) == 8080, "port came back as %d", bswap_16(addr.sin_port));

	char[46] text;
	libuv::ip4_name(&addr, &text)!!;
	test::@check(((ZString)&text).str_view() == "192.0.2.7", "formatted as %s", (ZString)&text);
}

fn void ip6_addr_round_trips_through_ip6_name() @test
{
	libuv::SockAddrIn6 addr;
	libuv::ip6_addr("::1", 443, &addr)!!;
	test::@check(bswap_16(addr.sin6_port) == 443);

	char[46] text;
	libuv::ip6_name(&addr, &text)!!;
	test::@check(((ZString)&text).str_view() == "::1", "formatted as %s", (ZString)&text);
}

fn void a_bad_address_is_rejected() @test
{
	libuv::SockAddrIn addr;
	if (catch err = libuv::ip4_addr("not an address", 80, &addr))
	{
		test::@check(err == libuv::EINVAL, "expected EINVAL");
	}
	else
	{
		test::@check(false, "ip4_addr should reject a non-address");
	}
}
