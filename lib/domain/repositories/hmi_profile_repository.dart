import '../entities/hmi_profile.dart';

/// Abstract interface for HMI profile persistence.
abstract class HmiProfileRepository {
  /// Returns all saved profiles.
  Future<List<HmiProfile>> getAll();

  /// Saves (creates or updates) a profile.
  Future<void> save(HmiProfile profile);

  /// Deletes a profile by ID.
  Future<void> delete(String id);

  /// Returns the currently active profile ID, or `null` if none set.
  Future<String?> getActiveProfileId();

  /// Sets the active profile ID.
  Future<void> setActiveProfileId(String id);

  /// Convenience: returns the active profile, or `null`.
  Future<HmiProfile?> getActiveProfile();
}
