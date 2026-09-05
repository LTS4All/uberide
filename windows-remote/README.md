# Uberide Windows Remote Companion

This is a **LAN-only, visibly paired remote desktop companion** for Windows 11. It serves a local control page that can be opened from Surf on the iPod touch. The PC captures the desktop as an MJPEG stream and accepts mouse/keyboard events only when the generated pairing token is supplied.

## Security model

The program binds to all local interfaces so a Wi-Fi iPod can reach the Ethernet PC, but it does not expose an unauthenticated endpoint. A fresh random token is printed in the PC console each time it starts. The token is required in the page URL. Do not forward the port to the Internet. Windows Firewall should allow the executable only on a Private network.

Press **Ctrl+Alt+Pause** on the PC to stop remote control immediately, or close the console window. The program exits when the console is closed.

## Build on Windows

Install Visual Studio 2022 with the **Desktop development with C++** workload, then open a Developer Command Prompt:

```bat
cl /std:c++17 /EHsc /O2 remotecompanion.cpp user32.lib gdi32.lib ole32.lib windowscodecs.lib ws2_32.lib /Fe:UberideRemote.exe
```

## Cross-build from Linux

The repository includes a MinGW build script. It produces a Windows x64 executable; it must still be tested on an actual Windows 11 PC because screen capture, WIC encoding, SendInput, and firewall behavior are Windows runtime features.

```sh
./build-linux.sh
```

Run `UberideRemote.exe`, note the printed address and token, then open the printed URL in Surf. The default port is `8765`; set `UBERIDE_REMOTE_PORT` to change it. The page uses an old-browser-compatible MJPEG stream rather than WebRTC.

This prototype is intended for the owner's own PC and private LAN. It does not include stealth, persistence, credential capture, or Internet exposure.
