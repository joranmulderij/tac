import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('units', () {
    test('siUnit', () async {
      expect(await run('siUnit 1[km]'), '1000[m]');
    });
    test('baseUnit', () async {
      expect(await run('baseUnit 1[N]'), '1[kg m s-2]');
      expect(await run('baseUnit 1[J]'), '1[kg m2 s-2]');
      expect(await run('baseUnit 1[W]'), '1[kg m2 s-3]');
    });
  });
}
