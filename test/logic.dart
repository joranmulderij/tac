import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Logic', () {
    test('Booleans', () async {
      expect(await run('true'), 'true');
      expect(await run('false'), 'false');
    });
    test('Boolean equality', () async {
      expect(await run('true == true'), 'true');
      expect(await run('true == false'), 'false');
    });
    test('Operator precedence', () async {
      expect(await run('true || false && false'), 'true');
      expect(await run('true && (false || false)'), 'false');
    });
  });
}
