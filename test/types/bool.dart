import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Boolean', () {
    test('Literals', () async {
      expect(await run('true'), 'true');
      expect(await run('false'), 'false');
    });
    test('Equality', () async {
      expect(await run('true == true'), 'true');
      expect(await run('true == false'), 'false');
      expect(await run('false == true'), 'false');
      expect(await run('false == false'), 'true');
    });
    test('Inequality', () async {
      expect(await run('true != true'), 'false');
      expect(await run('true != false'), 'true');
      expect(await run('false != true'), 'true');
      expect(await run('false != false'), 'false');
    });
    test('Negation', () async {
      expect(await run('!true'), 'false');
      expect(await run('!false'), 'true');
    });
    test('Logical AND', () async {
      expect(await run('true && true'), 'true');
      expect(await run('true && false'), 'false');
      expect(await run('false && true'), 'false');
      expect(await run('false && false'), 'false');
    });
    test('Logical OR', () async {
      expect(await run('true || true'), 'true');
      expect(await run('true || false'), 'true');
      expect(await run('false || true'), 'true');
      expect(await run('false || false'), 'false');
    });
    test('Operator precedence', () async {
      expect(await run('true || false && false'), 'true');
      expect(await run('true && (false || false)'), 'false');
    });
  });
}
