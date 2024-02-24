part of 'value.dart';

class FunValue extends Value {
  const FunValue(this.args, this.body);
  final Expr body;
  final List<String> args;

  @override
  Value call(State state, List<Value> args) {
    if (this.args.length != args.length) {
      throw MyError.argumentLengthError(this.args.length, args.length);
    }
    state.pushScope();
    for (var i = 0; i < this.args.length; i++) {
      state.set(this.args[i], args[i]);
    }
    final value = body.run(state);
    state.popScope();
    return value;
  }

  @override
  String toString() => 'fun(${args.join(', ')})';

  @override
  String get type => 'fun(${args.join(', ')})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FunValue && listEquals(other.args, args) && other.body == body);

  @override
  int get hashCode => Object.hashAll([...args, body]);
}
