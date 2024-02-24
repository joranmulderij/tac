import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Sequence', () {
    test('Literals', () {
      expect(run('1,2'), '(1, 2)');
      expect(run('1,2,3'), '(1, 2, 3)');
      expect(run('(1, 2)'), '(1, 2)');
      expect(run('(1, 2, 3)'), '(1, 2, 3)');
      // Sequences cannot be nested
      expect(run('(1, 2, 3), 4'), '(1, 2, 3, 4)');
      expect(run('1, (2, 3)'), '(1, 2, 3)');
      expect(run('(1, 2), (3, 4)'), '(1, 2, 3, 4)');
    });
  });
}
