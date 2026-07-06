import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/local_storage_datasource.dart';
import '../../data/repositories/hmi_profile_repository_impl.dart';
import '../../domain/entities/hmi_profile.dart';
import '../../domain/repositories/hmi_profile_repository.dart';

// ── Infrastructure Providers ────────────────────────────────────────────────

/// SharedPreferences instance — must be overridden at startup.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences not initialized'),
);

/// Local storage datasource.
final localStorageProvider = Provider<LocalStorageDatasource>(
  (ref) => LocalStorageDatasource(ref.watch(sharedPreferencesProvider)),
);

/// Profile repository.
final hmiProfileRepositoryProvider = Provider<HmiProfileRepository>(
  (ref) => HmiProfileRepositoryImpl(ref.watch(localStorageProvider)),
);

/// UUID generator.
final uuidProvider = Provider<Uuid>((ref) => const Uuid());

// ── Profile State ───────────────────────────────────────────────────────────

/// All saved HMI profiles.
final hmiProfilesProvider =
    StateNotifierProvider<HmiProfilesNotifier, List<HmiProfile>>(
  (ref) => HmiProfilesNotifier(ref),
);

/// The currently active profile ID.
final activeProfileIdProvider =
    StateNotifierProvider<ActiveProfileIdNotifier, String?>(
  (ref) => ActiveProfileIdNotifier(ref),
);

/// The currently active profile (derived).
final activeProfileProvider = Provider<HmiProfile?>((ref) {
  final profiles = ref.watch(hmiProfilesProvider);
  final activeId = ref.watch(activeProfileIdProvider);
  if (activeId == null || profiles.isEmpty) return null;
  try {
    return profiles.firstWhere((p) => p.id == activeId);
  } catch (_) {
    return profiles.isNotEmpty ? profiles.first : null;
  }
});

// ── Notifiers ───────────────────────────────────────────────────────────────

class HmiProfilesNotifier extends StateNotifier<List<HmiProfile>> {
  final Ref _ref;

  HmiProfilesNotifier(this._ref) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final repo = _ref.read(hmiProfileRepositoryProvider);
    state = await repo.getAll();
  }

  Future<void> addProfile({
    required String name,
    required String ipAddress,
    int port = 80,
  }) async {
    final id = _ref.read(uuidProvider).v4();
    final profile = HmiProfile(
      id: id,
      name: name,
      ipAddress: ipAddress,
      port: port,
    );
    final repo = _ref.read(hmiProfileRepositoryProvider);
    await repo.save(profile);
    state = await repo.getAll();

    // If this is the first profile, make it active.
    if (state.length == 1) {
      _ref.read(activeProfileIdProvider.notifier).setActive(id);
    }
  }

  Future<void> updateProfile(HmiProfile profile) async {
    final repo = _ref.read(hmiProfileRepositoryProvider);
    await repo.save(profile);
    state = await repo.getAll();
  }

  Future<void> deleteProfile(String id) async {
    final repo = _ref.read(hmiProfileRepositoryProvider);
    await repo.delete(id);
    state = await repo.getAll();

    // If the deleted profile was active, switch to the first remaining.
    final activeId = _ref.read(activeProfileIdProvider);
    if (activeId == id && state.isNotEmpty) {
      _ref.read(activeProfileIdProvider.notifier).setActive(state.first.id);
    }
  }

  Future<void> refresh() async {
    await _load();
  }
}

class ActiveProfileIdNotifier extends StateNotifier<String?> {
  final Ref _ref;

  ActiveProfileIdNotifier(this._ref) : super(null) {
    _load();
  }

  Future<void> _load() async {
    final repo = _ref.read(hmiProfileRepositoryProvider);
    state = await repo.getActiveProfileId();
  }

  Future<void> setActive(String id) async {
    final repo = _ref.read(hmiProfileRepositoryProvider);
    await repo.setActiveProfileId(id);
    state = id;
  }
}
