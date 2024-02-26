part of 'value.dart';

class ObjectValue extends Value {
  ObjectValue(this.values);
  Map<String, Value> values;

  @override
  Value getProperty(String name) {
    if (values.containsKey(name)) {
      final value = values[name]!;
      return switch (value) {
        FunValue(:final args, :final body) => MethodValue(this, args, body),
        _ => value
      };
    } else {
      return super.getProperty(name);
    }
  }

  @override
  Value setProperty(String name, Value value) {
    values[name] = value;
    return value;
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
