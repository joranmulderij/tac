import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('List', () {
    test('Literals', () async {
      expect(await run('[1]'), '[1]');
      expect(await run('[1, 2]'), '[1, 2]');
      expect(await run('[1, 2, 3]'), '[1, 2, 3]');
      expect(await run('[(1, (2, 3))]'), '[1, 2, 3]');
      expect(await run('[]'), '[]');
    });
    test('Equality', () async {
      expect(await run('[1] == [1]'), 'true');
      expect(await run('[1] == [2]'), 'false');
      expect(await run('[1, 2, 3] == [1, 2, 3]'), 'true');
      expect(await run('[1, 2, 3] == [3, 2, 1]'), 'false');
      expect(await run('[1, 2, 3] == [1, 2]'), 'false');
    });
    test('Index', () async {
      expect(await run('[1](0)'), '1');
      expect(await run('[1, 2](0)'), '1');
      expect(await run('[1, 2](1)'), '2');
      expect(await run('[1, 2, 3](2)'), '3');
      expect(await run('list = [1, 2, 3]; list 0'), '1');

      expect(
        await run('[](0)'),
        'IndexError: Index 0 out of range for length 0',
      );
      expect(
        await run('[1](5)'),
        'IndexError: Index 5 out of range for length 1',
      );
      expect(
        await run('[2] (1,2)'),
        'ArgumentError: Expected 1 arguments, got 2',
      );
      expect(await run('[2] "e"'), 'TypeError: Expected number, got string');
      expect(await run('[2] 1.5'), 'NumberError: Number is not an integer');
    });
    test('Type', () async {
      expect(await run('type []'), '"list"');
      expect(await run('type [1]'), '"list"');
      expect(await run('type [1, 2]'), '"list"');
    });
    test('Length', () async {
      expect(await run('length []'), '0');
      expect(await run('length [1]'), '1');
      expect(await run('length [1, 2]'), '2');
      expect(await run('length [1, 2, 3]'), '3');
    });
    test('Spread', () async {
      expect(await run('...[1, 2]'), '(1, 2)');
      expect(await run('a = [1, 2]; b = [3, 4]; [...a, ...b]'), '[1, 2, 3, 4]');
      expect(
        await run('a = [1, 2]; b = [3, 4]; [...a, 5, ...b]'),
        '[1, 2, 5, 3, 4]',
      );
      expect(await run('...1'), 'TypeError: Expected list, got number');
    });
    test('Add', () async {
      expect(await run('[1] + [2]'), '[1, 2]');
      expect(await run('[1, 2] + [3, 4]'), '[1, 2, 3, 4]');
      expect(await run('[1, 2] + [3]'), '[1, 2, 3]');
      expect(await run('[1] + [2, 3]'), '[1, 2, 3]');
      expect(await run('a = [1, 2]; b = [3, 4]; a + b'), '[1, 2, 3, 4]');
      expect(await run('[1, 2] + 3'), '[1, 2, 3]');
      expect(await run('[1, 2] + (3, 4)'), '[1, 2, 3, 4]');
    });
  });
}
