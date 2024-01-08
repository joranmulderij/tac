import 'package:hotreloader/hotreloader.dart';
import 'package:tac_dart/tac_dart.dart';

void main(List<String> args) async {
  try {
    final reloader = await HotReloader.create();
    // ignore: avoid_print
    print('HotReloader listening.');
    runRepl();
    await reloader.stop();
    // ignore: avoid_catching_errors
  } on StateError {
    runRepl();
  }
}
