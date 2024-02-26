import 'package:petitparser/petitparser.dart';
import 'package:tac_dart/number/number.dart';
import 'package:tac_dart/state.dart';
import 'package:tac_dart/units.dart';
import 'package:tac_dart/utils/errors.dart';
import 'package:tac_dart/value/value.dart';

sealed class Expr {
  Value run(State state);
}

class NumberExpr extends Expr {
  NumberExpr(this.rational, this.unitSet);

  final Number rational;
  final UnitSet unitSet;

  @override
  Value run(State state) => NumberValue(rational, unitSet);
}

class VariableExpr extends Expr {
  VariableExpr(this.name);
  final String name;

  @override
  Value run(State state) => state.get(name);

  @override
  String toString() => 'VariableExpr($name)';
}

class StringExpr extends Expr {
  StringExpr(this.string);
  final String string;

  @override
  Value run(State state) {
    return StringValue(string);
  }
}

class OperatorExpr extends Expr {
  OperatorExpr(this.left, this.op, this.right, this.start, this.stop);
  final Operator op;
  final Expr left;
  final Expr right;
  final int start;
  final int stop;

  static Token<OperatorExpr> Function(Token<Expr>, String, Token<Expr>)
      fromToken(
    Operator operator, {
    Expr Function(Expr left, Expr right)? mapRight,
  }) {
    return (left, op, right) => Token(
          OperatorExpr(
            left.value,
            operator,
            mapRight?.call(left.value, right.value) ?? right.value,
            left.start,
            right.stop,
          ),
          left.buffer + op + right.buffer,
          left.start,
          right.stop,
        );
  }

  @override
  Value run(State state) {
    Value leftValue() => left.run(state);
    Value rightValue() => right.run(state);

    return switch (op) {
      Operator.add => leftValue().add(rightValue()),
      Operator.sub => leftValue().sub(rightValue()),
      Operator.mul => leftValue().mul(rightValue()),
      Operator.div => leftValue().div(rightValue()),
      Operator.mod => leftValue().mod(rightValue()),
      Operator.pow => leftValue().pow(rightValue()),
      Operator.lt => leftValue().lt(rightValue()),
      Operator.gt => leftValue().gt(rightValue()),
      Operator.eq => leftValue() == rightValue()
          ? const BoolValue(true)
          : const BoolValue(false),
      Operator.ne => leftValue() != rightValue()
          ? const BoolValue(true)
          : const BoolValue(false),
      Operator.lte => leftValue().lte(rightValue()),
      Operator.gte => leftValue().gte(rightValue()),
      Operator.assign => _assign(state, left, right),
      Operator.plusAssign =>
        _assignValue(state, left, leftValue().add(rightValue())),
      Operator.minusAssign =>
        _assignValue(state, left, leftValue().sub(rightValue())),
      Operator.mulAssign =>
        _assignValue(state, left, leftValue().mul(rightValue())),
      Operator.divAssign =>
        _assignValue(state, left, leftValue().div(rightValue())),
      Operator.pipe => _pipe(state, leftValue(), right),
      Operator.pipeWhere => _pipeWhere(state, leftValue(), right),
      Operator.funCreate => _funCreate(left, right),
      Operator.and => _locicalAnd(leftValue(), rightValue()),
      Operator.or => _locicalOr(leftValue(), rightValue()),
      Operator.getProperty => _getProperty(leftValue(), right),
    };
  }

  Value _locicalOr(Value left, Value right) {
    return switch ((left, right)) {
      (BoolValue(value: final left), BoolValue(value: final right)) =>
        BoolValue(left || right),
      _ => throw MyError.binaryOperatorTypeError('||', left.type, right.type)
    };
  }

  Value _locicalAnd(Value left, Value right) {
    return switch ((left, right)) {
      (BoolValue(value: final left), BoolValue(value: final right)) =>
        BoolValue(left && right),
      _ => throw MyError.binaryOperatorTypeError('&&', left.type, right.type)
    };
  }

  Value _assign(State state, Expr left, Expr right) {
    if (left case SequencialExpr(left: final nameExpr, right: final argExpr)) {
      if (nameExpr case (VariableExpr(:final name))) {
        if (argExpr case VariableExpr(name: final arg)) {
          final fun = FunValue([arg], right);
          state.set(name, fun);
          return fun;
        } else if (argExpr case SequenceExpr(exprs: final argExprs)) {
          final args = argExprs
              .map(
                (expr) => switch (expr) {
                  VariableExpr(:final name) => name,
                  _ => throw MyError.expectedIdentifier(
                      expr.runtimeType.toString(),
                    ),
                },
              )
              .toList();
          final fun = FunValue(args, right);
          state.set(name, fun);
          return fun;
        } else {
          throw MyError.expectedIdentifier(argExpr.runtimeType.toString());
        }
      } else {
        throw MyError.expectedIdentifier(nameExpr.runtimeType.toString());
      }
    }

    final rightValue = right.run(state);
    return _assignValue(state, left, rightValue);
  }

  Value _assignValue(State state, Expr left, Value rightValue) {
    if (left case VariableExpr(:final name)) {
      state.set(name, rightValue);
      return rightValue;
    }

    if ((left, rightValue)
        case (SequenceExpr(:final exprs), SequenceValue(:final values))) {
      if (exprs.length != values.length) {
        throw Exception('Cannot assign to sequence of different length');
      }
      for (var i = 0; i < exprs.length; i++) {
        _assignValue(state, exprs[i], values[i]);
      }
      return rightValue;
    }

    throw Exception('Cannot assign to $left');
  }

  Value _funCreate(Expr left, Expr right) {
    final args = switch (left) {
      VariableExpr(:final name) => [name],
      SequenceExpr(:final exprs) => exprs
          .map(
            (expr) => switch (expr) {
              VariableExpr(:final name) => name,
              _ => throw MyError.expectedIdentifier(
                  expr.runtimeType.toString(),
                ),
            },
          )
          .toList(),
      _ => throw MyError.expectedIdentifier(left.runtimeType.toString()),
    };
    return FunValue(args, right);
  }

  Value _getProperty(Value left, Expr right) {
    final property = switch (right) {
      VariableExpr(:final name) => name,
      _ => throw MyError.expectedIdentifier(left.runtimeType.toString()),
    };
    return left.getProperty(property);
  }

  Value _pipe(State state, Value left, Expr right) {
    Value runPipe(Value value) {
      state.pushScope();
      state.set('_', value);
      final result = right.run(state);
      state.popScope();
      switch (result) {
        case DartFunctionValue(:final args):
        case FunValue(:final args):
          if (args.isEmpty) {
            return result.call(state, []);
          }
          if (args.length == 1) {
            return result.call(state, [value]);
          }
          throw MyError.argumentLengthError(1, args.length);
        default:
          return result;
      }
    }

    switch (left) {
      case NumberValue(value: final number, :final unitSet):
        final result = <Value>[];
        for (var i = 0; i < number.toInt(); i++) {
          final returned = runPipe(NumberValue(Number.fromInt(i), unitSet));
          switch (returned) {
            case SequenceValue(:final values):
              result.addAll(values);
            default:
              result.add(returned);
          }
        }
        return ListValue.fromList(result);
      case ListValue(values: final list):
        final result = <Value>[];
        for (final value in list) {
          final returned = runPipe(value);
          switch (returned) {
            case SequenceValue(:final values):
              result.addAll(values);
            default:
              result.add(returned);
          }
        }
        return ListValue.fromList(result);
      default:
        throw MyError.unexpectedType('number or list', left.type);
    }
  }

  Value _pipeWhere(State state, Value left, Expr right) {
    Value runPipe(Value value) {
      state.pushScope();
      state.set('_', value);
      final result = right.run(state);
      state.popScope();
      switch (result) {
        case DartFunctionValue(:final args):
        case FunValue(:final args):
          if (args.isEmpty) {
            return result.call(state, []);
          }
          if (args.length == 1) {
            return result.call(state, [value]);
          }
          throw MyError.argumentLengthError(1, args.length);
        default:
          return result;
      }
    }

    switch (left) {
      case NumberValue(value: final number, :final unitSet):
        final result = <Value>[];
        for (var i = 0; i < number.toInt(); i++) {
          final input = NumberValue(Number.fromInt(i), unitSet);
          final condition = runPipe(input);
          if (condition case BoolValue(:final value)) {
            if (value) {
              result.add(input);
            }
          } else {
            throw MyError.unexpectedType('bool', condition.type);
          }
        }
        return ListValue.fromList(result);
      case ListValue(values: final list):
        return ListValue.fromList(
          list.where((value) {
            final condition = runPipe(value);
            if (condition case BoolValue(:final value)) {
              return value;
            } else {
              throw MyError.unexpectedType('bool', condition.type);
            }
          }).toList(),
        );
      default:
        throw MyError.unexpectedType('number or list', left.type);
    }
  }
}

enum Operator {
  add,
  sub,
  mul,
  div,
  mod,
  pow,
  assign,
  plusAssign,
  minusAssign,
  mulAssign,
  divAssign,
  pipe,
  pipeWhere,
  lt,
  gt,
  eq,
  ne,
  lte,
  gte,
  funCreate,
  and,
  or,
  getProperty,
}

class UnaryExpr extends Expr {
  UnaryExpr(this.op, this.expr);
  final UnaryOperator op;
  final Expr expr;

  @override
  Value run(State state) {
    Value value() => expr.run(state);
    switch (op) {
      case UnaryOperator.not:
        return value().not();
      case UnaryOperator.neg:
        return value().neg();
      case UnaryOperator.print:
        return _print(value());
      case UnaryOperator.inc ||
            UnaryOperator.dec ||
            UnaryOperator.postInc ||
            UnaryOperator.postDec:
        switch (expr) {
          case VariableExpr(:final name):
            final value = state.get(name);
            final newValue = switch (op) {
              UnaryOperator.inc ||
              UnaryOperator.postInc =>
                value.add(NumberValue.one),
              UnaryOperator.dec ||
              UnaryOperator.postDec =>
                value.sub(NumberValue.one),
              _ => throw UnimplementedError(),
            };
            state.set(name, newValue);
            final returnedValue = switch (op) {
              UnaryOperator.postInc || UnaryOperator.postDec => value,
              UnaryOperator.inc || UnaryOperator.dec => newValue,
              _ => throw UnimplementedError(),
            };
            return returnedValue;
          default:
            throw MyError.expectedIdentifier(expr.runtimeType.toString());
        }
      case UnaryOperator.spread:
        return switch (value()) {
          ListValue(values: final values) => SequenceValue(values),
          _ => throw MyError.unexpectedType('list', value().type),
        };
    }
  }

  Value _print(Value value) {
    // ignore: avoid_print
    print(value);
    return value;
  }
}

enum UnaryOperator {
  not,
  neg,
  inc,
  dec,
  postInc,
  postDec,
  print,
  spread,
}

class TernaryExpr extends Expr {
  TernaryExpr(this.condition, this.trueExpr, this.falseExpr);
  final Expr condition;
  final Expr trueExpr;
  final Expr? falseExpr;

  @override
  Value run(State state) {
    final conditionValue = condition.run(state);
    return switch (conditionValue) {
      BoolValue(:final value) => switch (value) {
          true => trueExpr.run(state),
          false => falseExpr?.run(state) ?? const UnknownValue(),
        },
      _ => throw Exception('Condition must be a boolean'),
    };
  }
}

class SequencialExpr extends Expr {
  SequencialExpr(this.left, this.right);
  final Expr left;
  final Expr right;

  static Token<SequencialExpr> Function(Token<Expr>, Token<String>, Token<Expr>)
      fromToken = (left, op, right) => Token(
            SequencialExpr(left.value, right.value),
            left.buffer + op.buffer + right.buffer,
            left.start,
            right.stop,
          );

  @override
  Value run(State state) {
    final leftValue = left.run(state);
    switch (leftValue) {
      case DartFunctionValue():
      case FunValue():
      case ListValue():
      case SequenceValue():
        final rightValue = right.run(state);
        final argValues = switch (rightValue) {
          SequenceValue(values: final values) => values,
          _ => [rightValue],
        };
        final result = leftValue.call(state, argValues);
        return result;
      case BoolValue(:final value):
        return switch (value) {
          true => right.run(state),
          false => const UnknownValue(),
        };
      // case ListValue():
      // final rightValue = right.run(state);

      default:
        final rightValue = right.run(state);
        return leftValue.mul(rightValue);
    }
  }
}

class LinesExpr extends Expr {
  LinesExpr(this.exprs);
  final List<Expr> exprs;

  @override
  Value run(State state) {
    Value? result;
    try {
      for (final expr in exprs) {
        result = expr.run(state);
        state.set('_', result);
      }
    } on ReturnException catch (e) {
      return e.value;
    }
    return result ?? const UnknownValue();
  }
}

class BlockExpr extends Expr {
  BlockExpr(this.expr);
  final LinesExpr expr;

  @override
  Value run(State state) {
    state.pushScope();
    final result = expr.run(state);
    state.popScope();
    return result;
  }
}

class ProtectedBlockExpr extends Expr {
  ProtectedBlockExpr(this.lines);
  final LinesExpr lines;

  @override
  Value run(State state) {
    state.pushProtectedScope();
    try {
      for (final expr in lines.exprs) {
        state.set('_', expr.run(state));
      }
    } on ReturnException catch (e) {
      state.popScope();
      return e.value;
    }
    final result = state.popScope();
    result.variables.remove('_');
    return ObjectValue(result.variables);
  }
}

class BlockedBlockExpr extends Expr {
  BlockedBlockExpr(this.lines);
  final LinesExpr lines;

  @override
  Value run(State state) {
    state.pushBlockedScope();
    state.pushScope();
    try {
      for (final expr in lines.exprs) {
        state.set('_', expr.run(state));
      }
    } on ReturnException catch (e) {
      state.popScope();
      state.popScope();
      return e.value;
    }
    final result = state.popScope();
    state.popScope();
    result.variables.remove('_');
    return ObjectValue(result.variables);
  }
}

class SequenceExpr extends Expr {
  SequenceExpr(this.exprs)
      : assert(
          exprs.isEmpty || exprs.length > 1,
          'Sequence must have more than one expression',
        ),
        assert(
          exprs.every((element) => element is! SequenceExpr),
          'Sequence cannot contain another sequence',
        );
  final List<Expr> exprs;

  @override
  Value run(State state) {
    final values = <Value>[];
    for (final expr in exprs) {
      final value = expr.run(state);
      switch (value) {
        case SequenceValue(values: final values2):
          values.addAll(values2);
        default:
          values.add(value);
      }
    }
    return SequenceValue(values);
  }
}

class VectorExpr extends Expr {
  VectorExpr(this.exprs);
  final List<Expr> exprs;

  @override
  Value run(State state) {
    final values = <Value>[];
    for (final expr in exprs) {
      values.add(expr.run(state));
    }
    return VectorValue(values);
  }
}

class ListExpr extends Expr {
  ListExpr(this.expr);

  final Expr? expr;

  @override
  Value run(State state) {
    final value = expr?.run(state);
    if (value == null) return const ListValue.empty();
    return ListValue(value);
  }
}
