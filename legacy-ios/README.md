# Uberide legacy iOS target

This folder contains the Objective-C integration starter for a native iOS 9.3.5 build. The preview app in the root is an Expo prototype; Expo SDK 54 itself does not run on iOS 9.3.5, so the native target must be built separately with a legacy-compatible MapLibre Native iOS release.

## Map

`UBRMapViewController` uses MapLibre Native and the public OpenFreeMap Liberty style:

```text
https://tiles.openfreemap.org/styles/liberty
```

Keep OpenStreetMap/OpenMapTiles attribution visible in the shipped map UI and follow OpenFreeMap's current usage terms.

## Uber API

`UBRUberAPIClient` demonstrates the authorized active-request boundary. It requires an Uber OAuth access token and fetches details from the request-specific endpoint. The production app must exchange the OAuth authorization code on a secure server; never ship an Uber client secret in the app and never scrape Uber's consumer app.

Uber fleet live-location APIs are restricted to authorized fleet organizations and require the appropriate privileged scope. They are not a general-purpose way to locate arbitrary drivers. The UI must show no location until a valid authorized response includes coordinates.

Before shipping, confirm the current Uber Developer terms, scopes, endpoint versions, and approval status for the specific use case.

## Certificates

Uberide must not install certificates or profiles. OpenFreeMap and Uber use HTTPS and do not require a third-party certificate for ordinary API use. If an employer or device administrator provides a profile, verify its source and install it manually through iOS Settings only under that administrator's instruction.
