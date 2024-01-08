import 'package:tac_dart/errors.dart';
import 'package:tac_dart/parser.dart';
import 'package:tac_dart/state.dart';

String run(String input) {
  final state = State();
  final ast = parse(input);
  try {
    final value = ast.run(state);
    return value.toPrettyString();
  } on MyError catch (e) {
    return e.toPrettyString();
  }
}
