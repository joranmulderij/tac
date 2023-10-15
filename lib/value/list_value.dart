part of 'value.dart';

class ListValue extends Value {
  const ListValue(this.values);
  final List<Value> values;

  @override
  List<Object> get props => values;

  @override
  String get type => 'list';

  @override
  String toString() {
    return 'ListValue(${values.join(', ')})';
  }

  @override
  String toPrettyString() {
    return '[${values.map((e) => e.toString()).join(', ')}]';
  }
}
