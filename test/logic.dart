import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Logic', () {
    test('Booleans', () {
      expect(run('true'), 'true');
      expect(run('false'), 'false');
    });
    test('Boolean equality', () {
      expect(run('true == true'), 'true');
      expect(run('true == false'), 'false');
    });
    test('Operator precedence', () {
      // TODO: create example that shows that && has higher precedence than ||
      expect(run('false || true && false'), 'false');
      expect(run('(false || true) && true'), 'true');
    });
  });
}
