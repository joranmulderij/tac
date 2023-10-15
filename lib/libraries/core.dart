import 'package:tac_dart/errors.dart';
import 'package:tac_dart/libraries/library.dart';
import 'package:tac_dart/libraries/math.dart';
import 'package:tac_dart/value/value.dart';

final coreLibrary = Library({
  'true': const BoolValue(true),
  'false': const BoolValue(false),
  'print': _print,
  'type': _type,
  'import': _import,
  'load': _load,
});

final _print = DartFunctionValue.from1Param(
  (state, arg) {
    // ignore: avoid_print
    print(arg);
    return arg;
  },
  'value',
);

final _type = DartFunctionValue.from1Param(
  (state, arg) => StringValue(arg.type),
  'value',
);

final DartFunctionValue _import = DartFunctionValue.from1Param(
  (state, arg) {
    if (arg case StringValue(value: final path)) {
      if (path.startsWith('tac:')) {
        final _ = switch (path.substring(4)) {
          'core' => coreLibrary.load(state),
          'math' => mathLibrary.load(state),
          _ => throw UnimplementedError('Unknown tac: import: $path'),
        };
        return arg;
      } else {
        throw UnimplementedError('Only tac: imports are supported');
      }
    } else {
      throw IncorrectTypeError('string', arg.type);
    }
  },
  'path',
);

final DartFunctionValue _load = DartFunctionValue(
  (state, args) {
    final arg = args[0];
    if (arg case StringValue(value: final path)) {
      if (path.startsWith('tac:')) {
        final variables = switch (path.substring(4)) {
          'core' => coreLibrary.variables,
          'math' => mathLibrary.variables,
          _ => throw UnimplementedError('Unknown tac: import: $path'),
        };
        return ObjectValue(variables);
      } else {
        throw UnimplementedError('Only tac: imports are supported');
      }
    } else {
      throw IncorrectTypeError('string', arg.type);
    }
  },
  const ['path'],
);
