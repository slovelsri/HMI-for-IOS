import '../entities/hmi_profile.dart';
import '../repositories/hmi_profile_repository.dart';

/// Use case: Retrieve all saved HMI profiles.
class GetHmiProfiles {
  final HmiProfileRepository _repository;

  const GetHmiProfiles(this._repository);

  Future<List<HmiProfile>> call() {
    return _repository.getAll();
  }
}
