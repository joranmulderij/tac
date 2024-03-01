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
  String toConsoleString(bool color) =>
      '[${values.map((e) => e.toConsoleString(color)).join(', ')}]';

  @override
  Future<Value> call(State state, List<Value> args) async {
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
  Value add(Value other) {
    return switch (other) {
      ListValue(values: final otherValues) =>
        ListValue.fromList([...values, ...otherValues]),
      SequenceValue(values: final otherValues) =>
        ListValue.fromList([...values, ...otherValues]),
      _ => ListValue.fromList([...values, other])
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListValue &&
          const ListEquality<Value>().equals(other.values, values));

  @override
  int get hashCode => const ListEquality<Value>().hash(values);
}
