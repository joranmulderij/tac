import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:tac/ast/ast.dart';
import 'package:tac/number/number.dart';
import 'package:tac/tac.dart';
import 'package:tac/units/unitset.dart';
import 'package:tac/utils/console_colors.dart';
import 'package:tac/utils/errors.dart';

part 'bool_value.dart';
part 'dart_function_value.dart';
part 'fun_value.dart';
part 'list_value.dart';
part 'number_value.dart';
part 'object_value.dart';
part 'sequence_value.dart';
part 'string_value.dart';
part 'unknown_value.dart';
part 'vector_value.dart';

sealed class Value {
  const Value();
  Value add(Value other) =>
      throw MyError.binaryOperatorTypeError('+', type, other.type);
  Value sub(Value other) =>
      throw MyError.binaryOperatorTypeError('-', type, other.type);
  Value mul(Value other) =>
      throw MyError.binaryOperatorTypeError('*', type, other.type);
  Value div(Value other) =>
      throw MyError.binaryOperatorTypeError('/', type, other.type);
  Value mod(Value other) =>
      throw MyError.binaryOperatorTypeError('%', type, other.type);
  Value lt(Value other) =>
      throw MyError.binaryOperatorTypeError('<', type, other.type);
  Value gt(Value other) =>
      throw MyError.binaryOperatorTypeError('>', type, other.type);
  Value lte(Value other) =>
      throw MyError.binaryOperatorTypeError('<=', type, other.type);
  Value gte(Value other) =>
      throw MyError.binaryOperatorTypeError('>=', type, other.type);
  Value pow(Value other) =>
      throw MyError.binaryOperatorTypeError('^', type, other.type);
  Future<Value> call(Tac state, List<Value> args) =>
      throw MyError.notCallable(type);
  Value not() => throw MyError.unaryOperatorTypeError('!', type);
  Value neg() => throw MyError.unaryOperatorTypeError('-', type);
  Value getProperty(String name) =>
      throw MyError.propertyAccessError(this, name);
  Value setProperty(String name, Value value) =>
      throw MyError.propertyAccessError(this, name);

  String get type;
  @override
  String toString() => toConsoleString(false);
  // ignore: avoid_positional_boolean_parameters
  String toConsoleString(bool color);

  String toExpr();
}

abstract class ValueWithUnit {
  UnitSet get unitSet;
}
