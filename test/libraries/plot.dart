import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('plot', () {
    test('Basic', () {
      run('plot sin');
      run('plot(x => x)');
      expect(
        run('plot(x => "Hello")'),
        'TypeError: Expected number, got string.',
      );
    });
  });
}
