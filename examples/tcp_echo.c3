<*
 A TCP echo server.
 Run it, then talk to it with `nc 127.0.0.1 7000`.
*>
module example_tcp_echo;
import std::io;
import libuv;

const CInt PORT = 7000;
const usz MAX_CLIENTS = 64;

// One slot per client. A real server would allocate these; this keeps the
// example free of an allocator so that the libuv part stays in focus.
struct Client
{
	Tcp handle;
	Write write_req;
	char[4096] buf;
	bool in_use;
}

Client[MAX_CLIENTS] clients;
Tcp server;
Loop loop;

fn Client* take_slot()
{
	foreach (&c : clients)
	{
		if (!c.in_use)
		{
			c.in_use = true;
			return c;
		}
	}
	return null;
}

fn void on_client_closed(libuv::Handle* h)
{
	Client* c = (Client*)h;
	c.in_use = false;
	io::printn("client gone");
}

fn void on_alloc(libuv::Handle* h, usz suggested, libuv::Buf* buf)
{
	Client* c = (Client*)h;
	*buf = libuv::buf(&c.buf);
}

fn void on_write(libuv::Write* req, CInt status)
{
	if (status < 0) io::printfn("write failed: %s", ((libuv::ErrorCode)status).message());
}

fn void on_read(libuv::Stream* s, sz nread, libuv::Buf* buf)
{
	if (nread < 0)
	{
		if (nread != (sz)libuv::EOF_CODE)
		{
			io::printfn("read failed: %s", ((libuv::ErrorCode)(CInt)nread).message());
		}
		s.close(&on_client_closed);
		return;
	}
	if (nread == 0) return;

	// The data sits in the client's own buffer, which stays alive until the
	// client is closed, so it is safe to hand straight back to uv_write.
	Client* c = (Client*)s;
	libuv::Buf[1] out = { libuv::buf(buf.base[:(usz)nread]) };
	if (catch err = s.write(&c.write_req, &out, &on_write))
	{
		io::printfn("queueing a write failed: %s", err);
		s.close(&on_client_closed);
	}
}

fn void on_connection(libuv::Stream* srv, CInt status)
{
	if (status < 0)
	{
		io::printfn("accept failed: %s", ((libuv::ErrorCode)status).message());
		return;
	}

	Client* c = take_slot();
	if (!c)
	{
		io::printn("out of client slots, dropping the connection");
		return;
	}

	if (catch err = c.handle.init(&loop))
	{
		io::printfn("client init failed: %s", err);
		c.in_use = false;
		return;
	}
	if (catch err = srv.accept(&c.handle))
	{
		io::printfn("accept failed: %s", err);
		c.handle.close(&on_client_closed);
		return;
	}

	io::printn("client connected");
	if (catch err = c.handle.read_start(&on_alloc, &on_read))
	{
		io::printfn("read_start failed: %s", err);
		c.handle.close(&on_client_closed);
	}
}

fn int main(String[] args)
{
	// Catch a mismatch between these declarations and the linked libuv before
	// it turns into memory corruption.
	if (catch libuv::assert_abi())
	{
		io::eprintn("libuv layouts do not match this binding; see tools/README.md");
		return 1;
	}

	loop.init()!!;

	libuv::SockAddrIn addr;
	libuv::ip4_addr("0.0.0.0", PORT, &addr)!!;

	server.init(&loop)!!;
	server.bind((libuv::SockAddr*)&addr)!!;
	server.listen(128, &on_connection)!!;

	io::printfn("echoing on port %d", PORT);
	loop.run()!!;
	loop.close()!!;
	return 0;
}
