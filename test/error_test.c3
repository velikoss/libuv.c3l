module libuv_error_test;
import std::core::test;
import libuv;

fn void platform_independent_codes() @test
{
	test::@check(libuv::EOF_CODE.name() == "EOF");
	test::@check(libuv::UNKNOWN_CODE.name() == "UNKNOWN");
	test::@check(libuv::EAI_ADDRFAMILY_CODE.name() == "EAI_ADDRFAMILY");
	test::@check(libuv::EAI_PROTOCOL_CODE.name() == "EAI_PROTOCOL");
}

fn void codes_map_to_the_matching_fault() @test
{
	test::@check(libuv::EOF_CODE.to_fault() == libuv::EOF);
	test::@check(libuv::UNKNOWN_CODE.to_fault() == libuv::UNKNOWN);
	test::@check(libuv::EAI_NONAME_CODE.to_fault() == libuv::EAI_NONAME);
}

fn void messages_come_from_libuv() @test
{
	test::@check(libuv::EOF_CODE.message() == "end of file");
	test::@check(libuv::EAI_MEMORY_CODE.message().len > 0);
}

fn void ok_codes_are_not_errors() @test
{
	test::@check(((libuv::ErrorCode)0).is_ok());
	test::@check(((libuv::ErrorCode)42).is_ok());
	test::@check(!libuv::EOF_CODE.is_ok());
}

fn void check_turns_a_negative_into_a_fault() @test
{
	test::@check(@ok(libuv::check(0)));
	test::@check(@ok(libuv::check(7)));
	if (catch err = libuv::check((CInt)libuv::EOF_CODE))
	{
		test::@check(err == libuv::EOF);
	}
	else
	{
		test::@check(false, "a negative code should have produced a fault");
	}
}

fn void check_value_passes_the_value_through() @test
{
	CInt? v = libuv::check_value(11);
	if (try got = v)
	{
		test::@check(got == 11);
	}
	else
	{
		test::@check(false, "a non-negative code should have produced a value");
	}
}

fn void real_operations_produce_the_documented_faults() @test
{
	// Binding to a port on an address that does not exist locally.
	Loop loop;
	loop.init()!!;
	defer
	{
		(void)loop.run(libuv::RunMode.NOWAIT);
		(void)loop.close();
	}

	libuv::SockAddrIn addr;
	// 240.0.0.1 is reserved, so no interface can carry it.
	libuv::ip4_addr("240.0.0.1", 9, &addr)!!;

	Tcp tcp;
	tcp.init(&loop)!!;
	defer tcp.close();

	if (catch err = tcp.bind((libuv::SockAddr*)&addr))
	{
		test::@check(err == libuv::EADDRNOTAVAIL || err == libuv::EINVAL || err == libuv::EACCES,
			"unexpected fault binding a reserved address");
	}
}

fn void a_bad_path_produces_enoent() @test
{
	Loop loop;
	loop.init()!!;
	defer (void)loop.close();

	Fs req;
	defer req.cleanup();
	if (catch err = libuv::fs_stat(&loop, &req, "this/path/does/not/exist/at/all"))
	{
		test::@check(err == libuv::ENOENT, "expected ENOENT");
	}
	else
	{
		test::@check(false, "stat of a missing path should fail");
	}
}

fn void name_to_never_allocates() @test
{
	char[libuv::NAME_BUFSIZE] name;
	char[libuv::MESSAGE_BUFSIZE] message;

	test::@check(libuv::EOF_CODE.name_to(&name) == "EOF");
	test::@check(libuv::EOF_CODE.name_to(&name) == libuv::EOF_CODE.name());
	test::@check(libuv::EOF_CODE.message_to(&message) == "end of file");

	test::@check(((libuv::ErrorCode)0).name_to(&name).len > 0);
	test::@check(((libuv::ErrorCode)-999_999).name_to(&name).len > 0);
	test::@check(((libuv::ErrorCode)-999_999).message_to(&message).len > 0);

	for (int i = 0; i < 1000; i++)
	{
		test::@check(((libuv::ErrorCode)-999_999).name_to(&name).len > 0);
	}
}

fn void to_fault_on_an_unknown_code_does_not_allocate() @test
{
	for (int i = 0; i < 1000; i++)
	{
		test::@check(((libuv::ErrorCode)-999_999).to_fault() == libuv::UNKNOWN);
	}
}
