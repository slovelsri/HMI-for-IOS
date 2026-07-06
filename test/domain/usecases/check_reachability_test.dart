import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hmi_viewer/domain/repositories/connectivity_repository.dart';
import 'package:hmi_viewer/domain/usecases/check_reachability.dart';

class MockConnectivityRepository extends Mock
    implements ConnectivityRepository {}

void main() {
  late CheckReachability useCase;
  late MockConnectivityRepository mockRepo;

  setUp(() {
    mockRepo = MockConnectivityRepository();
    useCase = CheckReachability(mockRepo);
  });

  group('CheckReachability', () {
    const testIp = '192.168.1.50';
    const testPort = 80;

    test('returns true when device is reachable', () async {
      when(() => mockRepo.checkReachability(testIp, testPort))
          .thenAnswer((_) async => true);

      final result = await useCase(testIp, testPort);

      expect(result, isTrue);
      verify(() => mockRepo.checkReachability(testIp, testPort)).called(1);
    });

    test('returns false when device is unreachable', () async {
      when(() => mockRepo.checkReachability(testIp, testPort))
          .thenAnswer((_) async => false);

      final result = await useCase(testIp, testPort);

      expect(result, isFalse);
      verify(() => mockRepo.checkReachability(testIp, testPort)).called(1);
    });

    test('returns false when timeout occurs', () async {
      when(() => mockRepo.checkReachability(testIp, testPort))
          .thenAnswer((_) async => false);

      final result = await useCase(testIp, testPort);

      expect(result, isFalse);
    });

    test('works with custom port', () async {
      const customPort = 8080;
      when(() => mockRepo.checkReachability(testIp, customPort))
          .thenAnswer((_) async => true);

      final result = await useCase(testIp, customPort);

      expect(result, isTrue);
      verify(() => mockRepo.checkReachability(testIp, customPort)).called(1);
    });
  });
}
