import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Object', () {
    test('Literals', () async {
      expect(await run('{{ a = 1 }}'), '{ a = 1 }');
      expect(await run('{{ a = 1; b = 2 }}'), '{ a = 1; b = 2 }');
    });
    test('type', () async {
      expect(await run('type {{}}'), '"object"');
      expect(await run('type {{ a = 1; b = 2 }}'), '"object"');
    });
    test('Equality', () async {
      expect(await run('{{ a = 1 }} == {{ a = 1 }}'), 'true');
      expect(await run('{{ a = 1 }} == {{ a = 2 }}'), 'false');
    });
    test('Properties', () async {
      expect(await run('ob = {{ a = 1 }}; ob.a'), '1');
      expect(
        await run('ob = {{ a = 1 }}; ob.b'),
        'PropertyAccessError: Cannot access property "b" on value "{ a = 1 }"',
      );
    });
  });
}
