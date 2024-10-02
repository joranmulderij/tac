import 'dart:async';
import 'dart:io' show exit, stdout;

import 'package:args/args.dart';
import 'package:hotreloader/hotreloader.dart';
import 'package:tac/libraries/libraries.dart';
import 'package:tac/tac.dart';
import 'package:tac/utils/console_colors.dart';
import 'package:tac/utils/errors.dart';
import 'package:tac/utils/my_console.dart';

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
  final console = MyConsole();

  console.printLogo(console);
  console.writeLine('TAC Advaned Calculator $appVersion');
  console.writeLine('Copyright (c) 2024 Joran Mulderij');
  console.writeLine('Type .help for help');

  final tac = Tac(
    color: color,
    printAst: printAst,
    onPrint: console.writeLine,
  );
  // String? lastInput;
  while (true) {
    console.write('> ', 0);
    final input = console.readLine(cancelOnBreak: true);
    if (input == null) exit(0);

    if (input.isEmpty) continue;
    await reloader?.reloadCode();
    if (RegExp(r'^ *$').hasMatch(input) || RegExp(r'^ *; *$').hasMatch(input)) {
      continue;
    }
    if (input.trim() == '.exit') {
      exit(0);
    } else if (input.trim() == '.clear') {
      console.clear();
      continue;
    } else if (input.trim() == '.help') {
      console.writeLine('  .exit      - Exit the program');
      console.writeLine('  .clear     - Clear the screen');
      console.writeLine('  .help core - Show help for core functions');
      console.writeLine('  .help math - Show help for math functions');
      console.writeLine('  .help plot - Show help for plot functions');
      continue;
    } else if (input.trim().startsWith('.help')) {
      final match = RegExp(r' *\.help +(\w+) *').firstMatch(input);
      if (match != null) {
        final name = match.group(1);
        if (Library.builtin.containsKey(name)) {
          final library = Library.builtin[name]!;
          console.writeLine(library.helpText);
        } else {
          console.writeLine('Unknown library: $name');
        }
      }
      continue;
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
        console.writeLine(
          '  ${ConsoleColors.green('=', false)} ${value.toConsoleString(false)} ',
        );
      }
    } on MyError catch (e) {
      console.writeLine(e.toString());
    } catch (e, st) {
      console.writeLine('Unexpected error:');
      console.writeLine(e.toString());
      console.writeLine(st.toString());
    }
  }
}
