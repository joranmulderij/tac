import 'package:tac/value/value.dart';

class MyError implements Exception {
  const MyError(this.message);

  MyError.unexpectedType(String expected, String? got)
      : message = 'TypeError: Expected $expected, got ${got ?? 'unknown'}';

  MyError.unitParseError(String unit)
      : message = 'UnitParseError: [$unit] not a valid unit';

  MyError.unexpectedUnit(String expected, String got)
      : message = 'UnitError: Expected [$expected], got [$got]';

  MyError.argumentLengthError(int expected, int got)
      : message = 'ArgumentError: Expected $expected arguments, got $got';

  MyError.propertyAccessError(Value value, String property)
      : message =
            'PropertyAccessError: Cannot access property "$property" on value "$value"';

  MyError.binaryOperatorTypeError(
    String operator,
    String leftType,
    String rightType,
  ) : message =
            'TypeError: Cannot apply operator "$operator" to types "$leftType" and "$rightType"';

  MyError.unaryOperatorTypeError(String operator, String type)
      : message = 'TypeError: Cannot apply "$operator" to type "$type"';

  MyError.notCallable(String type)
      : message = 'TypeError: Cannot call type objects of type "$type"';

  MyError.notAnInteger() : message = 'NumberError: Number is not an integer';

  MyError.fileNotFound(String path)
      : message = 'FileError: File not found at "$path"';

  MyError.expectedIdentifier(String token)
      : message = 'SyntaxError: Expected identifier, got "$token"';

  MyError.syntax(String message) : message = 'SyntaxError: $message';

  MyError.divisionByZero() : message = 'NumberError: Division by zero';

  MyError.unknownLibrary(String library)
      : message = 'UnknownLibraryError: Could not find library "$library"';

  MyError.indexOutOfBounds(int index, int length)
      : message = 'IndexError: Index $index out of range for length $length';

  MyError.negativeValue() : message = 'NumberError: Value cannot be negative';

  final String message;

  @override
  String toString() => message;
}

class ReturnException implements Exception {
  const ReturnException(this.value);
  final Value value;
}
