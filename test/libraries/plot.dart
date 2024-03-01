import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('plot', () {
    test('Basic', () async {
      await run('plot sin');
      await run('plot(x => x)');
      expect(
        await run('plot(x => "Hello")'),
        'TypeError: Expected number, got string',
      );
    });
  });
}
