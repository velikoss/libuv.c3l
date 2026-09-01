module libuv_loop_test;
import std::core::test;
import libuv;

int timer_ticks;
int idle_ticks;
int prepare_ticks;
int check_ticks;
int async_ticks;
int closed_handles;

fn void on_close(libuv::Handle* h) @local
{
	closed_handles++;
}

fn void on_timer(libuv::Timer* t) @local
{
	timer_ticks++;
	if (timer_ticks == 3) t.close(&on_close);
}

fn void repeating_timer_fires_then_closes() @test
{
	timer_ticks = 0;
	closed_handles = 0;

	Loop loop;
	loop.init()!!;

	Timer timer;
	timer.init(&loop)!!;
	timer.start(&on_timer, 1, 1)!!;
	test::@check(timer.is_active());

	bool still_alive = loop.run()!!;
	test::@check(!still_alive, "the loop should have run out of work");
	test::@check(timer_ticks == 3, "expected 3 ticks, got %d", timer_ticks);
	test::@check(closed_handles == 1);
	loop.close()!!;
}

fn void one_shot_timer_fires_once() @test
{
	timer_ticks = 0;
	closed_handles = 0;

	Loop loop;
	loop.init()!!;

	Timer timer;
	timer.init(&loop)!!;
	timer.start(fn void(libuv::Timer* t) { timer_ticks++; }, 1)!!;
	loop.run()!!;

	test::@check(timer_ticks == 1);
	test::@check(!timer.is_active());
	timer.close(&on_close);
	loop.run()!!;
	test::@check(closed_handles == 1);
	loop.close()!!;
}

fn void timer_repeat_is_readable() @test
{
	Loop loop;
	loop.init()!!;
	Timer timer;
	timer.init(&loop)!!;
	timer.start(fn void(libuv::Timer* t) {}, 1000, 250)!!;
	test::@check(timer.get_repeat() == 250);
	timer.set_repeat(500);
	test::@check(timer.get_repeat() == 500);
	test::@check(timer.get_due_in() > 0);
	timer.stop()!!;
	timer.close();
	loop.run()!!;
	loop.close()!!;
}

fn void unref_lets_the_loop_finish() @test
{
	Loop loop;
	loop.init()!!;

	Timer timer;
	timer.init(&loop)!!;
	timer.start(fn void(libuv::Timer* t) {}, 60_000, 60_000)!!;
	test::@check(loop.alive());

	timer.unref();
	test::@check(!timer.has_ref());
	bool alive = loop.run()!!;
	test::@check(!alive);

	timer.ref();
	timer.stop()!!;
	timer.close();
	loop.run()!!;
	loop.close()!!;
}

libuv::Prepare* shared_prepare @local;
libuv::Check* shared_check @local;

fn void on_idle(libuv::Idle* h) @local
{
	idle_ticks++;
	if (idle_ticks < 5) return;
	h.stop()!!;
	shared_prepare.stop()!!;
	shared_check.stop()!!;
}

fn void idle_prepare_and_check_all_run() @test
{
	idle_ticks = 0;
	prepare_ticks = 0;
	check_ticks = 0;

	Loop loop;
	loop.init()!!;

	Idle idle;
	Prepare prepare;
	Check chk;
	idle.init(&loop)!!;
	prepare.init(&loop)!!;
	chk.init(&loop)!!;
	shared_prepare = &prepare;
	shared_check = &chk;

	idle.start(&on_idle)!!;
	prepare.start(fn void(libuv::Prepare* h) { prepare_ticks++; })!!;
	chk.start(fn void(libuv::Check* h) { check_ticks++; })!!;

	loop.run()!!;

	test::@check(idle_ticks == 5, "idle ran %d times", idle_ticks);
	test::@check(prepare_ticks == 4, "prepare ran %d times", prepare_ticks);
	test::@check(check_ticks == 4, "check ran %d times", check_ticks);

	idle.close();
	prepare.close();
	chk.close();
	loop.run()!!;
	loop.close()!!;
}

fn void on_async(libuv::Async* a) @local
{
	async_ticks++;
	a.close(&on_close);
}

fn void async_wakes_the_loop_from_another_thread() @test
{
	async_ticks = 0;
	closed_handles = 0;

	Loop loop;
	loop.init()!!;

	Async async;
	async.init(&loop, &on_async)!!;
	shared_async = &async;

	libuv::Thread tid;
	libuv::thread_create(&tid, fn void(void* arg)
	{
		libuv::sleep(20);
		(void)shared_async.send();
	})!!;

	loop.run()!!;
	libuv::thread_join(&tid)!!;

	test::@check(async_ticks == 1, "the async callback ran %d times", async_ticks);
	test::@check(closed_handles == 1);
	loop.close()!!;
}

libuv::Async* shared_async @local;

fn void walk_sees_every_handle() @test
{
	Loop loop;
	loop.init()!!;

	Timer a;
	Timer b;
	a.init(&loop)!!;
	b.init(&loop)!!;

	walked = 0;
	loop.walk(fn void(libuv::Handle* h, void* arg) { walked++; });
	test::@check(walked == 2, "walk saw %d handles", walked);

	a.close();
	b.close();
	loop.run()!!;
	loop.close()!!;
}

int walked @local;

fn void closing_twice_is_visible_through_is_closing() @test
{
	Loop loop;
	loop.init()!!;
	Timer t;
	t.init(&loop)!!;
	test::@check(!t.is_closing());
	t.close();
	test::@check(t.is_closing(), "the handle should report itself as closing right away");
	loop.run()!!;
	loop.close()!!;
}

fn void close_before_run_still_reports_ebusy() @test
{
	Loop loop;
	loop.init()!!;
	Timer t;
	t.init(&loop)!!;
	t.close();
	if (catch err = loop.close())
	{
		test::@check(err == libuv::EBUSY, "expected EBUSY while a handle is still closing");
	}
	else
	{
		test::@check(false, "closing a busy loop should fail");
	}
	loop.run()!!;
	loop.close()!!;
}

fn void loop_time_moves_forward() @test
{
	Loop loop;
	loop.init()!!;
	ulong t0 = loop.now();
	libuv::sleep(5);
	loop.update_time();
	test::@check(loop.now() >= t0, "loop time went backwards");
	loop.close()!!;
}

fn void hrtime_moves_forward() @test
{
	ulong a = libuv::hrtime();
	libuv::sleep(1);
	ulong b = libuv::hrtime();
	test::@check(b > a, "hrtime did not advance");
}
