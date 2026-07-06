import 'package:flutter_test/flutter_test.dart';
import 'package:hmi_viewer/core/utils/ip_validator.dart';

// Basic smoke test — the full widget tests are in test/domain/ and test/core/.
void main() {
  test('IpValidator smoke test', () {
    expect(IpValidator.validateIp('192.168.1.50'), isNull);
    expect(IpValidator.validateIp('invalid'), isNotNull);
  });
}
