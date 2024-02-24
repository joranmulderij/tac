part of 'value.dart';

class SequenceValue extends Value {
  const SequenceValue(this.values);
  final List<Value> values;

  @override
  String get type => 'sequence';

  @override
  String toString() {
    return 'SequenceValue(${values.join(', ')})';
  }

  @override
  String toPrettyString() {
    return '(${values.map((e) => e.toPrettyString()).join(', ')})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SequenceValue && listEquals(other.values, values));

  @override
  int get hashCode => Object.hashAll(values);
}
