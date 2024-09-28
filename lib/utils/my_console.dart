import 'dart:io';
import 'dart:math' as math;

import 'package:dart_console/dart_console.dart';
// ignore: implementation_imports
import 'package:dart_console/src/ansi.dart';
import 'package:tac/utils/tab_mappings.dart';
import 'package:termlib/termlib.dart';

class MyConsole {
  MyConsole() {
    termLib.setTerminalTitle('TAC Advanced Calculator');
  }

  final Console console = Console();
  final TermLib termLib = TermLib();
  final ScrollbackBuffer _scrollbackBuffer =
      ScrollbackBuffer(recordBlanks: false);

  void writeCentered(String text) {
    final padding = ' ' * ((console.windowWidth - text.displayWidth) ~/ 2);
    console.write('$padding$text\n');
  }

  Coordinate? get cursorPosition {
    console.rawMode = true;
    stdout.write(ansiDeviceStatusReportCursorPosition);
    // returns a Cursor Position Report result in the form <ESC>[24;80R
    // which we have to parse apart, unfortunately
    var result = '';
    var i = 0;

    // avoid infinite loop if we're getting a bad result
    while (i < 16) {
      final readByte = stdin.readByteSync();

      if (readByte == -1) break; // headless console may not report back

      // ignore: use_string_buffers
      result += String.fromCharCode(readByte);
      if (result.endsWith('R')) break;
      i++;
    }
    console.rawMode = false;

    if (result.isEmpty) {
      return null;
    }

    if (result.contains('\x1b')) {
      result = result.substring(result.indexOf('\x1b'));
    }

    result = result.substring(2, result.length - 1);
    final coords = result.split(';');

    if (coords.length != 2) {
      return null;
    }
    if ((int.tryParse(coords[0]) != null) &&
        (int.tryParse(coords[1]) != null)) {
      return Coordinate(int.parse(coords[0]) - 1, int.parse(coords[1]) - 1);
    } else {
      print(' coords[0]: ${coords[0]}   coords[1]: ${coords[1]}');
      return null;
    }
  }

  String? readLine({
    bool cancelOnBreak = false,
    bool cancelOnEscape = false,
    bool cancelOnEOF = false,
    void Function(String text, Key lastPressed)? callback,
  }) {
    var buffer = '';
    var index = 0; // cursor position relative to buffer, not screen

    final screenRow = cursorPosition!.row;
    final screenColOffset = cursorPosition!.col;

    final bufferMaxLength = console.windowWidth - screenColOffset - 3;

    while (true) {
      final key = console.readKey();

      if (key.isControl) {
        switch (key.controlChar) {
          case ControlCharacter.enter:
            _scrollbackBuffer.add(buffer);
            console.writeLine();
            return buffer;
          case ControlCharacter.ctrlC:
            if (cancelOnBreak) return null;
          case ControlCharacter.escape:
            if (cancelOnEscape) return null;
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
            } else if (cancelOnEOF) {
              return null;
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
          case ControlCharacter.tab:
            for (final entry in tabMappings) {
              if (buffer.endsWith(entry.$1)) {
                buffer = buffer.substring(0, buffer.length - entry.$1.length);
                buffer += entry.$2;
                index += entry.$2.length - entry.$1.length;
                break;
              }
            }
          // ignore: no_default_cases
          default:
            break;
        }
      } else {
        if (buffer.length < bufferMaxLength) {
          if (index == buffer.length) {
            buffer += key.char;
            index++;
          } else {
            buffer =
                buffer.substring(0, index) + key.char + buffer.substring(index);
            index++;
          }
        }
      }

      console.cursorPosition = Coordinate(screenRow, screenColOffset);
      console.eraseCursorToEnd();
      console.write(buffer); // allow for backspace condition
      console.cursorPosition = Coordinate(screenRow, screenColOffset + index);

      if (callback != null) callback(buffer, key);
    }
  }

  void write(String text) {
    console.write(text);
  }

  void writeLine([String text = '']) {
    console.writeLine(text);
  }

  void clear() {
    console.clearScreen();
  }
}
