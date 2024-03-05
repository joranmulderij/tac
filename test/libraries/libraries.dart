import 'package:test/test.dart';

import 'core.dart' as core;
import 'math.dart' as math;
import 'units.dart' as units;

void main() {
  group('Libraries', () {
    core.main();
    math.main();
    units.main();
    // plot.main();
  });
}
