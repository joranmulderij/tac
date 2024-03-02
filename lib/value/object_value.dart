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
  String toConsoleString(bool color) {
    if (values.isEmpty) {
      return '{}';
    }
    // ignore: lines_longer_than_80_chars
    return '{ ${values.entries.map(
          (e) =>
              '${Console.blue(e.key, color)} = ${e.value.toConsoleString(color)}',
        ).join('; ')} }';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObjectValue &&
          const MapEquality<String, Value>().equals(values, other.values);

  @override
  int get hashCode => const MapEquality<String, Value>().hash(values);

  @override
  String toExpr() {
    if (values.isEmpty) {
      return '{{}}';
    }
    return '{{${values.entries.map((e) => '${e.key}=${e.value.toExpr()}').join(';')}}}';
  }
}
