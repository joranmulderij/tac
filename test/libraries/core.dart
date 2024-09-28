import 'dart:io';

import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('core', () {
    test('type', () async {
      expect(await run('type 1'), '"number"');
      expect(await run('type "1"'), '"string"');
      expect(await run('type true'), '"bool"');
      expect(await run('type false'), '"bool"');
      expect(await run('type unknown'), '"unknown"');
      expect(await run('type {{}}'), '"object"');
    });
    test('import', () async {
      expect(await run('sin = unknown; import "tac:math"; sin(0)'), '0.0?');
      expect(
        await run('import "tac:anything"'),
        'UnknownLibraryError: Could not find library "tac:anything"',
      );
      expect(
        await run('import "test/libraries/test1.tac"; (a, b, c)'),
        '(1, 2, 3)',
      );
      expect(
        await run('import "test/libraries/test2.tac"; (a, b, c)'),
        '(1, 2, 3)',
      );
      expect(
        await run('import "test/libraries/test3.tac"'),
        'TypeError: Expected object, got string',
      );
      expect(
        await run('import "test/libraries/anything.tac"; (a, b, c)'),
        'FileError: File not found at "test/libraries/anything.tac"',
      );
      expect(await run('import 1'), 'TypeError: Expected string, got number');
    });
    test('load', () async {
      expect(await run('math = load "tac:math"; math.sin(0)'), '0.0?');
      expect(
        await run('import "tac:anything"'),
        'UnknownLibraryError: Could not find library "tac:anything"',
      );
      expect(
        await run('load "test/libraries/test1.tac"'),
        '{ a = 1; b = 2; c = 3 }',
      );
      expect(
        await run('load "test/libraries/test2.tac"'),
        '{ a = 1; b = 2; c = 3 }',
      );
      expect(await run('load "test/libraries/test3.tac"'), '"Hello World!"');
      expect(
        await run('load "test/libraries/anything.tac"; (a, b, c)'),
        'FileError: File not found at "test/libraries/anything.tac"',
      );
      expect(await run('load 1'), 'TypeError: Expected string, got number');
    });
    test('eval', () async {
      expect(await run('eval "1 + 1"'), '2');
      expect(await run('eval "a = 1"'), '1');
      expect(await run('eval "a = 1"; a'), '1');
      expect(await run('eval "return 1; 2"'), '1');
      expect(await run('eval 1'), 'TypeError: Expected string, got number');
    });
    test('save', () async {
      expect(
        await run('save("test/temp.tac", "Hello World!")'),
        '"Hello World!"',
      );
      expect(await run('load "test/temp.tac"'), '"Hello World!"');
      expect(
        await run('save("test/temp.tac", x=>x^2)'),
        'fun(x)',
      );
      expect(await run('load "test/temp.tac"'), 'fun(x)');
      expect(await run('load("test/temp.tac")(4)'), '16');

      File('test/temp.tac').deleteSync();
    });
    test('string', () async {
      expect(await run('string 1'), '"1"');
      expect(await run('string "1"'), '"1"');
      expect(await run('string true'), '"true"');
      expect(await run('string false'), '"false"');
      expect(await run('string unknown'), '"unknown"');
      expect(await run('string {{}}'), '"{}"');
    });
    test('expr', () async {
      expect(await run('expr 1'), '"1"');
      expect(await run('expr "1"'), '""1""');
      expect(await run('expr true'), '"true"');
      expect(await run('expr false'), '"false"');
      expect(await run('expr unknown'), '"unknown"');
      expect(await run('expr {{}}'), '"{{}}"');
      expect(await run('expr 20?'), '"20?"');
      expect(await run('eval expr 20?'), '20.0?');
    });
    test('print', () async {
      expect(await runWithPrint('print 1'), ('1', '1'));
      expect(await runWithPrint('print "a"'), ('a', '"a"'));
      expect(await runWithPrint('print(1, 2)'), ('1 2', '(1, 2)'));
      expect(await runWithPrint('print("a", "b")'), ('a b', '("a", "b")'));
      expect(await runWithPrint('print()'), ('', '()'));
    });
    test('length', () async {
      expect(await run('length [1, 2, 3]'), '3');
      expect(await run('length "123"'), '3');
      expect(
        await run('length 1'),
        'TypeError: Expected list, string, or vector, got number',
      );
    });
  });
}
