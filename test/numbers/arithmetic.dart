import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Arithmetic', () {
    test('addition', () async {
      expect(await run('1 + 2'), '3');
      expect(await run('1+2'), '3');
      expect(await run('1+    2'), '3');
      expect(await run('1      +    2'), '3');
      expect(await run('2+10902'), '10904');
      expect(await run('1 + 2 + 3'), '6');
      expect(await run('1 + 2 + 3 + 4'), '10');
    });
    test('subtraction', () async {
      expect(await run('1 - 2'), '-1');
      expect(await run('1-2'), '-1');
      expect(await run('2-1'), '1');
      expect(await run('1-    2'), '-1');
      expect(await run('1      -    2'), '-1');
      expect(await run('2-10902'), '-10900');
      expect(await run('1 - 2 - 3'), '-4');
      expect(await run('1 - 2 - 3 - 4'), '-8');
    });
    test('multiplication', () async {
      expect(await run('1 * 2'), '2');
      expect(await run('1*2'), '2');
      expect(await run('2*1'), '2');
      expect(await run('1*    2'), '2');
      expect(await run('1      *    2'), '2');
      expect(await run('2*10902'), '21804');
      expect(await run('1 * 2 * 3'), '6');
      expect(await run('1 * 2 * 3 * 4'), '24');
    });
    test('Implied multiplication', () async {
      expect(await run('1 2'), '2');
      expect(await run('1 2 3'), '6');
    });
    test('division', () async {
      expect(await run('1 / 2'), '1/2 ≈ 0.5');
      expect(await run('1/2'), '1/2 ≈ 0.5');
      expect(await run('2/1'), '2');
      expect(await run('1/    2'), '1/2 ≈ 0.5');
      expect(await run('1      /    2'), '1/2 ≈ 0.5');
      expect(await run('2/10902'), '1/5451 ≈ 0.000183452577508714');
      expect(await run('1 / 2 / 3'), '1/6 ≈ 0.16666666666666666');
      expect(await run('1 / 2 / 3 / 4'), '1/24 ≈ 0.041666666666666664');
      expect(await run('1 / 0'), 'NumberError: Division by zero');
    });
    test('exponents', () async {
      expect(await run('2 ^ 2'), '4');
      expect(await run('2^2'), '4');
      expect(await run('2**2'), '4');
      expect(await run('2 ** 2'), '4');
      expect(await run('2^1'), '2');
      expect(await run('2^    2'), '4');
      expect(await run('2      ^    2'), '4');
      expect(await run('2^100'), '1267650600228229401496703205376');
      expect(await run('1 ^ 2 ^ 3'), '1');
      expect(await run('2 ^ 3 ^ 4'), '2417851639229258349412352');
      expect(await run('(2 ^ 3) ^ 4'), '4096');
    });
    test('precedence', () async {
      expect(await run('1 + 2 * 3'), '7');
      expect(await run('1 * 2 + 3'), '5');
      expect(await run('1 + 2 * 3 + 4'), '11');
      expect(await run('1 * 2 + 3 / 4'), '11/4 ≈ 2.75');
      expect(await run('1 + 2 * 3 / 4'), '5/2 ≈ 2.5');
    });
    test('parentheses', () async {
      expect(await run('(1 + 2) * 3'), '9');
      expect(await run('1 * (2 + 3)'), '5');
      expect(await run('(1 + 2) * (3 + 4)'), '21');
      expect(await run('1 * (2 + 3) / 4'), '5/4 ≈ 1.25');
      expect(await run('(1 + 2 * 3) / 4'), '7/4 ≈ 1.75');
    });
  });
}
