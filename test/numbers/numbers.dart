import 'package:test/test.dart';

import 'arithmetic.dart' as arithmetic;
import 'floats.dart' as floats;
import 'units.dart' as units;

void main() {
  group('Numbers', () {
    arithmetic.main();
    floats.main();
    units.main();
  });
}
