# TrainMoreAccess

This project requires you to intercept and inspect requests from the TrainMore mobile app (iOS) using **mitmproxy**.

## ⚠️ Disclaimer

This guide is provided **for educational and debugging purposes only**.
Do not intercept, inspect, or modify traffic from apps or services without proper authorization.
Unauthorized use may violate laws or terms of service.

## Prerequisites

- macOS (with Homebrew installed)
- An iPhone on the same WiFi network

## Setup Steps

1. Install **mitmproxy**:
   ```bash
   brew install mitmproxy
   ```
2. Start mitmproxy:
    ```bash
    mitmproxy
    ```
3. On your iPhone, configure the WiFi settings so that traffic is routed through the local IP of the machine where mitmproxy is running.
4. On the iPhone, open http://mitm.it/#iOS and install the generated CA certificate.
5. Open the TrainMore app and display the access QR code (or trigger the network activity you want to inspect).
6. On the desktop running mitmproxy, you should now see the request captured - including headers with tokens.
7. Add your tokens to the `TrainMoreAccess Watch App/ContentView.swift`.
