#!/bin/sh
set -eu

SDKROOT="${SDKROOT:-${1:-}}"
BUILD_DIR="${BUILD_DIR:-build}"
IPA_PATH="${IPA_PATH:-$BUILD_DIR/Uberide-fakesigned.ipa}"
ARCH="${ARCH:-armv7}"

if [ -z "$SDKROOT" ]; then
  echo "Usage: SDKROOT=/path/to/iPhoneOS9.2.sdk ./build-native.sh" >&2
  exit 1
fi
if [ ! -d "$SDKROOT" ]; then
  echo "SDK not found: $SDKROOT" >&2
  exit 1
fi

mkdir -p "$BUILD_DIR"

if command -v xcodebuild >/dev/null 2>&1; then
  xcodebuild -project Uberide.xcodeproj -target Uberide -configuration Release -sdk "$SDKROOT" CONFIGURATION_BUILD_DIR="$BUILD_DIR" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
else
  if ! command -v clang >/dev/null 2>&1; then
    echo "xcodebuild is absent and clang is not installed." >&2
    exit 1
  fi
  rm -rf "$BUILD_DIR/obj" "$BUILD_DIR/Uberide.app"
  mkdir -p "$BUILD_DIR/obj" "$BUILD_DIR/Uberide.app"
  if [ "$ARCH" = "armv7" ]; then
    TARGET="armv7-apple-ios9.3"
    LINKER="/home/ubuntu/cctools/bin/arm-apple-darwin11-ld"
    if [ ! -x "$LINKER" ]; then
      echo "armv7 Darwin linker not found: $LINKER" >&2
      exit 1
    fi
    LINK_FLAGS="-fuse-ld=$LINKER -Wl,-syslibroot,$SDKROOT"
  elif [ "$ARCH" = "arm64" ]; then
    TARGET="arm64-apple-ios9.3"
    LINK_FLAGS="-fuse-ld=lld"
  else
    echo "Unsupported ARCH=$ARCH; use armv7 or arm64." >&2
    exit 1
  fi
  echo "Using Linux Clang/Darwin linker fallback for $ARCH." >&2
  for source in Uberide/main.m Uberide/UBRAppDelegate.m Uberide/UBRHomeViewController.m Uberide/UBRUberAPIClient.m; do
    name=$(basename "$source" .m)
    clang -target "$TARGET" -isysroot "$SDKROOT" -fobjc-arc -fblocks -I Uberide -c "$source" -o "$BUILD_DIR/obj/$name.o"
  done
  clang -target "$TARGET" $LINK_FLAGS -isysroot "$SDKROOT" -Wl,-platform_version,ios,9.3,9.3 -o "$BUILD_DIR/Uberide.app/Uberide" "$BUILD_DIR"/obj/*.o -framework UIKit -framework Foundation -framework CoreLocation -lobjc -lSystem
fi

cp Uberide/Info.plist "$BUILD_DIR/Uberide.app/Info.plist"
cp Uberide/Assets/icon.png "$BUILD_DIR/Uberide.app/"
printf 'APPL????' > "$BUILD_DIR/Uberide.app/PkgInfo"
./fakesign-ipa.sh "$BUILD_DIR/Uberide.app" "$IPA_PATH"
