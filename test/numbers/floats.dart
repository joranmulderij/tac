import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Floats', () {
    test('literals', () {
      expect(run('0f1'), '0f1.0');
      expect(run('0f1.0'), '0f1.0');
      expect(run('0f1.1'), '0f1.1');
    });
    test('operations', () {
      expect(run('0f1 + 0f1'), '0f2.0');
      expect(run('0f1 - 0f1'), '0f0.0');
      expect(run('0f1 * 0f1'), '0f1.0');
      expect(run('0f1 / 0f1'), '0f1.0');
      expect(run('0f1 % 0f1'), '0f0.0');
      expect(run('0f1 ^ 0f1'), '0f1.0');
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
