import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../models/hmi_profile_model.dart';

/// Local key-value storage wrapper using SharedPreferences.
class LocalStorageDatasource {
  final SharedPreferences _prefs;

  const LocalStorageDatasource(this._prefs);

  // ── Profiles ──────────────────────────────────────────────────────────────

  /// Load all saved HMI profile models.
  List<HmiProfileModel> loadProfiles() {
    final raw = _prefs.getString(AppConstants.profilesStorageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return HmiProfileModel.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  /// Persist the full list of profiles.
  Future<void> saveProfiles(List<HmiProfileModel> profiles) async {
    await _prefs.setString(
      AppConstants.profilesStorageKey,
      HmiProfileModel.encodeList(profiles),
    );
  }

  // ── Active Profile ────────────────────────────────────────────────────────

  /// Get the active profile ID, or `null`.
  String? getActiveProfileId() {
    return _prefs.getString(AppConstants.activeProfileIdKey);
  }

  /// Set the active profile ID.
  Future<void> setActiveProfileId(String id) async {
    await _prefs.setString(AppConstants.activeProfileIdKey, id);
  }

  // ── App Settings ──────────────────────────────────────────────────────────

  /// Load a boolean setting with a default value.
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  /// Persist a boolean setting.
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  /// Load a string setting.
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Persist a string setting.
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }
}
