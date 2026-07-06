import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/network_datasource.dart';
import '../../data/repositories/connectivity_repository_impl.dart';
import '../../domain/repositories/connectivity_repository.dart';

// ── Infrastructure ──────────────────────────────────────────────────────────

final networkDatasourceProvider = Provider<NetworkDatasource>(
  (ref) => NetworkDatasource(),
);

final connectivityRepositoryProvider = Provider<ConnectivityRepository>(
  (ref) => ConnectivityRepositoryImpl(ref.watch(networkDatasourceProvider)),
);

// ── WiFi Connectivity Stream ────────────────────────────────────────────────

/// Stream of WiFi connectivity status changes.
final wifiConnectivityProvider = StreamProvider<ConnectivityStatus>((ref) {
  final repo = ref.watch(connectivityRepositoryProvider);
  return repo.watchConnectivity();
});

/// Current WiFi connectivity (one-shot).
final currentConnectivityProvider = FutureProvider<ConnectivityStatus>((ref) {
  final repo = ref.watch(connectivityRepositoryProvider);
  return repo.getCurrentConnectivity();
});

// ── Reachability Check ──────────────────────────────────────────────────────

/// Parameters for a reachability check.
class ReachabilityParams {
  final String ip;
  final int port;

  const ReachabilityParams(this.ip, this.port);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReachabilityParams && ip == other.ip && port == other.port;

  @override
  int get hashCode => Object.hash(ip, port);
}

/// Family provider for checking reachability of a specific IP:port.
final reachabilityProvider =
    FutureProvider.family<bool, ReachabilityParams>((ref, params) {
  final repo = ref.watch(connectivityRepositoryProvider);
  return repo.checkReachability(params.ip, params.port);
});

/// Viewer connection state — tracks live connection status during viewing.
final viewerConnectionProvider =
    StateNotifierProvider<ViewerConnectionNotifier, ViewerConnectionState>(
  (ref) => ViewerConnectionNotifier(ref),
);

// ── Viewer Connection State ─────────────────────────────────────────────────

enum ViewerConnectionState {
  connected,
  reconnecting,
  disconnected,
}

class ViewerConnectionNotifier extends StateNotifier<ViewerConnectionState> {
  final Ref _ref;
  Timer? _reconnectTimer;
  StreamSubscription<ConnectivityStatus>? _connectivitySub;

  ViewerConnectionNotifier(this._ref) : super(ViewerConnectionState.connected);

  void startMonitoring(String ip, int port) {
    _connectivitySub?.cancel();
    final repo = _ref.read(connectivityRepositoryProvider);

    _connectivitySub = repo.watchConnectivity().listen((status) {
      if (status == ConnectivityStatus.disconnected) {
        state = ViewerConnectionState.disconnected;
        _startReconnect(ip, port);
      } else if (status == ConnectivityStatus.connected) {
        _checkReachability(ip, port);
      }
    });
  }

  void _startReconnect(String ip, int port) {
    _reconnectTimer?.cancel();
    state = ViewerConnectionState.reconnecting;
    _reconnectTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkReachability(ip, port),
    );
  }

  Future<void> _checkReachability(String ip, int port) async {
    final repo = _ref.read(connectivityRepositoryProvider);
    final reachable = await repo.checkReachability(ip, port);
    if (reachable) {
      _reconnectTimer?.cancel();
      state = ViewerConnectionState.connected;
    } else if (state != ViewerConnectionState.reconnecting) {
      _startReconnect(ip, port);
    }
  }

  Future<void> manualRetry(String ip, int port) async {
    state = ViewerConnectionState.reconnecting;
    await _checkReachability(ip, port);
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }
}
