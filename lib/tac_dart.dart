// ignore_for_file: avoid_print

import 'dart:io' show stdin, stdout;

import 'package:ansicolor/ansicolor.dart';
import 'package:tac_dart/errors.dart';
import 'package:tac_dart/libraries/core.dart';
import 'package:tac_dart/libraries/math.dart';
import 'package:tac_dart/parser.dart';
import 'package:tac_dart/state.dart';

final _redPen = AnsiPen()..red();
final _greenPen = AnsiPen()..green();

void runRepl() {
  final state = State();
  state.pushScope();
  state.loadLibrary(coreLibrary);
  state.loadLibrary(mathLibrary);
  while (true) {
    stdout.write('> ');
    final input = stdin.readLineSync();
    if (input == null) continue;
    try {
      final block = parse(input);
      final value = block.run(state);
      print(_greenPen(' = ${value.toPrettyString()}'));
    } on MyError catch (e) {
      print(_redPen(e.toPrettyString()));
    }
  }
}
