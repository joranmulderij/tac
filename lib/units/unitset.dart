import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';
import 'package:tac/number/number.dart';
import 'package:tac/parser.dart';
import 'package:tac/units/unit.dart';
import 'package:tac/utils/errors.dart';

@immutable
class UnitSet extends Equatable {
  const UnitSet(this._units);

  factory UnitSet.parse(String input) {
    if (input.isEmpty) return UnitSet.empty;
    _unitParser ??= unitParser();
    final result = _unitParser!.parse(input);
    final units = switch (result) {
      Success() => result.value,
      Failure() => throw MyError.unitParseError(input),
    };
    return UnitSet(units);
  }

  static Parser<Map<Unit, int>>? _unitParser;

  final Map<Unit, int> _units;

  DimensionSignature get dimensions {
    var mass = 0;
    var length = 0;
    var time = 0;
    var current = 0;
    var temperature = 0;
    for (final MapEntry(key: unit, value: amount) in _units.entries) {
      mass += unit.dim.mass * amount;
      length += unit.dim.length * amount;
      time += unit.dim.time * amount;
      current += unit.dim.current * amount;
      temperature += unit.dim.temperature * amount;
    }
    return DimensionSignature(
      mass: mass,
      length: length,
      time: time,
      current: current,
      temperature: temperature,
    );
  }

  Number get multiplier {
    var multiplier = Number.one;
    for (final MapEntry(key: unit, value: amount) in _units.entries) {
      multiplier *= unit.multiplier().pow(Number.fromInt(amount));
    }
    return multiplier;
  }

  Number get offset {
    var totalOffset = Number.zero;
    for (final MapEntry(key: unit, value: amount) in _units.entries) {
      final offset = unit.offset?.call() ?? Number.zero;
      totalOffset += offset * Number.fromInt(amount);
    }
    return totalOffset;
  }

  bool get isEmpty => _units.isEmpty;

  @override
  String toString() {
    if (_units.isEmpty) return '';
    final units = _units.entries.map((e) {
      final unit = e.key;
      final amount = e.value;
      return '$unit${amount == 1 ? '' : '$amount'}';
    }).join(' ');
    return units;
  }

  UnitSet operator +(UnitSet other) {
    final map = <Unit, int>{};
    for (final MapEntry(key: unit, value: amount) in _units.entries) {
      map[unit] = amount;
    }
    for (final MapEntry(key: unit, value: amount) in other._units.entries) {
      map[unit] = (map[unit] ?? 0) + amount;
      if (map[unit] == 0) map.remove(unit);
    }
    return UnitSet(map);
  }

  UnitSet operator -(UnitSet other) {
    final map = <Unit, int>{};
    for (final MapEntry(key: unit, value: amount) in _units.entries) {
      map[unit] = amount;
    }
    for (final MapEntry(key: unit, value: amount) in other._units.entries) {
      map[unit] = (map[unit] ?? 0) - amount;
      if (map[unit] == 0) map.remove(unit);
    }
    return UnitSet(map);
  }

  static const UnitSet empty = UnitSet({});

  @override
  List<Object?> get props => [toString()];
}

enum Dimension {
  mass(Unit.kiloGram),
  length(Unit.meter),
  time(Unit.second),
  current(Unit.ampere),
  temperature(Unit.kelvin);

  const Dimension(this.defaultUnit);

  final Unit defaultUnit;
}

@immutable
class DimensionSignature extends Equatable {
  const DimensionSignature({
    this.mass = 0,
    this.length = 0,
    this.time = 0,
    this.current = 0,
    this.temperature = 0,
  });

  final int mass;
  final int length;
  final int time;
  final int current;
  final int temperature;

  @override
  List<Object?> get props => [mass, length, time, current, temperature];
}

Parser<Map<Unit, int>> unitParser() => Unit.values
        .map(
          (e) => (([e.name, ...e.otherNames]
                        ..sort((a, b) => b.length - a.length))
                      .map((name) => string(name).trimNoNewline())
                      .toChoiceParser()
                      .flatten() &
                  (char('-').optional() & digit().star().flatten()).flatten())
              .map((token) {
            final amountString = token[1] as String;
            if (amountString.isEmpty) return {e: 1};
            final amount = int.parse(amountString);
            return {e: amount};
          }),
        )
        .toChoiceParser()
        .plus()
        .map((value) {
      final map = <Unit, int>{};
      for (final entry in value) {
        for (final key in entry.keys) {
          map[key] = entry[key]! + (map[key] ?? 0);
        }
      }
      return map;
    }).end();
