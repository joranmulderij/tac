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
        NumberValue(:final value) =>
          StringValue(this.value * value.toBigInt().toInt()),
        _ => super.mul(other),
      };

  @override
  String toString() => value;

  @override
  String toPrettyString() => '"$value"';

  @override
  List<Object> get props => [value];

  @override
  String get type => 'string';
}
