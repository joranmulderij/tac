import 'package:tac_dart/parser.dart';
import 'package:tac_dart/state.dart';

String run(String input) {
  final state = State();
  final ast = parse(input);
  final value = ast.run(state);
  return value.toPrettyString();
}
