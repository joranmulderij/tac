// ignore_for_file: avoid_positional_boolean_parameters

import 'package:ansicolor/ansicolor.dart';

class Console {
  static final _red = AnsiPen()..red();
  static final _green = AnsiPen()..green();
  static final _orange = AnsiPen()..rgb(r: 1, g: 0.5, b: 0);
  static final _gray = AnsiPen()..gray(level: 0.5);
  static final _purple = AnsiPen()..magenta();
  static final _blue = AnsiPen()..blue();

  static String red(String s, bool color) => color ? _red(s) : s;
  static String green(String s, bool color) => color ? _green(s) : s;
  static String orange(String s, bool color) => color ? _orange(s) : s;
  static String gray(String s, bool color) => color ? _gray(s) : s;
  static String purple(String s, bool color) => color ? _purple(s) : s;
  static String blue(String s, bool color) => color ? _blue(s) : s;
}
