import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Strings', () {
    test('Literals', () {
      expect(run('"Hello World"'), '"Hello World"');
      expect(run("'Hello World'"), '"Hello World"');
    });
    test('Addition', () {
      expect(run('"Hello" + " " + "World"'), '"Hello World"');
      expect(run('"Hello" + 1'),
          'TypeError: Cannot apply operator "+" to types "string" and "number".');
      expect(run('"Hello" + true'),
          'TypeError: Cannot apply operator "+" to types "string" and "bool".');
    });
    test('Multiplication', () {
      expect(run('"Hello" * 3'), '"HelloHelloHello"');
      expect(run('"Hello" * 0'), '""');
      expect(run('"Hello" * -1'), '""');
      expect(run('"Hello" * 1'), '"Hello"');
      expect(run('"Hello" * 1.5'), 'NumberError: Number is not an integer');
      expect(
        run('"Hello" * true'),
        'TypeError: Cannot apply operator "*" to types "string" and "bool".',
      );
    });
  });
}
