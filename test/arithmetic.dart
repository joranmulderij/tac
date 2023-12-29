import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('addition', () {
    expect(run('1 + 2'), '3');
    expect(run('1+2'), '3');
    expect(run('1+    2'), '3');
    expect(run('1      +    2'), '3');
    expect(run('2+10902'), '10904');
    expect(run('1 + 2 + 3'), '6');
    expect(run('1 + 2 + 3 + 4'), '10');
  });
  test('subtraction', () {
    expect(run('1 - 2'), '-1');
    expect(run('1-2'), '-1');
    expect(run('2-1'), '1');
    expect(run('1-    2'), '-1');
    expect(run('1      -    2'), '-1');
    expect(run('2-10902'), '-10900');
    expect(run('1 - 2 - 3'), '-4');
    expect(run('1 - 2 - 3 - 4'), '-8');
  });
  test('multiplication', () {
    expect(run('1 * 2'), '2');
    expect(run('1*2'), '2');
    expect(run('2*1'), '2');
    expect(run('1*    2'), '2');
    expect(run('1      *    2'), '2');
    expect(run('2*10902'), '21804');
    expect(run('1 * 2 * 3'), '6');
    expect(run('1 * 2 * 3 * 4'), '24');
  });
  test('division', () {
    expect(run('1 / 2'), '1/2 ≈ 0.5');
    expect(run('1/2'), '1/2 ≈ 0.5');
    expect(run('2/1'), '2');
    expect(run('1/    2'), '1/2 ≈ 0.5');
    expect(run('1      /    2'), '1/2 ≈ 0.5');
    expect(run('2/10902'), '1/5451 ≈ 0.000183452577508714');
    expect(run('1 / 2 / 3'), '1/6 ≈ 0.16666666666666666');
    expect(run('1 / 2 / 3 / 4'), '1/24 ≈ 0.041666666666666664');
  });
  test('precedence', () {
    expect(run('1 + 2 * 3'), '7');
    expect(run('1 * 2 + 3'), '5');
    expect(run('1 + 2 * 3 + 4'), '11');
    expect(run('1 * 2 + 3 / 4'), '11/4 ≈ 2.75');
    expect(run('1 + 2 * 3 / 4'), '5/2 ≈ 2.5');
  });
  test('parentheses', () {
    expect(run('(1 + 2) * 3'), '9');
    expect(run('1 * (2 + 3)'), '5');
    expect(run('(1 + 2) * (3 + 4)'), '21');
    expect(run('1 * (2 + 3) / 4'), '5/4 ≈ 1.25');
    expect(run('(1 + 2 * 3) / 4'), '7/4 ≈ 1.75');
  });
}
