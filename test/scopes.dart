import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Scopes', () {
    test('Assignment', () async {
      expect(await run('a = 1'), '1');
      expect(await run('(a = 1) + 1'), '2');
      expect(await run('(a = 1) + a'), '2');
      expect(await run('a = 1; a'), '1');
    });
    test('Pre Increment', () async {
      expect(await run('a = 1; ++a'), '2');
      expect(await run('a = 1; ++a; a'), '2');
      expect(await run('a = 1; --a'), '0');
      expect(await run('a = 1; --a; a'), '0');
      expect(await run('a = 1; ++a; ++a'), '3');
    });
    test('Post Increment', () async {
      expect(await run('a = 1; a++'), '1');
      expect(await run('a = 1; a++; a'), '2');
      expect(await run('a = 1; a--'), '1');
      expect(await run('a = 1; a--; a'), '0');
      expect(await run('a = 1; a++; a++'), '2');
    });
    test('Block', () async {
      expect(await run('{ a = 1 }; a'), 'unknown');
      expect(await run('a = 1; { a = 2 }; a'), '2');
      expect(await run('{ 1 }'), '1');
      expect(await run('{ 1; 2 }'), '2');
    });
    test('Protected Block', () async {
      expect(await run('{{ a = 1 }}; a'), 'unknown');
      expect(await run('a = 1; {{ a; a = 2 }}; a'), '1');
      expect(await run('{{ 1 }}'), '{}');
      expect(await run('{{ 1; 2 }}'), '{}');
      expect(await run('{{ return 1 }}'), '1');
    });
  });
}
