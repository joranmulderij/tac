import 'package:tac_dart/value/value.dart';

sealed class MyError implements Exception {
  const MyError(this.position);
  final int position;

  String toPrettyString();
}

class ErrorWithPositions<T extends MyError> extends MyError {
  const ErrorWithPositions(this.error, this.start, this.end) : super(start);
  final T error;
  final int start;
  final int end;

  @override
  String toString() => 'ErrorWithPositions($error, $start, $end)';

  @override
  String toPrettyString() {
    return '  ${' ' * start}${'^' * (end - start)}\n'
        '${error.toPrettyString()}';
  }
}

class SyntaxError extends MyError {
  const SyntaxError(this.message, super.position);
  final String message;

  @override
  String toString() => 'ParseError($message, $position)';

  @override
  String toPrettyString() => '  ${' ' * position}^\n'
      'SyntaxError: $message';
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

class TypeError extends MyError {
  const TypeError(this.expected, this.got) : super(0);
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
