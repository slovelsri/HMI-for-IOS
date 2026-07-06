import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local_storage_datasource.dart';
import 'hmi_profile_providers.dart';

// ── Setting Keys ────────────────────────────────────────────────────────────

class SettingKeys {
  SettingKeys._();
  static const kioskMode = 'setting_kiosk_mode';
  static const pinchToZoom = 'setting_pinch_to_zoom';
  static const orientationLock = 'setting_orientation_lock'; // 'auto', 'portrait', 'landscape'
  static const autoReconnect = 'setting_auto_reconnect';
  static const pullToRefresh = 'setting_pull_to_refresh';
}

// ── App Settings State ──────────────────────────────────────────────────────

class AppSettings {
  final bool kioskMode;
  final bool pinchToZoom;
  final String orientationLock; // 'auto', 'portrait', 'landscape'
  final bool autoReconnect;
  final bool pullToRefresh;

  const AppSettings({
    this.kioskMode = false,
    this.pinchToZoom = false,
    this.orientationLock = 'auto',
    this.autoReconnect = true,
    this.pullToRefresh = false,
  });

  AppSettings copyWith({
    bool? kioskMode,
    bool? pinchToZoom,
    String? orientationLock,
    bool? autoReconnect,
    bool? pullToRefresh,
  }) {
    return AppSettings(
      kioskMode: kioskMode ?? this.kioskMode,
      pinchToZoom: pinchToZoom ?? this.pinchToZoom,
      orientationLock: orientationLock ?? this.orientationLock,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      pullToRefresh: pullToRefresh ?? this.pullToRefresh,
    );
  }
}

// ── Provider ────────────────────────────────────────────────────────────────

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(ref.watch(localStorageProvider)),
);

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final LocalStorageDatasource _storage;

  AppSettingsNotifier(this._storage) : super(const AppSettings()) {
    _load();
  }

  void _load() {
    state = AppSettings(
      kioskMode: _storage.getBool(SettingKeys.kioskMode),
      pinchToZoom: _storage.getBool(SettingKeys.pinchToZoom),
      orientationLock:
          _storage.getString(SettingKeys.orientationLock) ?? 'auto',
      autoReconnect: _storage.getBool(SettingKeys.autoReconnect, defaultValue: true),
      pullToRefresh: _storage.getBool(SettingKeys.pullToRefresh),
    );
  }

  Future<void> setKioskMode(bool value) async {
    await _storage.setBool(SettingKeys.kioskMode, value);
    state = state.copyWith(kioskMode: value);
  }

  Future<void> setPinchToZoom(bool value) async {
    await _storage.setBool(SettingKeys.pinchToZoom, value);
    state = state.copyWith(pinchToZoom: value);
  }

  Future<void> setOrientationLock(String value) async {
    await _storage.setString(SettingKeys.orientationLock, value);
    state = state.copyWith(orientationLock: value);
  }

  Future<void> setAutoReconnect(bool value) async {
    await _storage.setBool(SettingKeys.autoReconnect, value);
    state = state.copyWith(autoReconnect: value);
  }

  Future<void> setPullToRefresh(bool value) async {
    await _storage.setBool(SettingKeys.pullToRefresh, value);
    state = state.copyWith(pullToRefresh: value);
  }
}
