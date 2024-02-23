import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:tac_dart/value/value.dart';

final _orangePen = AnsiPen()..rgb(r: 255, g: 165, b: 0);

class MyError implements Exception {
  const MyError(this.message);

  MyError.unexpectedType(String expected, String got)
      : message = 'TypeError: Expected $expected, got $got.';

  MyError.unitParseError(String unit)
      : message = 'UnitParseError: [$unit] not a valid unit.';

  MyError.unexpectedUnit(String expected, String got)
      : message = 'UnitError: Expected [$expected], got [$got].';

  MyError.argumentLengthError(int expected, int got)
      : message = 'ArgumentError: Expected $expected arguments, got $got.';

  MyError.propertyAccessError(Value value, String property)
      : message =
            'PropertyAccessError: Cannot access property "$property" on value "$value".';

  MyError.binaryOperatorTypeError(
    String operator,
    String leftType,
    String rightType,
  ) : message =
            'TypeError: Cannot apply operator "$operator" to types "$leftType" and "$rightType".';

  MyError.unaryOperatorTypeError(String operator, String type)
      : message = 'TypeError: Cannot apply "$operator" to type "$type".';

  MyError.notCallable(String type)
      : message = 'TypeError: Cannot call type objects of type "$type"';

  MyError.notAnInteger() : message = 'NumberError: Number is not an integer';

  MyError.fileNotFound(String path)
      : message = 'FileError: File not found at "$path"';

  MyError.expectedIdentifier(String token)
      : message = 'SyntaxError: Expected identifier, got "$token"';

  final String message;

  @override
  String toString() => message;

  static void printWarning(String message) {
    stdout.writeln(_orangePen('Warning: $message'));
  }
}

class ReturnException implements Exception {
  const ReturnException(this.value);
  final Value value;
}

/*class CustomMyError extends MyError {
  const CustomMyError(this.message) : super(0);
  final String message;

  @override
  String toString() => 'CustomMyError($message, $position)';

  @override
  String toPrettyString() => message;
}

class SyntaxError extends MyError {
  const SyntaxError(this.message, super.position);
class MyError implements Exception {
  const MyError(this.message);
  final String message;

  @override
  String toString() => 'ParseError($message, $position)';

  @override
  String toPrettyString() => '  ${' ' * position}^\n'
      'SyntaxError: $message $position';
}

class UnaryOperatorTypeError extends MyError {
  const UnaryOperatorTypeError(this.operator, this.type) : super(0);
  final String operator;
  final String type;

  @override
  String toString() => 'UnaryOperatorTypeError($operator, $type)';

  @override
  String toPrettyString() {
    return 'TypeError: Cannot apply "$operator" to type "$type".';
  }
}

class BinaryOperatorTypeError extends MyError {
  const BinaryOperatorTypeError(this.operator, this.leftType, this.rightType)
      : super(0);
  final String operator;
  final String leftType;
  final String rightType;

  @override
  String toString() =>
      'BinaryOperatorTypeError($operator, $leftType, $rightType)';

  @override
  String toPrettyString() {
    return 'TypeError: Cannot apply operator "$operator" to '
        'types "$leftType" and "$rightType".';
  }
}

class NotCallableError extends MyError {
  const NotCallableError(this.type) : super(0);
  final String type;

  @override
  String toString() => 'NotCallableError($type)';

  @override
  String toPrettyString() {
    return 'TypeError: Cannot call type "$type".';
  }
}

class ArgumentNumberError extends MyError {
  const ArgumentNumberError(this.expected, this.got) : super(0);
  final int expected;
  final int got;

  @override
  String toString() => 'ArgumentError($expected, $got)';

  @override
  String toPrettyString() {
    return 'TypeError: Expected $expected arguments, got $got.';
  }
}

class IncorrectTypeError extends MyError {
  const IncorrectTypeError(this.expected, this.got) : super(0);
  final String expected;
  final String got;

  @override
  String toString() => 'TypeError($expected, $got)';

  @override
  String toPrettyString() {
    return 'TypeError: Expected $expected, got $got.';
  }
}

class ExpectedIdentifierError extends MyError {
  const ExpectedIdentifierError(this.token) : super(0);
  final String token;

  @override
  String toString() => 'ExpectedIdentifierError($token)';

  @override
  String toPrettyString() {
    return 'SyntaxError: Expected identifier, got "$token".';
  }
}

class TacError extends MyError {
  const TacError(this.value) : super(0);
  final Value value;

  @override
  String toString() => 'TacError($value)';

  @override
  String toPrettyString() {
    return 'Uncaught $value';
  }
}

class PropertyAccessError extends MyError {
  const PropertyAccessError(this.value, this.property) : super(0);
  final Value value;
  final String property;

  @override
  String toString() => 'PropertyAccessError($value, $property)';

  @override
  String toPrettyString() {
    return 'PropertyAccessError: Cannot access property "$property" '
        'on value "${value.toPrettyString()}".';
  }
}

class PathNotFoundError extends MyError {
  const PathNotFoundError(this.path) : super(0);
  final String path;

  @override
  String toString() => 'PathNotFoundError($path)';

  @override
  String toPrettyString() {
    return 'PathNotFoundError: Path "$path" not found.';
  }
}

class UnitParseError extends MyError {
  const UnitParseError(this.unit) : super(0);
  final String unit;

  @override
  String toString() => 'UnitParseError($unit)';

  @override
  String toPrettyString() {
    return 'UnitParseError: "$unit" not a valid unit.';
  }
}

class UnitsNotEqualError extends MyError {
  const UnitsNotEqualError(this.left, this.right) : super(0);
  final String left;
  final String right;

  @override
  String toString() => 'UnitsNotEqualError($left, $right)';

  @override
  String toPrettyString() {
    return 'UnitsNotEqualError: Cannot compare values with different units '
        '("$left" and "$right").';
  }
}*/