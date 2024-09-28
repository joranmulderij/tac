part of 'value.dart';

class DartFunctionValue extends Value {
  const DartFunctionValue(this.function, this.args, [this.helpText]);

  factory DartFunctionValue.from0Params(
    Value Function(Tac state) function, {
    String? helpText,
  }) =>
      DartFunctionValue(
        (state, args) async {
          if (args.isNotEmpty) {
            throw MyError.argumentLengthError(0, args.length);
          }
          return function(state);
        },
        const [],
        helpText,
      );

  factory DartFunctionValue.from1Param(
    Future<Value> Function(Tac state, Value arg) function,
    String arg, {
    String? helpText,
  }) =>
      DartFunctionValue(
        (state, args) async {
          if (args.length != 1) {
            throw MyError.argumentLengthError(1, args.length);
          }
          return function(state, args[0]);
        },
        [arg],
        helpText,
      );

  factory DartFunctionValue.from2Params(
    Future<Value> Function(Tac state, Value arg1, Value arg2) function,
    String arg1,
    String arg2, {
    String? helpText,
  }) =>
      DartFunctionValue(
        (state, args) async {
          if (args.length != 2) {
            throw MyError.argumentLengthError(2, args.length);
          }
          return function(state, args[0], args[1]);
        },
        [arg1, arg2],
        helpText,
      );

  final Future<Value> Function(Tac state, List<Value> args) function;
  final List<String> args;
  final String? helpText;

  @override
  Future<Value> call(Tac state, List<Value> args) async =>
      function(state, args);

  @override
  String get type => 'fun(${args.join(', ')})';

  @override
  String toConsoleString(bool color) => 'fun(${args.map(
        (e) => ConsoleColors.blue(e, color),
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
