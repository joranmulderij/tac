import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Floats', () {
    test('literals', () async {
      expect(await run('1?'), '1.0?');
      expect(await run('1.0?'), '1.0?');
      expect(await run('1.1?'), '1.1?');
    });
    test('operations', () async {
      expect(await run('1? + 1?'), '2.0?');
      expect(await run('1? - 1?'), '0.0?');
      expect(await run('1? * 1?'), '1.0?');
      expect(await run('1? / 1?'), '1.0?');
      expect(await run('1? % 1?'), '0.0?');
      expect(await run('1? ^ 1?'), '1.0?');
    });
    test('mixed operations', () async {
      expect(await run('1? + 1'), '2.0?');
      expect(await run('1? - 1'), '0.0?');
      expect(await run('1 + 1?'), '2.0?');
      expect(await run('1 - 1?'), '0.0?');
    });
    test('unary operations', () async {
      expect(await run('-1?'), '-1.0?');
    });
    test('floating point error', () async {
      expect(await run('0.1? + 0.2'), '0.30000000000000004?');
    });
  });
}
