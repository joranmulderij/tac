part of 'value.dart';

class DartFunctionValue extends Value {
  const DartFunctionValue(this.function, this.args);

  factory DartFunctionValue.from0Params(
    Value Function(State state) function,
  ) =>
      DartFunctionValue(
        (state, args) {
          if (args.isNotEmpty) {
            throw MyError.argumentLengthError(0, args.length);
          }
          return function(state);
        },
        const [],
      );

  factory DartFunctionValue.from1Param(
    Value Function(State state, Value arg) function,
    String arg,
  ) =>
      DartFunctionValue(
        (state, args) {
          if (args.length != 1) {
            throw MyError.argumentLengthError(1, args.length);
          }
          return function(state, args[0]);
        },
        [arg],
      );

  final Value Function(State state, List<Value> args) function;
  final List<String> args;

  @override
  Value call(State state, List<Value> args) => function(state, args);

  @override
  String get type => 'fun(${args.join(', ')})';

  @override
  String toString() => 'fun(${args.join(', ')})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DartFunctionValue &&
          listEquals(other.args, args) &&
          other.function == function);

  @override
  int get hashCode => Object.hashAll([...args, function]);
}
