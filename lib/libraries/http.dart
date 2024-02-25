import 'package:sync_http/sync_http.dart';
import 'package:tac_dart/utils/errors.dart';
import 'package:tac_dart/value/value.dart';

// TODO: This package seems very wack.
final httpLibrary = {
  'get': DartFunctionValue.from1Param(
    (state, arg) {
      if (arg case StringValue(:final value)) {
        final url = Uri.parse(value);
        final request = SyncHttpClient.getUrl(url);
        request.headers.add('User-Agent', 'tac-dart');
        final response = request.close();
        return StringValue(response.body ?? '');
      } else {
        throw MyError.unexpectedType('string', arg.type);
      }
    },
    'url',
  ),
};
