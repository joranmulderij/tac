import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Object', () {
    test('Literals', () {
      expect(run('{{ a = 1 }}'), '{ a = 1 }');
      expect(run('{{ a = 1; b = 2 }}'), '{ a = 1; b = 2 }');
    });
    test('type', () {
      expect(run('type {{}}'), '"object"');
      expect(run('type {{ a = 1; b = 2 }}'), '"object"');
    });
    test('Equality', () {
      expect(run('{{ a = 1 }} == {{ a = 1 }}'), 'true');
      expect(run('{{ a = 1 }} == {{ a = 2 }}'), 'false');
    });
    test('Properties', () {
      expect(run('ob = {{ a = 1 }}; ob.a'), '1');
      expect(
        run('ob = {{ a = 1 }}; ob.b'),
        'PropertyAccessError: Cannot access property "b" on value "{ a = 1 }"',
      );
    });
  });
}
