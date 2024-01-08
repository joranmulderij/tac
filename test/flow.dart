import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Flow', () {
    test('Conditionals', () {
      expect(run('1 < 2 ? "yes" : "no"'), '"yes"');
      expect(run('1 > 2 ? "yes" : "no"'), '"no"');
      expect(
        run('{{yes = false; no = false; 1 > 2 ? {yes = true} : {no = true}}}'),
        '{ yes = false; no = true }',
      );
    });
    test('Loops', () {
      expect(run('counter = 0; 100 | {counter += 1}; counter'), '100');
    });
  });
}
