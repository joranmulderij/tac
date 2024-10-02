// ignore_for_file: avoid_positional_boolean_parameters

import 'package:ansicolor/ansicolor.dart';

abstract class ConsoleColors {
  static final _red = AnsiPen()..red();
  static final _green = AnsiPen()..green();
  static final _orange = AnsiPen()..rgb(r: 1, g: 0.5, b: 0);
  static final _gray = AnsiPen()..gray(level: 0.5);
  static final _purple = AnsiPen()..rgb(r: 0.8, g: 0.4, b: 1);
  static final _blue = AnsiPen()..rgb(r: 0.2, g: 0.6, b: 1);

  static String red(String s, bool color) => color ? _red(s) : s;
  static String green(String s, bool color) => color ? _green(s) : s;
  static String orange(String s, bool color) => color ? _orange(s) : s;
  static String gray(String s, bool color) => color ? _gray(s) : s;
  static String purple(String s, bool color) => color ? _purple(s) : s;
  static String blue(String s, bool color) => color ? _blue(s) : s;

  static (int, int, int) purpleRGB = (92, 12, 108);
}
