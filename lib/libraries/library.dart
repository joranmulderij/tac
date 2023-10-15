import 'package:tac_dart/state.dart';
import 'package:tac_dart/value/value.dart';

class Library {
  const Library(this.variables);

  final Map<String, Value> variables;

  void load(State state) {
    for (final entry in variables.entries) {
      state.set(entry.key, entry.value);
    }
  }
}
