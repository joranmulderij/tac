import 'package:tac/parser.dart';
import 'package:tac/state.dart';
import 'package:tac/utils/errors.dart';

int _runCount = 0;

String run(String input) {
  return runWithPrint(input).$2;
}

(String, String) runWithPrint(String input) {
  _runCount++;
  final printBuffer = StringBuffer();
  String getPrintBuffer() {
    if (printBuffer.isEmpty) return '';
    return printBuffer.toString().substring(0, printBuffer.length - 1);
  }

  final state = _MockState(onPrint: printBuffer.writeln);
  try {
    final ast = parse(input);
    final value = ast.run(state);
    return (getPrintBuffer(), value.toString());
  } on MyError catch (e) {
    return (getPrintBuffer(), e.toString());
  }
}

void printRunCount() {
  // ignore: avoid_print
  print('Number of runs: $_runCount');
}

class _MockState extends State {
  _MockState({required this.onPrint});

  void Function(String) onPrint;

  @override
  void print(String message) {
    onPrint(message);
  }

  @override
  void printWarning(String message) {
    onPrint('Warning: $message');
  }
}
