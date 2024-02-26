import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Pipe', () {
    test('Simple', () {
      expect(run('3 | _'), '[0, 1, 2]');
      expect(run('3 | _ + 1'), '[1, 2, 3]');
      expect(run('3 | _ + 1 | _ * 2'), '[2, 4, 6]');
    });
    test('List input', () {
      expect(run('[1, 2, 3] | _ + 1'), '[2, 3, 4]');
      expect(run('[1, 2, 3] | _ + 1 | _ * 2'), '[4, 6, 8]');
    });
    test('Function pipe', () {
      expect(run('f(x) = x^2; 4 | f'), '[0, 1, 4, 9]');
      expect(run('f(x) = x^2; [1, 2, 3] | f'), '[1, 4, 9]');
      expect(run('f(x, y) = x y; [1, 2, 3] | f(_, 3)'), '[3, 6, 9]');
      expect(run('f() = 3; 5 | f'), '[3, 3, 3, 3, 3]');
      expect(
        run('f(x) = (x, x+1); 5 | _*2 | f'),
        '[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]',
      );
      expect(
        run('f(x) = (x, x+1); 5 | _*2 | f'),
        '[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]',
      );
      expect(
        run('f(x) = (x, x+1); 5 | f'),
        '[0, 1, 1, 2, 2, 3, 3, 4, 4, 5]',
      );
    });
    test('Wrong input type', () {
      expect(
        run('"a" | 1'),
        'TypeError: Expected number or list, got string',
      );
      expect(
        run('f(x, y) = x y; 5 | f'),
        'ArgumentError: Expected 1 arguments, got 2',
      );
    });
    test('With units', () {
      expect(run('3[m] | _ + 1[m]'), '[1[m], 2[m], 3[m]]');
      expect(
        run('3[m] | _ + 1[m] | _ * 2[s-1]'),
        '[2[m s-1], 4[m s-1], 6[m s-1]]',
      );
    });
  });
}
