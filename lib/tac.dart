import 'dart:io' show stdout;

import 'package:tac/parser.dart';
import 'package:tac/state.dart';
import 'package:tac/utils/console.dart';
import 'package:tac/utils/errors.dart';

class TAC {
  static const appVersion = '0.0.1';

  final state = State();

  void run(String input) {
    try {
      final ast = parse(input);
      final value = ast.run(state);
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
