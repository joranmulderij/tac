import 'dart:async';
import 'dart:io' show stdin, stdout;

import 'package:args/args.dart';
import 'package:hotreloader/hotreloader.dart';
import 'package:tac/tac.dart';

void main(List<String> args) async {
  final argsParser = getArgsParser();
  final options = argsParser.parse(args);
  if (options['help'] == true) {
    stdout.writeln(argsParser.usage);
    return;
  } else if (options['cmd'] != null) {
    final tac = TAC();
    tac.run(options['cmd'] as String);
  } else if (options.command?.name == 'version') {
    stdout.writeln(TAC.appVersion);
  } else if (options['hot-reload'] == true) {
    final reloader = await HotReloader.create();
    stdout.writeln('HotReloader listening.');
    await runRepl(reloader: reloader);
    await reloader.stop();
    stdout.writeln('HotReloader stopped.');
  } else {
    await runRepl();
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
    'help',
    abbr: 'h',
    help: 'Print this help message',
    negatable: false,
  );
  argsParser.addFlag('hot-reload', hide: true);

  return argsParser;
}

Future<void> runRepl({HotReloader? reloader}) async {
  stdout.writeln('Copyright (c) 2024 Joran Mulderij');
  stdout.writeln('TAC  v${TAC.appVersion}');
  final tac = TAC();
  String? lastInput;
  while (true) {
    stdout.write('> ');
    var input = stdin.readLineSync();
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
    final regex = RegExp(r'^(\+|-|\*|\/|%|\^|==|!=|\|\|)');
    if (regex.hasMatch(input) && lastInput != null) {
      input = '_$input';
    }
    lastInput = input;
    tac.run(input);
  }
}
