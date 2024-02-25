import 'dart:math';

import 'package:tac_dart/number/number.dart';
import 'package:tac_dart/units.dart';
import 'package:tac_dart/utils/errors.dart';
import 'package:tac_dart/value/value.dart';

final _randomObject = Random();

final randLibrary = {
  'randint': DartFunctionValue.from1Param(
    (state, arg) {
      if (arg case NumberValue(:final value)) {
        if (value.isInteger) {
          if (value.toInt() <= 0) {
            throw MyError.negativeValue();
          }
          return NumberValue(
            Number.fromInt(_randomObject.nextInt(value.toInt())),
            UnitSet.empty,
          );
        } else {
          throw MyError.unexpectedType('integer', 'float');
        }
      } else {
        throw MyError.unexpectedType('number', arg.type);
      }
    },
    'max',
  ),
  'rand': DartFunctionValue.from0Params(
    (state) => NumberValue(
      Number.fromDouble(_randomObject.nextDouble()),
      UnitSet.empty,
    ),
  ),
};
