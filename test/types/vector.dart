import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Vector', () {
    test('Literals', () {
      expect(run('<1>'), '<1>');
      expect(run('<1, 2>'), '<1, 2>');
      expect(run('<1, 2, 3>'), '<1, 2, 3>');
      expect(run('<(1, (2, 3))>'), '<1, 2, 3>');
      expect(run('<>'), '<>');
      expect(run('< >'), '<>');
    });
    test('Equality', () {
      expect(run('<1> == <1>'), 'true');
      expect(run('<1> == <2>'), 'false');
      expect(run('<1, 2, 3> == <1, 2, 3>'), 'true');
      expect(run('<1, 2, 3> == <3, 2, 1>'), 'false');
      expect(run('<1, 2, 3> == <1, 2>'), 'false');
    });
    // test('Index', () {
    //   expect(run('<1>(0)'), '1');
    //   expect(run('<1, 2>(0)'), '1');
    //   expect(run('<1, 2>(1)'), '2');
    //   expect(run('<1, 2, 3>(2)'), '3');
    //   expect(run('vector = <1, 2, 3>; vector 0'), '1');

    //   expect(run('<>(0)'), 'IndexError: Index 0 out of range for length 0');
    //   expect(run('<1>(5)'), 'IndexError: Index 5 out of range for length 1');
    //   expect(run('<2> (1,2)'), 'ArgumentError: Expected 1 arguments, got 2');
    //   expect(run('<2> "e"'), 'TypeError: Expected number, got string');
    //   expect(run('<2> 1.5'), 'NumberError: Number is not an integer');
    // });
    test('Type', () {
      expect(run('type(<>)'), '"vector"');
      expect(run('type(<1>)'), '"vector"');
      expect(run('type(<1, 2>)'), '"vector"');
    });
    test('Length', () {
      expect(run('length <>'), '0');
      expect(run('length(<1>)'), '1');
      expect(run('length(<1, 2>)'), '2');
      expect(run('length(<1, 2, 3>)'), '3');
    });
    // test('Spread', () {
    //   expect(run('...<1, 2>'), '(1, 2)');
    //   expect(run('a = <1, 2>; b = <3, 4>; <...a, ...b>'), '<1, 2, 3, 4>');
    //   expect(run('a = <1, 2>; b = <3, 4>; <...a, 5, ...b>'), '<1, 2, 5, 3, 4>');
    //   expect(run('...1'), 'TypeError: Expected list, got number');
    // });
    // test('Add', () {
    //   expect(run('<1> + <2>'), '<1, 2>');
    //   expect(run('<1, 2> + <3, 4>'), '<1, 2, 3, 4>');
    //   expect(run('<1, 2> + <3>'), '<1, 2, 3>');
    //   expect(run('<1> + <2, 3>'), '<1, 2, 3>');
    //   expect(run('a = <1, 2>; b = <3, 4>; a + b'), '<1, 2, 3, 4>');
    //   expect(run('<1, 2> + 3'), '<1, 2, 3>');
    //   expect(run('<1, 2> + (3, 4)'), '<1, 2, 3, 4>');
    // });
  });
}
