# libuv.c3l

Port of [libuv](https://github.com/libuv/libuv) to [C3](https://github.com/c3lang/c3c) language

## Installation

- Install libuv to your OS
- Inside your project libs directory run:
```
git clone https://github.com/velikoss/libuv.c3l
```
- And add `libuv` to your project.json dependencies
- *For Windows users its necessary to add this in project.json*
  ```json
  "linked-libraries": ["advapi32", "userenv", "iphlpapi", "ole32"],
  "linker-search-paths": ["./build/", "C:/Windows/System32"],
  "wincrt": "none",
  ```
  *Where `./build/` is path to libuv.dll*
---
## Basic usage
#### Repeating timer
```c
import libuv;
import std::io;

fn void timer_cb(UVTimer* handle) {
    io::printn("Hi from libuv.c3l!");
    libuv::uv_timer_again(handle);
}

fn int main(String[] args) {
    UVTimer timer;
    libuv::uv_timer_init(libuv::uv_default_loop(), &timer);
    libuv::uv_timer_start(&timer, &timer_cb, 100, 100);
    libuv::uv_run(libuv::uv_default_loop(), UV_RUN_DEFAULT);
    return libuv::uv_loop_close(libuv::uv_default_loop());
}
```
