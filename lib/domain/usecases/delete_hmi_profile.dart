import '../repositories/hmi_profile_repository.dart';

/// Use case: Delete an HMI profile by ID.
class DeleteHmiProfile {
  final HmiProfileRepository _repository;

  const DeleteHmiProfile(this._repository);

  Future<void> call(String id) {
    return _repository.delete(id);
  }
}
