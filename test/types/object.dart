import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Object', () {
    test('Literals', () {
      expect(run('{{ a = 1 }}'), '{ a = 1 }');
      expect(run('{{ a = 1; b = 2 }}'), '{ a = 1; b = 2 }');
    });
    test('Equality', () {
      expect(run('{{ a = 1 }} == {{ a = 1 }}'), 'true');
      expect(run('{{ a = 1 }} == {{ a = 2 }}'), 'false');
    });
  });
}
