import 'package:test/test.dart';

import 'flow.dart' as flow;
import 'libraries/libraries.dart' as libraries;
import 'logic.dart' as logic;
import 'numbers/numbers.dart' as numbers;
import 'operators/operators.dart' as operators;
import 'scopes.dart' as scopes;
import 'syntax.dart' as syntax;
import 'types/types.dart' as types;
import 'utils.dart';

void main() {
  flow.main();
  libraries.main();
  logic.main();
  numbers.main();
  operators.main();
  scopes.main();
  syntax.main();
  types.main();
  test('Print number of runs', printRunCount);
}
