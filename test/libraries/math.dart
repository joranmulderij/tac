import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('math', () {
    test('sin', () async {
      expect(await run('sin(0)'), '0f0.0');
      expect(await run('sin(1)'), '0f0.8414709848078965');
      expect(await run('sin(2)'), '0f0.9092974268256817');
      expect(await run('sin("1")'), 'TypeError: Expected number, got string');
      expect(
        await run('sin(1, 2)'),
        'ArgumentError: Expected 1 arguments, got 2',
      );
    });
    test('cos', () async {
      expect(await run('cos(0)'), '0f1.0');
      expect(await run('cos(1)'), '0f0.5403023058681398');
      expect(await run('cos(2)'), '-0f0.4161468365471424');
      expect(await run('cos("1")'), 'TypeError: Expected number, got string');
      expect(
        await run('cos(1, 2)'),
        'ArgumentError: Expected 1 arguments, got 2',
      );
    });
    test('tan', () async {
      expect(await run('tan(0)'), '0f0.0');
      expect(await run('tan(1)'), '0f1.5574077246549023');
      expect(await run('tan(2)'), '-0f2.185039863261519');
      expect(await run('tan("1")'), 'TypeError: Expected number, got string');
      expect(
        await run('tan(1, 2)'),
        'ArgumentError: Expected 1 arguments, got 2',
      );
    });
    test('asin', () async {
      expect(await run('asin(0)'), '0f0.0');
      expect(await run('asin(0.5)'), '0f0.5235987755982989');
      expect(await run('asin(1)'), '0f1.5707963267948966');
      expect(await run('asin("1")'), 'TypeError: Expected number, got string');
      expect(
        await run('asin(1, 2)'),
        'ArgumentError: Expected 1 arguments, got 2',
      );
    });
    test('acos', () async {
      expect(await run('acos(0)'), '0f1.5707963267948966');
      expect(await run('acos(0.5)'), '0f1.0471975511965979');
      expect(await run('acos(1)'), '0f0.0');
      expect(await run('acos("1")'), 'TypeError: Expected number, got string');
      expect(
        await run('acos(1, 2)'),
        'ArgumentError: Expected 1 arguments, got 2',
      );
    });
    test('atan', () async {
      expect(await run('atan(0)'), '0f0.0');
      expect(await run('atan(1)'), '0f0.7853981633974483');
      expect(await run('atan(2)'), '0f1.1071487177940904');
      expect(await run('atan("1")'), 'TypeError: Expected number, got string');
      expect(
        await run('atan(1, 2)'),
        'ArgumentError: Expected 1 arguments, got 2',
      );
    });
    test('Constants', () async {
      expect(await run('pi'), '0f3.141592653589793');
      expect(await run('e'), '0f2.718281828459045');
    });
  });
}
