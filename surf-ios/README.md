# Surf ARM32 browser app

This directory contains the supplied Surf 0.15.5 native iOS client, packaged as a separate app named **Surf**. The source is included under the MIT license in `SURF-LICENSE.txt`; the upstream third-party notices are retained in `THIRD_PARTY_NOTICES.md`.

Surf is a **remote browser**, not an embedded WebKit replacement. It renders modern websites on a Surf host computer and streams the result to the legacy iPod/iPhone client. To use it, run a Surf host/server on a computer, install Surf on the jailbroken device, and pair the device using Surf’s QR or six-digit pairing flow. The app registers `surf`, `surf-http`, and `surf-https` URL schemes, so Uberide can hand official Uber and Uber Eats links to it.

## ARM32 build

With the uploaded `iPhoneOS9.2.sdk` unpacked and the Linux Darwin linker available:

```sh
SDKROOT=/home/ubuntu/ios92-sdk/iPhoneOS9.2.sdk \
  BUILD_DIR=/home/ubuntu/uberide/surf-ios/build-armv7 \
  IPA_PATH=/home/ubuntu/uberide/surf-ios/build-armv7/Surf-fakesigned.ipa \
  ./build-armv7.sh
```

The generated IPA targets `armv7` and iOS 6.0+, and is **jailbreak-only fakesigned**. It is not installable on stock iOS with Apple’s normal trust chain.

The standalone package uses bundle identifier `com.uberide.surf.browser` and build version `100`, rather than Surf’s original `space.seg6.surf` identity. This prevents Sideloadly or a jailbreak package manager from treating it as an upgrade of an existing system Surf package, which is the cause of the “ApplicationVerificationFailed / missing upgrade entitlement” dialog. No ordinary certificate can add Apple’s private `com.apple.private.mobileinstall.*` upgrade entitlement; on stock iOS, use a genuine Apple-signed provisioning profile instead.
