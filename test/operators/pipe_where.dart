import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Pipe-Where', () {
    test('Simple', () async {
      expect(await run('5 |? _ % 2 == 0'), '[0, 2, 4]');
      expect(await run('5 |? _ % 2 == 0 | _ * 2'), '[0, 4, 8]');
    });
    test('List input', () async {
      expect(await run('[1, 2, 3] |? _ % 2 == 0'), '[2]');
      expect(await run('[1, 2, 3] |? _ % 2 == 0 | _ * 2'), '[4]');
    });
    test('Function pipe', () async {
      expect(
        await run('f(x) = sqrt(x) % 1 == 0?; 100 | _+1 |? f'),
        '[1, 4, 9, 16, 25, 36, 49, 64, 81, 100]',
      );
    });
    test('Wrong input type', () async {
      expect(
        await run('"a" |? 1'),
        'TypeError: Expected number or list, got string',
      );
      expect(
        await run('f(x, y) = x y; 5 |? f'),
        'ArgumentError: Expected 1 arguments, got 2',
      );
      expect(
        await run('f(x) = x^2; 4 |? f'),
        'TypeError: Expected bool, got number',
      );
      expect(
        await run('f(x) = x^2; 4 | _ |? f'),
        'TypeError: Expected bool, got number',
      );
    });
  });
}
