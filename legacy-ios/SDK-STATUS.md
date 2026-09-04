# Uploaded SDK status

The uploaded `iPhoneOS9.2.sdk.zip` was unpacked for inspection. It contains the iPhoneOS 9.2 SDK headers, `.tbd` framework/library stubs, settings, and Apple SDK resources. It does not contain `xcodebuild`, Clang, an Apple Mach-O linker, or `ldid`; those open-source/Linux tools were installed separately in the sandbox.

The SDK plus Linux Clang, the open-source Darwin cctools/ld64 port, and Procursus ldid compiled the native sources into an armv7 arm32 iOS Mach-O executable and embedded a pseudo-signature. The native project also remains configured for a legacy-compatible Xcode installation. Example:

```sh
cd legacy-ios
SDKROOT=/path/to/iPhoneOS9.2.sdk ./build-native.sh
```

That wrapper builds `Uberide.app` with the supplied SDK and then calls `fakesign-ipa.sh`. The verified output is a jailbreak-only armv7/arm32 fakesigned IPA. Use `ARCH=arm64` for a newer arm64 device. Do not install the fakesigned IPA on stock iOS or use certificates/profiles from untrusted sources.
