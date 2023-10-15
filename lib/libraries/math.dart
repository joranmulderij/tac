import 'dart:math' as math;

import 'package:rational/rational.dart';
import 'package:tac_dart/errors.dart';
import 'package:tac_dart/libraries/library.dart';
import 'package:tac_dart/state.dart';

import 'package:tac_dart/value/value.dart';

final mathLibrary = MathLibrary();

class MathLibrary extends Library {
  @override
  void load(State state) {
    state.set('sin', _mathFunction(math.sin));
    state.set('cos', _mathFunction(math.cos));
    state.set('tan', _mathFunction(math.tan));
    state.set('asin', _mathFunction(math.asin));
    state.set('acos', _mathFunction(math.acos));
    state.set('atan', _mathFunction(math.atan));
    state.set('sqrt', _mathFunction(math.sqrt));
    state.set('log', _mathFunction(math.log));
    state.set('exp', _mathFunction(math.exp));
    state.set('pi', NumberValue(Rational.parse(math.pi.toString())));
  }
}

DartFunctionValue _mathFunction(num Function(num) f) {
  return DartFunctionValue(
    (args) {
      if (args.length != 1) {
        throw ArgumentNumberError(1, args.length);
      }
      final arg = args[0];
      if (arg case NumberValue(:final value)) {
        return NumberValue(Rational.parse(f(value.toDouble()).toString()));
      } else {
        throw TypeError('number', arg.type);
      }
    },
    const ['x'],
  );
}
