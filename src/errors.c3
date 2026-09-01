<*
 Error vocabulary.

 libuv reports failure as a negative `int`. 
 The raw value is modelled by `ErrorCode`; wrappers turn it into one of the faults below.
*>
module libuv;

<*
 A raw libuv result: zero or positive on success, negative on failure.

 Callbacks receive these directly, for example the `status` of a
 `ConnectCallback` or a negative `nread` in a `ReadCallback`.
*>
typedef ErrorCode = inline CInt;

// Codes libuv defines identically on every platform.
const ErrorCode EOF_CODE = (ErrorCode)-4095;
const ErrorCode UNKNOWN_CODE = (ErrorCode)-4094;
const ErrorCode EAI_ADDRFAMILY_CODE = (ErrorCode)-3000;
const ErrorCode EAI_AGAIN_CODE = (ErrorCode)-3001;
const ErrorCode EAI_BADFLAGS_CODE = (ErrorCode)-3002;
const ErrorCode EAI_CANCELED_CODE = (ErrorCode)-3003;
const ErrorCode EAI_FAIL_CODE = (ErrorCode)-3004;
const ErrorCode EAI_FAMILY_CODE = (ErrorCode)-3005;
const ErrorCode EAI_MEMORY_CODE = (ErrorCode)-3006;
const ErrorCode EAI_NODATA_CODE = (ErrorCode)-3007;
const ErrorCode EAI_NONAME_CODE = (ErrorCode)-3008;
const ErrorCode EAI_OVERFLOW_CODE = (ErrorCode)-3009;
const ErrorCode EAI_SERVICE_CODE = (ErrorCode)-3010;
const ErrorCode EAI_SOCKTYPE_CODE = (ErrorCode)-3011;
const ErrorCode EAI_BADHINTS_CODE = (ErrorCode)-3013;
const ErrorCode EAI_PROTOCOL_CODE = (ErrorCode)-3014;

<* One fault per entry of libuv's `UV_ERRNO_MAP`. *>
faultdef
	E2BIG, EACCES, EADDRINUSE, EADDRNOTAVAIL, EAFNOSUPPORT, EAGAIN,
	EAI_ADDRFAMILY, EAI_AGAIN, EAI_BADFLAGS, EAI_BADHINTS, EAI_CANCELED, EAI_FAIL,
	EAI_FAMILY, EAI_MEMORY, EAI_NODATA, EAI_NONAME, EAI_OVERFLOW, EAI_PROTOCOL,
	EAI_SERVICE, EAI_SOCKTYPE, EALREADY, EBADF, EBUSY, ECANCELED,
	ECHARSET, ECONNABORTED, ECONNREFUSED, ECONNRESET, EDESTADDRREQ, EEXIST,
	EFAULT, EFBIG, EHOSTUNREACH, EINTR, EINVAL, EIO,
	EISCONN, EISDIR, ELOOP, EMFILE, EMSGSIZE, ENAMETOOLONG,
	ENETDOWN, ENETUNREACH, ENFILE, ENOBUFS, ENODEV, ENOENT,
	ENOMEM, ENONET, ENOPROTOOPT, ENOSPC, ENOSYS, ENOTCONN,
	ENOTDIR, ENOTEMPTY, ENOTSOCK, ENOTSUP, EOVERFLOW, EPERM,
	EPIPE, EPROTO, EPROTONOSUPPORT, EPROTOTYPE, ERANGE, EROFS,
	ESHUTDOWN, ESPIPE, ESRCH, ETIMEDOUT, ETXTBSY, EXDEV,
	UNKNOWN, EOF, ENXIO, EMLINK, EHOSTDOWN, EREMOTEIO,
	ENOTTY, EFTYPE, EILSEQ, ESOCKTNOSUPPORT, ENODATA, EUNATCH,
	ENOEXEC;

<*
 Short name of the code, for example "EAGAIN".

 For a code libuv knows this borrows a static string that lives as long as the
 process. For anything else -- including 0, which is not in libuv's error map --
 libuv formats "Unknown system error N" into a fresh allocation and never frees
 it. Its own documentation says as much: "Leaks a few bytes of memory when you
 call it with an unknown error code."

 So do not call this on a status you have not already established is a failure,
 and do not call it in a loop. `ErrorCode.name_to` has neither problem.
*>
fn String ErrorCode.name(self) => api::uv_err_name((CInt)self).str_view();

<*
 Human readable description of the code, for example "resource temporarily
 unavailable".

 Leaks on unrecognised codes exactly as `ErrorCode.name` does; use
 `ErrorCode.message_to` when the code might not be one libuv knows.
*>
fn String ErrorCode.message(self) => api::uv_strerror((CInt)self).str_view();

<* A buffer of this size always holds what `ErrorCode.name_to` writes. *>
const usz NAME_BUFSIZE = 32;
<* A buffer of this size always holds what `ErrorCode.message_to` writes. *>
const usz MESSAGE_BUFSIZE = 96;

<*
 Copies the short name of the code into `buf`.

 The allocation-free form of `ErrorCode.name`.

 @require buf.len > 0
 @return "the name, borrowed from `buf`"
*>
fn String ErrorCode.name_to(self, char[] buf)
	=> ((ZString)api::uv_err_name_r((CInt)self, buf.ptr, buf.len)).str_view();

<*
 Copies the description of the code into `buf`.

 The allocation-free form of `ErrorCode.message`.

 @require buf.len > 0
 @return "the description, borrowed from `buf`"
*>
fn String ErrorCode.message_to(self, char[] buf)
	=> ((ZString)api::uv_strerror_r((CInt)self, buf.ptr, buf.len)).str_view();

<* True when the code does not signal an error. *>
fn bool ErrorCode.is_ok(self) @inline => (CInt)self >= 0;

<*
 The fault matching this code.

 @require !self.is_ok() : "only failing codes have a fault"
 @return "the matching fault, or `libuv::UNKNOWN` for a code this binding does not know"
*>
fn fault ErrorCode.to_fault(self)
{
	char[NAME_BUFSIZE] buf;
	switch (self.name_to(&buf))
	{
		case "E2BIG": return E2BIG;
		case "EACCES": return EACCES;
		case "EADDRINUSE": return EADDRINUSE;
		case "EADDRNOTAVAIL": return EADDRNOTAVAIL;
		case "EAFNOSUPPORT": return EAFNOSUPPORT;
		case "EAGAIN": return EAGAIN;
		case "EAI_ADDRFAMILY": return EAI_ADDRFAMILY;
		case "EAI_AGAIN": return EAI_AGAIN;
		case "EAI_BADFLAGS": return EAI_BADFLAGS;
		case "EAI_BADHINTS": return EAI_BADHINTS;
		case "EAI_CANCELED": return EAI_CANCELED;
		case "EAI_FAIL": return EAI_FAIL;
		case "EAI_FAMILY": return EAI_FAMILY;
		case "EAI_MEMORY": return EAI_MEMORY;
		case "EAI_NODATA": return EAI_NODATA;
		case "EAI_NONAME": return EAI_NONAME;
		case "EAI_OVERFLOW": return EAI_OVERFLOW;
		case "EAI_PROTOCOL": return EAI_PROTOCOL;
		case "EAI_SERVICE": return EAI_SERVICE;
		case "EAI_SOCKTYPE": return EAI_SOCKTYPE;
		case "EALREADY": return EALREADY;
		case "EBADF": return EBADF;
		case "EBUSY": return EBUSY;
		case "ECANCELED": return ECANCELED;
		case "ECHARSET": return ECHARSET;
		case "ECONNABORTED": return ECONNABORTED;
		case "ECONNREFUSED": return ECONNREFUSED;
		case "ECONNRESET": return ECONNRESET;
		case "EDESTADDRREQ": return EDESTADDRREQ;
		case "EEXIST": return EEXIST;
		case "EFAULT": return EFAULT;
		case "EFBIG": return EFBIG;
		case "EHOSTUNREACH": return EHOSTUNREACH;
		case "EINTR": return EINTR;
		case "EINVAL": return EINVAL;
		case "EIO": return EIO;
		case "EISCONN": return EISCONN;
		case "EISDIR": return EISDIR;
		case "ELOOP": return ELOOP;
		case "EMFILE": return EMFILE;
		case "EMSGSIZE": return EMSGSIZE;
		case "ENAMETOOLONG": return ENAMETOOLONG;
		case "ENETDOWN": return ENETDOWN;
		case "ENETUNREACH": return ENETUNREACH;
		case "ENFILE": return ENFILE;
		case "ENOBUFS": return ENOBUFS;
		case "ENODEV": return ENODEV;
		case "ENOENT": return ENOENT;
		case "ENOMEM": return ENOMEM;
		case "ENONET": return ENONET;
		case "ENOPROTOOPT": return ENOPROTOOPT;
		case "ENOSPC": return ENOSPC;
		case "ENOSYS": return ENOSYS;
		case "ENOTCONN": return ENOTCONN;
		case "ENOTDIR": return ENOTDIR;
		case "ENOTEMPTY": return ENOTEMPTY;
		case "ENOTSOCK": return ENOTSOCK;
		case "ENOTSUP": return ENOTSUP;
		case "EOVERFLOW": return EOVERFLOW;
		case "EPERM": return EPERM;
		case "EPIPE": return EPIPE;
		case "EPROTO": return EPROTO;
		case "EPROTONOSUPPORT": return EPROTONOSUPPORT;
		case "EPROTOTYPE": return EPROTOTYPE;
		case "ERANGE": return ERANGE;
		case "EROFS": return EROFS;
		case "ESHUTDOWN": return ESHUTDOWN;
		case "ESPIPE": return ESPIPE;
		case "ESRCH": return ESRCH;
		case "ETIMEDOUT": return ETIMEDOUT;
		case "ETXTBSY": return ETXTBSY;
		case "EXDEV": return EXDEV;
		case "UNKNOWN": return UNKNOWN;
		case "EOF": return EOF;
		case "ENXIO": return ENXIO;
		case "EMLINK": return EMLINK;
		case "EHOSTDOWN": return EHOSTDOWN;
		case "EREMOTEIO": return EREMOTEIO;
		case "ENOTTY": return ENOTTY;
		case "EFTYPE": return EFTYPE;
		case "EILSEQ": return EILSEQ;
		case "ESOCKTNOSUPPORT": return ESOCKTNOSUPPORT;
		case "ENODATA": return ENODATA;
		case "EUNATCH": return EUNATCH;
		case "ENOEXEC": return ENOEXEC;
		default: return UNKNOWN;
	}
}

<*
 Turns a raw libuv return value into an optional.
*>
macro void? check(CInt code)
{
	if (code < 0) return ((ErrorCode)code).to_fault()~;
}

<*
 Turns a raw libuv return value into an optional carrying the value.

 @return "the code itself"
*>
macro CInt? check_value(CInt code)
{
	if (code < 0) return ((ErrorCode)code).to_fault()~;
	return code;
}
