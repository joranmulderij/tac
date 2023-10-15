part of 'value.dart';

class DartFunctionValue extends Value {
  const DartFunctionValue(this.function, this.args);
  final Value Function(List<Value>) function;
  final List<String> args;

  @override
  Value call(State state, List<Value> args) => function(args);

  @override
  String get type => 'fun(${args.join(', ')})';

  @override
  List<Object> get props => [function, args];

  @override
  String toString() => 'fun(${args.join(', ')})';
}
