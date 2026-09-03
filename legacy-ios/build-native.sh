#!/bin/sh
set -eu

SDKROOT="${SDKROOT:-${1:-}}"
BUILD_DIR="${BUILD_DIR:-build}"
IPA_PATH="${IPA_PATH:-$BUILD_DIR/Uberide-fakesigned.ipa}"

if [ -z "$SDKROOT" ]; then
  echo "Usage: SDKROOT=/path/to/iPhoneOS9.2.sdk ./build-native.sh" >&2
  exit 1
fi
if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "xcodebuild is required; run this on macOS with a legacy-compatible Xcode." >&2
  exit 1
fi
if [ ! -d "$SDKROOT" ]; then
  echo "SDK not found: $SDKROOT" >&2
  exit 1
fi

mkdir -p "$BUILD_DIR"
xcodebuild -project Uberide.xcodeproj -target Uberide -configuration Release -sdk "$SDKROOT" CONFIGURATION_BUILD_DIR="$BUILD_DIR" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
./fakesign-ipa.sh "$BUILD_DIR/Uberide.app" "$IPA_PATH"
