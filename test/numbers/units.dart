import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Units', () {
    test('literals', () {
      expect(run('1[m]'), '1[m]');
      expect(run('1[Nm]'), '1[N m]');
      expect(run('1[m2]'), '1[m2]');
      expect(run('1[m2 m]'), '1[m3]');
    });
    test('operations', () {
      expect(run('1[m] + 1[m]'), '2[m]');
      expect(run('1[m] - 1[m]'), '0[m]');
      expect(run('1[m] * 1[m]'), '1[m2]');
      expect(run('1[m] / 1[m]'), '1');
      expect(run('1[m] % 1[m]'), '0[m]');
      expect(run('1[m] ^ 1'), '1[m2]');
    });
    test('mixed operations', () {
      expect(run('0f1 + 1'), '0f2.0');
      expect(run('0f1 - 1'), '0f0.0');
      expect(run('1 + 0f1'), '0f2.0');
      expect(run('1 - 0f1'), '0f0.0');
    });
    test('unary operations', () {
      expect(run('-0f1'), '-0f1.0');
    });
    test('floating point error', () {
      expect(run('0f0.1 + 0.2'), '0f0.30000000000000004');
    });
  });
}
