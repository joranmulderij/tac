import 'package:tac/parser.dart';
import 'package:tac/state.dart';
import 'package:tac/utils/errors.dart';
import 'package:test/test.dart';

int _runCount = 0;

Future<String> run(String input) async {
  return (await runWithPrint(input)).$2;
}

Future<(String, String)> runWithPrint(String input) async {
  final printBuffer = StringBuffer();
  String getPrintBuffer() {
    if (printBuffer.isEmpty) return '';
    return printBuffer.toString().substring(0, printBuffer.length - 1);
  }

  final state = State(onPrint: printBuffer.writeln);
  try {
    final ast = parse(input);
    final value = await ast.run(state);
    _runCount++;
    try {
      final state2 = State(onPrint: (_) {});
      final ast2 = parse(ast.toExpr());
      final value2 = await ast2.run(state2);
      _runCount++;
      expect(value.toConsoleString(false), value2.toConsoleString(false));
    } catch (e) {
      rethrow;
    }
    return (getPrintBuffer(), value.toConsoleString(false));
  } on MyError catch (e) {
    return (getPrintBuffer(), e.toString());
  }
}

void printRunCount() {
  // ignore: avoid_print
  print('Number of runs: $_runCount');
}
