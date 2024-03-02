import 'dart:io';

import 'package:tac/ast/ast.dart';
import 'package:tac/libraries/http.dart';
import 'package:tac/libraries/math.dart';
import 'package:tac/libraries/rand.dart';
import 'package:tac/parser.dart';
import 'package:tac/state.dart';
import 'package:tac/utils/errors.dart';
import 'package:tac/value/value.dart';

final coreLibrary = {
  'true': const BoolValue(true),
  'false': const BoolValue(false),
  'print': _print,
  'type': _type,
  'length': _length,
  'string': _string,
  'save': _save,
  'import': _import,
  'load': _load,
  'return': _return,
  'eval': _eval,
  'exit': _exit,
};

// Core functions

final _print = DartFunctionValue(
  (state, args) async {
    state.print(args.map((arg) => arg.toString()).join(' '));

    if (args.length == 1) {
      return args.first;
    }
    return SequenceValue(args);
  },
  ['...values'],
);

final _type = DartFunctionValue.from1Param(
  (state, arg) async => StringValue(arg.type),
  'value',
);

final _return = DartFunctionValue.from1Param(
  (state, arg) => throw ReturnException(arg),
  'value',
);

final _length = DartFunctionValue.from1Param(
  (state, arg) async {
    return switch (arg) {
      StringValue(:final value) => NumberValue.fromNum(value.length),
      ListValue(:final values) => NumberValue.fromNum(values.length),
      VectorValue(:final values) => NumberValue.fromNum(values.length),
      // Turns out you cannot check the length of a sequence like this because
      // the values get unpacked.
      // SequenceValue(:final values) => NumberValue.fromNum(values.length),
      _ => throw MyError.unexpectedType('list, string, or vector', arg.type),
    };
  },
  'value',
);

final _string = DartFunctionValue.from1Param(
  (state, arg) async {
    return StringValue(arg.toString());
  },
  'value',
);

final _save = DartFunctionValue.from2Params(
  (state, arg1, arg2) async {
    if (arg1 case StringValue(value: final path)) {
      final file = File(path);
      await file.writeAsString('return ${arg2.toExpr()}');
      return arg2;
    } else {
      throw MyError.unexpectedType('string', arg1.type);
    }
  },
  'path',
  'value',
);

final DartFunctionValue _import = DartFunctionValue.from1Param(
  (state, arg) async {
    final library = await _loadLibrary(state, arg);
    switch (library) {
      case ObjectValue(:final values):
        state.setAll(values);
        return library;
      default:
        throw MyError.unexpectedType('object', library.type);
    }
  },
  'path',
);

final _load = DartFunctionValue.from1Param(
  _loadLibrary,
  'path',
);

// Utils

Future<Value> _loadLibrary(State state, Value arg) async {
  if (arg case StringValue(value: final path)) {
    final library = switch (null) {
      _ when path.startsWith('tac:') => switch (path.substring(4)) {
          'core' => ObjectValue(coreLibrary),
          'math' => ObjectValue(mathLibrary),
          'rand' => ObjectValue(randLibrary),
          'http' => ObjectValue(httpLibrary),
          _ => throw MyError.unknownLibrary(path),
        },
      _ => await _loadLibraryFromPath(state, path),
    };
    return library;
  } else {
    throw MyError.unexpectedType('string', arg.type);
  }
}

Future<Value> _loadLibraryFromPath(State state, String path) async {
  try {
    final file = File(path);
    final contents = file.readAsStringSync();
    final lines = parse(contents);
    final block = BlockedBlockExpr(lines);
    return await block.run(state);
  } on PathNotFoundException {
    throw MyError.fileNotFound(path);
  }
}

Value _eval = DartFunctionValue.from1Param(
  (state, arg) {
    if (arg case StringValue(value: final input)) {
      final ast = parse(input);
      return ast.run(state);
    } else {
      throw MyError.unexpectedType('string', arg.type);
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
        throw MyError.notAnInteger();
      }
    } else {
      throw MyError.unexpectedType('number', arg.type);
    }
  },
  'returnCode',
);
