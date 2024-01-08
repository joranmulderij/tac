import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Scopes', () {
    test('Assignment', () {
      expect(run('a = 1'), '1');
      expect(run('(a = 1) + 1'), '2');
      expect(run('(a = 1) + a'), '2');
      expect(run('a = 1; a'), '1');
    });
    test('Block', () {
      expect(run('{ a = 1 }; a'), 'unknown');
      expect(run('a = 1; { a = 2 }; a'), '2');
      expect(run('{ 1 }'), '1');
      expect(run('{ 1; 2 }'), '2');
    });
    test('Protected Block', () {
      expect(run('{{ a = 1 }}; a'), 'unknown');
      expect(run('a = 1; {{ a; a = 2 }}; a'), '1');
      expect(run('{{ 1 }}'), '{}');
      expect(run('{{ 1; 2 }}'), '{}');
      expect(run('{{ return 1 }}'), '1');
    });
    test('Blocked Block', () {
      expect(run('{{{ a = 1 }}}; a'), 'unknown');
      expect(run('a = 1; {{{ a = 2 }}}; a'), '1');
      expect(run('{{{ 1 }}}'), '{}');
      expect(run('{{{ 1; 2 }}}'), '{}');
      expect(run('{{{ return 1 }}}'), '1');
    });
  });
}
