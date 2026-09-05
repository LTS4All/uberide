#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SDKROOT="${SDKROOT:-/home/ubuntu/ios92-sdk/iPhoneOS9.2.sdk}"
BUILD_DIR="${BUILD_DIR:-$ROOT/build-armv7}"
OBJ_DIR="$BUILD_DIR/obj"
APP_DIR="$BUILD_DIR/Surf.app"
IPA_PATH="${IPA_PATH:-$BUILD_DIR/Surf-fakesigned.ipa}"
CLANG="${CLANG:-clang}"
LD="${DARWIN_LD:-/home/ubuntu/cctools/bin/arm-apple-darwin11-ld}"

rm -rf "$OBJ_DIR" "$APP_DIR"
mkdir -p "$OBJ_DIR" "$APP_DIR"

COMMON="-target armv7-apple-ios9.3 -isysroot $SDKROOT -I $ROOT/Classes -I $ROOT/Classes/quirc -DRBAppVersion=@\"0.15.5\" -DRBCompatibilityVersion=@\"1\""

for source in "$ROOT"/Classes/*.m; do
  name=$(basename "$source" .m)
  # shellcheck disable=SC2086
  "$CLANG" $COMMON -fobjc-arc -fblocks -c "$source" -o "$OBJ_DIR/$name.o"
done
for source in "$ROOT"/Classes/*.c "$ROOT"/Classes/quirc/*.c; do
  name=$(basename "$source" .c)
  # shellcheck disable=SC2086
  "$CLANG" $COMMON -fblocks -c "$source" -o "$OBJ_DIR/$name.o"
done

# shellcheck disable=SC2086
"$CLANG" -target armv7-apple-ios9.3 -fuse-ld="$LD" -isysroot "$SDKROOT" \
  -Wl,-syslibroot,"$SDKROOT" -Wl,-platform_version,ios,6.0,9.3 \
  -o "$APP_DIR/Surf" "$OBJ_DIR"/*.o \
  -framework Foundation -framework CoreFoundation -framework UIKit \
  -framework CoreGraphics -framework QuartzCore -framework ImageIO \
  -framework Security -framework CFNetwork -framework AudioToolbox \
  -framework CoreMedia -framework CoreVideo -framework OpenGLES \
  -framework MessageUI -framework AVFoundation -framework CoreText \
  -framework MobileCoreServices -lobjc -lSystem

cp "$ROOT/Resources/Info.plist" "$APP_DIR/Info.plist"
cp "$ROOT/Resources/icon-57.png" "$APP_DIR/Icon.png"
cp "$ROOT/Resources/icon-57@2x.png" "$APP_DIR/Icon@2x.png"
cp "$ROOT/Resources/icon-72.png" "$APP_DIR/Icon-72.png"
cp "$ROOT/Resources/icon-72@2x.png" "$APP_DIR/Icon-72@2x.png"
cp "$ROOT/Resources/icon-60.png" "$APP_DIR/Icon-60.png"
cp "$ROOT/Resources/icon-60@2x.png" "$APP_DIR/Icon-60@2x.png"
cp "$ROOT/Resources/icon-76.png" "$APP_DIR/Icon-76.png"
cp "$ROOT/Resources/icon-76@2x.png" "$APP_DIR/Icon-76@2x.png"
cp "$ROOT/Resources/Lucide.ttf" "$APP_DIR/Lucide.ttf"
cp "$ROOT/Resources/brand-mark.png" "$APP_DIR/brand-mark.png"
cp "$ROOT/Resources/Default.png" "$APP_DIR/Default.png"
cp "$ROOT/Resources/Default@2x.png" "$APP_DIR/Default@2x.png"
printf 'APPL????' > "$APP_DIR/PkgInfo"

ENTITLEMENTS="${ENTITLEMENTS:-$ROOT/Resources/Surf.entitlements}"
"$ROOT/../legacy-ios/fakesign-ipa.sh" "$APP_DIR" "$IPA_PATH" "$ENTITLEMENTS"
printf 'Created Surf ARM32 fakesigned IPA: %s\n' "$IPA_PATH"
