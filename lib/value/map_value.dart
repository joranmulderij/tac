part of 'value.dart';

class ObjectValue extends Value {
  const ObjectValue(this.values);
  final Map<String, Value> values;

  @override
  Value getProperty(String name) {
    if (values.containsKey(name)) {
      return values[name]!;
    } else {
      return super.getProperty(name);
    }
  }

  @override
  List<Object> get props => values.entries.toList();

  @override
  String get type => 'object';

  @override
  String toString() {
    return 'ObjectValue($values)';
  }

  @override
  String toPrettyString() {
    // ignore: lines_longer_than_80_chars
    return '{ ${values.entries.map((e) => '${e.key} = ${e.value.toPrettyString()}').join('; ')} }';
  }
}
