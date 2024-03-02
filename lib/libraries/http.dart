import 'package:http/http.dart' as http;
import 'package:tac/utils/errors.dart';
import 'package:tac/value/value.dart';

final httpLibrary = {
  'get': DartFunctionValue.from1Param(
    (state, arg) async {
      final response = await switch (arg) {
        StringValue(:final value) => http.get(Uri.parse(value)),
        ObjectValue(:final values) => () {
            final url = values['url'];
            if (url is! StringValue) {
              throw MyError.unexpectedType('string', url?.type);
            }
            return http.get(Uri.parse(url.value));
          }(),
        _ => throw MyError.unexpectedType('string', arg.type),
      };
      return ObjectValue({
        'statusCode': NumberValue.fromNum(response.statusCode),
        'body': StringValue(response.body),
        'headers': ObjectValue(
          response.headers
              .map((key, value) => MapEntry(key, StringValue(value))),
        ),
      });
    },
    'url',
  ),
};
