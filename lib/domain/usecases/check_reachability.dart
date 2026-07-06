import '../repositories/connectivity_repository.dart';

/// Use case: Check if an HMI device is reachable at a given IP:port.
class CheckReachability {
  final ConnectivityRepository _repository;

  const CheckReachability(this._repository);

  /// Returns `true` if the device responds within the timeout window.
  Future<bool> call(String ipAddress, int port) {
    return _repository.checkReachability(ipAddress, port);
  }
}
