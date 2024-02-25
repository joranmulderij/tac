import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('List', () {
    test('Literals', () {
      expect(run('[1]'), '[1]');
      expect(run('[1, 2]'), '[1, 2]');
      expect(run('[1, 2, 3]'), '[1, 2, 3]');
      expect(run('[(1, (2, 3))]'), '[1, 2, 3]');
      expect(run('[]'), '[]');
    });
    test('Equality', () {
      expect(run('[1] == [1]'), 'true');
      expect(run('[1] == [2]'), 'false');
      expect(run('[1, 2, 3] == [1, 2, 3]'), 'true');
      expect(run('[1, 2, 3] == [3, 2, 1]'), 'false');
      expect(run('[1, 2, 3] == [1, 2]'), 'false');
    });
    test('Index', () {
      expect(run('[1](0)'), '1');
      expect(run('[1, 2](0)'), '1');
      expect(run('[1, 2](1)'), '2');
      expect(run('[1, 2, 3](2)'), '3');
      expect(run('list = [1, 2, 3]; list 0'), '1');

      expect(run('[](0)'), 'IndexError: Index 0 out of range for length 0');
      expect(run('[1](5)'), 'IndexError: Index 5 out of range for length 1');
      expect(run('[2] (1,2)'), 'ArgumentError: Expected 1 arguments, got 2');
      expect(run('[2] "e"'), 'TypeError: Expected number, got string');
      expect(run('[2] 1.5'), 'NumberError: Number is not an integer');
    });
    test('Type', () {
      expect(run('type []'), '"list"');
      expect(run('type [1]'), '"list"');
      expect(run('type [1, 2]'), '"list"');
    });
  });
}
