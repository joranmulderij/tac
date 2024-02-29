import 'dart:io' show stdout;

import 'package:hotreloader/hotreloader.dart';

import 'tac.dart';

void main(List<String> args) async {
  try {
    final reloader = await HotReloader.create();
    stdout.writeln('HotReloader listening.');
    await runRepl(reloader);
    stdout.writeln('HotReloader stopped.');
    await reloader.stop();
    // ignore: avoid_catching_errors
  } on StateError {
    await runRepl();
  }
}
