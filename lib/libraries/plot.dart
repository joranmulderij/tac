import 'package:ansicolor/ansicolor.dart';
import 'package:dart_console/dart_console.dart';
import 'package:tac_dart/errors.dart';
import 'package:tac_dart/number/number.dart';
import 'package:tac_dart/units.dart';
import 'package:tac_dart/value/value.dart';

final _bluePen = AnsiPen()..blue();

final plotLibrary = {
  'plot': _splot,
};

// - Create matrix of bool values
// - For each x value, evaluate the function
// - For each y value, if the function value is equal to the y value, set the
//   bool value to true
// - Convert the matrix to a list of braille characters
// - Print the list of braille characters
final DartFunctionValue _splot = DartFunctionValue.from1Param(
  (state, arg) {
    final console = Console();
    final boxGlyphSet = BoxGlyphSet.rounded();
    final plotWidth = console.windowWidth * 2 - 2;
    final width = console.windowWidth - 1;
    final height = (console.windowWidth ~/ 4) * 5;
    const min = -10.0;
    const max = 10.0;
    final step = (max - min) / plotWidth;
    final values = <num>[];
    for (var x = min; x < max; x += step) {
      final value = arg.call(
        state,
        [NumberValue(FloatNumber(x), UnitSet.empty)],
      );
      final number = switch (value) {
        NumberValue(:final value) => value,
        _ => throw MyError.unexpectedType('number', value.type),
      };
      values.add(number.toNum());
    }
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final rangeValue = maxValue - minValue;
    final normalizedValues = values
        .map((e) => (maxValue - e) / rangeValue * (height - 1))
        .map((e) => e.floor());
    final matrix = List<List<bool>>.generate(
      height,
      (_) => List.generate(plotWidth, (_) => false),
    );
    int? lastY;
    for (var x = 0; x < plotWidth; x++) {
      final y = normalizedValues.elementAt(x);
      if (lastY == null || y == lastY) {
        matrix[y][x] = true;
      } else {
        final (
          lowerY,
          upperY,
          lowerXOffset,
          upperXOffset,
        ) = switch (y > lastY) {
          true => (lastY, y, -1, 0),
          false => (y, lastY, 0, -1),
        };
        final middleY = (lowerY + upperY) ~/ 2;
        for (var i = lowerY; i <= middleY; i++) {
          matrix[i][x + lowerXOffset] = true;
        }
        for (var i = middleY; i <= upperY; i++) {
          matrix[i][x + upperXOffset] = true;
        }
      }
      lastY = y;
    }
    for (var y = 0; y < height; y += 5) {
      final buffer = StringBuffer();
      for (var x = 0; x < plotWidth; x += 2) {
        final braille1 = matrix[y][x] ? 1 : 0;
        final braille2 = matrix[y + 1][x] ? 1 : 0;
        final braille3 = matrix[y + 2][x] ? 1 : 0;
        final braille4 = matrix[y][x + 1] ? 1 : 0;
        final braille5 = matrix[y + 1][x + 1] ? 1 : 0;
        final braille6 = matrix[y + 2][x + 1] ? 1 : 0;
        final braille7 = matrix[y + 3][x] ? 1 : 0;
        final braille8 = matrix[y + 3][x + 1] ? 1 : 0;
        final brailleChar = 0x2800 |
            braille1 |
            braille2 * 2 |
            braille3 * 4 |
            braille4 * 8 |
            braille5 * 16 |
            braille6 * 32 |
            braille7 * 64 |
            braille8 * 128;
        buffer.write(String.fromCharCode(brailleChar));
      }
      console.writeLine(_bluePen(buffer.toString()));
    }
    var bottomBar = boxGlyphSet.horizontalLine * width;
    var numberBar = ' ' * width;
    const numberOfTicks = 6;
    for (var i = 0; i < numberOfTicks; i++) {
      final x = (width / numberOfTicks * i).round();
      bottomBar = bottomBar.replaceRange(x, x + 1, boxGlyphSet.cross);
      final numberString =
          (min + (max - min) / numberOfTicks * i).toStringAsPrecision(2);
      numberBar =
          numberBar.replaceRange(x, x + numberString.length, numberString);
    }
    console.writeLine(bottomBar);
    console.writeLine(numberBar);
    return arg;
  },
  'function',
);
