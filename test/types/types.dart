import 'package:test/test.dart';

import 'bool.dart' as bool;
import 'function.dart' as function;
import 'object.dart' as object;
import 'string.dart' as string;

void main() {
  group('Types', () {
    bool.main();
    function.main();
    object.main();
    string.main();
  });
}
