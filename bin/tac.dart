import 'dart:async';
import 'dart:io' show exit, stdout;

import 'package:args/args.dart';
import 'package:dart_console/dart_console.dart';
import 'package:hotreloader/hotreloader.dart';
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
    final tac = Tac(color: color, onPrint: stdout.writeln);
    final value = await tac.run(options['cmd'] as String);
    stdout.writeln(value.toConsoleString(color));
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
  final console = Console.scrolling(recordBlanks: false);

  console.writeLine('Copyright (c) 2024 Joran Mulderij');
  console.writeLine('TAC $appVersion');
  final tac = Tac(
    color: color,
    printAst: printAst,
    onPrint: console.writeLine,
  );
  // String? lastInput;
  while (true) {
    console.write('> ');
    final input = console.readLine(cancelOnBreak: true);
    if (input == null) exit(0);
    if (input.isEmpty) continue;
    await reloader?.reloadCode();
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
      final value = await tac.run(input);
      if (!input.trim().endsWith(';')) {
        tac.print(
          '  ${ConsoleColors.green('=', color)} ${value.toConsoleString(color)} ',
        );
      }
    } on MyError catch (e) {
      stdout.writeln(ConsoleColors.red(e.toString(), color));
    } catch (e, st) {
      stdout.writeln(ConsoleColors.red('Unexpected error:', color));
      stdout.writeln(ConsoleColors.red(e.toString(), color));
      stdout.writeln(ConsoleColors.red(st.toString(), color));
    }
  }
}
