module uv::fs;
import uv;
import std::os::win32;

enum UVFSEventEnum : int (int code) {
    UV_RENAME = 1,
    UV_CHANGE = 2
}

struct UVFSEvent @if(env::WIN32) {
    inline UVHandleFields handleFields;
    char* filename;
    struct req {
        inline UVRequiredFields requiredFields;
    }
    Win32_HANDLE dir_handle;
    CInt req_pending;
    UVFSEventCb cb;
    CUShort* filew;
    CUShort* short_filew;
    CUShort* dirw;
    CChar* buffer;
}

struct UVTimespec {
  long tv_sec;
  long tv_nsec;
}

struct UVStat {
  CUInt st_dev;
  CUInt st_mode;
  CUInt st_nlink;
  CUInt st_uid;
  CUInt st_gid;
  CUInt st_rdev;
  CUInt st_ino;
  CUInt st_size;
  CUInt st_blksize;
  CUInt st_blocks;
  CUInt st_flags;
  CUInt st_gen;
  UVTimespec st_atim;
  UVTimespec st_mtim;
  UVTimespec st_ctim;
  UVTimespec st_birthtim;
}

enum UVFSType {
  UV_FS_UNKNOWN,
  UV_FS_CUSTOM,
  UV_FS_OPEN,
  UV_FS_CLOSE,
  UV_FS_READ,
  UV_FS_WRITE,
  UV_FS_SENDFILE,
  UV_FS_STAT,
  UV_FS_LSTAT,
  UV_FS_FSTAT,
  UV_FS_FTRUNCATE,
  UV_FS_UTIME,
  UV_FS_FUTIME,
  UV_FS_ACCESS,
  UV_FS_CHMOD,
  UV_FS_FCHMOD,
  UV_FS_FSYNC,
  UV_FS_FDATASYNC,
  UV_FS_UNLINK,
  UV_FS_RMDIR,
  UV_FS_MKDIR,
  UV_FS_MKDTEMP,
  UV_FS_RENAME,
  UV_FS_SCANDIR,
  UV_FS_LINK,
  UV_FS_SYMLINK,
  UV_FS_READLINK,
  UV_FS_CHOWN,
  UV_FS_FCHOWN,
  UV_FS_REALPATH,
  UV_FS_COPYFILE,
  UV_FS_LCHOWN,
  UV_FS_OPENDIR,
  UV_FS_READDIR,
  UV_FS_CLOSEDIR,
  UV_FS_STATFS,
  UV_FS_MKSTEMP,
  UV_FS_LUTIME
}

struct UVFs @if(env::WIN32) {
    inline UVRequiredFields requiredFields;
    UVFSType fs_type;
    UVLoop* loop;
    UVFSCb cb;
    usz result;
    void* ptr;
    char* path;
    UVStat statbuf;  /* Stores the result of uv_fs_stat() and uv_fs_fstat(). */
    UVWork work_req;
    CInt flags;
    Win32_DWORD sys_errno_;
    union file {
      Win32_WCHAR* pathw;
      CInt fd;
    }
    union fs {
      struct info {
        CInt mode;
        ushort* new_pathw;
        CInt file_flags;
        CInt fd_out;
        CUInt nbufs;
        UVBuf* bufs;
        long offset;
        UVBuf[4] bufsml;
      }
      struct time {
        double atime;
        double mtime;
      }
    }
}

def UVFile = CInt;
def Unix_Mode = CUInt;
def Unix_Off = CLong;

def UVUIdW = CUChar;
def UVUIdU = CUInt;

def UVGIdW = CUChar;
def UVGIdU = CUInt;

def UVOSSock = Win32_SOCKET;
def UVOSFd = Win32_HANDLE;
def UVPId = CInt;

struct UVFs @if(!env::WIN32) {
    inline UVRequiredFields requiredFields;
    UVFSType fs_type;
    UVLoop* loop;
    UVFSCb cb;
    usz result;
    void* ptr;
    char* path;
    UVStat statbuf;  /* Stores the result of uv_fs_stat() and uv_fs_fstat(). */
    UVWork work_req;
    char *new_path;
    UVFile file;
    CInt flags;
    Unix_Mode mode;
    CUInt nbufs;
    UVBuf* bufs;
    Unix_Off off;
    UVUIdU uid;
    UVGIdU gid;
    double atime;
    double mtime;
    UVBuf[4] bufsml;
}

const MAX_PATH = 260;

struct Win32_FIND_DATAW {
  Win32_DWORD    dwFileAttributes;
  Win32_FILETIME ftCreationTime;
  Win32_FILETIME ftLastAccessTime;
  Win32_FILETIME ftLastWriteTime;
  Win32_DWORD    nFileSizeHigh;
  Win32_DWORD    nFileSizeLow;
  Win32_DWORD    dwReserved0;
  Win32_DWORD    dwReserved1;
  Win32_WCHAR[MAX_PATH]    cFileName;
  Win32_WCHAR[14]    cAlternateFileName;
  Win32_DWORD    dwFileType; // Obsolete. Do not use.
  Win32_DWORD    dwCreatorType; // Obsolete. Do not use
  Win32_WORD     wFinderFlags; // Obsolete. Do not use
}

struct UVDir @if(env::WIN32) {
    UVDirent* dirents;
    usz nentries;
    void*[4] reserved;
    Win32_HANDLE dir_handle;
    Win32_FIND_DATAW find_data;
    bool need_find_call;
}

struct Dirent {
	CLong d_ino;
	CLong d_off;
	CUShort d_reclen;
	usz d_namlen;
	CInt d_type;
	char[MAX_PATH+1] d_name;
}


enum UVDirentType {
    UV_DIRENT_UNKNOWN,
    UV_DIRENT_FILE,
    UV_DIRENT_DIR,
    UV_DIRENT_LINK,
    UV_DIRENT_FIFO,
    UV_DIRENT_SOCKET,
    UV_DIRENT_CHAR,
    UV_DIRENT_BLOCK
}

struct UVDirent {
    char* name;
    UVDirentType type;
}

struct WDir {
	Dirent ent;
	Win32_FIND_DATAW data;
	CInt cached;
	CInt invalid;
	Win32_HANDLE handle;
	CUShort *patt;
}

struct Dir @if(!env::WIN32) {
    Dirent ent;
    WDir* wdirp;
}

struct UVDir @if(!env::WIN32) {
    UVDirent* dirents;
    usz nentries;
    void*[4] reserved;
    Dir* dir;
}

def UVFSEventCb = fn void(UVHandle*);

extern fn CInt uv_fs_close(UVLoop* loop, UVFs* req, UVFile file, UVFSCb cb) @extern("uv_fs_close");
extern fn CInt uv_fs_open(UVLoop* loop, UVFs* req, char* path, CInt flags, CInt mode, UVFSCb cb) @extern("uv_fs_open");
extern fn CInt uv_fs_read(UVLoop* loop, UVFs* req, UVFile file, UVBuf[] bufs, CUInt nbufs, CLongLong offset, UVFSCb cb) @extern("uv_fs_read");
extern fn CInt uv_fs_unlink(UVLoop* loop, UVFs* req, char* path, UVFSCb cb) @extern("uv_fs_unlink");
extern fn CInt uv_fs_write(UVLoop* loop, UVFs* req, UVFile file, UVBuf[] bufs, CUInt nbufs, CLongLong offset, UVFSCb cb) @extern("uv_fs_write");
extern fn CInt uv_fs_copyfile(UVLoop* loop, UVFs* req, char* path, char* new_path, CInt flags, UVFSCb cb) @extern("uv_fs_copyfile");
extern fn CInt uv_fs_mkdir(UVLoop* loop, UVFs* req, char* path, CInt mode, UVFSCb cb) @extern("uv_fs_mkdir");
extern fn CInt uv_fs_mkdtemp(UVLoop* loop, UVFs* req, char* tpl, UVFSCb cb) @extern("uv_fs_mkdtemp");
extern fn CInt uv_fs_mkstemp(UVLoop* loop, UVFs* req, char* tpl, UVFSCb cb) @extern("uv_fs_mkstemp");
extern fn CInt uv_fs_rmdir(UVLoop* loop, UVFs* req, char* path, UVFSCb cb) @extern("uv_fs_rmdir");
extern fn CInt uv_fs_scandir(UVLoop* loop, UVFs* req, char* path, CInt flags, UVFSCb cb) @extern("uv_fs_scandir");
extern fn CInt uv_fs_scandir_next(UVLoop* req, UVFs* ent) @extern("uv_fs_scandir_next");
extern fn CInt uv_fs_opendir(UVLoop* loop, UVFs* req, char* path, UVFSCb cb) @extern("uv_fs_opendir");
extern fn CInt uv_fs_readdir(UVLoop* loop, UVFs* req, UVDir* dir, UVFSCb cb) @extern("uv_fs_readdir");
extern fn CInt uv_fs_closedir(UVLoop* loop, UVFs* req, UVDir* dir, UVFSCb cb) @extern("uv_fs_closedir");
extern fn CInt uv_fs_stat(UVLoop* loop, UVFs* req, char* path, UVFSCb cb) @extern("uv_fs_stat");
extern fn CInt uv_fs_fstat(UVLoop* loop, UVFs* req, UVFile file, UVFSCb cb) @extern("uv_fs_fstat");
extern fn CInt uv_fs_rename(UVLoop* loop, UVFs* req, char* path, char* new_path, UVFSCb cb) @extern("uv_fs_rename");
extern fn CInt uv_fs_fsync(UVLoop* loop, UVFs* req, UVFile file, UVFSCb cb) @extern("uv_fs_fsync");
extern fn CInt uv_fs_fdatasync(UVLoop* loop, UVFs* req, UVFile file, UVFSCb cb) @extern("uv_fs_fdatasync");
extern fn CInt uv_fs_ftruncate(UVLoop* loop, UVFs* req, UVFile file, CLongLong offset, UVFSCb cb) @extern("uv_fs_ftruncate");
extern fn CInt uv_fs_sendfile(UVLoop* loop, UVFs* req, UVFile out_fd, UVFile in_fd, CLongLong in_offset, usz length, UVFSCb cb) @extern("uv_fs_sendfile");
extern fn CInt uv_fs_access(UVLoop* loop, UVFs* req, char* path, CInt mode, UVFSCb cb) @extern("uv_fs_access");
extern fn CInt uv_fs_chmod(UVLoop* loop, UVFs* req, char* path, CInt mode, UVFSCb cb) @extern("uv_fs_chmod");
extern fn CInt uv_fs_utime(UVLoop* loop, UVFs* req, char* path, double atime, double mtime, UVFSCb cb) @extern("uv_fs_utime");
extern fn CInt uv_fs_futime(UVLoop* loop, UVFs* req, UVFile file, double atime, double mtime, UVFSCb cb) @extern("uv_fs_futime");
extern fn CInt uv_fs_lutime(UVLoop* loop, UVFs* req, char* path, double atime, double mtime, UVFSCb cb) @extern("uv_fs_lutime");
extern fn CInt uv_fs_lstat(UVLoop* loop, UVFs* req, char* path, UVFSCb cb) @extern("uv_fs_lstat");
extern fn CInt uv_fs_link(UVLoop* loop, UVFs* req, char* path, char* new_path, UVFSCb cb) @extern("uv_fs_link");
extern fn CInt uv_fs_symlink(UVLoop* loop, UVFs* req, char* path, char* new_path, CInt flags, UVFSCb cb) @extern("uv_fs_symlink");
extern fn CInt uv_fs_readlink(UVLoop* loop, UVFs* req, char* path, UVFSCb cb) @extern("uv_fs_readlink");
extern fn CInt uv_fs_realpath(UVLoop* loop, UVFs* req, char* path, UVFSCb cb) @extern("uv_fs_realpath");
extern fn CInt uv_fs_fchmod(UVLoop* loop, UVFs* req, UVFile file, CInt mode, UVFSCb cb) @extern("uv_fs_fchmod");
extern fn CInt uv_fs_chown(UVLoop* loop, UVFs* req, char* path, UVUIdW uid, UVGIdW gid, UVFSCb cb) @extern("uv_fs_chown") @if(env::WIN32);
extern fn CInt uv_fs_chown(UVLoop* loop, UVFs* req, char* path, UVUIdU uid, UVGIdU gid, UVFSCb cb) @extern("uv_fs_chown") @if(!env::WIN32);
extern fn CInt uv_fs_fchown(UVLoop* loop, UVFs* req, UVFile file, UVUIdW uid, UVGIdW gid, UVFSCb cb) @extern("uv_fs_fchown") @if(env::WIN32);
extern fn CInt uv_fs_fchown(UVLoop* loop, UVFs* req, UVFile file, UVUIdU uid, UVGIdU gid, UVFSCb cb) @extern("uv_fs_fchown") @if(!env::WIN32);
extern fn CInt uv_fs_lchown(UVLoop* loop, UVFs* req, char* path, UVUIdW uid, UVGIdW gid, UVFSCb cb) @extern("uv_fs_lchown") @if(env::WIN32);
extern fn CInt uv_fs_lchown(UVLoop* loop, UVFs* req, char* path, UVUIdU uid, UVGIdU gid, UVFSCb cb) @extern("uv_fs_lchown") @if(!env::WIN32);
extern fn CInt uv_fs_statfs(UVLoop* loop, UVFs* req, char* path, UVFSCb cb) @extern("uv_fs_statfs");