import 'dart:io';

import 'package:tac/libraries/core.dart';
import 'package:tac/libraries/math.dart';
import 'package:tac/libraries/plot.dart';
import 'package:tac/utils/console.dart';
import 'package:tac/value/value.dart';

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
          final oldUnit = (oldValue as ValueWithUnit).unitSet;
          final newUnit = (value as ValueWithUnit).unitSet;
          if (newUnit != oldUnit && name != '_') {
            printWarning(
              'Variable "$name" change it\'s unit dimension from [$oldUnit] to [$newUnit]',
            );
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

  void print(String message) {
    stdout.writeln(message);
  }

  void printWarning(String message) {
    stdout.writeln(ConsoleUtils.orange('Warning: $message'));
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
