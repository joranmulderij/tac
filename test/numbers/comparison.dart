import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Comparison', () {
    test('Equality', () {
      expect(run('1 == 1'), 'true');
      expect(run('1 == 2'), 'false');
      expect(run('0f1 == 1'), 'true');
      expect(run('1 == 0f1'), 'true');
      expect(run('1 == 0f2'), 'false');
    });
    test('Inequality', () {
      expect(run('1 != 1'), 'false');
      expect(run('0f1 != 1'), 'false');
      expect(run('1 != 0f1'), 'false');
      expect(run('1 != 2'), 'true');
      expect(run('1 != 0f2'), 'true');
    });
    test('Less than', () {
      expect(run('1 < 2'), 'true');
      expect(run('1 < 1'), 'false');
      expect(run('2 < 1'), 'false');
      expect(run('0f1 < 1'), 'true');
      expect(run('1 < 0f1'), 'false');
      expect(run('1 < 0f2'), 'true');
    });
    test('Less than or equal', () {
      expect(run('1 <= 2'), 'true');
      expect(run('1 <= 1'), 'true');
      expect(run('2 <= 1'), 'false');
      expect(run('0f1 <= 1'), 'true');
      expect(run('1 <= 0f1'), 'true');
      expect(run('1 <= 0f2'), 'true');
    });
    test('Greater than', () {
      expect(run('2 > 1'), 'true');
      expect(run('1 > 1'), 'false');
      expect(run('1 > 2'), 'false');
      expect(run('1 > 0f1'), 'false');
      expect(run('0f1 > 1'), 'false');
      expect(run('1 > 0f2'), 'false');
    });
    test('Greater than or equal', () {
      expect(run('2 >= 1'), 'true');
      expect(run('1 >= 1'), 'true');
      expect(run('1 >= 2'), 'false');
      expect(run('1 >= 0f1'), 'true');
      expect(run('0f1 >= 1'), 'false');
      expect(run('1 >= 0f2'), 'false');
    });
  });
}
