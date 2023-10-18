import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';
import 'package:tac_dart/errors.dart';

@immutable
class UnitSet extends Equatable {
  const UnitSet(this._units);

  factory UnitSet.parse(String input) {
    if (input.isEmpty) return UnitSet.empty;
    final result = unitParser().parse(input);
    final units = switch (result) {
      Success() => result.value,
      Failure() => throw UnitParseError(input),
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
      dimensions[Dimension.mass] = unit.dim.mass * amount;
      dimensions[Dimension.length] = unit.dim.length * amount;
      dimensions[Dimension.time] = unit.dim.time * amount;
      dimensions[Dimension.current] = unit.dim.current * amount;
      dimensions[Dimension.temperature] = unit.dim.temperature * amount;
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
    final result = StringBuffer();
    for (final MapEntry(key: unit, value: amount)
        in _units.entries.where((element) => element.value > 0)) {
      result.write(unit.toString());
      if (amount != 1) result.write('$amount');
    }
    for (final MapEntry(key: unit, value: amount)
        in _units.entries.where((element) => element.value < 0)) {
      result.write('/$unit');
      if (amount != -1) result.write('${-amount}');
    }
    return result.toString();
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

const mass = DimensionSignature(mass: 1);
const length = DimensionSignature(length: 1);
const time = DimensionSignature(time: 1);
const current = DimensionSignature(time: 1);
const temperature = DimensionSignature(temperature: 1);
const force = DimensionSignature(mass: 1, length: 1, time: -2);

enum Unit {
  // Mass
  kiloGram('kg', 1, mass),
  gram('g', 0.001, mass),

  // Length
  meter('m', 1, length),
  kiloMeter('km', 1000, length),

  // Time
  second('s', 1, time),
  minute('min', 60, time),
  hour('h', 3600, time),

  // Current
  ampere('A', 1, current),

  // Temperature
  kelvin('K', 1, temperature),
  celsius('°C', 1, temperature),

  // Force
  newton('N', 1, force),
  kiloNewton('kN', 1000, force);

  const Unit(
    this.name,
    this.multiplier,
    this.dim,
  );

  final String name;
  final double multiplier;
  final DimensionSignature dim;

  @override
  String toString() => name;
}

Parser<List<Unit>> unitParser() => Unit.values
    .map(
      (e) => (string(e.name) & digit().star().flatten()).map((token) {
        final amountString = token[1] as String;
        if (amountString.isEmpty) return [e];
        final amount = int.parse(amountString);
        return [for (var i = 0; i < amount; i++) e];
      }),
    )
    .toChoiceParser()
    .plus()
    .map((value) => value.expand((element) => element).toList())
    .end();
