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
      expect(run('true || false && false'), 'true');
      expect(run('true && (false || false)'), 'false');
    });
  });
}
