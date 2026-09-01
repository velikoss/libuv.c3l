<*
 Listing a directory two ways.

 libuv offers two shapes for this and they are easy to confuse:

   scandir   reads the whole directory at once, then you pull entries out of
             the request one at a time until it reports EOF. Simple, but the
             whole listing sits in memory.

   opendir   gives you a stream you read in batches of a size you choose. More
             moving parts, but a directory with a million entries costs you
             only as much memory as the batch you asked for.

 Run it with a path, or with no argument to list the current directory.
*>
module example_readdir;
import std::io;
import libuv;

fn void scandir_way(Loop* loop, String path)
{
	io::printfn("--- scandir: %s ---", path);

	Fs req;
	// The count comes back straight away; the entries stay inside the request.
	CInt count = libuv::fs_scandir(loop, &req, path)!!;
	defer req.cleanup();
	io::printfn("%d entries", count);

	libuv::Dirent entry;
	while (true)
	{
		// Each call copies the next entry into `entry`, and reports EOF once
		// the listing is exhausted.
		if (catch err = libuv::fs_scandir_next(&req, &entry))
		{
			if (err == libuv::EOF) break;
			io::printfn("scandir_next failed: %s", err);
			break;
		}
		io::printfn("  %-8s %s", kind(entry.type), entry.name.str_view());
	}
}

fn void opendir_way(Loop* loop, String path)
{
	io::printfn("--- opendir, 4 entries at a time: %s ---", path);

	// fs_opendir allocates the Dir and leaves it in the request's ptr. Cleaning
	// up the request does not free it; only fs_closedir does.
	Fs open_req;
	libuv::fs_opendir(loop, &open_req, path)!!;
	libuv::Dir* dir = (libuv::Dir*)open_req.get_ptr();
	open_req.cleanup();

	// We own the slots the entries are copied into. Four at a time here, to
	// make the batching visible; a real program would use a bigger array.
	libuv::Dirent[4] slots;

	while (true)
	{
		// libuv reads these two fields on entry, so they have to be set before
		// every single readdir call, not just the first.
		dir.dirents = &slots[0];
		dir.nentries = slots.len;

		Fs read_req;
		CInt n = libuv::fs_readdir(loop, &read_req, dir)!!;
		if (!n)
		{
			read_req.cleanup();
			break;
		}

		io::printfn("  batch of %d:", n);
		foreach (e : slots[:(usz)n])
		{
			io::printfn("    %-8s %s", kind(e.type), e.name.str_view());
		}

		// The names belong to libuv and die here, so anything worth keeping has
		// to be copied out first. This must also happen before fs_closedir.
		read_req.cleanup();
	}

	Fs close_req;
	libuv::fs_closedir(loop, &close_req, dir)!!;
	close_req.cleanup();
}

fn String kind(libuv::DirentType t)
{
	switch (t)
	{
		case DIR: return "dir";
		case FILE: return "file";
		case LINK: return "link";
		case FIFO: return "fifo";
		case SOCKET: return "socket";
		case CHAR: return "char";
		case BLOCK: return "block";
		default: return "?";
	}
}

fn int main(String[] args)
{
	String path = args.len > 1 ? args[1] : ".";

	Loop loop;
	loop.init()!!;
	defer (void)loop.close();

	scandir_way(&loop, path);
	opendir_way(&loop, path);
	return 0;
}
