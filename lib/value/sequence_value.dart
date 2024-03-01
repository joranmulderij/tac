part of 'value.dart';

class SequenceValue extends Value {
  const SequenceValue(this.values);
  final List<Value> values;

  @override
  String get type => 'sequence';

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
  String toConsoleString(bool color) =>
      '(${values.map((e) => e.toConsoleString(color)).join(', ')})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SequenceValue &&
          const ListEquality<Value>().equals(other.values, values));

  @override
  int get hashCode => const ListEquality<Value>().hash(values);
}
