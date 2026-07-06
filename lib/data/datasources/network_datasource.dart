import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/constants.dart';
import '../../domain/repositories/connectivity_repository.dart';

/// Network datasource: reachability checks and WiFi state monitoring.
class NetworkDatasource {
  final Connectivity _connectivity;

  NetworkDatasource([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  /// Attempt an HTTP GET to the given [ip]:[port] with a short timeout.
  /// Returns `true` if the device responds, `false` otherwise.
  Future<bool> isReachable(String ip, int port) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = AppConstants.reachabilityTimeout;
      final uri = Uri.parse('http://$ip:$port');
      final request = await client.getUrl(uri).timeout(
            AppConstants.reachabilityTimeout + const Duration(seconds: 1),
          );
      final response = await request.close().timeout(
            AppConstants.reachabilityTimeout + const Duration(seconds: 1),
          );
      // Drain the response body.
      await response.drain<void>();
      client.close();
      // Any HTTP response (even 4xx/5xx) means the device is reachable.
      return true;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } on HttpException {
      // HTTP error but the device responded — still "reachable".
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Stream WiFi connectivity changes as [ConnectivityStatus].
  Stream<ConnectivityStatus> watchConnectivity() {
    return _connectivity.onConnectivityChanged.map((results) {
      if (results.contains(ConnectivityResult.wifi)) {
        return ConnectivityStatus.connected;
      }
      if (results.contains(ConnectivityResult.ethernet)) {
        return ConnectivityStatus.connected;
      }
      if (results.contains(ConnectivityResult.none)) {
        return ConnectivityStatus.disconnected;
      }
      return ConnectivityStatus.unknown;
    });
  }

  /// One-shot current WiFi check.
  Future<ConnectivityStatus> getCurrentConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet)) {
      return ConnectivityStatus.connected;
    }
    if (results.contains(ConnectivityResult.none)) {
      return ConnectivityStatus.disconnected;
    }
    return ConnectivityStatus.unknown;
  }
}
