part of 'value.dart';

class ListValue extends Value {
  const ListValue(this.values);
  final List<Value> values;

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListValue &&
          const ListEquality<Value>().equals(other.values, values));

  @override
  int get hashCode => const ListEquality<Value>().hash(values);
}
