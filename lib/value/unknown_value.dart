part of 'value.dart';

class UnknownValue extends Value {
  const UnknownValue();

  @override
  String get type => 'unknown';

  @override
  String toConsoleString(bool color) => Console.orange('unknown', color);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UnknownValue;

  @override
  int get hashCode => 0;

  @override
  String toExpr() => 'unknown';
}
