import 'package:console/console.dart' show createTree;
import 'package:tac/libraries/libraries.dart';
import 'package:tac/parser.dart';
import 'package:tac/utils/console_colors.dart';
import 'package:tac/value/value.dart';

/// Format: `v{major}.{minor}.{patch}`
const appVersion = 'v0.1.0';

class Tac {
  Tac({
    required this.onPrint,
    this.color = false,
    this.printAst = false,
  });

  final List<Scope> scopes = [Scope(ScopeProtectionLevel.blocked)];
  final void Function(String) onPrint;
  final bool color;
  final bool printAst;

  Value get(String name) {
    if (name == 'this') {
      final thisValue = Map<String, Value>.from(scopes.last.variables);
      return ObjectValue(thisValue);
    }
    for (final scope in scopes.reversed) {
      if (scope.variables.containsKey(name)) {
        return scope.variables[name]!;
      } else if (scope.protectionLevel == ScopeProtectionLevel.blocked) {
        break;
      }
    }
    // const unknown = UnknownValue();
    // scopes.last.variables[name] = unknown;
    // return unknown;
    return const UnknownValue();
  }

  void set(String name, Value value) {
    if (name == 'this') {
      printWarning('Cannot assign to "$name"');
      return;
    }
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

  void setAll(Map<String, Value> library) {
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
    onPrint(message);
  }

  void printWarning(String message) {
    onPrint(ConsoleColors.orange('Warning: $message', color));
  }

  Future<Value> run(String input) async {
    final ast = parse(input);
    if (printAst) {
      print(createTree(ast.toTree().toJson()));
    }
    final value = await ast.run(this);
    return value;
  }
}

class Scope {
  Scope(this.protectionLevel) {
    if (protectionLevel == ScopeProtectionLevel.blocked) {
      for (final library in Library.builtin.values) {
        variables.addAll(library.definitions);
      }
    }
  }

  final Map<String, Value> variables = {};
  final ScopeProtectionLevel protectionLevel;
}

enum ScopeProtectionLevel { none, protected, blocked }
