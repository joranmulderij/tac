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
    test('Equality', () {
      expect(run('(1, 2) == (1, 2)'), 'true');
      expect(run('(1, 2) == (2, 1)'), 'false');
      expect(run('(1, 2, 3) == (1, 2, 3)'), 'true');
      expect(run('(1, 2, 3) == (3, 2, 1)'), 'false');
      expect(run('(1, 2, 3) == (1, 2)'), 'false');
    });
    test('Index', () {
      expect(run('(1, 2)(0)'), '1');
      expect(run('(1, 2, 3)(0)'), '1');
      expect(run('(1, 2, 3)(1)'), '2');
      expect(run('(1, 2, 3)(2)'), '3');
      expect(run('seq = (1, 2, 3); seq 0'), '1');

      expect(run('(1, 2)(5)'), 'IndexError: Index 5 out of range for length 2');
      expect(run('(1, 2) (1,2)'), 'ArgumentError: Expected 1 arguments, got 2');
      expect(run('(1, 2) "e"'), 'TypeError: Expected number, got string');
      expect(run('(1, 2) 1.5'), 'NumberError: Number is not an integer');
    });
  });
}
