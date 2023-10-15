import 'package:petitparser/petitparser.dart';
import 'package:rational/rational.dart';
import 'package:tac_dart/errors.dart';

import 'package:tac_dart/state.dart';
import 'package:tac_dart/value/value.dart';

sealed class Expr {
  Value run(State state);
}

class NumberExpr extends Expr {
  NumberExpr(this.rational);
  final Rational rational;

  @override
  Value run(State state) => NumberValue(rational);
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
    Operator operator,
  ) {
    return (left, op, right) => Token(
          OperatorExpr(
            left.value,
            operator,
            right.value,
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

    try {
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
        Operator.pipe => throw UnimplementedError(),
        Operator.funCreate => _funCreate(left, right),
        Operator.and => throw UnimplementedError(),
        Operator.or => throw UnimplementedError(),
        Operator.getProperty => _getProperty(leftValue(), right),
      };
    } on BinaryOperatorTypeError catch (e) {
      print(e);
      throw ErrorWithPositions(e, start, stop);
    }
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
              _ => throw ExpectedIdentifierError(
                  expr.runtimeType.toString(),
                ),
            },
          )
          .toList(),
      _ => throw ExpectedIdentifierError(left.runtimeType.toString()),
    };
    return FunValue(args, right);
  }

  Value _getProperty(Value left, Expr right) {
    final property = switch (right) {
      VariableExpr(:final name) => name,
      _ => throw ExpectedIdentifierError(left.runtimeType.toString()),
    };
    return left.getProperty(property);
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
    final value = expr.run(state);
    return switch (op) {
      UnaryOperator.not => value.not(),
      UnaryOperator.neg => value.neg(),
      UnaryOperator.print => _print(value),
    };
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
        state.pushScope();
        final result = leftValue.call(state, argValues);
        state.popScope();
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

class ScopelessBlockExpr extends Expr {
  ScopelessBlockExpr(this.exprs);
  final List<Expr> exprs;

  @override
  Value run(State state) {
    Value? result;
    for (final expr in exprs) {
      result = expr.run(state);
    }
    return result ?? const UnknownValue();
  }
}

class BlockExpr extends Expr {
  BlockExpr(this.exprs);
  final List<Expr> exprs;

  @override
  Value run(State state) {
    state.pushScope();
    for (final expr in exprs) {
      expr.run(state);
    }
    final result = state.popScope();
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
