import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Comparison', () {
    test('Equality', () async {
      expect(await run('1 == 1'), 'true');
      expect(await run('1 == 2'), 'false');
      expect(await run('1? == 1'), 'false');
      expect(await run('1 == 1?'), 'false');
      expect(await run('1 == 2?'), 'false');
    });
    test('Inequality', () async {
      expect(await run('1 != 1'), 'false');
      expect(await run('1? != 1'), 'true');
      expect(await run('1 != 1?'), 'true');
      expect(await run('1 != 2'), 'true');
      expect(await run('1 != 2?'), 'true');
    });
    test('Less than', () async {
      expect(await run('1 < 2'), 'true');
      expect(await run('1 < 1'), 'false');
      expect(await run('2 < 1'), 'false');
      expect(await run('1? < 1'), 'false');
      expect(await run('1 < 1?'), 'false');
      expect(await run('1 < 2?'), 'true');
    });
    test('Less than or equal', () async {
      expect(await run('1 <= 2'), 'true');
      expect(await run('1 <= 1'), 'true');
      expect(await run('2 <= 1'), 'false');
      expect(await run('1? <= 1'), 'true');
      expect(await run('1 <= 1?'), 'true');
      expect(await run('1 <= 2?'), 'true');
    });
    test('Greater than', () async {
      expect(await run('2 > 1'), 'true');
      expect(await run('1 > 1'), 'false');
      expect(await run('1 > 2'), 'false');
      expect(await run('1 > 1?'), 'false');
      expect(await run('1? > 1'), 'false');
      expect(await run('1 > 2?'), 'false');
    });
    test('Greater than or equal', () async {
      expect(await run('2 >= 1'), 'true');
      expect(await run('1 >= 1'), 'true');
      expect(await run('1 >= 2'), 'false');
      expect(await run('1 >= 1?'), 'true');
      expect(await run('1? >= 1'), 'true');
      expect(await run('1 >= 2?'), 'false');
    });
  });
}
