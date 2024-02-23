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
    });
  });
}
