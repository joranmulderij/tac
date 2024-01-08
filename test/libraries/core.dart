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
      expect(run('sin = unknown; import "tac:math"; sin(0)'), '0.0');
      // TODO:
      // expect(run('import "tac:does_not_exist"'), '0.0');
    });
    test('load', () {
      expect(run('math = load "tac:math"; math.sin(0)'), '0.0');
      // TODO:
      // expect(run('import "tac:does_not_exist"'), '0.0');
    });
    test('eval', () {
      expect(run('eval "1 + 1"'), '2');
      expect(run('eval "a = 1"'), '1');
      expect(run('eval "a = 1"; a'), '1');
      // TODO:
      // expect(run('eval "return 1"; a'), '1');
      expect(run('eval 1'), 'TypeError: Expected string, got number.');
    });
  });
}
