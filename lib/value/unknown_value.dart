part of 'value.dart';

class UnknownValue extends Value {
  const UnknownValue();

  @override
  String get type => 'unknown';

  @override
  String toString() => 'unknown';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UnknownValue;

  @override
  int get hashCode => 0;
}
