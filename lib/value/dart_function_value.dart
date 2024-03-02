part of 'value.dart';

class DartFunctionValue extends Value {
  const DartFunctionValue(this.function, this.args);

  factory DartFunctionValue.from0Params(
    Value Function(State state) function,
  ) =>
      DartFunctionValue(
        (state, args) async {
          if (args.isNotEmpty) {
            throw MyError.argumentLengthError(0, args.length);
          }
          return function(state);
        },
        const [],
      );

  factory DartFunctionValue.from1Param(
    Future<Value> Function(State state, Value arg) function,
    String arg,
  ) =>
      DartFunctionValue(
        (state, args) async {
          if (args.length != 1) {
            throw MyError.argumentLengthError(1, args.length);
          }
          return function(state, args[0]);
        },
        [arg],
      );

  factory DartFunctionValue.from2Params(
    Future<Value> Function(State state, Value arg1, Value arg2) function,
    String arg1,
    String arg2,
  ) =>
      DartFunctionValue(
        (state, args) async {
          if (args.length != 2) {
            throw MyError.argumentLengthError(2, args.length);
          }
          return function(state, args[0], args[1]);
        },
        [arg1, arg2],
      );

  final Future<Value> Function(State state, List<Value> args) function;
  final List<String> args;

  @override
  Future<Value> call(State state, List<Value> args) async =>
      function(state, args);

  @override
  String get type => 'fun(${args.join(', ')})';

  @override
  String toConsoleString(bool color) => 'fun(${args.map(
        (e) => Console.blue(e, color),
      ).join(', ')})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DartFunctionValue &&
          const ListEquality<String>().equals(other.args, args) &&
          other.function == function);

  @override
  int get hashCode => Object.hashAll([
        const ListEquality<String>().hash(args),
        function,
      ]);

  @override
  String toExpr() => throw const MyError('Cannot convert to expression');
}
