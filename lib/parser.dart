import 'package:petitparser/petitparser.dart';
import 'package:rational/rational.dart';
import 'package:tac_dart/ast/ast.dart';
import 'package:tac_dart/errors.dart';

BlockExpr parse(String input) {
  final parser = createParser();
  final result = parser.parse(input);
  return switch (result) {
    Failure(:final message, :final position) =>
      throw SyntaxError(message, position),
    Success(value: final token) => token.value,
  };
}

Parser<Token<BlockExpr>> createParser() {
  final builder = ExpressionBuilder<Token<Expr>>();

  final expr = builder.loopback;

  final lines = expr.plusSeparated(char(';')).token().mapToken(
        (token) => BlockExpr(token.value.elements.map((e) => e.value).toList()),
      );

  final integer = digit().plus().flatten().token().trim().mapToken(
        (token) => NumberExpr(Rational.parse(token.value)),
      );
  final decimal = (digit().star() & char('.') & digit().plus())
      .flatten()
      .token()
      .mapToken((token) => NumberExpr(Rational.parse(token.value)));
  final integerWithUnit =
      (integer & letter().plus().flatten()).pick(0).cast<Token<Expr>>();
  final variable = letter()
      .plus()
      .flatten()
      .token()
      .trim()
      .mapToken((token) => VariableExpr(token.value));
  final string1 = (char('"') & any().starLazy(char('"')).flatten() & char('"'))
      .token()
      .trim()
      .mapToken((token) {
    return StringExpr(token.value[1] as String);
  });
  final string2 = (char("'") & any().starLazy(char("'")).flatten() & char("'"))
      .token()
      .trim()
      .mapToken((token) {
    return StringExpr(token.value[1] as String);
  });
  // final funCall = (expr & char('(') & expr & char(')')).map((value) {
  // return FunCallExpr(
  // value[0] as Expr,
  // value[2] as Expr,
  // );
  // });
  final block = (char('{') & lines & char('}'))
      .pick(1)
      .cast<Token<BlockExpr>>()
      .value()
      .token();

  builder.primitive(integerWithUnit);
  builder.primitive(integer);
  builder.primitive(decimal);
  builder.primitive(variable);
  builder.primitive(string1);
  builder.primitive(string2);
  builder.primitive(block);

  builder.group().wrapper(
        char('('),
        char(')'),
        (left, value, right) => value,
      );

  builder.group()
    ..prefix(
      Tokens.minus.token(),
      (op, a) => Token(
        UnaryExpr(UnaryOperator.neg, a.value),
        op.buffer + a.buffer,
        op.start,
        a.stop,
      ),
    )
    ..prefix(
      Tokens.exclaim.token(),
      (op, a) => Token(
        UnaryExpr(UnaryOperator.not, a.value),
        op.buffer + a.buffer,
        op.start,
        a.stop,
      ),
    )
    ..prefix(
      Tokens.gt.token(),
      (op, a) => Token(
        UnaryExpr(UnaryOperator.print, a.value),
        op.buffer + a.buffer,
        op.start,
        a.stop,
      ),
    );

  builder.group().right(Tokens.power, OperatorExpr.fromToken(Operator.pow));

  builder.group()
    ..left(Tokens.mul, OperatorExpr.fromToken(Operator.mul))
    ..left(Tokens.div, OperatorExpr.fromToken(Operator.div))
    ..left(Tokens.mod, OperatorExpr.fromToken(Operator.mod));

  builder.group()
    ..left(Tokens.plus, OperatorExpr.fromToken(Operator.add))
    ..left(Tokens.minus, OperatorExpr.fromToken(Operator.sub));

  builder.group()
    ..left(Tokens.lt, OperatorExpr.fromToken(Operator.lt))
    ..left(Tokens.gt, OperatorExpr.fromToken(Operator.gt))
    ..left(Tokens.eq, OperatorExpr.fromToken(Operator.eq))
    ..left(Tokens.ne, OperatorExpr.fromToken(Operator.ne))
    ..left(Tokens.lte, OperatorExpr.fromToken(Operator.lte))
    ..left(Tokens.gte, OperatorExpr.fromToken(Operator.gte));

  builder.group().left(Tokens.and, OperatorExpr.fromToken(Operator.and));

  builder.group().left(Tokens.or, OperatorExpr.fromToken(Operator.or));

  builder
      .group()
      // ..postfix(
      // (char('(') & expr & char(')'))
      // .pick(1)
      // .cast<Token<Expr>>()
      // .value()
      // .token(),
      // FunCallExpr.fromToken,
      // )
      .postfix(expr, SequencialExpr.fromToken);

  builder.group().left(Tokens.comma, (left, op, right) {
    final expr = switch (left.value) {
      SequenceExpr(:final exprs) => SequenceExpr([...exprs, right.value]),
      _ => SequenceExpr([left.value, right.value]),
    };
    return Token(expr, left.buffer, left.start, right.stop);
  });

  builder.group().right(
        Tokens.funCreate,
        OperatorExpr.fromToken(Operator.funCreate),
      );

  builder.group().right(
        Tokens.assign,
        OperatorExpr.fromToken(Operator.assign),
      );

  final _ = builder.build();

  return lines.end();
}

class Tokens {
  static final power1 = char('^').trim();
  static final power2 = string('**').trim();
  static final power = (power1 | power2).cast<String>();

  static final mul = char('*').trim();
  static final div = char('/').trim();
  static final mod = char('%').trim();

  static final plus = char('+').trim();
  static final minus = char('-').trim();

  static final and = string('&&').trim();
  static final or = string('||').trim();

  static final eq = string('==').trim();
  static final ne = string('!=').trim();
  static final lt = char('<').trim();
  static final gt = char('>').trim();
  static final lte = string('<=').trim();
  static final gte = string('>=').trim();

  static final comma = char(',').trim();

  static final assign = char('=').trim();

  static final openParen = char('(').trim();
  static final closeParen = char(')').trim();

  static final openBrace = char('{').trim();
  static final closeBrace = char('}').trim();

  static final openBracket = char('[').trim();
  static final closeBracket = char(']').trim();

  static final semicolon = char(';').trim();

  static final funCreate = string('=>').trim();

  static final exclaim = char('!').trim();
}

extension MapTokenParser<T1> on Parser<Token<T1>> {
  Parser<Token<T2>> mapToken<T2>(T2 Function(Token<T1>) f) {
    return map(
      (token) => Token(f(token), token.buffer, token.start, token.stop),
    );
  }

  Parser<T1> value() => map((token) => token.value);
}

// class MyGrammarDefinition extends GrammarDefinition<BlockExpr> {
//   @override
//   Parser<BlockExpr> start() => ref0(lines).end();

//   Parser<BlockExpr> lines() => ref0(expr)
//       .plusSeparated(char(';'))
//       .map((list) => BlockExpr(list.elements));

//   Parser<Expr> expr() {
//     final builder = ExpressionBuilder<Expr>();

//     builder.primitive(exprFinal());

//     builder.group().wrapper(
//           char('('),
//           char(')'),
//           (left, value, right) => value,
//         );

//     builder.group()
//       ..prefix(
//         char('-'),
//         (op, a) => UnaryExpr(UnaryOperator.neg, a),
//       )
//       ..prefix(
//         char('!'),
//         (op, a) => UnaryExpr(UnaryOperator.not, a),
//       )
//       ..prefix(
//         char('>'),
//         (op, a) => UnaryExpr(UnaryOperator.print, a),
//       );

//     builder.group().right(char('^'), OperatorExpr.fromToken(Operator.pow));

//     builder.group()
//       ..left(char('*'), OperatorExpr.fromToken(Operator.mul))
//       ..left(char('/'), OperatorExpr.fromToken(Operator.div))
//       ..left(char('%'), OperatorExpr.fromToken(Operator.mod));

//     builder.group()
//       ..left(char('+'), OperatorExpr.fromToken(Operator.add))
//       ..left(char('-'), OperatorExpr.fromToken(Operator.sub));

//     builder.group()
//       ..left(char('<'), OperatorExpr.fromToken(Operator.lt))
//       ..left(char('>'), OperatorExpr.fromToken(Operator.gt))
//       ..left(string('=='), OperatorExpr.fromToken(Operator.eq))
//       ..left(string('!='), OperatorExpr.fromToken(Operator.ne))
//       ..left(string('<='), OperatorExpr.fromToken(Operator.lte))
//       ..left(
//         string('>='),
//         OperatorExpr.fromToken(Operator.gte),
//       );

//     return builder.build();
//   }

//   Parser<Expr> exprAssign() => [
//         ref0(exprPipe),
//         [
//           ref0(exprPipe),
//           char('='),
//           ref0(exprAssign),
//         ].toSequenceParser().map((token) {
//           return OperatorExpr(
//             token.value[0] as Expr,
//             Operator.assign,
//             token.value[2] as Expr,
//           );
//         }),
//       ].toChoiceParser();

//   Parser<Expr> exprPipe() => [
//         ref0(exprFunCreate),
//         [
//           ref0(exprFunCreate),
//           char('|'),
//           ref0(exprPipe),
//         ].toSequenceParser().map((value) {
//           return OperatorExpr(
//             value[0] as Expr,
//             Operator.pipe,
//             value[2] as Expr,
//           );
//         }),
//       ].toChoiceParser();

//   Parser<Expr> exprFunCreate() => [
//         ref0(exprSequence),
//         [
//           ref0(exprSequence),
//           string('=>'),
//           ref0(exprFunCreate),
//         ].toSequenceParser().map((value) {
//           return OperatorExpr(
//             value[0] as Expr,
//             Operator.funCreate,
//             value[2] as Expr,
//           );
//         }),
//       ].toChoiceParser();

//   Parser<Expr> exprSequence() =>
//       ref0(exprComparison).plusSeparated(char(',')).map((value) {
//         if (value.elements.length == 1) {
//           return value.elements.first;
//         }
//         return SequenceExpr(value.elements);
//       });

//   Parser<Expr> exprComparison() => [
//         ref0(exprAdd),
//         [
//           ref0(exprAdd),
//           [
//             char('<'),
//             char('>'),
//             string('=='),
//             string('!='),
//             char('<'),
//             char('>'),
//             string('<='),
//           ].toChoiceParser().map((value) {
//             final operatorMap = {
//               '<': Operator.lt,
//               '>': Operator.gt,
//               '==': Operator.eq,
//               '!=': Operator.ne,
//               '<=': Operator.lte,
//               '>=': Operator.gte,
//             };
//             return operatorMap[value];
//           }),
//           ref0(exprComparison),
//         ].toSequenceParser().map((value) {
//           return OperatorExpr(
//             value[0]! as Expr,
//             value[1]! as Operator,
//             value[2]! as Expr,
//           );
//         }),
//       ].toChoiceParser();

//   Parser<Expr> exprAdd() => [
//         ref0(exprMul),
//         [
//           ref0(exprMul),
//           [
//             char('+'),
//             char('-'),
//           ].toChoiceParser().map((value) {
//             final operatorMap = {
//               '+': Operator.add,
//               '-': Operator.sub,
//             };
//             return operatorMap[value];
//           }),
//           ref0(exprAdd),
//         ].toSequenceParser().map((value) {
//           return OperatorExpr(
//             value[0]! as Expr,
//             value[1]! as Operator,
//             value[2]! as Expr,
//           );
//         }),
//       ].toChoiceParser();

//   Parser<Expr> exprMul() => [
//         ref0(exprPow),
//         [
//           ref0(exprPow),
//           [
//             char('*'),
//             char('/'),
//             char('%'),
//           ].toChoiceParser().map((value) {
//             final operatorMap = {
//               '*': Operator.mul,
//               '/': Operator.div,
//               '%': Operator.mod,
//             };
//             return operatorMap[value];
//           }),
//           ref0(exprMul),
//         ].toSequenceParser().map((value) {
//           return OperatorExpr(
//             value[0]! as Expr,
//             value[1]! as Operator,
//             value[2]! as Expr,
//           );
//         }),
//       ].toChoiceParser();

//   Parser<Expr> exprPow() => [
//         ref0(exprUnary),
//         [
//           ref0(exprUnary),
//           char('^'),
//           ref0(exprPow),
//         ].toSequenceParser().map((value) {
//           return OperatorExpr(
//             value[0] as Expr,
//             Operator.pow,
//             value[2] as Expr,
//           );
//         }),
//       ].toChoiceParser();

//   Parser<Expr> exprUnary() => [
//         ref0(exprFunCall),
//         [
//           [
//             char('-'),
//             char('!'),
//           ].toChoiceParser().map((value) {
//             final operatorMap = {
//               '-': UnaryOperator.neg,
//               '!': UnaryOperator.not,
//             };
//             return operatorMap[value];
//           }),
//           ref0(exprUnary),
//         ].toSequenceParser().map((value) {
//           return UnaryExpr(
//             value[0]! as UnaryOperator,
//             value[1]! as Expr,
//           );
//         }).cast<Expr>(),
//       ].toChoiceParser();

//   Parser<Expr> exprFunCall() => [
//         ref0(exprFinal),
//         [
//           ref0(exprFinal),
//           char('('),
//           ref0(expr).plusSeparated(char(',')).map((value) => value.elements),
//           char(')'),
//         ].toSequenceParser().map((value) {
//           return FunCallExpr(
//             value[0] as Expr,
//             value[2] as Expr,
//           );
//         }),
//       ].toChoiceParser();

//   Parser<Expr> exprFinal() => [
//         decimalExpr(),
//         integerExpr(),
//         variableExpr(),
//         string1Expr(),
//         string2Expr(),
//         blockExpr(),
//       ].toChoiceParser();

//   Parser<Expr> integerExpr() =>
//       digit().plus().flatten().map((str) => NumberExpr(Rational.parse(str)));

//   Parser<Expr> decimalExpr() => [
//         digit().star().flatten(),
//         char('.'),
//         digit().plus().flatten(),
//       ].toSequenceParser().map((value) {
//         return NumberExpr(Rational.parse(value.join()));
//       });

//   Parser<VariableExpr> variableExpr() =>
//       letter().plus().flatten().map(VariableExpr.new);

//   Parser<Expr> string1Expr() => [
//         char('"'),
//         any().starLazy(char('"')).map((list) {
//           return list.join();
//         }),
//         char('"'),
//       ].toSequenceParser().map((value) {
//         return StringExpr(value[1]);
//       });

//   Parser<Expr> string2Expr() => [
//         char("'"),
//         any().starLazy(char("'")).map((list) {
//           return list.join();
//         }),
//         char("'"),
//       ].toSequenceParser().map((value) {
//         return StringExpr(value[1]);
//       });

//   Parser<Expr> parenthExpr() =>
//       char('(').seq(ref0(expr)).seq(char(')')).pick(1).cast<Expr>();

//   Parser<Expr> blockExpr() => [
//         char('{'),
//         ref0(lines),
//         char('}'),
//       ].toSequenceParser().pick(1).cast<Expr>();
// }
