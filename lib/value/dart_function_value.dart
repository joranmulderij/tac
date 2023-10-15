part of 'value.dart';

class DartFunctionValue extends Value {
  const DartFunctionValue(this.function, this.args);

  factory DartFunctionValue.from1Param(
    Value Function(State state, Value arg) function,
    String arg,
  ) =>
      DartFunctionValue(
        (state, args) {
          if (args.length != 1) {
            throw ArgumentNumberError(1, args.length);
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
  List<Object> get props => [function, args];

  @override
  String toString() => 'fun(${args.join(', ')})';
}
