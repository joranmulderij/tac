import 'dart:math' as math;

import 'package:tac/number/number.dart';
import 'package:tac/units.dart';
import 'package:tac/utils/errors.dart';
import 'package:tac/value/value.dart';

//TODO: check for values that don't need to be computed, for example sin(0)
final mathLibrary = {
  'sin': _mathFunction(math.sin),
  'cos': _mathFunction(math.cos),
  'tan': _mathFunction(math.tan),
  'asin': _mathFunction(math.asin),
  'acos': _mathFunction(math.acos),
  'atan': _mathFunction(math.atan),
  'sqrt': _mathFunction(math.sqrt),
  'log': _mathFunction(math.log),
  'exp': _mathFunction(math.exp),
  'pi': const NumberValue(FloatNumber(math.pi), UnitSet.empty),
  'e': const NumberValue(FloatNumber(math.e), UnitSet.empty),
  'i': VectorValue.fromList(
    [NumberValue.fromNum(1), NumberValue.fromNum(0), NumberValue.fromNum(0)],
  ),
  'j': VectorValue.fromList(
    [NumberValue.fromNum(0), NumberValue.fromNum(1), NumberValue.fromNum(0)],
  ),
  'k': VectorValue.fromList(
    [NumberValue.fromNum(0), NumberValue.fromNum(0), NumberValue.fromNum(1)],
  ),
};

DartFunctionValue _mathFunction(num Function(num) f) {
  return DartFunctionValue.from1Param(
    (state, arg) async {
      if (arg case NumberValue(:final value)) {
        var result = f(value.toNum());
        if (result.roundToDouble() == result) {
          result = result.toInt();
        }
        // if (result is int || result.roundToDouble() == result) {
        //   return NumberValue(
        //     Number.fromInt(result.toInt()),
        //     UnitSet.empty,
        //   );
        // } else {
        //   return NumberValue(
        //     FloatNumber(result),
        //     UnitSet.empty,
        //   );
        // }
        return NumberValue(
          FloatNumber(result),
          UnitSet.empty,
        );
      } else {
        throw MyError.unexpectedType('number', arg.type);
      }
    },
    'x',
  );
}
