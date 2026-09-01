module libuv_stream_stress_test;
import std::core::test;
import libuv;

const usz CHUNKS = 200;
const usz CHUNK_LEN = 7;
const usz VECTOR_PARTS = 9;

Loop loop @local;
Tcp server @local;
Tcp client @local;
Tcp conn @local;
Connect connect_req @local;

// one request per queued write
// they all have to stay alive until their callbacks have run.
Write[CHUNKS] writes @local;
libuv::Buf[CHUNKS] write_bufs @local;
char[CHUNKS * CHUNK_LEN] source @local;

char[4096] recv_scratch @local;
char[CHUNKS * CHUNK_LEN + 64] sink @local;
usz sink_len @local;

usz writes_done @local;
int write_errors @local;
int read_errors @local;
usz expected_len @local;

fn void on_alloc(libuv::Handle* h, usz suggested, libuv::Buf* buf) @local
{
	*buf = libuv::buf(&recv_scratch);
}

fn void on_write(libuv::Write* req, CInt status) @local
{
	if (status < 0) write_errors++;
	writes_done++;
}

fn void on_server_read(libuv::Stream* s, sz nread, libuv::Buf* buf) @local
{
	if (nread < 0)
	{
		if (nread != (sz)libuv::EOF_CODE) read_errors++;
		s.close();
		client.close();
		server.close();
		return;
	}
	if (nread == 0) return;

	usz n = (usz)nread;
	if (sink_len + n <= sink.len)
	{
		sink[sink_len:n] = buf.base[:n];
		sink_len += n;
	}
	else
	{
		read_errors++;
	}

	if (sink_len >= expected_len)
	{
		s.close();
		client.close();
		server.close();
	}
}

fn void on_connection(libuv::Stream* srv, CInt status) @local
{
	if (status < 0)
	{
		read_errors++;
		return;
	}
	if (catch conn.init(&loop)) { read_errors++; return; }
	if (catch srv.accept(&conn)) { read_errors++; return; }
	(void)conn.read_start(&on_alloc, &on_server_read);
}

int mode @local;
const int MODE_MANY_WRITES = 0;
const int MODE_LONG_VECTOR = 1;

fn void on_connect(libuv::Connect* req, CInt status) @local
{
	if (status < 0)
	{
		write_errors++;
		return;
	}
	if (mode == MODE_MANY_WRITES)
	{
		for (usz i = 0; i < CHUNKS; i++)
		{
			write_bufs[i] = libuv::buf(source[i * CHUNK_LEN : CHUNK_LEN]);
			if (catch req.handle.write(&writes[i], write_bufs[i : 1], &on_write)) write_errors++;
		}
		return;
	}

	for (usz i = 0; i < VECTOR_PARTS; i++)
	{
		write_bufs[i] = libuv::buf(source[i * CHUNK_LEN : CHUNK_LEN]);
	}
	if (catch req.handle.write(&writes[0], write_bufs[:VECTOR_PARTS], &on_write)) write_errors++;
}

fn void setup() @local
{
	write_errors = 0;
	read_errors = 0;
	writes_done = 0;
	sink_len = 0;
	for (usz i = 0; i < source.len; i++) source[i] = (char)('a' + (char)(i % 26));
}

fn CInt start_server() @local
{
	loop.init()!!;

	libuv::SockAddrIn bind_addr;
	libuv::ip4_addr("127.0.0.1", 0, &bind_addr)!!;
	server.init(&loop)!!;
	server.bind((libuv::SockAddr*)&bind_addr)!!;

	libuv::SockAddrStorage bound;
	CInt bound_len = libuv::SockAddrStorage::size;
	server.getsockname((libuv::SockAddr*)&bound, &bound_len)!!;
	libuv::SockAddrIn* b4 = (libuv::SockAddrIn*)&bound;
	CInt port = (CInt)((b4.sin_port >> 8) | (b4.sin_port << 8));

	server.listen(1, &on_connection)!!;

	libuv::SockAddrIn target;
	libuv::ip4_addr("127.0.0.1", port, &target)!!;
	client.init(&loop)!!;
	client.connect(&connect_req, (libuv::SockAddr*)&target, &on_connect)!!;
	return port;
}

fn void two_hundred_queued_writes_arrive_in_order() @test
{
	setup();
	mode = MODE_MANY_WRITES;
	expected_len = CHUNKS * CHUNK_LEN;

	start_server();
	loop.run()!!;

	test::@check(write_errors == 0, "%d writes failed", write_errors);
	test::@check(read_errors == 0, "%d read errors", read_errors);
	test::@check(writes_done == CHUNKS, "%d of %d write callbacks ran", writes_done, CHUNKS);
	test::@check(sink_len == expected_len, "received %d bytes, expected %d", sink_len, expected_len);
	test::@check(sink[:expected_len] == source[:expected_len], "the byte stream came back changed");

	loop.close()!!;
}

fn void a_nine_buffer_vector_is_written_whole() @test
{
	setup();
	mode = MODE_LONG_VECTOR;
	expected_len = VECTOR_PARTS * CHUNK_LEN;

	start_server();
	loop.run()!!;

	test::@check(write_errors == 0, "%d writes failed", write_errors);
	test::@check(read_errors == 0, "%d read errors", read_errors);
	test::@check(writes_done == 1, "%d write callbacks ran, expected 1", writes_done);
	test::@check(sink_len == expected_len, "received %d bytes, expected %d", sink_len, expected_len);
	test::@check(sink[:expected_len] == source[:expected_len], "the vectored write came back changed");

	loop.close()!!;
}
