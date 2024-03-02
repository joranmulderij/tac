import 'dart:async';
import 'dart:io' show stdin, stdout;

import 'package:args/args.dart';
import 'package:hotreloader/hotreloader.dart';
import 'package:tac/state.dart';
import 'package:tac/tac.dart';
import 'package:tac/utils/console.dart';
import 'package:tac/utils/errors.dart';

void main(List<String> args) async {
  final argsParser = getArgsParser();
  final options = argsParser.parse(args);
  final color = options['color'] == true;
  final printAst = options['print-ast'] == true;
  if (options['help'] == true) {
    stdout.writeln(argsParser.usage);
    return;
  } else if (options['cmd'] != null) {
    final tac = State(color: color, onPrint: stdout.writeln);
    await tac.run(options['cmd'] as String);
  } else if (options.command?.name == 'version') {
    stdout.writeln(appVersion);
  } else if (options['hot-reload'] == true) {
    final reloader = await HotReloader.create();
    stdout.writeln('HotReloader listening.');
    await runRepl(color: color, printAst: printAst, reloader: reloader);
    await reloader.stop();
    stdout.writeln('HotReloader stopped.');
  } else {
    await runRepl(color: color, printAst: printAst);
  }
}

ArgParser getArgsParser() {
  final argsParser = ArgParser();

  argsParser.addCommand('version');

  argsParser.addOption(
    'cmd',
    abbr: 'c',
    help: 'Run code passed as a string',
    valueHelp: 'code',
  );
  argsParser.addFlag(
    'color',
    help: 'Enable color output',
    defaultsTo: true,
  );
  argsParser.addFlag(
    'print-ast',
    help: 'Print the AST of the code before running it',
  );
  argsParser.addFlag(
    'help',
    abbr: 'h',
    help: 'Print this help message',
    negatable: false,
  );
  argsParser.addFlag('hot-reload', hide: true);

  return argsParser;
}

Future<void> runRepl({
  required bool color,
  required bool printAst,
  HotReloader? reloader,
}) async {
  stdout.writeln('Copyright (c) 2024 Joran Mulderij');
  stdout.writeln('TAC  v$appVersion');
  final state = State(
    color: color,
    printAst: printAst,
    onPrint: stdout.writeln,
  );
  // String? lastInput;
  while (true) {
    stdout.write('> ');
    final input = stdin.readLineSync();
    await reloader?.reloadCode();
    if (input == null || input.isEmpty) continue;
    if (RegExp(r'^ *$').hasMatch(input) || RegExp(r'^ *; *$').hasMatch(input)) {
      continue;
    }
    if (input.trim() == 'exit') {
      break;
    }
    // if (input.isEmpty && lastInput != null) {
    //   input = lastInput;
    // }
    // final regex = RegExp(r'^(\+|-|\*|\/|%|\^|==|!=|\|\|)');
    // if (regex.hasMatch(input) && lastInput != null) {
    //   input = '_$input';
    // }
    // lastInput = input;
    try {
      final value = await state.run(input);
      state.print(
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
