#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CXX=${CXX:-x86_64-w64-mingw32-g++}
"$CXX" -std=c++17 -O2 -static -static-libgcc -static-libstdc++ \
  "$ROOT/remotecompanion.cpp" -o "$ROOT/UberideRemote.exe" \
  -lws2_32 -luser32 -lgdi32 -lole32 -lwindowscodecs
printf 'Built %s\n' "$ROOT/UberideRemote.exe"
