module libuv_work_test;
import std::core::test;
import libuv;
import std::net::os;

Loop loop @local;
Work work_req @local;
GetAddrInfo dns_req @local;
Random random_req @local;

int worker_ran @local;
int after_ran @local;
int after_status @local;
libuv::Thread worker_thread @local;
libuv::Thread main_thread @local;

int dns_status @local;
int dns_results @local;
char[32] entropy @local;
int random_status @local;

fn void do_work(libuv::Work* req) @local
{
	worker_thread = libuv::thread_self();
	worker_ran++;
}

fn void after_work(libuv::Work* req, CInt status) @local
{
	after_status = status;
	after_ran++;
}

fn void queue_work_runs_off_the_loop_thread() @test
{
	worker_ran = 0;
	after_ran = 0;
	after_status = 0;
	main_thread = libuv::thread_self();

	loop.init()!!;
	libuv::queue_work(&loop, &work_req, &do_work, &after_work)!!;
	loop.run()!!;

	test::@check(worker_ran == 1, "the work callback ran %d times", worker_ran);
	test::@check(after_ran == 1, "the completion callback ran %d times", after_ran);
	test::@check(after_status == 0, "completion status was %d", after_status);
	test::@check(!libuv::thread_equal(&worker_thread, &main_thread),
		"the work callback ran on the loop thread");
	loop.close()!!;
}

fn void on_addrinfo(libuv::GetAddrInfo* req, CInt status, libuv::AddrInfo* res) @local
{
	dns_status = status;
	for (libuv::AddrInfo* a = res; a; a = a.ai_next) dns_results++;
	libuv::freeaddrinfo(res);
}

fn void getaddrinfo_resolves_localhost() @test
{
	dns_status = 0;
	dns_results = 0;

	Loop l;
	l.init()!!;
	libuv::getaddrinfo(&l, &dns_req, &on_addrinfo, "localhost", "")!!;
	l.run()!!;

	char[libuv::NAME_BUFSIZE] name;
	test::@check(dns_status == 0, "resolving localhost failed with %s",
		((libuv::ErrorCode)dns_status).name_to(&name));
	test::@check(dns_results > 0, "localhost resolved to %d addresses", dns_results);
	l.close()!!;
}

fn void getaddrinfo_reports_a_bad_name() @test
{
	dns_status = 0;
	dns_results = 0;

	Loop l;
	l.init()!!;

	libuv::AddrInfo hints;
	hints.ai_family = os::AF_UNSPEC;
	hints.ai_socktype = os::SOCK_STREAM;
	hints.ai_flags = os::AI_NUMERICHOST;

	libuv::getaddrinfo(&l, &dns_req, &on_addrinfo, "definitely-not-an-ip", "", &hints)!!;
	l.run()!!;

	test::@check(dns_status != 0, "a non-numeric host should be rejected under AI_NUMERICHOST");
	l.close()!!;
}

fn void on_random(libuv::Random* req, CInt status, void* buf, usz buflen) @local
{
	random_status = status;
}

fn void random_fills_the_buffer() @test
{
	random_status = 0;
	entropy = {};

	Loop l;
	l.init()!!;
	libuv::random(&l, &random_req, &entropy, 0, &on_random)!!;
	l.run()!!;

	char[libuv::NAME_BUFSIZE] name;
	test::@check(random_status == 0, "uv_random failed with %s",
		((libuv::ErrorCode)random_status).name_to(&name));

	bool all_zero = true;
	foreach (c : entropy) if (c != 0) all_zero = false;
	test::@check(!all_zero, "the entropy buffer came back untouched");
	l.close()!!;
}

fn void system_information_is_readable() @test
{
	test::@check(libuv::available_parallelism() >= 1);
	test::@check(libuv::get_total_memory() > 0);
	test::@check(libuv::hrtime() > 0);

	libuv::Utsname un;
	libuv::os_uname(&un)!!;
	test::@check(((ZString)&un.sysname).str_view().len > 0, "uname gave an empty sysname");

	char[libuv::MAXHOSTNAMESIZE] host;
	usz size = host.len;
	libuv::os_gethostname(&host, &size)!!;
	test::@check(size > 0, "the hostname came back empty");

	libuv::CpuInfo* cpus;
	CInt count;
	libuv::cpu_info(&cpus, &count)!!;
	defer libuv::free_cpu_info(cpus, count);
	test::@check(count >= 1, "cpu_info reported %d CPUs", count);
	test::@check(cpus[0].model.str_view().len > 0, "the first CPU has no model string");

	libuv::Rusage ru;
	libuv::getrusage(&ru)!!;

	libuv::TimeVal64 tv;
	libuv::gettimeofday(&tv)!!;
	test::@check(tv.tv_sec > 1_600_000_000, "the wall clock reads %d seconds since the epoch", tv.tv_sec);

	libuv::TimeSpec64 ts;
	libuv::clock_gettime(libuv::ClockId.MONOTONIC, &ts)!!;
	test::@check(ts.tv_sec > 0 || ts.tv_nsec > 0);
}

fn void environment_round_trips() @test
{
	libuv::os_setenv("LIBUV_C3L_TEST", "present")!!;

	char[64] value;
	usz size = value.len;
	libuv::os_getenv("LIBUV_C3L_TEST", &value, &size)!!;
	test::@check(value[:size] == "present", "read back %s", (String)value[:size]);

	libuv::os_unsetenv("LIBUV_C3L_TEST")!!;
	size = value.len;
	if (catch err = libuv::os_getenv("LIBUV_C3L_TEST", &value, &size))
	{
		test::@check(err == libuv::ENOENT, "expected ENOENT after unsetenv");
	}
	else
	{
		test::@check(false, "the variable should be gone after unsetenv");
	}
}

fn void mutex_and_semaphore_work() @test
{
	libuv::Mutex m;
	m.init()!!;
	m.lock();
	if (catch err = m.trylock())
	{
		test::@check(err == libuv::EBUSY || err == libuv::EAGAIN);
	}
	m.unlock();
	m.trylock()!!;
	m.unlock();
	m.destroy();

	libuv::Sem s;
	s.init(1)!!;
	s.wait();
	if (catch err = s.trywait())
	{
		test::@check(err == libuv::EAGAIN);
	}
	else
	{
		test::@check(false, "a drained semaphore should not be acquirable");
	}
	s.post();
	s.trywait()!!;
	s.post();
	s.destroy();

	libuv::RwLock rw;
	rw.init()!!;
	rw.rdlock();
	rw.rdunlock();
	rw.wrlock();
	rw.wrunlock();
	rw.destroy();
}

fn void thread_local_storage_is_per_thread() @test
{
	libuv::Key key;
	key.create()!!;
	defer key.delete();

	test::@check(key.get() == null, "a fresh key should read as null");
	key.set((void*)(uptr)0xC3);
	test::@check(key.get() == (void*)(uptr)0xC3);

	shared_key = &key;
	other_thread_value = (void*)(uptr)0xFFFF;

	libuv::Thread tid;
	libuv::thread_create(&tid, fn void(void* arg)
	{
		other_thread_value = shared_key.get();
	})!!;
	libuv::thread_join(&tid)!!;

	test::@check(other_thread_value == null, "the key leaked across threads");
	test::@check(key.get() == (void*)(uptr)0xC3, "this thread's value was disturbed");
}

libuv::Key* shared_key @local;
void* other_thread_value @local;
