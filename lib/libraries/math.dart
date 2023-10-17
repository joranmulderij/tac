import 'dart:math' as math;

import 'package:rational/rational.dart';
import 'package:tac_dart/errors.dart';
import 'package:tac_dart/units.dart';

import 'package:tac_dart/value/value.dart';

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
  'pi': NumberValue(Rational.parse(math.pi.toString()), UnitSet.empty),
};

DartFunctionValue _mathFunction(num Function(num) f) {
  return DartFunctionValue.from1Param(
    (state, arg) {
      if (arg case NumberValue(:final value)) {
        return NumberValue(
          Rational.parse(f(value.toDouble()).toString()),
          UnitSet.empty,
        );
      } else {
        throw IncorrectTypeError('number', arg.type);
      }
    },
    'x',
  );
}
