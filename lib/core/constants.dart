/// Application-wide constants for the HMI Viewer app.
class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────────────────────────
  static const String appName = 'HMI Viewer';
  static const String appVersion = '1.0.0';

  // ── Networking ────────────────────────────────────────────────────────────
  static const int defaultPort = 80;
  static const Duration reachabilityTimeout = Duration(seconds: 3);
  static const Duration reconnectInterval = Duration(seconds: 5);
  static const Duration pageLoadTimeout = Duration(seconds: 15);

  // ── Storage Keys ──────────────────────────────────────────────────────────
  static const String profilesStorageKey = 'hmi_profiles';
  static const String activeProfileIdKey = 'hmi_active_profile_id';
  static const String settingsStorageKey = 'hmi_app_settings';

  // ── UI ────────────────────────────────────────────────────────────────────
  static const Duration floatingControlsAutoHide = Duration(seconds: 4);
  static const Duration bannerAnimationDuration = Duration(milliseconds: 300);
  static const double floatingButtonSize = 40.0;
}
