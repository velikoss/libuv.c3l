module libuv_test;
import std::core::test;
import libuv;

fn void abi_sizes_match() @test
{
	libuv::AbiMismatch[40] found;
	usz n = libuv::check_abi(&found);
	if (n)
	{
		usz shown = n < 40 ? n : 40;
		foreach (m : found[:shown])
		{
			test::@check(false, "%s: declared %d, libuv says %d", m.name, m.declared, m.actual);
		}
	}
	test::@check(n == 0, "%d type sizes disagree with the linked libuv", n);
}

fn void version_is_the_bound_one() @test
{
	CUInt[3] v = libuv::version();
	test::@check(libuv::version_matches(),
		"linked libuv %d.%d.%d, these declarations were transcribed from %d.%d.x",
		v[0], v[1], v[2], libuv::BOUND_VERSION_MAJOR, libuv::BOUND_VERSION_MINOR);
}

fn void handle_and_req_sizes_are_reported() @test
{
	test::@check(libuv::handle_size(libuv::HandleType.TCP) == Tcp::size);
	test::@check(libuv::req_size(libuv::ReqType.WRITE) == Write::size);
	test::@check(libuv::loop_size() == Loop::size);
}

fn void subtyping_keeps_the_base_at_offset_zero() @test
{
	Tcp tcp;
	Stream* as_stream = &tcp;
	Handle* as_handle = &tcp;
	test::@check((void*)as_stream == (void*)&tcp);
	test::@check((void*)as_handle == (void*)&tcp);

	Write w;
	Req* as_req = &w;
	test::@check((void*)as_req == (void*)&w);
}

fn void handle_type_names_line_up() @test
{
	test::@check(libuv::handle_type_name(libuv::HandleType.TCP) == "tcp");
	test::@check(libuv::handle_type_name(libuv::HandleType.TIMER) == "timer");
	test::@check(libuv::handle_type_name(libuv::HandleType.NAMED_PIPE) == "pipe");
	test::@check(libuv::handle_type_name(libuv::HandleType.SIGNAL) == "signal");
	test::@check(libuv::req_type_name(libuv::ReqType.WRITE) == "write");
	test::@check(libuv::req_type_name(libuv::ReqType.GETNAMEINFO) == "getnameinfo");
	test::@check(libuv::req_type_name(libuv::ReqType.RANDOM) == "random");
}
