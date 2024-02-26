import 'package:test/test.dart';

import 'pipe.dart' as pipe;
import 'pipe_where.dart' as pipe_where;

void main() {
  group('Numbers', () {
    pipe.main();
    pipe_where.main();
  });
}
