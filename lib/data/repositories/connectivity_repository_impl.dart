import '../../domain/repositories/connectivity_repository.dart';
import '../datasources/network_datasource.dart';

/// Concrete implementation of [ConnectivityRepository].
class ConnectivityRepositoryImpl implements ConnectivityRepository {
  final NetworkDatasource _network;

  const ConnectivityRepositoryImpl(this._network);

  @override
  Future<bool> checkReachability(String ipAddress, int port) {
    return _network.isReachable(ipAddress, port);
  }

  @override
  Stream<ConnectivityStatus> watchConnectivity() {
    return _network.watchConnectivity();
  }

  @override
  Future<ConnectivityStatus> getCurrentConnectivity() {
    return _network.getCurrentConnectivity();
  }
}
