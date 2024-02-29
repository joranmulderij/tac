import 'dart:io' show stdin, stdout;

import 'package:hotreloader/hotreloader.dart';
import 'package:tac/tac.dart';
import 'package:tac/utils/console.dart';
import 'package:tac/utils/constants.dart';

void main(List<String> args) {
  runRepl();
}

Future<void> runRepl([HotReloader? reloader]) async {
  stdout.writeln('TAC (TAC Advanced Calculator) $appVersion');
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
    // if (input.isEmpty && lastInput != null) {
    //   input = lastInput;
    // }
    final regex = RegExp(r'^(\+|-|\*|\/|%|\^|==|!=|\|\|)');
    if (regex.hasMatch(input) && lastInput != null) {
      input = '_$input';
    }
    lastInput = input;
    try {
      final ast = parse(input);
      final value = ast.run(state);
      if (RegExp(r'^ *$').hasMatch(input) || RegExp(r'; *$').hasMatch(input)) {
        continue;
      }
      stdout.writeln(
        ConsoleUtils.green('  = $value '),
      );
    } on MyError catch (e) {
      stdout.writeln(ConsoleUtils.red(e.toString()));
    } catch (e, st) {
      stdout.writeln(ConsoleUtils.red('Unexpected error:'));
      stdout.writeln(ConsoleUtils.red(e.toString()));
      stdout.writeln(ConsoleUtils.red(st.toString()));
    }
  }
}
