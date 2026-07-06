import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hmi_viewer/domain/entities/hmi_profile.dart';
import 'package:hmi_viewer/domain/repositories/hmi_profile_repository.dart';
import 'package:hmi_viewer/domain/usecases/save_hmi_profile.dart';

class MockHmiProfileRepository extends Mock implements HmiProfileRepository {}

void main() {
  late SaveHmiProfile useCase;
  late MockHmiProfileRepository mockRepo;

  setUp(() {
    mockRepo = MockHmiProfileRepository();
    useCase = SaveHmiProfile(mockRepo);
  });

  setUpAll(() {
    registerFallbackValue(const HmiProfile(
      id: 'fallback',
      name: 'Fallback',
      ipAddress: '0.0.0.0',
    ));
  });

  group('SaveHmiProfile', () {
    const testProfile = HmiProfile(
      id: 'test-id-123',
      name: 'Workshop HMI',
      ipAddress: '192.168.1.50',
      port: 80,
    );

    test('saves profile via repository', () async {
      when(() => mockRepo.save(any())).thenAnswer((_) async {});

      await useCase(testProfile);

      verify(() => mockRepo.save(testProfile)).called(1);
    });

    test('saves profile with custom port', () async {
      const customProfile = HmiProfile(
        id: 'test-id-456',
        name: 'Main Panel',
        ipAddress: '10.0.1.100',
        port: 8080,
      );

      when(() => mockRepo.save(any())).thenAnswer((_) async {});

      await useCase(customProfile);

      verify(() => mockRepo.save(customProfile)).called(1);
    });

    test('profile fullUrl is correct for default port', () {
      expect(testProfile.fullUrl, equals('http://192.168.1.50'));
    });

    test('profile fullUrl includes non-default port', () {
      const profile = HmiProfile(
        id: 'id',
        name: 'Test',
        ipAddress: '192.168.1.50',
        port: 8080,
      );
      expect(profile.fullUrl, equals('http://192.168.1.50:8080'));
    });

    test('profile displayAddress omits port 80', () {
      expect(testProfile.displayAddress, equals('192.168.1.50'));
    });

    test('profile displayAddress includes non-default port', () {
      const profile = HmiProfile(
        id: 'id',
        name: 'Test',
        ipAddress: '10.0.0.1',
        port: 3000,
      );
      expect(profile.displayAddress, equals('10.0.0.1:3000'));
    });

    test('profile value equality works', () {
      const a = HmiProfile(
        id: 'same',
        name: 'Same',
        ipAddress: '1.2.3.4',
        port: 80,
      );
      const b = HmiProfile(
        id: 'same',
        name: 'Same',
        ipAddress: '1.2.3.4',
        port: 80,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
