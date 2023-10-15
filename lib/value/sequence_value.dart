part of 'value.dart';

class SequenceValue extends Value {
  const SequenceValue(this.values);
  final List<Value> values;

  @override
  List<Object> get props => values;

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
}
