part of 'value.dart';

class BoolValue extends Value {
  // ignore: avoid_positional_boolean_parameters
  const BoolValue(this.value);
  final bool value;

  @override
  String toString() => value.toString();

  @override
  Value not() => BoolValue(!value);

  @override
  String get type => 'bool';

  @override
  List<Object> get props => [value];
}
