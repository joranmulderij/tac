import 'package:test/test.dart';

import 'bool.dart' as bool;
import 'function.dart' as function;
import 'list.dart' as list;
import 'object.dart' as object;
import 'sequence.dart' as sequence;
import 'string.dart' as string;
import 'vector.dart' as vector;

void main() {
  group('Types', () {
    bool.main();
    function.main();
    list.main();
    object.main();
    sequence.main();
    string.main();
    vector.main();
  });
}
