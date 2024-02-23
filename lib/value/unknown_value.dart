part of 'value.dart';

class UnknownValue extends Value {
  const UnknownValue();

  @override
  String get type => 'unknown';

  @override
  String toString() => 'unknown';
}
