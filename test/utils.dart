import 'package:tac_dart/parser.dart';
import 'package:tac_dart/state.dart';
import 'package:tac_dart/utils/errors.dart';

int _runCount = 0;

String run(String input) {
  _runCount++;
  final state = State();
  try {
    final ast = parse(input);
    final value = ast.run(state);
    return value.toPrettyString();
  } on MyError catch (e) {
    return e.toString();
  }
}

void printRunCount() {
  // ignore: avoid_print
  print('Number of runs: $_runCount');
}
