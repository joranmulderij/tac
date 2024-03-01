import 'package:tac/state.dart';
import 'package:tac/utils/errors.dart';

int _runCount = 0;

Future<String> run(String input) async {
  return (await runWithPrint(input)).$2;
}

Future<(String, String)> runWithPrint(String input) async {
  _runCount++;
  final printBuffer = StringBuffer();
  String getPrintBuffer() {
    if (printBuffer.isEmpty) return '';
    return printBuffer.toString().substring(0, printBuffer.length - 1);
  }

  final state = State(onPrint: printBuffer.writeln, color: false);
  try {
    final value = await state.run(input);
    return (getPrintBuffer(), value.toConsoleString(false));
  } on MyError catch (e) {
    return (getPrintBuffer(), e.toString());
  }
}

void printRunCount() {
  // ignore: avoid_print
  print('Number of runs: $_runCount');
}
