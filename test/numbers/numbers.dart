import 'package:test/test.dart';

import 'arithmetic.dart' as arithmetic;
import 'comparison.dart' as comparison;
import 'floats.dart' as floats;
import 'units.dart' as units;

void main() {
  group('Numbers', () {
    arithmetic.main();
    comparison.main();
    floats.main();
    units.main();
  });
}
