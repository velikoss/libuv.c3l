#!/usr/bin/env bash

set -euo pipefail

OUT_DIR="${1:-$PWD/uvlib}"
VERSION="${2:-1.51.0}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

case "$(uname -s)" in
	MINGW*|MSYS*|CYGWIN*) PLATFORM=windows ;;
	Darwin)               PLATFORM=darwin  ;;
	*)                    PLATFORM=unix    ;;
esac

echo "building libuv $VERSION for $PLATFORM into $OUT_DIR"

curl -sfL -o "$WORK/libuv.tar.gz" \
	"https://codeload.github.com/libuv/libuv/tar.gz/refs/tags/v$VERSION"
tar xzf "$WORK/libuv.tar.gz" -C "$WORK"
UV="$WORK/libuv-$VERSION"

mkdir -p "$WORK/obj" "$OUT_DIR"
cd "$WORK/obj"

if [ "$PLATFORM" = windows ]; then
	clang -c -O2 -I "$UV/include" -I "$UV/src" \
		-D_WIN32_WINNT=0x0602 -DWIN32_LEAN_AND_MEAN \
		-Wno-deprecated-declarations \
		"$UV"/src/*.c "$UV"/src/win/*.c
	# "-out:" rather than "/OUT:" so that MSYS does not rewrite the leading
	# slash into a Windows path.
	llvm-lib "-out:$OUT_DIR/libuv.lib" ./*.o
	LIB_NAME=libuv.lib
else
	# The unix backend is split per OS; take the shared files plus the ones
	# this platform actually has.
	SRC=("$UV"/src/*.c
		"$UV"/src/unix/async.c "$UV"/src/unix/core.c "$UV"/src/unix/dl.c
		"$UV"/src/unix/fs.c "$UV"/src/unix/getaddrinfo.c
		"$UV"/src/unix/getnameinfo.c "$UV"/src/unix/loop-watcher.c
		"$UV"/src/unix/loop.c "$UV"/src/unix/pipe.c "$UV"/src/unix/poll.c
		"$UV"/src/unix/process.c "$UV"/src/unix/signal.c
		"$UV"/src/unix/stream.c "$UV"/src/unix/tcp.c "$UV"/src/unix/thread.c
		"$UV"/src/unix/tty.c "$UV"/src/unix/udp.c)

	if [ "$PLATFORM" = darwin ]; then
		SRC+=("$UV"/src/unix/bsd-ifaddrs.c "$UV"/src/unix/darwin.c
			"$UV"/src/unix/darwin-proctitle.c "$UV"/src/unix/fsevents.c
			"$UV"/src/unix/kqueue.c "$UV"/src/unix/proctitle.c
			"$UV"/src/unix/random-getentropy.c)
		DEFS=(-D_DARWIN_USE_64_BIT_INODE=1 -D_DARWIN_UNLIMITED_SELECT=1)
	else
		SRC+=("$UV"/src/unix/linux.c "$UV"/src/unix/procfs-exepath.c
			"$UV"/src/unix/proctitle.c "$UV"/src/unix/random-devurandom.c
			"$UV"/src/unix/random-getrandom.c
			"$UV"/src/unix/random-sysctl-linux.c)
		DEFS=(-D_GNU_SOURCE)
	fi

	cc -c -O2 "${DEFS[@]}" -I "$UV/include" -I "$UV/src" "${SRC[@]}"
	ar rcs "$OUT_DIR/libuv.a" ./*.o
	LIB_NAME=libuv.a
fi

rm -rf "$OUT_DIR/include"
cp -r "$UV/include" "$OUT_DIR/include"

echo
echo "done: $OUT_DIR/$LIB_NAME"
echo "point linker-search-paths at $OUT_DIR in your project.json"
