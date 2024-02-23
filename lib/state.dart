import 'package:tac_dart/errors.dart';
import 'package:tac_dart/libraries/core.dart';
import 'package:tac_dart/libraries/math.dart';
import 'package:tac_dart/libraries/plot.dart';
import 'package:tac_dart/value/value.dart';

class State {
  State() : scopes = [Scope(ScopeProtectionLevel.blocked)];

  final List<Scope> scopes;

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
        final oldValue = scope.variables[name]!;
        if (oldValue is ValueWithUnit && value is ValueWithUnit) {
          if ((value as ValueWithUnit).unitSet !=
              (oldValue as ValueWithUnit).unitSet) {
            throw const CustomMyError('Cannot change the unit of a variable.');
          }
        }
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
    scopes.add(Scope(ScopeProtectionLevel.blocked));
  }

  Scope popScope() {
    return scopes.removeLast();
  }
}

class Scope {
  Scope(this.protectionLevel) {
    if (protectionLevel == ScopeProtectionLevel.blocked) {
      variables.addAll(coreLibrary);
      variables.addAll(mathLibrary);
      variables.addAll(plotLibrary);
    }
  }

  final Map<String, Value> variables = {};
  final ScopeProtectionLevel protectionLevel;
}

enum ScopeProtectionLevel { none, protected, blocked }
