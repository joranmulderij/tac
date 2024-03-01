import 'package:http/http.dart' as http;
import 'package:tac/utils/errors.dart';
import 'package:tac/value/value.dart';

final httpLibrary = {
  'get': DartFunctionValue.from1Param(
    (state, arg) async {
      if (arg case StringValue(:final value)) {
        final url = Uri.parse(value);
        final response = await http.get(url);
        return ObjectValue({
          'statusCode': NumberValue.fromNum(response.statusCode),
          'body': StringValue(response.body),
          'headers': ObjectValue(
            response.headers
                .map((key, value) => MapEntry(key, StringValue(value))),
          ),
        });
      } else {
        throw MyError.unexpectedType('string', arg.type);
      }
    },
    'url',
  ),
};
