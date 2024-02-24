import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('List', () {
    test('Literals', () {
      expect(run('[1]'), '[1]');
      expect(run('[1, 2]'), '[1, 2]');
      expect(run('[1, 2, 3]'), '[1, 2, 3]');
    });
    test('Equality', () {
      expect(run('[1] == [1]'), 'true');
      expect(run('[1] == [2]'), 'false');
      expect(run('[1, 2, 3] == [1, 2, 3]'), 'true');
      expect(run('[1, 2, 3] == [3, 2, 1]'), 'false');
      expect(run('[1, 2, 3] == [1, 2]'), 'false');
    });
  });
}
