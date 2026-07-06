import '../repositories/hmi_profile_repository.dart';

/// Use case: Set the active HMI profile that loads on app launch.
class SetActiveProfile {
  final HmiProfileRepository _repository;

  const SetActiveProfile(this._repository);

  Future<void> call(String profileId) {
    return _repository.setActiveProfileId(profileId);
  }
}
