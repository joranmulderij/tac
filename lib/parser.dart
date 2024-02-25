import 'package:petitparser/petitparser.dart';
import 'package:tac_dart/ast/ast.dart';
import 'package:tac_dart/number/number.dart';
import 'package:tac_dart/units.dart';
import 'package:tac_dart/utils/errors.dart';

final _parser = _createParser();

LinesExpr parse(String input) {
  final result = _parser.parse(input);
  return switch (result) {
    Failure(:final message) => throw MyError.syntax(message),
    Success(value: final token) => token.value,
  };
}

Parser<Token<LinesExpr>> _createParser() {
  final builder = ExpressionBuilder<Token<Expr>>();

  final expr = builder.loopback;

  final lineSeperator =
      (Tokens.semicolon | char('\n') | char('\r')).trimNoNewline().cast<void>();

  final lines = (expr.starSeparated(lineSeperator.plus()) &
          (lineSeperator | whitespace()).star())
      .pick(0)
      .cast<SeparatedList<Token<Expr>, void>>()
      .token()
      .mapToken(
        (token) => LinesExpr(token.value.elements.map((e) => e.value).toList()),
      );

  final unitSet = (Tokens.openBracket &
          (letter().trimNoNewline() | digit().trimNoNewline() | Tokens.minus)
              .star()
              .flatten() &
          Tokens.closeBracket)
      .map((values) => UnitSet.parse(values[1] as String));

  final integer = (digit().plus().flatten() & unitSet.optional())
      .token()
      .trimNoNewline()
      .mapToken(
        (token) => NumberExpr(
          Number.fromString(token.value[0] as String),
          (token.value[1] as UnitSet?) ?? UnitSet.empty,
        ),
      );
  final decimal = ((digit().star() & char('.') & digit().plus()).flatten() &
          unitSet.optional())
      .token()
      .trimNoNewline()
      .mapToken(
        (token) => NumberExpr(
          Number.fromString(token.value[0] as String),
          (token.value[1] as UnitSet?) ?? UnitSet.empty,
        ),
      );
  final float = (Tokens.floatPrefix &
          (digit().plus() & (char('.') & digit().plus()).optional()).flatten() &
          unitSet.optional())
      .token()
      .trimNoNewline()
      .mapToken(
        (token) => NumberExpr(
          FloatNumber(num.parse(token.value[1] as String)),
          (token.value[2] as UnitSet?) ?? UnitSet.empty,
        ),
      );
  final variable = (letter() | char('_'))
      .plus()
      .flatten()
      .token()
      .trimNoNewline()
      .mapToken((token) => VariableExpr(token.value));
  final string1 = (char('"') & any().starLazy(char('"')).flatten() & char('"'))
      .token()
      .trimNoNewline()
      .mapToken((token) {
    return StringExpr(token.value[1] as String);
  });
  final string2 = (char("'") & any().starLazy(char("'")).flatten() & char("'"))
      .token()
      .trimNoNewline()
      .mapToken((token) {
    return StringExpr(token.value[1] as String);
  });
  final emptySequence = (Tokens.openParen & Tokens.closeParen)
      .map((value) => SequenceExpr([]))
      .token();
  final emptyList = (Tokens.openBracket & Tokens.closeBracket)
      .map((value) => ListExpr(null))
      .token();

  Parser<Token<T>> block<T extends Expr>(
    Parser<String> start,
    Parser<String> end,
    T Function(LinesExpr lines) blockFun,
  ) {
    return (start &
            lineSeperator.star() &
            expr.starSeparated(lineSeperator.plus()).token().mapToken(
                  (token) => blockFun(
                    LinesExpr(
                      token.value.elements.map((e) => e.value).toList(),
                    ),
                  ),
                ) &
            lineSeperator.star() &
            end)
        .pick(2)
        .cast<Token<T>>()
        .value()
        .token();
  }

  builder.primitive(float);
  builder.primitive(decimal);
  builder.primitive(integer);
  builder.primitive(variable);
  builder.primitive(string1);
  builder.primitive(string2);
  builder.primitive(emptySequence);
  builder.primitive(emptyList);
  builder.primitive(
    block<BlockedBlockExpr>(
      Tokens.openTripleBrace,
      Tokens.closeTripleBrace,
      BlockedBlockExpr.new,
    ),
  );
  builder.primitive(
    block<ProtectedBlockExpr>(
      Tokens.openDoubleBrace,
      Tokens.closeDoubleBrace,
      ProtectedBlockExpr.new,
    ),
  );
  builder.primitive(
    block<BlockExpr>(Tokens.openBrace, Tokens.closeBrace, BlockExpr.new),
  );

  builder.group().wrapper(
        Tokens.openParen,
        Tokens.closeParen,
        (left, value, right) => value,
      );

  builder.group().wrapper(
    Tokens.openBracket.token(),
    (Tokens.comma.optional() & Tokens.closeBracket).token(),
    (left, middle, right) {
      return Token(
        ListExpr(middle.value),
        left.buffer + middle.buffer + right.buffer,
        left.start,
        right.stop,
      );
    },
  );

  // TODO: Find syntax for vectors
  // Currently, they are not correctly parsed because of the < and > tokens
  // builder.group().wrapper(
  //   Tokens.lt.token(),
  //   (Tokens.comma.optional() & Tokens.gt).token(),
  //   (left, middle, right) {
  //     final exprs = switch (middle.value) {
  //       SequenceExpr(:final exprs) => exprs,
  //       final expr => [expr],
  //     };
  //     return Token(
  //       VectorExpr(exprs),
  //       left.buffer + middle.buffer + right.buffer,
  //       left.start,
  //       right.stop,
  //     );
  //   },
  // );

  // Property access
  builder.group().right(
        Tokens.dot,
        OperatorExpr.fromToken(Operator.getProperty),
      );

  builder.group()
    ..prefix(
      Tokens.spread.token(),
      (op, a) => Token(
        UnaryExpr(UnaryOperator.spread, a.value),
        op.buffer + a.buffer,
        op.start,
        a.stop,
      ),
    )
    ..prefix(
      Tokens.exclaimark.token(),
      (op, a) => Token(
        UnaryExpr(UnaryOperator.not, a.value),
        op.buffer + a.buffer,
        op.start,
        a.stop,
      ),
    )
    ..postfix(
      Tokens.increment.token(),
      (a, op) => Token(
        UnaryExpr(UnaryOperator.postInc, a.value),
        op.buffer + a.buffer,
        op.start,
        a.stop,
      ),
    )
    ..postfix(
      Tokens.decrement.token(),
      (a, op) => Token(
        UnaryExpr(UnaryOperator.postDec, a.value),
        op.buffer + a.buffer,
        op.start,
        a.stop,
      ),
    )
    ..prefix(
      Tokens.increment.token(),
      (op, a) => Token(
        UnaryExpr(UnaryOperator.inc, a.value),
        op.buffer + a.buffer,
        op.start,
        a.stop,
      ),
    )
    ..prefix(
      Tokens.decrement.token(),
      (op, a) => Token(
        UnaryExpr(UnaryOperator.dec, a.value),
        op.buffer + a.buffer,
        op.start,
        a.stop,
      ),
    )
    ..prefix(
      Tokens.minus.token(),
      (op, a) => Token(
        UnaryExpr(UnaryOperator.neg, a.value),
        op.buffer + a.buffer,
        op.start,
        a.stop,
      ),
    );

  // ..prefix(
  //   Tokens.gt.token(),
  //   (op, a) => Token(
  //     UnaryExpr(UnaryOperator.print, a.value),
  //     op.buffer + a.buffer,
  //     op.start,
  //     a.stop,
  // ),
  // );

  builder.group().right(Tokens.power, OperatorExpr.fromToken(Operator.pow));

  builder.group()
    ..left(Tokens.mul, OperatorExpr.fromToken(Operator.mul))
    ..left(Tokens.div, OperatorExpr.fromToken(Operator.div))
    ..left(Tokens.mod, OperatorExpr.fromToken(Operator.mod));

  builder.group()
    ..left(Tokens.plus, OperatorExpr.fromToken(Operator.add))
    ..left(Tokens.minus, OperatorExpr.fromToken(Operator.sub));

  builder.group()
    ..left(Tokens.lte, OperatorExpr.fromToken(Operator.lte))
    ..left(Tokens.gte, OperatorExpr.fromToken(Operator.gte))
    ..left(Tokens.lt, OperatorExpr.fromToken(Operator.lt))
    ..left(Tokens.gt, OperatorExpr.fromToken(Operator.gt))
    ..left(Tokens.eq, OperatorExpr.fromToken(Operator.eq))
    ..left(Tokens.ne, OperatorExpr.fromToken(Operator.ne));

  builder.group().left(Tokens.and, OperatorExpr.fromToken(Operator.and));

  builder.group().left(Tokens.or, OperatorExpr.fromToken(Operator.or));

  // Function call
  // TODO: replace [char('@').not()] with a parser that never matches
  builder.group()
    ..right(char('@').not().flatten().token(), SequencialExpr.fromToken)
    ..postfix(
      [Tokens.openParen, Tokens.closeParen]
          .toSequenceParser()
          .flatten()
          .token(),
      (left, op) => Token(
        SequencialExpr(left.value, SequenceExpr([])),
        left.buffer + op.buffer,
        left.start,
        op.stop,
      ),
    );

  // Sequence
  builder.group().left(Tokens.comma, (left, op, right) {
    final expr = switch ((left.value, right.value)) {
      (
        SequenceExpr(exprs: final leftExprs),
        SequenceExpr(exprs: final rightExprs)
      ) =>
        SequenceExpr([...leftExprs, ...rightExprs]),
      (SequenceExpr(:final exprs), _) => SequenceExpr([...exprs, right.value]),
      (_, SequenceExpr(:final exprs)) => SequenceExpr([left.value, ...exprs]),
      _ => SequenceExpr([left.value, right.value]),
    };
    return Token(expr, left.buffer, left.start, right.stop);
  });

  // Function definition
  builder.group().right(
        Tokens.funCreate,
        OperatorExpr.fromToken(Operator.funCreate),
      );

  // Ternary
  builder.group().postfix(
    (Tokens.questionmark & expr & (Tokens.colon & expr).pick(1).optional())
        .token(),
    (left, post) {
      final tokenTrue = post.value[1] as Token<Expr>;
      final tokenFalse = post.value[2] as Token<Expr>?;
      return Token(
        TernaryExpr(left.value, tokenTrue.value, tokenFalse?.value),
        left.buffer + post.buffer,
        left.start,
        post.stop,
      );
    },
  );

  // Pipe
  builder.group()
    ..left(
      [Tokens.pipeWhere].toChoiceParser(),
      OperatorExpr.fromToken(Operator.pipeWhere),
    )
    ..left(
      [Tokens.pipe].toChoiceParser(),
      OperatorExpr.fromToken(Operator.pipe),
    );

  // Assignment
  final assignmentGroup = builder.group();
  for (final (token, operator) in [
    (Tokens.assign, Operator.assign),
    (Tokens.plusAssign, Operator.plusAssign),
    (Tokens.minusAssign, Operator.minusAssign),
    (Tokens.mulAssign, Operator.mulAssign),
    (Tokens.divAssign, Operator.divAssign),
  ]) {
    assignmentGroup.right(
      token,
      OperatorExpr.fromToken(operator),
    );
  }

  final _ = builder.build();

  return lines.end();
}

class Tokens {
  static final power1 = char('^').trimNoNewline();
  static final power2 = string('**').trimNoNewline();
  static final power = (power1 | power2).cast<String>();

  static final mul = char('*').trimNoNewline();
  static final div = char('/').trimNoNewline();
  static final mod = char('%').trimNoNewline();

  static final plus = char('+').trimNoNewline();
  static final minus = char('-').trimNoNewline();

  static final and = string('&&').trimNoNewline();
  static final or = string('||').trimNoNewline();

  static final eq = string('==').trimNoNewline();
  static final ne = string('!=').trimNoNewline();
  static final lt = char('<').trimNoNewline();
  static final gt = char('>').trimNoNewline();
  static final lte = string('<=').trimNoNewline();
  static final gte = string('>=').trimNoNewline();

  static final comma = char(',').trimNoNewline();

  static final assign = char('=').trimNoNewline();
  static final plusAssign = string('+=').trimNoNewline();
  static final minusAssign = string('-=').trimNoNewline();
  static final mulAssign = string('*=').trimNoNewline();
  static final divAssign = string('/=').trimNoNewline();

  static final pipe = char('|').trimNoNewline();
  static final pipeWhere = string('|?').trimNoNewline();

  static final openParen = char('(').trimNoNewline();
  static final closeParen = char(')').trimNoNewline();

  static final openBrace = char('{').trimNoNewline();
  static final closeBrace = char('}').trimNoNewline();

  static final openDoubleBrace = string('{{').trimNoNewline();
  static final closeDoubleBrace = string('}}').trimNoNewline();

  static final openTripleBrace = string('{{{').trimNoNewline();
  static final closeTripleBrace = string('}}}').trimNoNewline();

  static final openBracket = char('[').trimNoNewline();
  static final closeBracket = char(']').trimNoNewline();

  static final semicolon = char(';').trimNoNewline();
  static final colon = char(':').trimNoNewline();

  static final funCreate = string('=>').trimNoNewline();

  static final spread = string('...').trimNoNewline();

  static final exclaimark = char('!').trimNoNewline();
  static final questionmark = char('?').trimNoNewline();

  static final increment = string('++').trimNoNewline();
  static final decrement = string('--').trimNoNewline();

  static final dot = char('.').trimNoNewline();

  static final floatPrefix = string('0f').trimNoNewline();
}

extension MapTokenParser<T1> on Parser<Token<T1>> {
  Parser<Token<T2>> mapToken<T2>(T2 Function(Token<T1>) f) {
    return map(
      (token) => Token(f(token), token.buffer, token.start, token.stop),
    );
  }

  Parser<T1> value() => map((token) => token.value);
}

extension TrimParser<T> on Parser<T> {
  Parser<T> trimNoNewline() => trim(char(' '));
}
