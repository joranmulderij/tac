part of 'value.dart';

class BoolValue extends Value {
  // ignore: avoid_positional_boolean_parameters
  const BoolValue(this.value);

  final bool value;

  @override
  String toConsoleString(bool color) =>
      ConsoleColors.orange(value.toString(), color);

  @override
  Value not() => BoolValue(!value);

  @override
  String get type => 'bool';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is BoolValue && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toExpr() => value.toString();
}
