import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Units', () {
    test('literals', () {
      expect(run('1[m]'), '1[m]');
      expect(run('1[Nm]'), '1[N m]');
      expect(run('1[m2]'), '1[m2]');
      expect(run('1[m2 m]'), '1[m3]');

      expect(run('1[anything]'), 'UnitParseError: [anything] not a valid unit');
    });
    test('operations', () {
      expect(run('1[m] + 1[m]'), '2[m]');
      expect(run('1[m] - 1[m]'), '0[m]');
      expect(run('1[m] * 1[m]'), '1[m2]');
      expect(run('1[m] / 1[m]'), '1');
      expect(run('10[m] % 3[m]'), '1[m]');

      expect(run('1[m] * 1[s-1]'), '1[m s-1]');
    });
    test('Assignment warning', () {
      expect(
        runWithPrint('a = 1[m]; a = 1[s]'),
        (
          'Warning: Variable "a" change it\'s unit dimension from [m] to [s]',
          '1[s]',
        ),
      );
    });
  });
}
