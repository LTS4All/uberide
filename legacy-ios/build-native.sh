#!/bin/sh
set -eu

SDKROOT="${SDKROOT:-${1:-}}"
BUILD_DIR="${BUILD_DIR:-build}"
IPA_PATH="${IPA_PATH:-$BUILD_DIR/Uberide-fakesigned.ipa}"

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
  if ! command -v clang >/dev/null 2>&1 || ! command -v ld.lld >/dev/null 2>&1; then
    echo "xcodebuild is absent and Linux clang/ld.lld are not installed." >&2
    exit 1
  fi
  echo "Using Linux Clang/LLD fallback; this produces an arm64 iOS Mach-O app." >&2
  rm -rf "$BUILD_DIR/obj" "$BUILD_DIR/Uberide.app"
  mkdir -p "$BUILD_DIR/obj" "$BUILD_DIR/Uberide.app"
  for source in Uberide/main.m Uberide/UBRAppDelegate.m Uberide/UBRHomeViewController.m Uberide/UBRUberAPIClient.m; do
    name=$(basename "$source" .m)
    clang -target arm64-apple-ios9.3 -isysroot "$SDKROOT" -fobjc-arc -fblocks -I Uberide -c "$source" -o "$BUILD_DIR/obj/$name.o"
  done
  clang -target arm64-apple-ios9.3 -fuse-ld=lld -isysroot "$SDKROOT" -Wl,-platform_version,ios,9.3,9.3 -o "$BUILD_DIR/Uberide.app/Uberide" "$BUILD_DIR"/obj/*.o -framework UIKit -framework Foundation -framework CoreLocation -lobjc -lSystem
fi

cp Uberide/Info.plist "$BUILD_DIR/Uberide.app/Info.plist"
cp Uberide/Assets/icon.png Uberide/Assets/food-table.jpg Uberide/Assets/restaurant-exterior.jpg "$BUILD_DIR/Uberide.app/"
printf 'APPL????' > "$BUILD_DIR/Uberide.app/PkgInfo"
./fakesign-ipa.sh "$BUILD_DIR/Uberide.app" "$IPA_PATH"
