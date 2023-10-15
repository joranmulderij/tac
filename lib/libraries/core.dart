import 'package:tac_dart/libraries/library.dart';
import 'package:tac_dart/state.dart';
import 'package:tac_dart/value/value.dart';

final coreLibrary = CoreLibrary();

class CoreLibrary extends Library {
  @override
  void load(State state) {
    state.set('true', const BoolValue(true));
    state.set('false', const BoolValue(false));
    state.set('print', _print);
  }
}

final _print = DartFunctionValue(
  (args) {
    if (args.length != 1) {
      throw Exception('print() takes exactly one argument');
    }
    // ignore: avoid_print
    print(args[0]);
    return args[0];
  },
  const ['value'],
);
