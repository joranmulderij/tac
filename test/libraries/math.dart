import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('math', () {
    test('sin', () {
      expect(run('sin(0)'), '0f0.0');
      expect(run('sin(1)'), '0f0.8414709848078965');
      expect(run('sin(2)'), '0f0.9092974268256817');
      expect(run('sin("1")'), 'TypeError: Expected number, got string');
      expect(run('sin(1, 2)'), 'ArgumentError: Expected 1 arguments, got 2');
    });
    test('cos', () {
      expect(run('cos(0)'), '0f1.0');
      expect(run('cos(1)'), '0f0.5403023058681398');
      expect(run('cos(2)'), '-0f0.4161468365471424');
      expect(run('cos("1")'), 'TypeError: Expected number, got string');
      expect(run('cos(1, 2)'), 'ArgumentError: Expected 1 arguments, got 2');
    });
    test('tan', () {
      expect(run('tan(0)'), '0f0.0');
      expect(run('tan(1)'), '0f1.5574077246549023');
      expect(run('tan(2)'), '-0f2.185039863261519');
      expect(run('tan("1")'), 'TypeError: Expected number, got string');
      expect(run('tan(1, 2)'), 'ArgumentError: Expected 1 arguments, got 2');
    });
    test('asin', () {
      expect(run('asin(0)'), '0f0.0');
      expect(run('asin(0.5)'), '0f0.5235987755982989');
      expect(run('asin(1)'), '0f1.5707963267948966');
      expect(run('asin("1")'), 'TypeError: Expected number, got string');
      expect(run('asin(1, 2)'), 'ArgumentError: Expected 1 arguments, got 2');
    });
    test('acos', () {
      expect(run('acos(0)'), '0f1.5707963267948966');
      expect(run('acos(0.5)'), '0f1.0471975511965979');
      expect(run('acos(1)'), '0f0.0');
      expect(run('acos("1")'), 'TypeError: Expected number, got string');
      expect(run('acos(1, 2)'), 'ArgumentError: Expected 1 arguments, got 2');
    });
    test('atan', () {
      expect(run('atan(0)'), '0f0.0');
      expect(run('atan(1)'), '0f0.7853981633974483');
      expect(run('atan(2)'), '0f1.1071487177940904');
      expect(run('atan("1")'), 'TypeError: Expected number, got string');
      expect(run('atan(1, 2)'), 'ArgumentError: Expected 1 arguments, got 2');
    });
    test('Constants', () {
      expect(run('pi'), '0f3.141592653589793');
      expect(run('e'), '0f2.718281828459045');
    });
  });
}
