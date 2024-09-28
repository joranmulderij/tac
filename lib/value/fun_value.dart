part of 'value.dart';

class FunValue extends Value {
  const FunValue(this.args, this.body);
  final Expr body;
  final List<String> args;

  @override
  Future<Value> call(Tac state, List<Value> args) async {
    if (this.args.length != args.length) {
      throw MyError.argumentLengthError(this.args.length, args.length);
    }
    final argMap = <String, Value>{
      for (var i = 0; i < this.args.length; i++) this.args[i]: args[i],
    };
    state.pushScope();
    for (var i = 0; i < this.args.length; i++) {
      state.set(this.args[i], args[i]);
    }
    final body = this.body;
    final value = switch (body) {
      AnyBlockExpr() => await body.runWithProps(state, argMap),
      _ => await body.run(state),
    };
    state.popScope();
    return value;
  }

  @override
  String toConsoleString(bool color) =>
      'fun(${args.map((e) => ConsoleColors.blue(e, color)).join(', ')})';

  @override
  String get type => 'fun(${args.join(', ')})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FunValue &&
          const ListEquality<String>().equals(other.args, args) &&
          other.body == body);

  @override
  int get hashCode => Object.hashAll([
        const ListEquality<String>().hash(args),
        body,
      ]);

  @override
  String toExpr() => '(${args.join(',')}) => ${body.toExpr()}';
}

class MethodValue extends FunValue {
  const MethodValue(this.object, super.args, super.body);

  final ObjectValue object;

  @override
  Future<Value> call(Tac state, List<Value> args) async {
    state.pushScope();
    state.setAll(object.values);
    final value = await super.call(state, args);
    object.values = state.popScope().variables;
    return value;
  }
}
