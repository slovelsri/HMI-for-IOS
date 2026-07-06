/// Validates IPv4 address and optional port formats.
class IpValidator {
  IpValidator._();

  static final _ipv4Pattern = RegExp(
    r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$',
  );

  /// Validates an IPv4 address string.
  /// Returns `null` if valid, or an error message string if invalid.
  static String? validateIp(String? ip) {
    if (ip == null || ip.trim().isEmpty) {
      return 'IP address is required';
    }

    final trimmed = ip.trim();
    final match = _ipv4Pattern.firstMatch(trimmed);

    if (match == null) {
      return 'Invalid IP format (expected: 192.168.1.50)';
    }

    // Validate each octet is 0–255.
    for (var i = 1; i <= 4; i++) {
      final octet = int.tryParse(match.group(i)!) ?? -1;
      if (octet < 0 || octet > 255) {
        return 'Each IP octet must be 0–255';
      }
    }

    return null; // Valid.
  }

  /// Validates a port number string.
  /// Returns `null` if valid, or an error message string if invalid.
  static String? validatePort(String? port) {
    if (port == null || port.trim().isEmpty) {
      return null; // Port is optional — defaults to 80.
    }

    final portNum = int.tryParse(port.trim());
    if (portNum == null || portNum < 1 || portNum > 65535) {
      return 'Port must be 1–65535';
    }

    return null; // Valid.
  }

  /// Validates an IP:port combination entered in a single field.
  /// Accepts: "192.168.1.50", "192.168.1.50:8080"
  static String? validateIpWithOptionalPort(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'IP address is required';
    }

    final trimmed = input.trim();
    final parts = trimmed.split(':');

    if (parts.length > 2) {
      return 'Invalid format (expected: 192.168.1.50 or 192.168.1.50:8080)';
    }

    final ipError = validateIp(parts[0]);
    if (ipError != null) return ipError;

    if (parts.length == 2) {
      final portError = validatePort(parts[1]);
      if (portError != null) return portError;
    }

    return null; // Valid.
  }
}
