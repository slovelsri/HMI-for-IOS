# HMI Viewer

A production-ready Flutter application that acts as a dedicated kiosk-style viewer for V-Box HMI devices on a local network. The app loads the HMI's web-based control UI inside a full-screen WebView, hiding all browser chrome to look and feel like a native control panel.

## Features

- **Full-screen HMI display** — Embedded WebView with no URL bar, no tabs, no browser UI
- **Multiple HMI profiles** — Save and switch between multiple HMI devices (name + IP + port)
- **Connection monitoring** — Real-time WiFi state tracking with auto-reconnect on disconnect
- **Kiosk mode** — Hide system status/navigation bars for a true full-screen panel experience
- **Screen wake lock** — Keeps the display on while the HMI viewer is active
- **Configurable display** — Pinch-to-zoom toggle, orientation lock (auto/portrait/landscape), pull-to-refresh
- **Graceful error handling** — No blank white screens; custom error overlays with retry buttons
- **Splash/connection screen** — Pre-flight WiFi & reachability check before loading the WebView
- **Floating controls** — Auto-hiding settings and reload buttons that don't obstruct the HMI UI

## Architecture

Clean Architecture with three layers + core:

```
lib/
├── core/           # Constants, theme, error types, utilities
├── data/           # Repository implementations, datasources, models
├── domain/         # Entities, repository interfaces, use cases
└── presentation/   # Screens, widgets, Riverpod providers
```

**State management**: [Riverpod](https://riverpod.dev/) for state management and dependency injection.

**WebView**: [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) — chosen over `webview_flutter` for better kiosk-mode control (zoom management, pull-to-refresh suppression, context menu disable, error page handling).

## Quick Start

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.5.0+)
- Android Studio or Xcode (for device deployment)
- A physical Android/iOS device on the same WiFi network as the HMI

### Run on Android

```bash
cd hmi_viewer
flutter pub get
flutter run                    # Debug mode on connected device
flutter build apk              # Release APK
flutter build appbundle        # Release AAB for Play Store
```

### Run on iOS (requires macOS + Xcode)

```bash
cd hmi_viewer
flutter pub get
flutter run                    # Debug mode on connected device
flutter build ios              # Release build (open in Xcode to archive)
```

## Configuring the Default HMI IP

The app starts with an empty "Add your first HMI profile" flow. Users enter their HMI's IP address and port on first launch, and the app persists it locally.

To pre-configure a default IP for deployment, edit `lib/core/constants.dart`:

```dart
static const String defaultIp = '192.168.1.50';
static const int defaultPort = 80;
```

## Platform Configuration

### Android — Cleartext HTTP

HMI devices serve their web UI over plain HTTP (no TLS). Android blocks cleartext by default, so two changes are made:

1. **`AndroidManifest.xml`**: `android:usesCleartextTraffic="true"` + `android:networkSecurityConfig` reference
2. **`res/xml/network_security_config.xml`**: Allows cleartext specifically for RFC 1918 private IP ranges (192.168.x.x, 10.x.x.x, 172.16.x.x)

Permissions added: `INTERNET`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`

### iOS — App Transport Security

iOS blocks non-HTTPS traffic by default. Changes in `Info.plist`:

1. **`NSAppTransportSecurity`**: `NSAllowsArbitraryLoads = true`, `NSAllowsLocalNetworking = true`
2. **`NSLocalNetworkUsageDescription`**: Required by iOS 14+ for the local network permission prompt

## Known Platform Limitations

### iOS

- **Local Network Permission**: iOS 14+ shows a system dialog asking the user to allow local network access. If denied, the app cannot reach the HMI. The app guides users to re-enable this in Settings → Privacy → Local Network.
- **ATS Exception**: `NSAllowsArbitraryLoads = true` is a broad exception. For App Store submission, Apple may request justification — the rationale is that HMI devices on local networks don't have valid TLS certificates.

### Android

- **Cleartext Traffic**: The `network_security_config.xml` uses `cleartextTrafficPermitted="true"` with domain-config for local IP ranges. Since Android's domain matching doesn't perfectly handle raw IP addresses, the base-config also allows cleartext as a fallback.
- **WebView Version**: The system WebView version affects rendering. Users with very old WebView versions may experience UI issues with modern HMI dashboards.

### General

- **WiFi Only**: The app is designed for local WiFi networks only. It does not work over mobile data, VPN, or cloud relays.
- **No HTTPS Support for HMI**: While the URL builder passes through `https://` URLs, HMI devices typically don't support TLS.

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.5.1 | State management + DI |
| `flutter_inappwebview` | ^6.1.5 | WebView with kiosk controls |
| `shared_preferences` | ^2.3.3 | Local profile/settings storage |
| `connectivity_plus` | ^6.1.0 | WiFi state monitoring |
| `wakelock_plus` | ^1.2.8 | Keep screen on during viewing |
| `uuid` | ^4.5.1 | Profile ID generation |
| `mocktail` | ^1.0.4 | Test mocking (dev only) |

## Running Tests

```bash
flutter test
```

Covers:
- `CheckReachability` use case (mock connectivity repo)
- `SaveHmiProfile` use case + `HmiProfile` entity (URLs, equality)
- `IpValidator` utility (IP format, port range, edge cases)
