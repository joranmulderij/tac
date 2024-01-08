import 'package:test/test.dart';
import 'core.dart' as core;
import 'math.dart' as math;
import 'plot.dart' as plot;

void main() {
  group('Libraries', () {
    core.main();
    math.main();
    plot.main();
  });
}
