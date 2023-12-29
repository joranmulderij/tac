import 'package:hotreloader/hotreloader.dart';
import 'package:tac_dart/tac_dart.dart';

void main(List<String> args) async {
  final reloader = await HotReloader.create();
  await runRepl();
  await reloader.stop();
}
