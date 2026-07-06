import '../../domain/entities/hmi_profile.dart';
import '../../domain/repositories/hmi_profile_repository.dart';
import '../datasources/local_storage_datasource.dart';
import '../models/hmi_profile_model.dart';

/// Concrete implementation of [HmiProfileRepository] using local storage.
class HmiProfileRepositoryImpl implements HmiProfileRepository {
  final LocalStorageDatasource _storage;

  const HmiProfileRepositoryImpl(this._storage);

  @override
  Future<List<HmiProfile>> getAll() async {
    return _storage.loadProfiles().map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> save(HmiProfile profile) async {
    final models = _storage.loadProfiles();
    final index = models.indexWhere((m) => m.id == profile.id);
    final model = HmiProfileModel.fromEntity(profile);

    if (index >= 0) {
      models[index] = model;
    } else {
      models.add(model);
    }

    await _storage.saveProfiles(models);
  }

  @override
  Future<void> delete(String id) async {
    final models = _storage.loadProfiles();
    models.removeWhere((m) => m.id == id);
    await _storage.saveProfiles(models);

    // If the deleted profile was active, clear the active ID.
    if (_storage.getActiveProfileId() == id) {
      if (models.isNotEmpty) {
        await _storage.setActiveProfileId(models.first.id);
      }
    }
  }

  @override
  Future<String?> getActiveProfileId() async {
    return _storage.getActiveProfileId();
  }

  @override
  Future<void> setActiveProfileId(String id) async {
    await _storage.setActiveProfileId(id);
  }

  @override
  Future<HmiProfile?> getActiveProfile() async {
    final activeId = _storage.getActiveProfileId();
    if (activeId == null) return null;

    final profiles = _storage.loadProfiles();
    try {
      return profiles.firstWhere((m) => m.id == activeId).toEntity();
    } catch (_) {
      return null;
    }
  }
}
