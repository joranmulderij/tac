import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('core', () {
    test('type', () {
      expect(run('type 1'), '"number"');
      expect(run('type "1"'), '"string"');
      expect(run('type true'), '"bool"');
      expect(run('type false'), '"bool"');
      expect(run('type unknown'), '"unknown"');
      expect(run('type {{}}'), '"object"');
    });
    test('import', () {
      expect(run('sin = unknown; import "tac:math"; sin(0)'), '0f0.0');
      expect(
        run('import "tac:anything"'),
        'UnknownLibraryError: Could not find library "tac:anything"',
      );
      expect(run('import "test/libraries/test1.tac"; (a, b, c)'), '(1, 2, 3)');
      expect(run('import "test/libraries/test2.tac"; (a, b, c)'), '(1, 2, 3)');
      expect(
        run('import "test/libraries/test3.tac"'),
        'TypeError: Expected object, got string',
      );
      expect(
        run('import "test/libraries/anything.tac"; (a, b, c)'),
        'FileError: File not found at "test/libraries/anything.tac"',
      );
      expect(run('import 1'), 'TypeError: Expected string, got number');
    });
    test('load', () {
      expect(run('math = load "tac:math"; math.sin(0)'), '0f0.0');
      expect(
        run('import "tac:anything"'),
        'UnknownLibraryError: Could not find library "tac:anything"',
      );
      expect(run('load "test/libraries/test1.tac"'), '{ a = 1; b = 2; c = 3 }');
      expect(run('load "test/libraries/test2.tac"'), '{ a = 1; b = 2; c = 3 }');
      expect(run('load "test/libraries/test3.tac"'), '"Hello World!"');
      expect(
        run('load "test/libraries/anything.tac"; (a, b, c)'),
        'FileError: File not found at "test/libraries/anything.tac"',
      );
      expect(run('load 1'), 'TypeError: Expected string, got number');
    });
    test('eval', () {
      expect(run('eval "1 + 1"'), '2');
      expect(run('eval "a = 1"'), '1');
      expect(run('eval "a = 1"; a'), '1');
      expect(run('eval "return 1; 2"'), '1');
      expect(run('eval 1'), 'TypeError: Expected string, got number');
    });
    test('string', () {
      expect(run('string 1'), '"1"');
      expect(run('string "1"'), '"1"');
      expect(run('string true'), '"true"');
      expect(run('string false'), '"false"');
      expect(run('string unknown'), '"unknown"');
      expect(run('string {{}}'), '"{}"');
    });
    test('print', () {
      expect(runWithPrint('print 1'), ('1', '1'));
      expect(runWithPrint('print "a"'), ('a', '"a"'));
      expect(runWithPrint('print(1, 2)'), ('1 2', '(1, 2)'));
      expect(runWithPrint('print("a", "b")'), ('a b', '("a", "b")'));
      expect(runWithPrint('print()'), ('', '()'));
    });
    test('length', () {
      expect(run('length [1, 2, 3]'), '3');
      expect(run('length "123"'), '3');
      expect(
        run('length 1'),
        'TypeError: Expected list, string, or vector, got number',
      );
    });
  });
}
