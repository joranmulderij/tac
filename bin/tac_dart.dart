import 'dart:io' show stdin, stdout;

import 'package:hotreloader/hotreloader.dart';
import 'package:tac_dart/tac_dart.dart';

void main(List<String> args) async {
  try {
    final reloader = await HotReloader.create();
    // ignore: avoid_print
    print('HotReloader listening.');
    await runRepl(reloader);
    print('HotReloader stopped.');
    await reloader.stop();
    // ignore: avoid_catching_errors
  } on StateError {
    await runRepl();
  }
}

final _redPen = AnsiPen()..red();
final _greenPen = AnsiPen()..green();

Future<void> runRepl([HotReloader? reloader]) async {
  final console = Console();
  final state = State();
  String? lastInput;
  while (true) {
    stdout.write('> ');
    var input = stdin.readLineSync();
    await reloader?.reloadCode();
    if (input == null) continue;
    if (input == 'exit') {
      break;
    }
    if (input.isEmpty && lastInput != null) {
      input = lastInput;
    }
    if (RegExp(r'^(\+|-|\*|\/|%|\^|==|!=|>|<|\|\|)').hasMatch(input)) {
      input = '_$input';
    }
    lastInput = input;
    try {
      final ast = parse(input);
      final value = ast.run(state);
      if (RegExp(r'^ *$').hasMatch(input) || RegExp(r'; *$').hasMatch(input)) {
        continue;
      }
      console.writeLine(
        _greenPen('  = ${value.toPrettyString()} '),
      );
    } on MyError catch (e) {
      console.writeLine(_redPen(e.toString()));
    }
  }
}