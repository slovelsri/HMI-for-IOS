/// Connectivity status for WiFi monitoring.
enum ConnectivityStatus {
  connected,
  disconnected,
  unknown,
}

/// Abstract interface for network connectivity operations.
abstract class ConnectivityRepository {
  /// Check if a specific IP:port is reachable via HTTP.
  Future<bool> checkReachability(String ipAddress, int port);

  /// Stream of WiFi connectivity changes.
  Stream<ConnectivityStatus> watchConnectivity();

  /// One-shot check of current WiFi state.
  Future<ConnectivityStatus> getCurrentConnectivity();
}
