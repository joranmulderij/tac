import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Flow', () {
    test('Conditionals', () async {
      expect(await run('1 < 2 ? "yes" : "no"'), '"yes"');
      expect(await run('1 > 2 ? "yes" : "no"'), '"no"');
      expect(
        await run(
          '{{yes = false; no = false; 1 > 2 ? {yes = true} : {no = true}}}',
        ),
        '{ yes = false; no = true }',
      );
    });
    test('Implicit Conditionals', () async {
      // TODO: Might remove this feature
      expect(await run('(1 < 2) "yes"'), '"yes"');
      expect(await run('(1 > 2) "yes"'), 'unknown');
    });
    test('Loops', () async {
      expect(await run('counter = 0; 100 | {counter += 1}; counter'), '100');
    });
  });
}
