import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Boolean', () {
    test('Literals', () {
      expect(run('true'), 'true');
      expect(run('false'), 'false');
    });
    test('Equality', () {
      expect(run('true == true'), 'true');
      expect(run('true == false'), 'false');
      expect(run('false == true'), 'false');
      expect(run('false == false'), 'true');
    });
    test('Inequality', () {
      expect(run('true != true'), 'false');
      expect(run('true != false'), 'true');
      expect(run('false != true'), 'true');
      expect(run('false != false'), 'false');
    });
    test('Negation', () {
      expect(run('!true'), 'false');
      expect(run('!false'), 'true');
    });
    test('Logical AND', () {
      expect(run('true && true'), 'true');
      expect(run('true && false'), 'false');
      expect(run('false && true'), 'false');
      expect(run('false && false'), 'false');
    });
    test('Logical OR', () {
      expect(run('true || true'), 'true');
      expect(run('true || false'), 'true');
      expect(run('false || true'), 'true');
      expect(run('false || false'), 'false');
    });
    test('Operator precedence', () {
      expect(run('true || false && false'), 'true');
      expect(run('true && (false || false)'), 'false');
    });
  });
}
