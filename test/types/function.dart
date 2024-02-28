import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Function', () {
    test('Literals', () {
      expect(run('x => x^2'), 'fun(x)');
      expect(run('() => 1'), 'fun()');
      expect(run('(x, y) => x + y'), 'fun(x, y)');
    });
    test('Calling', () {
      expect(run('((x) => x^2)(2)'), '4');
      expect(run('((x, y) => x + y)(1, 2)'), '3');
      expect(run('(() => 2)()'), '2');
      expect(run('f = x => x^2; f 2'), '4');
      expect(
        run('((x) => x^2)(2, 3)'),
        'ArgumentError: Expected 1 arguments, got 2',
      );
    });
    test('Equality', () {
      // Closures get created with function creation, so functions never equal.
      expect(run('((x) => x^2) == (x => x^2)'), 'false');
      expect(run('((x) => x^2) == (x => x^3)'), 'false');
      expect(run('((x) => x^2) == (x, y => x^2)'), 'false');
    });
    test('Types', () {
      expect(run('type((x) => x^2)'), '"fun(x)"');
      expect(run('type((x, y) => x + y)'), '"fun(x, y)"');
      expect(run('type(() => 1)'), '"fun()"');
    });
    test('Blocks', () {
      expect(run('f(a) = {{}}; f 2'), '{ a = 2 }');
      expect(run('f(a) = { a }; f 2'), '2');
      expect(
        run('a = 1; f(b) = {{{ c = a; }}}; f 2'),
        '{ b = 2; c = unknown }',
      );
    });
  });
}
