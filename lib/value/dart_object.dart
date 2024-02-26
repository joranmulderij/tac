part of 'value.dart';

class DartObjectValue<T extends DartObject> extends Value {
  const DartObjectValue(this.object);

  final T object;

  @override
  Value call(State state, List<Value> args) => object.call(state, args);

  @override
  Value getProperty(String name) {
    final property = object.getProperty(name);
    if (property == null) {
      throw MyError.propertyAccessError(this, name);
    }
    return property;
  }

  @override
  String get type => 'dart:${object.type}';

  @override
  String toString() => object.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DartObjectValue && other.object == object);

  @override
  int get hashCode => object.hashCode;
}

@immutable
abstract class DartObject {
  const DartObject();

  Value call(State state, List<Value> args);
  @override
  String toString();
  String get type;
  @override
  bool operator ==(Object other);
  @override
  int get hashCode;
  Value? getProperty(String name) => null;
}
