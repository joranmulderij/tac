import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Function', () {
    test('Literals', () async {
      expect(await run('x => x^2'), 'fun(x)');
      expect(await run('() => 1'), 'fun()');
      expect(await run('(x, y) => x + y'), 'fun(x, y)');
    });
    test('Calling', () async {
      expect(await run('((x) => x^2)(2)'), '4');
      expect(await run('((x, y) => x + y)(1, 2)'), '3');
      expect(await run('(() => 2)()'), '2');
      expect(await run('f = x => x^2; f 2'), '4');
      expect(
        await run('((x) => x^2)(2, 3)'),
        'ArgumentError: Expected 1 arguments, got 2',
      );
    });
    test('Equality', () async {
      // Closures get created with function creation, so functions never equal.
      expect(await run('((x) => x^2) == (x => x^2)'), 'false');
      expect(await run('((x) => x^2) == (x => x^3)'), 'false');
      expect(await run('((x) => x^2) == (x, y => x^2)'), 'false');
    });
    test('Types', () async {
      expect(await run('type((x) => x^2)'), '"fun(x)"');
      expect(await run('type((x, y) => x + y)'), '"fun(x, y)"');
      expect(await run('type(() => 1)'), '"fun()"');
    });
    test('Blocks', () async {
      expect(await run('f(a) = {{}}; f 2'), '{ a = 2 }');
      expect(await run('f(a) = { a }; f 2'), '2');
    });
  });
}
