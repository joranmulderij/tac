import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rational/rational.dart';
import 'package:tac_dart/ast/ast.dart';
import 'package:tac_dart/errors.dart';
import 'package:tac_dart/state.dart';

part 'number_value.dart';
part 'dart_function_value.dart';
part 'bool_value.dart';
part 'string_value.dart';
part 'unknown_value.dart';
part 'fun_value.dart';
part 'sequence_value.dart';

@immutable
sealed class Value extends Equatable {
  const Value();
  Value add(Value other) =>
      throw BinaryOperatorTypeError('+', type, other.type);
  Value sub(Value other) =>
      throw BinaryOperatorTypeError('-', type, other.type);
  Value mul(Value other) =>
      throw BinaryOperatorTypeError('*', type, other.type);
  Value div(Value other) =>
      throw BinaryOperatorTypeError('/', type, other.type);
  Value mod(Value other) =>
      throw BinaryOperatorTypeError('%', type, other.type);
  Value lt(Value other) => throw BinaryOperatorTypeError('<', type, other.type);
  Value gt(Value other) => throw BinaryOperatorTypeError('>', type, other.type);
  Value lte(Value other) =>
      throw BinaryOperatorTypeError('<=', type, other.type);
  Value gte(Value other) =>
      throw BinaryOperatorTypeError('>=', type, other.type);
  Value pow(Value other) =>
      throw BinaryOperatorTypeError('^', type, other.type);
  Value call(State state, List<Value> args) => throw NotCallableError(type);
  Value not() => throw UnaryOperatorTypeError('!', type);
  Value neg() => throw UnaryOperatorTypeError('-', type);

  String get type;
  @override
  List<Object> get props;
  @override
  String toString();
  String toPrettyString() => toString();
}
