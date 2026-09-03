# Uploaded SDK status

The uploaded `iPhoneOS9.2.sdk.zip` was unpacked for inspection. It contains the iPhoneOS 9.2 SDK headers, `.tbd` framework/library stubs, settings, and Apple SDK resources. It does **not** contain `xcodebuild`, Clang, an Apple Mach-O linker, or `ldid`.

Therefore the SDK alone cannot compile an IPA in the Linux sandbox. The native project is configured to use it on a Mac with a legacy-compatible Xcode installation. Example:

```sh
cd legacy-ios
SDKROOT=/path/to/iPhoneOS9.2.sdk ./build-native.sh
```

That wrapper builds an unsigned `Uberide.app` with the supplied SDK and then calls `fakesign-ipa.sh`. The final output is a jailbreak-only fakesigned IPA. Do not install it on stock iOS or use certificates/profiles from untrusted sources.
