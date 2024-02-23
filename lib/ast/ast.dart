import 'package:petitparser/petitparser.dart';
import 'package:tac_dart/errors.dart';
import 'package:tac_dart/number/number.dart';
import 'package:tac_dart/state.dart';
import 'package:tac_dart/units.dart';
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
      Operator.assign => _assign(state, left, rightValue()),
      Operator.plusAssign =>
        _assign(state, left, leftValue().add(rightValue())),
      Operator.minusAssign =>
        _assign(state, left, leftValue().sub(rightValue())),
      Operator.mulAssign => _assign(state, left, leftValue().mul(rightValue())),
      Operator.divAssign => _assign(state, left, leftValue().div(rightValue())),
      Operator.pipe => _pipe(state, leftValue(), right),
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

  Value _assign(State state, Expr left, Value rightValue) {
    if (left case VariableExpr(:final name)) {
      state.set(name, rightValue);
      return rightValue;
    } else {
      throw Exception('Cannot assign to $left');
    }
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
          if (args.length != 1) {
            throw Exception('Pipe function must have exactly one argument');
          }
          return result.call(state, [value]);
        default:
          return result;
      }
    }

    switch (left) {
      case NumberValue(value: final number, :final unitSet):
        final result = <Value>[];
        for (var i = 0; i < number.toInt(); i++) {
          result.add(runPipe(NumberValue(Number.fromInt(i), unitSet)));
        }
        return ListValue(result);
      case ListValue(values: final list):
        return ListValue(list.map(runPipe).toList());
      default:
        return runPipe(left);
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
      case UnaryOperator.inc || UnaryOperator.dec:
        switch (expr) {
          case VariableExpr(:final name):
            var value = state.get(name);
            value = switch (op) {
              UnaryOperator.inc => value.add(NumberValue.one),
              UnaryOperator.dec => value.sub(NumberValue.one),
              _ => value,
            };
            state.set(name, value);
            return value;
          default:
            throw Exception('Cannot increment $expr');
        }
      default:
        throw UnimplementedError();
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
  SequenceExpr(this.exprs);
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
  ListExpr(this.exprs);
  final List<Expr> exprs;

  @override
  Value run(State state) {
    final values = <Value>[];
    for (final expr in exprs) {
      values.add(expr.run(state));
    }
    return ListValue(values);
  }
}