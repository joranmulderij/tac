import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Units', () {
    test('literals', () async {
      expect(await run('1[m]'), '1[m]');
      expect(await run('1[Nm]'), '1[N m]');
      expect(await run('1[m2]'), '1[m2]');
      expect(await run('1[m2 m]'), '1[m3]');

      expect(
        await run('1[anything]'),
        'UnitParseError: [anything] not a valid unit',
      );
    });
    test('operations', () async {
      expect(await run('1[m] + 1[m]'), '2[m]');
      expect(await run('1[m] - 1[m]'), '0[m]');
      expect(await run('1[m] * 1[m]'), '1[m2]');
      expect(await run('1[m] / 1[m]'), '1');
      expect(await run('10[m] % 3[m]'), '1[m]');

      expect(await run('1[m] * 1[s-1]'), '1[m s-1]');
    });
    test('Assignment warning', () async {
      expect(
        await runWithPrint('a = 1[m]; a = 1[s]'),
        (
          'Warning: Variable "a" change it\'s unit dimension from [m] to [s]',
          '1[s]',
        ),
      );
    });
  });
}
