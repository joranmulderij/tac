import 'dart:io';
import 'dart:math' as math;

import 'package:dart_console/dart_console.dart';
// ignore: implementation_imports
import 'package:dart_console/src/ansi.dart';
import 'package:tac/utils/tab_mappings.dart';
import 'package:termlib/termlib.dart';

class MyConsole {
  MyConsole() {
    _termLib.setTerminalTitle('TAC Advanced Calculator');
    _console.rawMode = false;
  }

  final Console _console = Console();
  final TermLib _termLib = TermLib();
  final List<ReplEntry> _replEntries = [];
  int _activeReplEntryIndex = -1; // Increments to 0 on first readLine
  ReplEntry get _activeReplEntry => _replEntries[_activeReplEntryIndex];

  String get _currentReadingBuffer => _replEntries[_activeReplEntryIndex].input;
  set _currentReadingBuffer(String value) =>
      _replEntries[_activeReplEntryIndex].input = value;

  Coordinate? get cursorPosition {
    stdout.write(ansiDeviceStatusReportCursorPosition);
    // returns a Cursor Position Report result in the form <ESC>[24;80R
    // which we have to parse apart, unfortunately
    var result = '';
    var i = 0;

    // avoid infinite loop if we're getting a bad result
    while (i < 32) {
      final readByte = stdin.readByteSync();

      if (readByte == -1) break; // headless console may not report back

      // ignore: use_string_buffers
      result += String.fromCharCode(readByte);
      if (result.endsWith('R')) break;
      i++;
    }

    if (result.isEmpty) {
      return null;
    }

    if (result.contains('\x1b')) {
      result = result.substring(result.indexOf('\x1b'));
    } else {
      throw Exception();
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
    _activeReplEntryIndex++;
    _replEntries.add(ReplEntry(''));
    var index = 0; // cursor position relative to buffer, not screen

    final screenRow = cursorPosition!.row;
    final screenColOffset = cursorPosition!.col;

    final bufferMaxLength = _console.windowWidth - screenColOffset - 3;

    while (true) {
      final key = _console.readKey();

      if (key.isControl) {
        switch (key.controlChar) {
          case ControlCharacter.enter:
            _console.writeLine();
            return _currentReadingBuffer;
          case ControlCharacter.ctrlC:
            if (cancelOnBreak) return null;
          case ControlCharacter.escape:
            if (cancelOnEscape) return null;
          case ControlCharacter.backspace:
          case ControlCharacter.ctrlH:
            if (index > 0) {
              _currentReadingBuffer =
                  _currentReadingBuffer.substring(0, index - 1) +
                      _currentReadingBuffer.substring(index);
              index--;
            }
          case ControlCharacter.ctrlU:
            _currentReadingBuffer = _currentReadingBuffer.substring(
              index,
              _currentReadingBuffer.length,
            );
            index = 0;
          case ControlCharacter.delete:
          case ControlCharacter.ctrlD:
            if (index < _currentReadingBuffer.length) {
              _currentReadingBuffer =
                  _currentReadingBuffer.substring(0, index) +
                      _currentReadingBuffer.substring(index + 1);
            } else if (cancelOnEOF) {
              return null;
            }
          case ControlCharacter.ctrlK:
            _currentReadingBuffer = _currentReadingBuffer.substring(0, index);
          case ControlCharacter.arrowLeft:
          case ControlCharacter.ctrlB:
            index = index > 0 ? index - 1 : index;
          // case ControlCharacter.arrowUp:
          //   _activeReplEntryIndex--;
          //   if (_activeReplEntryIndex < 0) {
          //     _activeReplEntryIndex = 0;
          //     continue;
          //   }
          //   screenRow -= _activeReplEntry.lines;
          //   _termLib.moveUp(_activeReplEntry.lines);
          // case ControlCharacter.arrowDown:
          //   _console.write(_activeReplEntry.lines);
          case ControlCharacter.arrowRight:
          case ControlCharacter.ctrlF:
            index = index < _currentReadingBuffer.length ? index + 1 : index;
          case ControlCharacter.wordLeft:
            if (index > 0) {
              final bufferLeftOfCursor =
                  _currentReadingBuffer.substring(0, index - 1);
              final lastSpace = bufferLeftOfCursor.lastIndexOf(' ');
              index = lastSpace != -1 ? lastSpace + 1 : 0;
            }
          case ControlCharacter.wordRight:
            if (index < _currentReadingBuffer.length) {
              final bufferRightOfCursor =
                  _currentReadingBuffer.substring(index + 1);
              final nextSpace = bufferRightOfCursor.indexOf(' ');
              index = nextSpace != -1
                  ? math.min(
                      index + nextSpace + 2,
                      _currentReadingBuffer.length,
                    )
                  : _currentReadingBuffer.length;
            }
          case ControlCharacter.home:
          case ControlCharacter.ctrlA:
            index = 0;
          case ControlCharacter.end:
          case ControlCharacter.ctrlE:
            index = _currentReadingBuffer.length;
          case ControlCharacter.tab:
            for (final entry in tabMappings) {
              if (_currentReadingBuffer.endsWith(entry.$1)) {
                _currentReadingBuffer = _currentReadingBuffer.substring(
                  0,
                  _currentReadingBuffer.length - entry.$1.length,
                );
                _currentReadingBuffer += entry.$2;
                index += entry.$2.length - entry.$1.length;
                break;
              }
            }
          // ignore: no_default_cases
          default:
            break;
        }
      } else {
        if (_currentReadingBuffer.length < bufferMaxLength) {
          if (index == _currentReadingBuffer.length) {
            _currentReadingBuffer += key.char;
            index++;
          } else {
            _currentReadingBuffer = _currentReadingBuffer.substring(0, index) +
                key.char +
                _currentReadingBuffer.substring(index);
            index++;
          }
        }
      }

      _console.cursorPosition = Coordinate(screenRow, screenColOffset);
      _console.eraseCursorToEnd();
      _console.write(_currentReadingBuffer); // allow for backspace condition
      _console.cursorPosition = Coordinate(screenRow, screenColOffset + index);

      if (callback != null) callback(_currentReadingBuffer, key);
    }
  }

  void write(String text) {
    _console.write(text);
  }

  void writeLine([String text = '']) {
    _console.writeLine(text);
    _replEntries[_activeReplEntryIndex].lines++;
  }

  void clear() {
    // TODO
    // _replEntries.clear();
    // _replEntries.add(ReplEntry('', []));
  }
}

class ReplEntry {
  ReplEntry(this.input);

  String input;
  int lines = 1;
}

// abstract class Renderable {
//   int numberOfLines(int width);

//   List<String> lines(int width);
// }

// class RenderableString implements Renderable {
//   RenderableString(this.text);

//   final String text;

//   @override
//   int numberOfLines(int width) {
//     return text.split('\n').fold<int>(0, (prev, line) {
//       return prev + (line.length / width).ceil();
//     });
//   }

//   @override
//   List<String> lines(int width) {
//     // TODO: handle long lines
//     return text.split('\n').where((line) => line.isNotEmpty).toList();
//   }
// }
