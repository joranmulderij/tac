import 'dart:io';

import 'package:tac_dart/ast/ast.dart';
import 'package:tac_dart/errors.dart';
import 'package:tac_dart/libraries/math.dart';
import 'package:tac_dart/libraries/rand.dart';
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
  'eval': _eval,
  'exit': _exit,
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

final _load = DartFunctionValue.from1Param(
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
          'rand' => ObjectValue(randLibrary),
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

Value _eval = DartFunctionValue.from1Param(
  (state, arg) {
    if (arg case StringValue(value: final input)) {
      final ast = parse(input);
      return ast.run(state);
    } else {
      throw IncorrectTypeError('string', arg.type);
    }
  },
  'value',
);

Value _exit = DartFunctionValue.from1Param(
  (state, arg) {
    if (arg case NumberValue(value: final code)) {
      if (code.isInteger) {
        exit(code.toInt());
      } else {
        throw IncorrectTypeError('int', arg.type);
      }
    } else {
      throw IncorrectTypeError('int', arg.type);
    }
  },
  'returnCode',
);
