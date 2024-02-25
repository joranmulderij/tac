import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Syntax', () {
    test('End of input', () {
      expect(run('a = 1%'), 'SyntaxError: end of input expected');
    });
  });
}
