import 'dart:io' show stdout;

import 'package:tac/parser.dart';
import 'package:tac/state.dart';
import 'package:tac/utils/console.dart';
import 'package:tac/utils/errors.dart';

class TAC {
  TAC({required this.color}) : state = State(color: color);

  static const appVersion = '0.0.1';

  final bool color;
  final State state;

  void run(String input) {
    try {
      final ast = parse(input);
      final value = ast.run(state);
      stdout.writeln(
        '  ${Console.green('=', color)} ${value.toConsoleString(color)} ',
      );
    } on MyError catch (e) {
      stdout.writeln(Console.red(e.toString(), color));
    } catch (e, st) {
      stdout.writeln(Console.red('Unexpected error:', color));
      stdout.writeln(Console.red(e.toString(), color));
      stdout.writeln(Console.red(st.toString(), color));
    }
  }
}
