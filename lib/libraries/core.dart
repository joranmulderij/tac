import 'dart:io';

import 'package:tac_dart/ast/ast.dart';
import 'package:tac_dart/errors.dart';
import 'package:tac_dart/libraries/math.dart';
import 'package:tac_dart/parser.dart';
import 'package:tac_dart/state.dart';
import 'package:tac_dart/value/value.dart';

final coreLibrary = {
  'true': const BoolValue(true),
  'false': const BoolValue(false),
  'print': _print,
  'type': _type,
  'import': _import,
  'load': _load,
  'return': _return,
};

// Core functions

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

final _return = DartFunctionValue.from1Param(
  (state, arg) => throw ReturnException(arg),
  'value',
);

final DartFunctionValue _import = DartFunctionValue.from1Param(
  (state, arg) {
    final library = _loadLibrary(state, arg);
    switch (library) {
      case ObjectValue(:final values):
        state.loadLibrary(values);
        return library;
      case Value():
        throw IncorrectTypeError('object', library.type);
    }
  },
  'path',
);

final DartFunctionValue _load = DartFunctionValue.from1Param(
  _loadLibrary,
  'path',
);

// Utils

Value _loadLibrary(State state, Value arg) {
  if (arg case StringValue(value: final path)) {
    final library = switch (null) {
      _ when path.startsWith('tac:') => switch (path.substring(4)) {
          'core' => ObjectValue(coreLibrary),
          'math' => ObjectValue(mathLibrary),
          _ => throw UnimplementedError('Unknown "tac:" import: $path'),
        },
      _ => _loadLibraryFromPath(state, path),
    };
    return library;
  } else {
    throw IncorrectTypeError('string', arg.type);
  }
}

Value _loadLibraryFromPath(State state, String path) {
  try {
    final file = File(path);
    final contents = file.readAsStringSync();
    final lines = parse(contents);
    final block = BlockedBlockExpr(lines);
    return block.run(state);
  } on PathNotFoundException {
    throw PathNotFoundError(path);
  }
}
