import 'package:tac_dart/libraries/library.dart';
import 'package:tac_dart/value/value.dart';

class State {
  final List<Scope> scopes = [];

  Value get(String name) {
    for (final scope in scopes.reversed) {
      if (scope.variables.containsKey(name)) {
        return scope.variables[name]!;
      }
    }
    const unknown = UnknownValue();
    scopes.last.variables[name] = unknown;
    return unknown;
  }

  void set(String name, Value value) {
    for (final scope in scopes.reversed) {
      if (scope.variables.containsKey(name)) {
        scope.variables[name] = value;
        return;
      }
    }
    scopes.last.variables[name] = value;
  }

  void loadLibrary(Library library) {
    library.load(this);
  }

  void pushScope() {
    scopes.add(Scope());
  }

  Scope popScope() {
    return scopes.removeLast();
  }
}

class Scope {
  final Map<String, Value> variables = {};
}
