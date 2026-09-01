module libuv_fs_test;
import std::core::test;
import libuv;
import std::io;

const String CONTENT = "libuv.c3l filesystem round trip";

Loop loop @local;
Fs open_req @local;
Fs write_req @local;
Fs read_req @local;
Fs close_req @local;
Fs stat_req @local;
Fs unlink_req @local;

char[128] read_back @local;
usz read_len @local;
int async_errors @local;
int async_steps @local;
libuv::Fd async_fd @local;
char[64] tmpdir @local;

fn String temp_path(String name) @local
{
	usz size = tmpdir.len;
	libuv::os_tmpdir(&tmpdir, &size)!!;
	String dir = (String)tmpdir[:size];
	return string::tformat("%s%s%s", dir, dir.ends_with("/") || dir.ends_with("\\") ? "" : "/", name);
}

fn void sync_write_then_read_back() @test
{
	loop.init()!!;
	defer (void)loop.close();

	String path = temp_path("libuv_c3l_sync.txt");

	CInt fd = libuv::fs_open(&loop, &open_req, path,
		libuv::O_CREAT | libuv::O_TRUNC | libuv::O_RDWR)!!;
	open_req.cleanup();
	test::@check(fd >= 0, "open returned %d", fd);

	libuv::Buf[1] out = { libuv::buf(CONTENT.ptr[:CONTENT.len]) };
	CInt written = libuv::fs_write(&loop, &write_req, fd, &out, 0)!!;
	write_req.cleanup();
	test::@check(written == (CInt)CONTENT.len, "wrote %d of %d bytes", written, CONTENT.len);

	libuv::Buf[1] in = { libuv::buf(&read_back) };
	CInt got = libuv::fs_read(&loop, &read_req, fd, &in, 0)!!;
	read_req.cleanup();
	test::@check(got == (CInt)CONTENT.len, "read %d of %d bytes", got, CONTENT.len);
	test::@check(read_back[:CONTENT.len] == CONTENT, "the bytes read differ from the bytes written");

	libuv::fs_fstat(&loop, &stat_req, fd)!!;
	libuv::Stat* st = stat_req.get_statbuf();
	test::@check(st.st_size == CONTENT.len, "fstat reports %d bytes, expected %d", st.st_size, CONTENT.len);
	stat_req.cleanup();

	libuv::fs_close(&loop, &close_req, fd)!!;
	close_req.cleanup();

	// stat by path should agree
	libuv::fs_stat(&loop, &stat_req, path)!!;
	test::@check(stat_req.get_statbuf().st_size == CONTENT.len);
	stat_req.cleanup();

	libuv::fs_unlink(&loop, &unlink_req, path)!!;
	unlink_req.cleanup();

	if (catch libuv::fs_stat(&loop, &stat_req, path))
	{
		// file is gone
	}
	else
	{
		test::@check(false, "the file should be gone after unlink");
	}
	stat_req.cleanup();
}

fn void on_close_done(libuv::Fs* req) @local
{
	if (catch req.status()) async_errors++;
	async_steps++;
	req.cleanup();
}

fn void on_read_done(libuv::Fs* req) @local
{
	sz? r = req.status();
	if (catch r)
	{
		async_errors++;
	}
	else
	{
		read_len = (usz)r;
	}
	async_steps++;
	req.cleanup();
	(void)libuv::fs_close(&loop, &close_req, async_fd, &on_close_done);
}

fn void on_write_done(libuv::Fs* req) @local
{
	if (catch req.status()) async_errors++;
	async_steps++;
	req.cleanup();

	libuv::Buf[1] in = { libuv::buf(&read_back) };
	(void)libuv::fs_read(&loop, &read_req, async_fd, &in, 0, &on_read_done);
}

fn void on_open_done(libuv::Fs* req) @local
{
	sz? r = req.status();
	if (catch r)
	{
		async_errors++;
		async_steps++;
		req.cleanup();
		return;
	}
	async_fd = (libuv::Fd)r;
	async_steps++;
	req.cleanup();

	libuv::Buf[1] out = { libuv::buf(CONTENT.ptr[:CONTENT.len]) };
	(void)libuv::fs_write(&loop, &write_req, async_fd, &out, 0, &on_write_done);
}

fn void async_write_then_read_back() @test
{
	async_errors = 0;
	async_steps = 0;
	read_len = 0;
	read_back = {};

	loop.init()!!;
	String path = temp_path("libuv_c3l_async.txt");

	libuv::fs_open(&loop, &open_req, path,
		libuv::O_CREAT | libuv::O_TRUNC | libuv::O_RDWR, 0o644, &on_open_done)!!;

	loop.run()!!;

	test::@check(async_errors == 0, "%d asynchronous steps failed", async_errors);
	test::@check(async_steps == 4, "%d of 4 callbacks ran", async_steps);
	test::@check(read_len == CONTENT.len, "read %d bytes, expected %d", read_len, CONTENT.len);
	test::@check(read_back[:CONTENT.len] == CONTENT);

	libuv::fs_unlink(&loop, &unlink_req, path)!!;
	unlink_req.cleanup();
	loop.close()!!;
}

fn void mkdir_scandir_and_rmdir() @test
{
	Loop l;
	l.init()!!;
	defer (void)l.close();

	String dir = temp_path("libuv_c3l_dir");
	Fs req;

	(void)libuv::fs_rmdir(&l, &req, dir);
	req.cleanup();

	libuv::fs_mkdir(&l, &req, dir)!!;
	req.cleanup();

	String inner = string::tformat("%s/inner.txt", dir);
	Fs f;
	CInt fd = libuv::fs_open(&l, &f, inner, libuv::O_CREAT | libuv::O_WRONLY)!!;
	f.cleanup();
	libuv::fs_close(&l, &f, fd)!!;
	f.cleanup();

	CInt entries = libuv::fs_scandir(&l, &req, dir)!!;
	test::@check(entries == 1, "scandir found %d entries, expected 1", entries);

	libuv::Dirent ent;
	libuv::fs_scandir_next(&req, &ent)!!;
	test::@check(ent.name.str_view() == "inner.txt", "found %s", ent.name);
	test::@check(ent.type == libuv::DirentType.FILE || ent.type == libuv::DirentType.UNKNOWN,
		"unexpected dirent type");

	if (catch err = libuv::fs_scandir_next(&req, &ent))
	{
		test::@check(err == libuv::EOF, "expected EOF after the last entry");
	}
	else
	{
		test::@check(false, "scandir_next should run out of entries");
	}
	req.cleanup();

	libuv::fs_unlink(&l, &f, inner)!!;
	f.cleanup();
	libuv::fs_rmdir(&l, &req, dir)!!;
	req.cleanup();
}

fn void mkdtemp_creates_a_unique_directory() @test
{
	Loop l;
	l.init()!!;
	defer (void)l.close();

	Fs req;
	String tpl = temp_path("libuv_c3l_XXXXXX");
	libuv::fs_mkdtemp(&l, &req, tpl)!!;

	String created = req.get_path().str_view();
	test::@check(created.len == tpl.len, "the created path has a different length to the template");
	test::@check(!created.contains("XXXXXX"), "the template was not substituted: %s", created);

	Fs rm;
	libuv::fs_rmdir(&l, &rm, created)!!;
	rm.cleanup();
	req.cleanup();
}

fn void a_failed_request_reports_its_type_and_result() @test
{
	Loop l;
	l.init()!!;
	defer (void)l.close();

	Fs req;
	defer req.cleanup();
	(void)libuv::fs_open(&l, &req, "definitely/not/here.txt", libuv::O_RDONLY);

	test::@check(req.get_type() == libuv::FS_OPEN, "fs_type came back as %d", (CInt)req.get_type());
	test::@check(req.get_result() < 0, "a failed open should leave a negative result");
	if (catch err = req.status())
	{
		test::@check(err == libuv::ENOENT, "expected ENOENT");
	}
	else
	{
		test::@check(false, "opening a missing file should fail");
	}
}

fn void cleanup_twice_is_a_no_op() @test
{
	Loop l;
	l.init()!!;
	defer (void)l.close();

	Fs failed;
	(void)libuv::fs_open(&l, &failed, "definitely/not/here.txt", libuv::O_RDONLY);
	failed.cleanup();
	failed.cleanup();
	failed.cleanup();

	String dir = temp_path("libuv_c3l_cleanup");
	Fs req;
	(void)libuv::fs_rmdir(&l, &req, dir);
	req.cleanup();
	libuv::fs_mkdir(&l, &req, dir)!!;
	req.cleanup();

	String inner = string::tformat("%s/entry.txt", dir);
	Fs f;
	CInt fd = libuv::fs_open(&l, &f, inner, libuv::O_CREAT | libuv::O_WRONLY)!!;
	f.cleanup();
	f.cleanup();

	Fs st;
	libuv::fs_fstat(&l, &st, fd)!!;
	test::@check(st.get_statbuf().st_size == 0);
	st.cleanup();
	st.cleanup();

	libuv::fs_close(&l, &f, fd)!!;
	f.cleanup();
	f.cleanup();

	Fs scan;
	CInt entries = libuv::fs_scandir(&l, &scan, dir)!!;
	test::@check(entries == 1);
	libuv::Dirent ent;
	libuv::fs_scandir_next(&scan, &ent)!!;
	scan.cleanup();
	scan.cleanup();
	scan.cleanup();

	Fs tmp;
	libuv::fs_mkdtemp(&l, &tmp, temp_path("libuv_c3l_cl_XXXXXX"))!!;
	String created = tmp.get_path().str_view();
	Fs rm;
	libuv::fs_rmdir(&l, &rm, created)!!;
	rm.cleanup();
	tmp.cleanup();
	tmp.cleanup();

	libuv::fs_unlink(&l, &req, inner)!!;
	req.cleanup();
	libuv::fs_rmdir(&l, &req, dir)!!;
	req.cleanup();
	req.cleanup();
}
