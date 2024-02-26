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
  String get type => 'object';

  @override
  String toString() {
    if (values.isEmpty) {
      return '{}';
    }
    // ignore: lines_longer_than_80_chars
    return '{ ${values.entries.map((e) => '${e.key} = ${e.value}').join('; ')} }';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObjectValue &&
          const MapEquality<String, Value>().equals(values, other.values);

  @override
  int get hashCode => const MapEquality<String, Value>().hash(values);
}
