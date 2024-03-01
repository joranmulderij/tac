import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Strings', () {
    test('Literals', () async {
      expect(await run('"Hello World"'), '"Hello World"');
      expect(await run("'Hello World'"), '"Hello World"');
    });
    test('Equality', () async {
      expect(await run('"Hello" == "Hello"'), 'true');
      expect(await run('"Hello" == "World"'), 'false');
      expect(await run('"Hello" == 1'), 'false');
      expect(await run('"Hello" == true'), 'false');
    });
    test('Type', () async {
      expect(await run('type("Hello")'), '"string"');
    });
    test('Addition', () async {
      expect(await run('"Hello" + " " + "World"'), '"Hello World"');
      expect(
        await run('"Hello" + 1'),
        'TypeError: Cannot apply operator "+" to types "string" and "number"',
      );
      expect(
        await run('"Hello" + true'),
        'TypeError: Cannot apply operator "+" to types "string" and "bool"',
      );
    });
    test('Multiplication', () async {
      expect(await run('"Hello" * 3'), '"HelloHelloHello"');
      expect(await run('"Hello" * 0'), '""');
      expect(await run('"Hello" * -1'), '""');
      expect(await run('"Hello" * 1'), '"Hello"');
      expect(
        await run('"Hello" * 1.5'),
        'NumberError: Number is not an integer',
      );
      expect(
        await run('"Hello" * true'),
        'TypeError: Cannot apply operator "*" to types "string" and "bool"',
      );
    });
  });
}
