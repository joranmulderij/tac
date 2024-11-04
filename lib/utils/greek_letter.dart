import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';

/// Returns a parser that accepts any greek letter character (lowercase or uppercase).
/// The accepted input is equivalent to the character-set `a-zA-Z`.
@useResult
Parser<String> greekLetter([String message = 'greek letter expected']) =>
    SingleCharacterParser(const LetterCharPredicate(), message);

class LetterCharPredicate extends CharacterPredicate {
  const LetterCharPredicate();

  @override
  bool test(int value) =>
      (0x03B1 <= value && value <= 0x03C9) ||
      (0x0391 <= value && value <= 0x03A9);

  @override
  bool isEqualTo(CharacterPredicate other) => other is LetterCharPredicate;
}
