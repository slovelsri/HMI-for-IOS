/// Represents a saved HMI device connection profile.
class HmiProfile {
  final String id;
  final String name;
  final String ipAddress;
  final int port;

  const HmiProfile({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.port = 80,
  });

  /// The full HTTP URL for this profile.
  String get fullUrl {
    if (port == 80) return 'http://$ipAddress';
    return 'http://$ipAddress:$port';
  }

  /// Display string: "192.168.1.50:8080" or "192.168.1.50" if port is 80.
  String get displayAddress {
    if (port == 80) return ipAddress;
    return '$ipAddress:$port';
  }

  HmiProfile copyWith({
    String? id,
    String? name,
    String? ipAddress,
    int? port,
  }) {
    return HmiProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HmiProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          ipAddress == other.ipAddress &&
          port == other.port;

  @override
  int get hashCode => Object.hash(id, name, ipAddress, port);

  @override
  String toString() => 'HmiProfile(id: $id, name: $name, addr: $displayAddress)';
}
