import '../constants.dart';

/// Normalizes user input into a proper HTTP URL for the HMI device.
class UrlBuilder {
  UrlBuilder._();

  /// Builds a full `http://` URL from an IP address and port.
  ///
  /// - If [port] is `80` (default), the port is omitted from the URL.
  /// - Always produces `http://` — HMI devices don't use TLS.
  static String build(String ipAddress, [int port = AppConstants.defaultPort]) {
    final ip = ipAddress.trim();
    if (port == 80) {
      return 'http://$ip';
    }
    return 'http://$ip:$port';
  }

  /// Normalizes raw user input into a full URL.
  ///
  /// Accepts:
  /// - `192.168.1.50` → `http://192.168.1.50`
  /// - `192.168.1.50:8080` → `http://192.168.1.50:8080`
  /// - `http://192.168.1.50` → passed through unchanged
  /// - `https://192.168.1.50` → passed through unchanged
  static String fromRawInput(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'http://$trimmed';
  }
}
