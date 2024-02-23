import 'package:ansicolor/ansicolor.dart';

class ConsoleUtils {
  static final red = AnsiPen()..red();
  static final green = AnsiPen()..green();
  static final orange = AnsiPen()..rgb(r: 1, g: 0.5, b: 0);
}
