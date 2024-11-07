import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:dart_console/dart_console.dart';
import 'package:termlib/termlib.dart';
import 'package:termunicode/termunicode.dart';

class MyConsole {
  MyConsole({required this.colorBackground}) {
    _console.rawMode = false;
    _termLib.setTerminalTitle('TAC Advanced Calculator');
    stdin.lineMode = false;
    stdin.echoMode = false;
  }

  final ScrollbackBuffer _scrollbackBuffer =
      ScrollbackBuffer(recordBlanks: false);
  final Console _console = Console();
  final TermLib _termLib = TermLib();
  final bool colorBackground;

  void write(String text, int col) {
    if (colorBackground) {
      writeColorBackground(text, col);
    } else {
      final trailingSpaces = _console.windowWidth - widthString(text) - col;
      if (trailingSpaces < 0) {
        throw Exception('Text too long to fit on screen');
      }
      stdout.write(text);
    }
  }

  void writeColorBackground(String text, int col) {
    final trailingSpaces = _console.windowWidth - widthString(text) - col;
    // print(widthString(text));
    if (trailingSpaces < 0) {
      throw Exception('Text too long to fit on screen');
    }
    final newText = text + ' ' * trailingSpaces;
    for (var i = 0; i < newText.length; i++) {
      const purpleRGB = (92, 12, 108);
      final offset = widthString(newText.substring(0, i)) + col;
      final t = offset / widthString(newText);
      final r = (purpleRGB.$1 * t).round();
      final g = (purpleRGB.$2 * t).round();
      final b = (purpleRGB.$3 * t).round();
      stdout.write('\x1B[48;2;$r;$g;${b}m${newText[i]}\x1B[0m');
    }
    _termLib.moveLeft(trailingSpaces - 1);
  }

  void writeNewLine() {
    stdout.writeln();
  }

  void writeLine(String text) {
    write(text, 0);
    stdout.writeln();
  }

  void clear() {
    _termLib.eraseClear();
  }

  String? readLine() {
    var buffer = '';
    var unicodeBuffer = '';
    var index = 0; // cursor position relative to buffer, not screen

    final screenRow = _console.cursorPosition!.row;
    final screenColOffset = _console.cursorPosition!.col;

    final bufferMaxLength = width - screenColOffset - 3;

    while (true) {
      final key = _console.readKey();

      if (key.isControl) {
        switch (key.controlChar) {
          case ControlCharacter.enter:
            _scrollbackBuffer.add(buffer);
            writeNewLine();
            return buffer;
          case ControlCharacter.ctrlC:
            return null;
          // case ControlCharacter.escape:
          case ControlCharacter.backspace:
          case ControlCharacter.ctrlH:
            if (index > 0) {
              buffer = buffer.substring(0, index - 1) + buffer.substring(index);
              index--;
            }
          case ControlCharacter.ctrlU:
            buffer = buffer.substring(index, buffer.length);
            index = 0;
          case ControlCharacter.delete:
          case ControlCharacter.ctrlD:
            if (index < buffer.length) {
              buffer = buffer.substring(0, index) + buffer.substring(index + 1);
            }
          case ControlCharacter.ctrlK:
            buffer = buffer.substring(0, index);
          case ControlCharacter.arrowLeft:
          case ControlCharacter.ctrlB:
            index = index > 0 ? index - 1 : index;
          case ControlCharacter.arrowUp:
            buffer = _scrollbackBuffer.up(buffer);
            index = buffer.length;
          case ControlCharacter.arrowDown:
            final temp = _scrollbackBuffer.down();
            if (temp != null) {
              buffer = temp;
              index = buffer.length;
            }
          case ControlCharacter.arrowRight:
          case ControlCharacter.ctrlF:
            index = index < buffer.length ? index + 1 : index;
          case ControlCharacter.wordLeft:
            if (index > 0) {
              final bufferLeftOfCursor = buffer.substring(0, index - 1);
              final lastSpace = bufferLeftOfCursor.lastIndexOf(' ');
              index = lastSpace != -1 ? lastSpace + 1 : 0;
            }
          case ControlCharacter.wordRight:
            if (index < buffer.length) {
              final bufferRightOfCursor = buffer.substring(index + 1);
              final nextSpace = bufferRightOfCursor.indexOf(' ');
              index = nextSpace != -1
                  ? math.min(index + nextSpace + 2, buffer.length)
                  : buffer.length;
            }
          case ControlCharacter.home:
          case ControlCharacter.ctrlA:
            index = 0;
          case ControlCharacter.end:
          case ControlCharacter.ctrlE:
            index = buffer.length;
          // ignore: no_default_cases
          default:
            break;
        }
      } else {
        if (buffer.length < bufferMaxLength) {
          try {
            final char = utf8.decode((unicodeBuffer + key.char).codeUnits);
            unicodeBuffer = '';
            if (index == widthString(buffer)) {
              buffer += char;
              index++;
            } else {
              buffer =
                  buffer.substring(0, index) + char + buffer.substring(index);
              index++;
            }
          } on FormatException {
            unicodeBuffer += key.char;
          }
        }
      }

      // print(utf8.decode(buffer.codeUnits));
      // buffer = String.(buffer);
      // print(buffer.codeUnits);

      _console.cursorPosition = Coordinate(screenRow, screenColOffset);
      _console.eraseCursorToEnd();
      write(buffer, screenColOffset); // allow for backspace condition
      final cursorOffset = widthString(buffer.substring(0, index));
      _console.cursorPosition =
          Coordinate(screenRow, screenColOffset + cursorOffset);
    }
  }

  int get width => _console.windowWidth;
}

abstract class ConsoleWriter {
  void write(String text, int col);
}

class GradientBackgroundConsoleWriter implements ConsoleWriter {
  @override
  void write(String text, int col) {}
}
