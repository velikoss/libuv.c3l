# libuv.c3l

[libuv](https://github.com/libuv/libuv) bindings for [C3](https://github.com/c3lang/c3c).

```c3
import libuv;

fn void on_tick(libuv::Timer* timer)
{
    io::printn("tick");
    if (++ticks == 5) timer.close();
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
```

---

## Installing

**1. Install libuv bindings**

On Linux and macOS your package manager has one:

```bash
sudo apt install libuv1-dev      # Debian, Ubuntu
brew install libuv               # macOS
```

Windows has no package, so there is a script that compiles it for you:

```bash
tools/build_libuv.sh /c/c3c/uvlib
```

It downloads libuv 1.51.0, compiles it, and leaves `libuv.lib` (or `libuv.a`)
plus the headers in the directory you name. Windows needs `clang` and
`llvm-lib`. Unix needs any `cc` and `ar`.

**2. Clone this repository into your project's library directory:**

```bash
git clone https://github.com/velikoss/libuv.c3l lib/libuv.c3l
```

**3. Wire it into your `project.json`:**

```json
{
  "dependency-search-paths": [ "lib" ],
  "dependencies": [ "libuv" ],
  "linker-search-paths": [ "C:/c3c/uvlib" ]
}
```

---

## API

The module path is the namespace, so the `uv_` prefix and the `_t` suffix are
dropped from every name:

| C | C3 |
|---|---|
| `uv_loop_t` | `libuv::Loop` |
| `uv_tcp_t` | `libuv::Tcp` |
| `uv_run_mode` | `libuv::RunMode` |
| `uv_file` | `libuv::Fd` (not `File`, not to be confused with `std::io::File`) |
| `UV_RUN_NOWAIT` | `libuv::RunMode.NOWAIT` |
| `uv_timer_start(&t, cb, 100, 100)` | `t.start(cb, 100, 100)!` |

There are two layers, and they share one set of types:

- **`libuv`** - checked API. Operations return `void?` or `T?` instead of an
  `int`. Contracts on the arguments are live in safe builds.
- **`libuv::api`** - the C entry points, one to one, under their original names:
  `libuv::api::uv_timer_start(&t, cb, 100, 100)` returns the raw `int`. Reach
  for it when the checked layer does not expose something. `libuv::check` turns
  a raw code into an optional.

### Errors

libuv reports failure as a negative `int` whose value is platform dependent.
That raw value is `libuv::ErrorCode`; the checked layer turns it into one of the
faults that mirror libuv's own `UV_ERRNO_MAP`:

```c3
if (catch err = tcp.bind(addr))
{
    if (err == libuv::EADDRINUSE) { /* pick another port */ }
}
```

The code-to-fault mapping goes through the linked libuv's `uv_err_name`, so it
follows the library you actually built against rather than a table baked in
here. It only runs on the error path.

`ErrorCode.name` and `ErrorCode.message` borrow a static string for codes libuv
knows, but for anything else — **including 0**, since success is not in libuv's
error map — libuv allocates the text and never frees it. That is its own
documented behaviour, not a bug in these bindings. Use the buffer forms when the
code might not be a known failure, or when you are in a loop:

```c3
char[libuv::NAME_BUFSIZE] name;
io::printfn("status: %s", ((libuv::ErrorCode)status).name_to(&name));
```

Callbacks still receive raw codes, because that is what libuv passes them:

```c3
fn void on_read(libuv::Stream* s, sz nread, libuv::Buf* buf)
{
    if (nread == (sz)libuv::EOF_CODE) { s.close(); return; }
    if (nread < 0)
    {
        io::printfn("read failed: %s", ((libuv::ErrorCode)(CInt)nread).message());
        return;
    }
    // ...
}
```

### Subtyping

Each handle starts with `inline Handle`, and each stream kind with
`inline Stream`, so the C hierarchy works without casts:

```c3
Tcp tcp;
tcp.read_start(&on_alloc, &on_read)!;   // a Stream method
tcp.unref();                            // a Handle method
tcp.close();                            // a Handle method
```

The same applies to requests: `Write`, `Connect`, `Fs` and the rest start with
`inline Req`, so `req.cancel()` works on any of them.

### Memory

- a handle must stay alive and unmoved until its `CloseCallback` has run;
- a request must stay alive until its callback has run;
- a buffer handed to `write` must stay alive until the `WriteCallback` has run.

The one place strings are copied is at the boundary: functions taking a `String`
make a temporary NUL-terminated copy under `@pool` for the duration of the call.

---

## ABI verification

The `Loop`, handle and request structs are hand transcriptions of libuv's
per-platform headers, including the private fields, so that a debugger shows the
same field names a C build would.

`libuv::check_abi` asks the linked libuv for the
size of every handle, request and of the loop, and compares. 
It needs no headers and no C compiler:

```c3
if (catch libuv::assert_abi())
{
    io::eprintn("libuv layouts do not match this binding");
    return 1;
}
```

| Platform | Status |
|---|---|
| windows-x64 | ✅ |
| linux-x64 | ✅ |
| linux-aarch64 | Needs to be checked |
| macos-x64, macos-aarch64 | Needs to be checked |
| BSD | Needs to be checked |

---

## Source layout

| File | Holds |
|---|---|
| `types.c3` | enums, callback signatures, plain data structs |
| `handle_types.c3` | `Loop` and every handle struct |
| `req_types.c3` | every request struct |
| `platform_win32.c3`, `platform_posix.c3` | per-OS typedefs and the private field blocks |
| `errors.c3` | `ErrorCode`, the fault set, `check` |
| `api.c3` | the raw C entry points |
| `abi.c3` | `check_abi`, `assert_abi` |
| `handle.c3` | `Handle` and `Req` operations, buffers, descriptors |
| `loop.c3` | loop operations |
| `watchers.c3` | timer, idle, prepare, check, async, poll, signal, fs watchers |
| `stream.c3` | `Stream`, `Tcp`, `Pipe`, `Tty` |
| `udp.c3` | `Udp` and the address helpers |
| `fs.c3`, `fs_flags.c3` | filesystem requests and the open flags |
| `dns.c3` | `getaddrinfo`, `getnameinfo` |
| `threadpool.c3` | `queue_work`, `random` |
| `process.c3` | `spawn`, `kill` |
| `threading.c3` | threads, mutex, rwlock, semaphore, condition variable, barrier |
| `misc.c3` | clocks, system information, environment, dynamic loading |

All types and APIs from 'uv.h' are present.

---

## Building and testing

The library needs no build of its own. Once `linker-search-paths` in
`project.json` points at your libuv (see Installing):

```bash
c3c test tests --safe=yes
```

---

## Differences from the pre-0.2 bindings

If you used the older version of this library, note:

- `def` is gone from the language; every type alias is now `alias` or `typedef`.
- Names lost their `UV` prefix: `UVLoop` is `libuv::Loop`, `UVTimer` is
  `libuv::Timer`.
- Raw C entry points moved to `libuv::api` and kept their C names, so
  `libuv::uv_timer_start` is now either `t.start(...)` or
  `libuv::api::uv_timer_start(...)`.
- Several struct fields were declared as pointers to arrays where C had inline
  arrays — `char[14]* sa_data` instead of `char[14] sa_data`, and the same in
  `sockaddr_storage`, `uv_loop_t.signal_pipefd`, `uv_dir_t.reserved` and
  `uv_tcp_accept_t.accept_buffer`. Every one of those made the enclosing struct
  the wrong size. They are fixed and now verified.
- `uv_timespec64_t.tv_nsec` and `uv_timeval64_t.tv_usec` were `CLong`, which is
  64 bits on unix where libuv declares them as `int32_t`.
- `uv_sem_t` on unix was `CLong` (8 bytes) where a POSIX `sem_t` is 32 bytes,
  which corrupted the loop struct on Linux.

---

## Licence

MIT
