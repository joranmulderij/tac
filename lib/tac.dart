import 'package:console/console.dart' show createTree;
import 'package:tac/libraries/core.dart';
import 'package:tac/libraries/math.dart';
import 'package:tac/libraries/plot.dart';
import 'package:tac/libraries/units.dart';
import 'package:tac/parser.dart';
import 'package:tac/utils/console.dart';
import 'package:tac/value/value.dart';

const appVersion = '0.0.1';

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
      variables.addAll(coreLibrary);
      variables.addAll(mathLibrary);
      variables.addAll(plotLibrary);
      variables.addAll(unitsLibrary);
    }
  }

  final Map<String, Value> variables = {};
  final ScopeProtectionLevel protectionLevel;
}

enum ScopeProtectionLevel { none, protected, blocked }
