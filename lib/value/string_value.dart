part of 'value.dart';

@immutable
class StringValue extends Value {
  const StringValue(this.value);
  final String value;

  @override
  Value add(Value other) => switch (other) {
        StringValue(:final value) => StringValue(this.value + value),
        _ => super.add(other),
      };

  @override
  Value mul(Value other) => switch (other) {
        NumberValue(:final value) => StringValue(this.value * value.toInt()),
        _ => super.mul(other),
      };

  @override
  String toString() => value;

  @override
  String toConsoleString(bool color) => Console.blue('"$value"', color);

  @override
  String get type => 'string';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is StringValue && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toExpr() => '"$value"';
}
