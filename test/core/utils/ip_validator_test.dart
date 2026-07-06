import 'package:flutter_test/flutter_test.dart';

import 'package:hmi_viewer/core/utils/ip_validator.dart';

void main() {
  group('IpValidator.validateIp', () {
    test('accepts valid IP addresses', () {
      expect(IpValidator.validateIp('192.168.1.50'), isNull);
      expect(IpValidator.validateIp('10.0.0.1'), isNull);
      expect(IpValidator.validateIp('172.16.0.1'), isNull);
      expect(IpValidator.validateIp('0.0.0.0'), isNull);
      expect(IpValidator.validateIp('255.255.255.255'), isNull);
    });

    test('rejects empty input', () {
      expect(IpValidator.validateIp(null), isNotNull);
      expect(IpValidator.validateIp(''), isNotNull);
      expect(IpValidator.validateIp('   '), isNotNull);
    });

    test('rejects invalid formats', () {
      expect(IpValidator.validateIp('abc'), isNotNull);
      expect(IpValidator.validateIp('192.168.1'), isNotNull);
      expect(IpValidator.validateIp('192.168.1.50.1'), isNotNull);
      expect(IpValidator.validateIp('192.168.1.256'), isNotNull);
      expect(IpValidator.validateIp('999.999.999.999'), isNotNull);
    });
  });

  group('IpValidator.validatePort', () {
    test('accepts valid ports', () {
      expect(IpValidator.validatePort('80'), isNull);
      expect(IpValidator.validatePort('8080'), isNull);
      expect(IpValidator.validatePort('1'), isNull);
      expect(IpValidator.validatePort('65535'), isNull);
    });

    test('accepts empty/null port (optional)', () {
      expect(IpValidator.validatePort(null), isNull);
      expect(IpValidator.validatePort(''), isNull);
    });

    test('rejects invalid ports', () {
      expect(IpValidator.validatePort('0'), isNotNull);
      expect(IpValidator.validatePort('65536'), isNotNull);
      expect(IpValidator.validatePort('-1'), isNotNull);
      expect(IpValidator.validatePort('abc'), isNotNull);
    });
  });

  group('IpValidator.validateIpWithOptionalPort', () {
    test('accepts IP without port', () {
      expect(IpValidator.validateIpWithOptionalPort('192.168.1.50'), isNull);
    });

    test('accepts IP with port', () {
      expect(
          IpValidator.validateIpWithOptionalPort('192.168.1.50:8080'), isNull);
    });

    test('rejects invalid combinations', () {
      expect(IpValidator.validateIpWithOptionalPort('192.168.1.50:0'),
          isNotNull);
      expect(IpValidator.validateIpWithOptionalPort('invalid:80'), isNotNull);
      expect(IpValidator.validateIpWithOptionalPort('192.168.1.50:80:extra'),
          isNotNull);
    });
  });
}
