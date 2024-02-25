part of 'value.dart';

class ListValue extends Value {
  ListValue(Value value)
      : values = switch (value) {
          SequenceValue(:final values) => values,
          _ => [value],
        };

  const ListValue.empty() : values = const [];

  const ListValue.fromList(this.values);

  final List<Value> values;

  @override
  String get type => 'list';

  @override
  String toString() {
    return '[${values.map((e) => e.toString()).join(', ')}]';
  }

  @override
  Value call(State state, List<Value> args) {
    if (args.length != 1) {
      throw MyError.argumentLengthError(1, args.length);
    }
    final arg = args[0];
    if (arg is! NumberValue) {
      throw MyError.unexpectedType('number', arg.type);
    }
    if (!arg.value.isInteger) {
      throw MyError.notAnInteger();
    }
    final index = arg.value.toInt();
    if (index < 0 || index >= values.length) {
      throw MyError.indexOutOfBounds(index, values.length);
    }
    return values[index];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListValue &&
          const ListEquality<Value>().equals(other.values, values));

  @override
  int get hashCode => const ListEquality<Value>().hash(values);
}
