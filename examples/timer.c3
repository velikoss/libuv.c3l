<*
 Small program to demo working libuv
*>
module example_timer;
import std::io;
import libuv;

int ticks;

fn void on_tick(libuv::Timer* timer)
{
	ticks++;
	io::printfn("tick %d", ticks);
	if (ticks == 5) timer.close();
}

fn int main(String[] args)
{
	Loop loop;
	loop.init()!!;

	Timer timer;
	timer.init(&loop)!!;
	timer.start(&on_tick, 100, 100)!!;

	loop.run()!!;
	loop.close()!!;
	return 0;
}
