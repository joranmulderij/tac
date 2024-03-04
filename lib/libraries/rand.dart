import 'dart:math';

import 'package:tac/number/number.dart';
import 'package:tac/units/unitset.dart';
import 'package:tac/utils/errors.dart';
import 'package:tac/value/value.dart';

final _randomObject = Random();

final randLibrary = {
  'randint': DartFunctionValue.from1Param(
    (state, arg) async {
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

// class MyRandomObject extends DartObject {
//   const MyRandomObject(this.random, this.seed);

//   final Random random;
//   final int? seed;

//   @override
//   Value call(State state, List<Value> args) {
//     throw MyError.notCallable(type);
//   }

//   @override
//   Value? getProperty(String name) => null;

//   @override
//   String get type => 'random';

//   @override
//   String toString() {
//     return 'random';
//   }
// }
