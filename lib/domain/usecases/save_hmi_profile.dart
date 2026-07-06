import '../entities/hmi_profile.dart';
import '../repositories/hmi_profile_repository.dart';

/// Use case: Save (create or update) an HMI profile.
class SaveHmiProfile {
  final HmiProfileRepository _repository;

  const SaveHmiProfile(this._repository);

  /// Persists the profile. If a profile with the same ID exists, it's updated.
  Future<void> call(HmiProfile profile) {
    return _repository.save(profile);
  }
}
