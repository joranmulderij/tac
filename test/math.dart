import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('sin', () {
    expect(run('sin(0)'), '0.0');
    expect(run('sin(1)'), '0.8414709848078965');
    expect(run('sin(2)'), '0.9092974268256817');
  });
  test('cos', () {
    expect(run('cos(0)'), '1.0');
    expect(run('cos(1)'), '0.5403023058681398');
    expect(run('cos(2)'), '-0.4161468365471424');
  });
  test('tan', () {
    expect(run('tan(0)'), '0.0');
    expect(run('tan(1)'), '1.5574077246549023');
    expect(run('tan(2)'), '-2.185039863261519');
  });
  test('asin', () {
    expect(run('asin(0)'), '0.0');
    expect(run('asin(0.5)'), '0.5235987755982989');
    expect(run('asin(1)'), '1.5707963267948966');
  });
  test('acos', () {
    expect(run('acos(0)'), '1.5707963267948966');
    expect(run('acos(0.5)'), '1.0471975511965979');
    expect(run('acos(1)'), '0.0');
  });
  test('atan', () {
    expect(run('atan(0)'), '0.0');
    expect(run('atan(1)'), '0.7853981633974483');
    expect(run('atan(2)'), '1.1071487177940904');
  });
  test('atan2', () {
    // expect(run('atan2(0, 0)'), throwsA());
    expect(run('atan2(0, 1)'), '0.0');
    expect(run('atan2(1, 0)'), '1.5707963267948966');
    expect(run('atan2(1, 1)'), '0.7853981633974483');
    expect(run('atan2(1, 2)'), '0.4636476090008061');
  });
}
