# Uberide native iOS 9.3.5 app

This directory is the **native Objective-C app**, separate from the earlier web prototype. It targets an iPod touch running iOS 9.3.5 and uses UIKit, Core Location, a compact curved iOS 6-inspired interface, real bundled food photos, an Order Food section, Rides, place details, Google Maps directions, and an embedded official web handoff for Uber Eats and Uber rides.

## Open the project

Open `Uberide.xcodeproj` with a legacy-compatible Xcode installation that still contains an iOS 9-compatible iPhoneOS SDK. The project target is `com.uberide.legacy`, deployment target 9.3, device family iPhone/iPod, and architectures armv7/arm64. Add the files under `Uberide/` and the resources under `Uberide/Assets/` to the target if Xcode does not pick them up automatically.

## Order and Uber behavior

Food BUY buttons and the detail dialog open `https://www.ubereats.com/` inside a native `UIWebView`. Ride GO buttons open `https://m.uber.com/ul/` in the same way. Uberide does not scrape Uber or Uber Eats, process payment, or copy Uber content. It uses official web handoffs and the authorized Uber API client only where an approved OAuth token and scope are available.

The bundled photos are local lightweight assets. Replace them only with images that are legally reusable or covered by the local restaurant/town owner’s permission, and preserve any required attribution.

## Location

The app includes typed location entry and a **USE MY LOCATION** control backed by Core Location. It uses iOS 9-compatible APIs and shows a fallback message when permission is denied. The user’s location is not silently collected or uploaded. After geocoding, the app sends the coordinates to the public Overpass endpoint at `https://overpass-api.de/api/interpreter` and requests up to 100 nearby named places within 5 km using `amenity=restaurant`, `amenity=cafe`, `amenity=fast_food`, and `amenity=pub`. Overpass/OpenStreetMap data does not provide review scores, so the detail view states that clearly.

## Uberide AI

The corner Uberide AI control is a key-free local helper. It answers basic questions from the currently selected place facts and explains how to open directions or Uber Eats. It does not use OpenRouter, does not require an API key, and does not make an undisclosed network AI request.

## Build and fakesign

A final device IPA can be built on a Mac with legacy Xcode or on Linux using the supplied SDK plus Clang, the Darwin ld64 port, and `ldid`. The current replacement build was produced with the Linux fallback as an **armv7 arm32 Mach-O IPA** for older iPod touch hardware. On a compatible build machine:

1. Set `SDKROOT` to the supplied `iPhoneOS9.2.sdk` directory.
2. Run `SDKROOT=/path/to/iPhoneOS9.2.sdk ARCH=armv7 ./build-native.sh` (or open the Xcode project on macOS).
3. Transfer `build/Uberide-fakesigned.ipa` to the user’s own compatible jailbroken iPod touch and install it using the device’s supported jailbreak installer/trust component.

The resulting IPA is **jailbreak-only** and is not intended for stock iOS. Fakesigning bypasses Apple’s normal distribution signing; do not use it to distribute the app to other people or to install profiles/certificates from untrusted sources. The Linux fallback also supports `ARCH=arm64` when building for a newer arm64 iPod touch.

## Files

- `Uberide.xcodeproj/project.pbxproj` — native Xcode project configuration.
- `Uberide/main.m` — application entry point.
- `Uberide/UBRAppDelegate.*` — window and navigation root.
- `Uberide/UBRHomeViewController.*` — Food/Rides UI, location, details, AI helper, and web handoffs.
- `Uberide/UBRUberAPIClient.*` — authorized Uber API boundary; no scraping.
- `Uberide/Assets/` — icon and bundled food photos.
- `fakesign-ipa.sh` — jailbreak-only IPA packaging script.
- `native-build-settings.txt` — deployment and architecture reference.
