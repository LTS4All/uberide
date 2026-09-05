#!/bin/sh
set -eu

APP_PATH="${1:-build/Uberide.app}"
OUTPUT_IPA="${2:-build/Uberide-fakesigned.ipa}"

if [ ! -d "$APP_PATH" ]; then
  echo "Missing app bundle: $APP_PATH" >&2
  echo "Build the Objective-C target with an iOS 9-compatible toolchain first." >&2
  exit 1
fi
if ! command -v ldid >/dev/null 2>&1; then
  echo "ldid is required for jailbreak-only fakesigning." >&2
  echo "Install a compatible ldid on the legacy build machine, then run this script again." >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT_IPA")"
WORK_DIR="$(mktemp -d /tmp/uberide-fakesign.XXXXXX)"
trap 'rm -rf "$WORK_DIR"' EXIT
mkdir -p "$WORK_DIR/Payload"
cp -R "$APP_PATH" "$WORK_DIR/Payload/Uberide.app"

APP_EXECUTABLE="$WORK_DIR/Payload/Uberide.app/$(basename "$APP_PATH" .app)"
ENTITLEMENTS="${ENTITLEMENTS:-}"
if [ -n "$ENTITLEMENTS" ] && [ -f "$ENTITLEMENTS" ]; then
  ldid -S"$ENTITLEMENTS" "$APP_EXECUTABLE"
else
  ldid -S "$APP_EXECUTABLE"
fi
rm -f "$OUTPUT_IPA"
(cd "$WORK_DIR" && /usr/bin/zip -qry "$OLDPWD/$OUTPUT_IPA" Payload)

echo "Created jailbreak-only fakesigned IPA: $OUTPUT_IPA"
echo "This IPA is not for stock iOS and requires a compatible jailbreak-side trust component."
