<*
 Filesystem requests.

 Every call takes a `Fs` request and a callback. Pass a null callback and the
 operation runs synchronously on the calling thread; pass a real one and it runs
 on the threadpool, calling back on the loop thread.

 Either way the request owns memory afterwards: always call `Fs.cleanup` when
 you are done reading the result.

 The returned value is the raw libuv result: a descriptor for `fs_open`, a byte
 count for `fs_read` and `fs_write`, and 0 for everything else. Asynchronous
 calls always return 0 and deliver the real result in `Fs.result`.
*>
module libuv;

<*
 Frees whatever the request allocated.

 Call it once the request has finished, whether it ran synchronously or through
 a callback. Anything the request handed you dies here, so read it first.

 A second call is a no-op, but its not documented behavior.

 @param [&inout] self
*>
fn void Fs.cleanup(&self) => api::uv_fs_req_cleanup(self);

<* Which operation the request ran. *>
fn FsType Fs.get_type(&self) => api::uv_fs_get_type(self);

<* Result of the operation: a count or descriptor, or a negative `ErrorCode`. *>
fn sz Fs.get_result(&self) => api::uv_fs_get_result(self);

<*
 The platform specific error the operation failed with.

 Useful when libuv's own code is not specific enough. 0 when there was none.
*>
fn CInt Fs.get_system_error(&self) => api::uv_fs_get_system_error(self);

<*
 Operation specific result pointer. What it holds depends on the call:

 | after | `ptr` is |
 |---|---|
 | `fs_readlink`, `fs_realpath` | a `ZString`, the resolved path |
 | `fs_opendir` | a `Dir*` |
 | `fs_statfs` | a `StatFs*` |
 | the `stat` family | an alias of the request's own `statbuf` |
 | anything else | null |

 Cast it to what the call promised; there is no tag to check. Everything except
 the `Dir` from `fs_opendir` dies at `Fs.cleanup` -- that one has to go to
 `fs_closedir` instead.
*>
fn void* Fs.get_ptr(&self) => api::uv_fs_get_ptr(self);

<* Path the operation ran on, or null. Valid until `Fs.cleanup`. *>
fn ZString Fs.get_path(&self) => api::uv_fs_get_path(self);

<* The stat buffer filled in by the `stat` family. *>
fn Stat* Fs.get_statbuf(&self) => api::uv_fs_get_statbuf(self);

<*
 Result of the operation as an optional.

 Turns the negative `Fs.result` of a completed request into a fault, which is
 the convenient way to check an asynchronous result inside an `FsCallback`.

 @return "the result, which is a descriptor or a byte count depending on the operation"
*>
fn sz? Fs.status(&self)
{
	sz r = api::uv_fs_get_result(self);
	if (r < 0) return ((ErrorCode)(CInt)r).to_fault()~;
	return r;
}

// Files
<*
 Opens a file.

 @param flags : "bitwise or of the `libuv::O_*` constants"
 @param mode : "unix permission bits, used only when the file is created"
 @return "the new file descriptor when `cb` is null, otherwise 0"
 @param [&inout] req
*>
fn CInt? fs_open(Loop* loop, Fs* req, String path, CInt flags, CInt mode = 0o644, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_open(loop, req, path.zstr_tcopy(), flags, mode, cb));
}

<*
 Closes a file descriptor.

 @param [&inout] req
*>
fn CInt? fs_close(Loop* loop, Fs* req, Fd file, FsCallback cb = null)
	=> check_value(api::uv_fs_close(loop, req, file, cb));

<*
 Reads into the given buffers.

 @param offset : "byte offset to read from, or -1 to read from the current position"
 @require bufs.len > 0
 @require bufs.len <= CUInt::max
 @return "the number of bytes read when `cb` is null, otherwise 0"
 @param [&inout] req
*>
fn CInt? fs_read(Loop* loop, Fs* req, Fd file, Buf[] bufs, long offset = -1, FsCallback cb = null)
	=> check_value(api::uv_fs_read(loop, req, file, bufs.ptr, (CUInt)bufs.len, offset, cb));

<*
 Writes the given buffers.

 @param offset : "byte offset to write at, or -1 to write at the current position"
 @require bufs.len > 0
 @require bufs.len <= CUInt::max
 @return "the number of bytes written when `cb` is null, otherwise 0"
 @param [&inout] req
*>
fn CInt? fs_write(Loop* loop, Fs* req, Fd file, Buf[] bufs, long offset = -1, FsCallback cb = null)
	=> check_value(api::uv_fs_write(loop, req, file, bufs.ptr, (CUInt)bufs.len, offset, cb));

<* @param [&inout] req *>
fn CInt? fs_unlink(Loop* loop, Fs* req, String path, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_unlink(loop, req, path.zstr_tcopy(), cb));
}

<*
 Copies a file, using a reflink or a kernel side copy where the platform offers
 one.

 @param flags : "bitwise or of `FS_COPYFILE_EXCL`, `FS_COPYFILE_FICLONE` and `FS_COPYFILE_FICLONE_FORCE`"
 @param [&inout] req
*>
fn CInt? fs_copyfile(Loop* loop, Fs* req, String path, String new_path, CInt flags = 0, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_copyfile(loop, req, path.zstr_tcopy(), new_path.zstr_tcopy(), flags, cb));
}

<* @param [&inout] req *>
fn CInt? fs_rename(Loop* loop, Fs* req, String path, String new_path, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_rename(loop, req, path.zstr_tcopy(), new_path.zstr_tcopy(), cb));
}

<* @param [&inout] req *>
fn CInt? fs_ftruncate(Loop* loop, Fs* req, Fd file, long offset, FsCallback cb = null)
	=> check_value(api::uv_fs_ftruncate(loop, req, file, offset, cb));

<* @param [&inout] req *>
fn CInt? fs_fsync(Loop* loop, Fs* req, Fd file, FsCallback cb = null)
	=> check_value(api::uv_fs_fsync(loop, req, file, cb));

<* @param [&inout] req *>
fn CInt? fs_fdatasync(Loop* loop, Fs* req, Fd file, FsCallback cb = null)
	=> check_value(api::uv_fs_fdatasync(loop, req, file, cb));

<*
 Copies bytes straight from one descriptor to another where the platform can.

 @return "the number of bytes copied when `cb` is null, otherwise 0"
 @param [&inout] req
*>
fn CInt? fs_sendfile(Loop* loop, Fs* req, Fd out_fd, Fd in_fd, long in_offset, usz length, FsCallback cb = null)
	=> check_value(api::uv_fs_sendfile(loop, req, out_fd, in_fd, in_offset, length, cb));

// Metadata

<*
 Tests access to a path.

 @param mode : "bitwise or of `F_OK`, `R_OK`, `W_OK` and `X_OK`"
 @param [&inout] req
*>
fn CInt? fs_access(Loop* loop, Fs* req, String path, CInt mode, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_access(loop, req, path.zstr_tcopy(), mode, cb));
}

<* @param [&inout] req *>
fn CInt? fs_stat(Loop* loop, Fs* req, String path, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_stat(loop, req, path.zstr_tcopy(), cb));
}

<* @param [&inout] req *>
fn CInt? fs_lstat(Loop* loop, Fs* req, String path, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_lstat(loop, req, path.zstr_tcopy(), cb));
}

<* @param [&inout] req *>
fn CInt? fs_fstat(Loop* loop, Fs* req, Fd file, FsCallback cb = null)
	=> check_value(api::uv_fs_fstat(loop, req, file, cb));

<*
 Filesystem statistics. The result is a `StatFs*` in `Fs.get_ptr`.

 @param [&inout] req
*>
fn CInt? fs_statfs(Loop* loop, Fs* req, String path, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_statfs(loop, req, path.zstr_tcopy(), cb));
}

<* @param [&inout] req *>
fn CInt? fs_chmod(Loop* loop, Fs* req, String path, CInt mode, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_chmod(loop, req, path.zstr_tcopy(), mode, cb));
}

<* @param [&inout] req *>
fn CInt? fs_fchmod(Loop* loop, Fs* req, Fd file, CInt mode, FsCallback cb = null)
	=> check_value(api::uv_fs_fchmod(loop, req, file, mode, cb));

<*
 Sets the access and modification stamps of a path, in seconds since the epoch.

 Pass `FS_UTIME_NOW` for "right now" or `FS_UTIME_OMIT` to leave one alone.

 @param [&inout] req
*>
fn CInt? fs_utime(Loop* loop, Fs* req, String path, double atime, double mtime, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_utime(loop, req, path.zstr_tcopy(), atime, mtime, cb));
}

<* @param [&inout] req *>
fn CInt? fs_futime(Loop* loop, Fs* req, Fd file, double atime, double mtime, FsCallback cb = null)
	=> check_value(api::uv_fs_futime(loop, req, file, atime, mtime, cb));

<*
 Like `fs_utime`, but does not follow a final symlink.

 @param [&inout] req
*>
fn CInt? fs_lutime(Loop* loop, Fs* req, String path, double atime, double mtime, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_lutime(loop, req, path.zstr_tcopy(), atime, mtime, cb));
}

<* @param [&inout] req *>
fn CInt? fs_chown(Loop* loop, Fs* req, String path, Uid uid, Gid gid, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_chown(loop, req, path.zstr_tcopy(), uid, gid, cb));
}

<* @param [&inout] req *>
fn CInt? fs_fchown(Loop* loop, Fs* req, Fd file, Uid uid, Gid gid, FsCallback cb = null)
	=> check_value(api::uv_fs_fchown(loop, req, file, uid, gid, cb));

<* @param [&inout] req *>
fn CInt? fs_lchown(Loop* loop, Fs* req, String path, Uid uid, Gid gid, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_lchown(loop, req, path.zstr_tcopy(), uid, gid, cb));
}

// Directories and links
<*
 @param mode : "unix permission bits"
 @param [&inout] req
*>
fn CInt? fs_mkdir(Loop* loop, Fs* req, String path, CInt mode = 0o755, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_mkdir(loop, req, path.zstr_tcopy(), mode, cb));
}

<* @param [&inout] req *>
fn CInt? fs_rmdir(Loop* loop, Fs* req, String path, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_rmdir(loop, req, path.zstr_tcopy(), cb));
}

<*
 Creates a uniquely named temporary directory.

 The final six characters of `tpl` must be "XXXXXX". The created path lands in
 `Fs.get_path`.

 @require tpl.ends_with("XXXXXX") : "the template must end in six X characters"
 @param [&inout] req
*>
fn CInt? fs_mkdtemp(Loop* loop, Fs* req, String tpl, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_mkdtemp(loop, req, tpl.zstr_tcopy(), cb));
}

<*
 Creates and opens a uniquely named temporary file.

 The final six characters of `tpl` must be "XXXXXX". The created path lands in
 `Fs.get_path`.

 @require tpl.ends_with("XXXXXX") : "the template must end in six X characters"
 @return "the new file descriptor when `cb` is null, otherwise 0"
 @param [&inout] req
*>
fn CInt? fs_mkstemp(Loop* loop, Fs* req, String tpl, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_mkstemp(loop, req, tpl.zstr_tcopy(), cb));
}

<*
 Reads a whole directory in one go, the simpler of the two listing APIs.

 The entries are held inside `req`; take them out one at a time with
 `fs_scandir_next` until it reports `libuv::EOF`, then call `Fs.cleanup`. The
 whole listing is in memory until you do, so prefer `fs_opendir` for a directory
 that might be enormous.

 "." and ".." are never included.

 @param flags : "reserved by libuv, pass 0"
 @return "the number of entries found when `cb` is null, otherwise 0"
 @param [&inout] req
*>
fn CInt? fs_scandir(Loop* loop, Fs* req, String path, CInt flags = 0, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_scandir(loop, req, path.zstr_tcopy(), flags, cb));
}

<*
 Copies the next entry of a completed `fs_scandir` request into `ent`.

 Call it repeatedly until it fails with `libuv::EOF`, which is how the listing
 signals that it is exhausted rather than an error to report.

 `ent.name` points into the request, so it is only valid until that request is
 cleaned up: copy anything you mean to keep. On Linux `ent.type` is only filled
 in on filesystems that report it -- btrfs and the ext family -- and is
 `DirentType.UNKNOWN` elsewhere.

 @param [&inout] req
 @param [out] ent
*>
fn void? fs_scandir_next(Fs* req, Dirent* ent) => check(api::uv_fs_scandir_next(req, ent));

<*
 Opens a directory as a stream, to be read in batches with `fs_readdir`.

 On success libuv allocates a `Dir` and leaves it in `Fs.get_ptr`, so take it
 out before cleaning the request up:

     libuv::fs_opendir(&loop, &req, path)!;
     Dir* dir = (Dir*)req.get_ptr();
     req.cleanup();

 `Fs.cleanup` does not free the `Dir` -- only `fs_closedir` does, and failing to
 call it leaks the stream. On failure nothing is allocated.

 @return "0; the stream itself arrives through `Fs.get_ptr`"
 @param [&inout] req
*>
fn CInt? fs_opendir(Loop* loop, Fs* req, String path, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_opendir(loop, req, path.zstr_tcopy(), cb));
}

<*
 Reads the next batch of entries from a stream opened by `fs_opendir`.

 Set `dir.dirents` to an array you own and `dir.nentries` to its length before
 every call, not just the first: libuv reads both fields each time and fills in
 at most `nentries` slots. See `Dir` for the whole loop, or
 `examples/readdir.c3` for it as a running program.

 A return of 0 means the directory is exhausted. A smaller number than you asked
 for does not -- keep going until you see 0.

 The name in each filled slot belongs to libuv and dies at the `Fs.cleanup` for
 this request, which you must also do before `fs_closedir`. Not thread safe: one
 stream must not be read from two threads at once.

 "." and ".." are never included.

 @require dir.dirents != null : "set dir.dirents to your own array before calling"
 @require dir.nentries > 0 : "set dir.nentries to the length of that array"
 @return "the number of entries read when `cb` is null, otherwise 0"
 @param [&inout] req
 @param [&inout] dir
*>
fn CInt? fs_readdir(Loop* loop, Fs* req, Dir* dir, FsCallback cb = null)
	=> check_value(api::uv_fs_readdir(loop, req, dir, cb));

<*
 Closes a stream opened by `fs_opendir` and frees the `Dir`.

 Clean up the last `fs_readdir` request first; libuv requires that order.

 @param [&inout] req
 @param [&inout] dir
*>
fn CInt? fs_closedir(Loop* loop, Fs* req, Dir* dir, FsCallback cb = null)
	=> check_value(api::uv_fs_closedir(loop, req, dir, cb));

<* @param [&inout] req *>
fn CInt? fs_link(Loop* loop, Fs* req, String path, String new_path, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_link(loop, req, path.zstr_tcopy(), new_path.zstr_tcopy(), cb));
}

<*
 Creates a symbolic link.

 @param flags : "on Windows, 0 or a combination of `FS_SYMLINK_DIR` and `FS_SYMLINK_JUNCTION`; ignored elsewhere"
 @param [&inout] req
*>
fn CInt? fs_symlink(Loop* loop, Fs* req, String path, String new_path, CInt flags = 0, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_symlink(loop, req, path.zstr_tcopy(), new_path.zstr_tcopy(), flags, cb));
}

<*
 Reads the target of a symbolic link. The target lands in `Fs.get_ptr` as a
 NUL terminated string.

 @param [&inout] req
*>
fn CInt? fs_readlink(Loop* loop, Fs* req, String path, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_readlink(loop, req, path.zstr_tcopy(), cb));
}

<*
 Resolves a path to its canonical form. The result lands in `Fs.get_ptr` as a
 NUL terminated string.

 @param [&inout] req
*>
fn CInt? fs_realpath(Loop* loop, Fs* req, String path, FsCallback cb = null) => @pool()
{
	return check_value(api::uv_fs_realpath(loop, req, path.zstr_tcopy(), cb));
}
