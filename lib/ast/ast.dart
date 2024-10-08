import 'package:petitparser/petitparser.dart';
import 'package:tac/ast/ast_tree.dart';
import 'package:tac/number/number.dart';
import 'package:tac/tac.dart';
import 'package:tac/units/unitset.dart';
import 'package:tac/utils/errors.dart';
import 'package:tac/value/value.dart';

sealed class Expr {
  Future<Value> run(Tac state);

  AstTree toTree();
  String toExpr();
}

class ValueExpr extends Expr {
  ValueExpr(this.value);

  final Value value;

  @override
  Future<Value> run(Tac state) async => value;

  @override
  String toExpr() => value.toExpr();

  @override
  AstTree toTree() => AstTree('value', {
        'value': value.toString(),
      });
}

class NumberExpr extends Expr {
  NumberExpr(this.rational, this.unitSet);

  final Number rational;
  final UnitSet unitSet;

  @override
  Future<Value> run(Tac state) async => NumberValue(rational, unitSet);

  @override
  AstTree toTree() => AstTree(
        'number',
        {
          'value': rational.toString(),
          if (!unitSet.isEmpty) 'unitSet': unitSet.toString(),
        },
      );

  @override
  String toExpr() => '$rational${unitSet.isEmpty ? '' : '[$unitSet]'}';
}

class VariableExpr extends Expr {
  VariableExpr(this.name);
  final String name;

  @override
  Future<Value> run(Tac state) async => state.get(name);

  @override
  String toString() => 'VariableExpr($name)';

  @override
  AstTree toTree() => AstTree('variable', {'name': name});

  @override
  String toExpr() => name;
}

class StringExpr extends Expr {
  StringExpr(this.string);
  final String string;

  @override
  Future<Value> run(Tac state) async => StringValue(string);

  @override
  AstTree toTree() => AstTree('string', {'value': string});

  @override
  String toExpr() => '"$string"';
}

class OperatorExpr extends Expr {
  OperatorExpr(this.left, this.op, this.right);
  final Operator op;
  final Expr left;
  final Expr right;

  @override
  AstTree toTree() => AstTree(
        'operator',
        {'op': op.name},
        [left.toTree(), right.toTree()],
      );

  @override
  String toExpr() => '(${left.toExpr()}${op.symbol}${right.toExpr()})';

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
          ),
          left.buffer + op + right.buffer,
          left.start,
          right.stop,
        );
  }

  @override
  Future<Value> run(Tac state) async {
    Future<Value> leftValue() => left.run(state);
    Future<Value> rightValue() => right.run(state);

    return switch (op) {
      Operator.add => (await leftValue()).add(await rightValue()),
      Operator.sub => (await leftValue()).sub(await rightValue()),
      Operator.mul => (await leftValue()).mul(await rightValue()),
      Operator.div => (await leftValue()).div(await rightValue()),
      Operator.mod => (await leftValue()).mod(await rightValue()),
      Operator.pow => (await leftValue()).pow(await rightValue()),
      Operator.lt => (await leftValue()).lt(await rightValue()),
      Operator.gt => (await leftValue()).gt(await rightValue()),
      Operator.eq => (await leftValue()) == (await rightValue())
          ? const BoolValue(true)
          : const BoolValue(false),
      Operator.ne => (await leftValue()) != (await rightValue())
          ? const BoolValue(true)
          : const BoolValue(false),
      Operator.lte => (await leftValue()).lte(await rightValue()),
      Operator.gte => (await leftValue()).gte(await rightValue()),
      Operator.assign => await _assign(state, left, right),
      Operator.plusAssign =>
        _assignValue(state, left, (await leftValue()).add(await rightValue())),
      Operator.minusAssign =>
        _assignValue(state, left, (await leftValue()).sub(await rightValue())),
      Operator.mulAssign =>
        _assignValue(state, left, (await leftValue()).mul(await rightValue())),
      Operator.divAssign =>
        _assignValue(state, left, (await leftValue()).div(await rightValue())),
      Operator.pipe => await _pipe(state, await leftValue(), right),
      Operator.pipeWhere => await _pipeWhere(state, await leftValue(), right),
      Operator.funCreate => _funCreate(left, right),
      Operator.and => _locicalAnd(await leftValue(), await rightValue()),
      Operator.or => _locicalOr(await leftValue(), await rightValue()),
      Operator.getProperty => _getProperty(await leftValue(), right),
      Operator.unitConvert =>
        _unitConvert(state, await leftValue(), await rightValue()),
    };
  }

  Future<Value> _unitConvert(Tac state, Value left, Value right) async {
    if (left is NumberValue) {
      if (right case NumberValue(unitSet: final unitSet2)) {
        final number = left.convertToUnit(unitSet2);
        return NumberValue(number, unitSet2);
      } else {
        throw MyError.unexpectedType('number', right.type);
      }
    } else {
      throw MyError.unexpectedType('number', left.type);
    }
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

  List<String>? getPropertyChain(Expr expr) {
    if (expr
        case OperatorExpr(
          left: VariableExpr(:final name),
          op: Operator.getProperty,
          right: VariableExpr(name: final property)
        )) {
      return [name, property];
    }
    if (expr
        case OperatorExpr(
          left: VariableExpr(:final name),
          op: Operator.getProperty,
          right: OperatorExpr(),
        )) {
      final properties = getPropertyChain(expr.left);
      if (properties != null) {
        return [name, ...properties];
      }
    }
    return null;
  }

  Future<Value> _assign(Tac state, Expr left, Expr right) async {
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

    final properties = getPropertyChain(left);
    if (properties != null) {
      var value = state.get(properties.first);
      for (var i = 1; i < properties.length - 2; i++) {
        value = value.getProperty(properties[i]);
      }
      final property = properties.last;
      final rightValue = await right.run(state);
      value.setProperty(property, rightValue);
      return rightValue;
    }

    final rightValue = await right.run(state);
    return _assignValue(state, left, rightValue);
  }

  Value _assignValue(Tac state, Expr left, Value rightValue) {
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
    // var tempRight = right;
    // final operations = <Expr>[];
    // String? foundName;
    // while (true) {
    //   if (tempRight case VariableExpr(:final name)) {
    //     foundName = name;
    //     break;
    //   } else if (tempRight
    //       case SequencialExpr(left: VariableExpr(:final name))) {
    //     operations.add(tempRight.right);
    //     foundName = name;
    //     break;
    //   } else if (tempRight
    //       case SequencialExpr(left: SequencialExpr(), right: SequenceExpr())) {
    //     operations.add(tempRight.right);
    //     tempRight = tempRight.left;
    //   } else {
    //     throw 'temp';
    //   }
    // }
    final property = switch (right) {
      VariableExpr(:final name) => name,
      _ => throw MyError.expectedIdentifier(left.runtimeType.toString()),
    };
    return left.getProperty(property);
    // var result = left.getProperty(foundName);
    // for (final operation in operations.reversed) {
    //   result = await SequencialExpr(result, operation).run(state);
    // }
  }

  Future<Value> _pipe(Tac state, Value left, Expr right) async {
    Future<Value> runPipe(Value value) async {
      state.pushScope();
      state.set('_', value);
      final result = await right.run(state);
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
          final returned =
              await runPipe(NumberValue(Number.fromInt(i), unitSet));
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
          final returned = await runPipe(value);
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

  Future<Value> _pipeWhere(Tac state, Value left, Expr right) async {
    Future<Value> runPipe(Value value) async {
      state.pushScope();
      state.set('_', value);
      final result = await right.run(state);
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
          final condition = await runPipe(input);
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
        final newList = <Value>[];
        for (final value in list) {
          final condition = await runPipe(value);
          if (condition case BoolValue(value: final conditionValue)) {
            if (conditionValue) {
              newList.add(value);
            }
          } else {
            throw MyError.unexpectedType('bool', condition.type);
          }
        }
        return ListValue.fromList(newList);
      default:
        throw MyError.unexpectedType('number or list', left.type);
    }
  }
}

enum Operator {
  add('+'),
  sub('-'),
  mul('*'),
  div('/'),
  mod('%'),
  pow('^'),
  assign('='),
  plusAssign('+='),
  minusAssign('-='),
  mulAssign('*='),
  divAssign('/='),
  pipe('|'),
  pipeWhere('|?'),
  lt('<'),
  gt('>'),
  eq('=='),
  ne('!='),
  lte('<='),
  gte('>='),
  funCreate('=>'),
  and('&&'),
  or('||'),
  getProperty('.'),
  unitConvert('->');

  const Operator(this.symbol);

  final String symbol;
}

class UnaryExpr extends Expr {
  UnaryExpr(this.op, this.expr);
  final UnaryOperator op;
  final Expr expr;

  @override
  Future<Value> run(Tac state) async {
    switch (op) {
      case UnaryOperator.not:
        return (await expr.run(state)).not();
      case UnaryOperator.neg:
        return (await expr.run(state)).neg();
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
        final value = await expr.run(state);
        return switch (value) {
          ListValue(values: final values) => SequenceValue(values),
          _ => throw MyError.unexpectedType('list', value.type),
        };
    }
  }

  @override
  AstTree toTree() => AstTree(
        'unary',
        {'op': op.name},
        [expr.toTree()],
      );

  @override
  String toExpr() {
    if (op.isPost) {
      return '${expr.toExpr()}${op.symbol}';
    }
    return '${op.symbol}${expr.toExpr()}';
  }
}

enum UnaryOperator {
  not('!'),
  neg('-'),
  inc('++'),
  dec('--'),
  postInc('++', isPost: true),
  postDec('--', isPost: true),
  spread('...');

  const UnaryOperator(this.symbol, {this.isPost = false});

  final String symbol;
  final bool isPost;
}

class TernaryExpr extends Expr {
  TernaryExpr(this.condition, this.trueExpr, this.falseExpr);
  final Expr condition;
  final Expr trueExpr;
  final Expr? falseExpr;

  @override
  Future<Value> run(Tac state) async {
    final conditionValue = await condition.run(state);
    return switch (conditionValue) {
      BoolValue(:final value) => switch (value) {
          true => await trueExpr.run(state),
          false => await falseExpr?.run(state) ?? const UnknownValue(),
        },
      _ => throw Exception('Condition must be a boolean'),
    };
  }

  @override
  AstTree toTree() => AstTree(
        'ternary',
        {},
        [
          condition.toTree(),
          trueExpr.toTree(),
          if (falseExpr != null) falseExpr!.toTree(),
        ],
      );

  @override
  String toExpr() {
    var expr = '${condition.toExpr()} ? ${trueExpr.toExpr()}';
    if (falseExpr != null) {
      expr += ' : ${falseExpr!.toExpr()}';
    }
    return expr;
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
  Future<Value> run(Tac state) async {
    final leftValue = await left.run(state);
    switch (leftValue) {
      case DartFunctionValue():
      case FunValue():
      case ListValue():
      case VectorValue():
      case SequenceValue():
        final rightValue = await right.run(state);
        final argValues = switch (rightValue) {
          SequenceValue(values: final values) => values,
          _ => [rightValue],
        };
        final result = leftValue.call(state, argValues);
        return result;
      case BoolValue(:final value):
        final rightValue = await right.run(state);
        return switch (value) {
          true => rightValue,
          false => const UnknownValue(),
        };
      default:
        final rightValue = await right.run(state);
        return leftValue.mul(rightValue);
    }
  }

  @override
  AstTree toTree() => AstTree(
        'sequencial',
        {},
        [left.toTree(), right.toTree()],
      );

  @override
  String toExpr() => '${left.toExpr()}(${right.toExpr()})';
}

class LinesExpr extends Expr {
  LinesExpr(this.exprs);
  final List<Expr> exprs;

  @override
  Future<Value> run(Tac state) async {
    Value? result;
    try {
      for (final expr in exprs) {
        result = await expr.run(state);
        state.set('_', result);
      }
    } on ReturnException catch (e) {
      return e.value;
    }
    return result ?? const UnknownValue();
  }

  @override
  AstTree toTree() => AstTree(
        'lines',
        {},
        exprs.map((expr) => expr.toTree()).toList(),
      );

  @override
  String toExpr() => exprs.map((expr) => expr.toExpr()).join(';');
}

abstract class AnyBlockExpr extends Expr {
  Future<Value> runWithProps(Tac state, Map<String, Value> props);
}

class BlockExpr extends AnyBlockExpr {
  BlockExpr(this.lines);
  final LinesExpr lines;

  @override
  Future<Value> run(Tac state) => runWithProps(state, {});

  @override
  Future<Value> runWithProps(Tac state, Map<String, Value> props) async {
    state.pushScope();
    state.setAll(props);
    final result = await lines.run(state);
    state.popScope();
    return result;
  }

  @override
  AstTree toTree() => AstTree(
        'block',
        {},
        [lines.toTree()],
      );

  @override
  String toExpr() => '{${lines.toExpr()}}';
}

class ProtectedBlockExpr extends AnyBlockExpr {
  ProtectedBlockExpr(this.lines);
  final LinesExpr lines;

  @override
  Future<Value> run(Tac state) => runWithProps(state, {});

  @override
  Future<Value> runWithProps(Tac state, Map<String, Value> props) async {
    state.pushProtectedScope();
    state.setAll(props);
    try {
      for (final expr in lines.exprs) {
        state.set('_', await expr.run(state));
      }
    } on ReturnException catch (e) {
      state.popScope();
      return e.value;
    }
    final result = state.popScope();
    result.variables.remove('_');
    return ObjectValue(result.variables);
  }

  @override
  AstTree toTree() => AstTree(
        'protectedBlock',
        {},
        [lines.toTree()],
      );

  @override
  String toExpr() => '{{${lines.toExpr()}}}';
}

class BlockedBlockExpr extends AnyBlockExpr {
  BlockedBlockExpr(this.lines);
  final LinesExpr lines;

  @override
  Future<Value> run(Tac state) => runWithProps(state, {});

  @override
  Future<Value> runWithProps(Tac state, Map<String, Value> props) async {
    // This is to make sure that all the loaded libraries are not returned.
    state.pushBlockedScope();
    state.pushScope();
    state.setAll(props);
    try {
      for (final expr in lines.exprs) {
        state.set('_', await expr.run(state));
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

  @override
  AstTree toTree() => AstTree(
        'blockedBlock',
        {},
        [lines.toTree()],
      );

  @override
  String toExpr() => '{{{${lines.toExpr()}}}}';
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
  Future<Value> run(Tac state) async {
    final values = <Value>[];
    for (final expr in exprs) {
      final value = await expr.run(state);
      switch (value) {
        case SequenceValue(values: final values2):
          values.addAll(values2);
        default:
          values.add(value);
      }
    }
    return SequenceValue(values);
  }

  @override
  AstTree toTree() => AstTree(
        'sequence',
        {},
        exprs.map((expr) => expr.toTree()).toList(),
      );

  @override
  String toExpr() => '(${exprs.map((expr) => expr.toExpr()).join(',')})';
}

class ListExpr extends Expr {
  ListExpr(this.expr);

  final Expr? expr;

  @override
  Future<Value> run(Tac state) async {
    final value = await expr?.run(state);
    if (value == null) return const ListValue.empty();
    return ListValue(value);
  }

  @override
  AstTree toTree() => AstTree(
        'list',
        {},
        [if (expr != null) expr!.toTree()],
      );

  @override
  String toExpr() => '[${expr?.toExpr() ?? ''}]';
}

class VectorExpr extends Expr {
  VectorExpr(this.expr);

  final Expr? expr;

  @override
  Future<Value> run(Tac state) async {
    final value = await expr?.run(state);
    if (value == null) return const VectorValue.empty();
    return VectorValue.fromSingleValue(value);
  }

  @override
  AstTree toTree() => AstTree(
        'vector',
        {},
        [if (expr != null) expr!.toTree()],
      );

  @override
  String toExpr() => '<${expr?.toExpr() ?? ''}>';
}
