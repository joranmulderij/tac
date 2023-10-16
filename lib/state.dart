import 'package:tac_dart/libraries/core.dart';
import 'package:tac_dart/libraries/math.dart';
import 'package:tac_dart/value/value.dart';

class State {
  final List<Scope> scopes = [];

  Value get(String name) {
    for (final scope in scopes.reversed) {
      if (scope.variables.containsKey(name)) {
        return scope.variables[name]!;
      } else if (scope.protectionLevel == ScopeProtectionLevel.blocked) {
        break;
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
      } else if (scope.protectionLevel == ScopeProtectionLevel.protected ||
          scope.protectionLevel == ScopeProtectionLevel.blocked) {
        break;
      }
    }
    scopes.last.variables[name] = value;
  }

  void loadLibrary(Map<String, Value> library) {
    scopes.last.variables.addAll(library);
  }

  void pushScope() {
    scopes.add(Scope(ScopeProtectionLevel.none));
  }

  void pushProtectedScope() {
    scopes.add(Scope(ScopeProtectionLevel.protected));
  }

  void pushBlockedScope() {
    final scope = Scope(ScopeProtectionLevel.blocked);
    scopes.add(scope);
    loadLibrary(coreLibrary);
    loadLibrary(mathLibrary);
  }

  Scope popScope() {
    return scopes.removeLast();
  }
}

class Scope {
  Scope(this.protectionLevel);

  final Map<String, Value> variables = {};
  final ScopeProtectionLevel protectionLevel;
}

enum ScopeProtectionLevel { none, protected, blocked }
