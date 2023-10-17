import 'dart:math' as math;

import 'package:petitparser/petitparser.dart';
import 'package:tac_dart/errors.dart';

class UnitSet {
  const UnitSet(this._units);

  factory UnitSet.parse(String input) {
    final result = unitParser().parse(input);
    final units = switch (result) {
      Success() => result.value,
      Failure() =>
        throw ArgumentError.value(input, 'input', 'Invalid unit set'),
    };
    final map = <Unit, int>{};
    for (final unit in units) {
      map[unit] = (map[unit] ?? 0) + 1;
    }
    return UnitSet(map);
  }

  final Map<Unit, int> _units;

  Map<Dimension, int> get dimensions {
    final dimensions = <Dimension, int>{};
    for (final MapEntry(key: unit, value: amount) in _units.entries) {
      dimensions[Dimension.mass] = unit.mass * amount;
      dimensions[Dimension.length] = unit.length * amount;
      dimensions[Dimension.time] = unit.time * amount;
      dimensions[Dimension.current] = unit.current * amount;
      dimensions[Dimension.temperature] = unit.temperature * amount;
    }
    return dimensions;
  }

  double get multiplier {
    var multiplier = 1.0;
    for (final MapEntry(key: unit, value: amount) in _units.entries) {
      multiplier *= math.pow(unit.multiplier, amount);
    }
    return multiplier;
  }

  @override
  String toString() {
    return _units.entries
        .map((e) => e.value == 1 ? e.key.name : '${e.key.name}^${e.value}')
        .join(' * ');
  }

  UnitSet operator *(UnitSet other) {
    const result = UnitSet.empty;
    for (final MapEntry(key: unit, value: amount) in _units.entries) {
      result[unit] = amount + other[unit];
    }
    return result;
  }

  int operator [](Unit unit) => _units[unit] ?? 0;

  void operator []=(Unit unit, int amount) {
    _units[unit] = amount;
  }

  static const UnitSet empty = UnitSet({});

  UnitSet checkEq(UnitSet other) {
    if (this == other) {
      return this;
    } else {
      throw UnitsNotEqualError(toString(), other.toString());
    }
  }
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

enum Unit {
  // Mass
  kiloGram('kg', 1, mass: 1),
  gram('g', 0.001, mass: 1),

  // Length
  meter('m', 1, length: 1),
  kiloMeter('km', 1000, length: 1),

  // Time
  second('s', 1, time: 1),
  minute('min', 60, time: 1),
  hour('h', 3600, time: 1),

  // Current
  ampere('A', 1, current: 1),

  // Temperature
  kelvin('K', 1, temperature: 1),
  celsius('°C', 1, temperature: 1),

  // Force
  newton('N', 1, mass: 1, length: 1, time: -2),
  kiloNewton('kN', 1000, mass: 1, length: 1, time: -2);

  const Unit(
    this.name,
    this.multiplier, {
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
  final String name;
  final double multiplier;
}

Parser<List<Unit>> unitParser() => Unit.values
    .map((e) => string(e.name).map((_) => e))
    .toChoiceParser()
    .plus()
    .map((e) => e.whereType<Unit>().toList())
    .end();
