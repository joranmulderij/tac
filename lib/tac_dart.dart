import 'dart:io' show stdin, stdout;

import 'package:ansicolor/ansicolor.dart';
import 'package:dart_console/dart_console.dart';
import 'package:tac_dart/parser.dart';
import 'package:tac_dart/state.dart';

import 'errors.dart';

final _redPen = AnsiPen()..red();
final _greenPen = AnsiPen()..green();

void runRepl() {
  final console = Console();
  final state = State();
  String? lastInput;
  while (true) {
    stdout.write('> ');
    var input = stdin.readLineSync();
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
      console.writeLine();
      console.writeLine(
        _greenPen('  = ${value.toPrettyString()} '),
        TextAlignment.right,
      );
      console.writeLine();
    } on MyError catch (e) {
      console.writeLine(_redPen(e.toPrettyString()));
    }
  }
}
