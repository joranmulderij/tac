import 'package:test/test.dart';

import 'core.dart' as core;
import 'math.dart' as math;

void main() {
  group('Libraries', () {
    core.main();
    math.main();
    // plot.main();
  });
}
