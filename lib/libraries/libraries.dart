import 'package:tac/libraries/core.dart';
import 'package:tac/libraries/math.dart';
import 'package:tac/libraries/plot.dart';
import 'package:tac/libraries/rand.dart';
import 'package:tac/libraries/units.dart';
import 'package:tac/value/value.dart';

class Library {
  Library({
    required this.name,
    required this.displayName,
    required this.definitions,
  });
  final String name;
  final String displayName;

  final Map<String, Value> definitions;

  String get helpText => '''
$displayName
============
${definitions.entries.where((e) => e.value is DartFunctionValue).map((e) {
        final function = e.value as DartFunctionValue;
        return '${e.key}(${function.args.join(', ')}): ${(e.value as DartFunctionValue).helpText}';
      }).join('\n')}
''';

  static final builtin = <String, Library>{
    'core': coreLibrary,
    'math': mathLibrary,
    'rand': randLibrary,
    'plot': plotLibrary,
    'units': unitsLibrary,
  };

  static final autoImported = <String, Library>{
    'core': coreLibrary,
    'math': mathLibrary,
    'rand': randLibrary,
    'plot': plotLibrary,
    'units': unitsLibrary,
  };
}
