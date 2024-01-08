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

  num get multiplier {
    num multiplier = 1;
    for (final MapEntry(key: unit, value: amount) in _units.entries) {
      multiplier *= math.pow(unit.multiplier, amount);
    }
    return multiplier;
  }

  num get offset {
    num offset = 0;
    for (final MapEntry(key: unit, value: amount) in _units.entries) {
      offset += (unit.offset ?? 0) * amount;
    }
    return offset;
  }

  bool get isEmpty => _units.isEmpty;

  UnitSet operator *(int other) =>
      UnitSet(_units.map((key, value) => MapEntry(key, value * other)));

  @override
  String toString() {
    if (_units.isEmpty) return '';
    final units = _units.entries.map((e) {
      final unit = e.key;
      final amount = e.value;
      return '$unit${amount == 1 ? '' : '$amount'}';
    }).join(' ');
    return '[$units]';
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
  kiloGram('kg', ['kilograms', 'kilogram', 'kg'], 1, mass),
  gram('g', ['g', 'gram', 'grams'], 0.001, mass),

  // Length
  milliMeter('mm', ['mm'], 0.001, length),
  meter('m', ['meters', 'meter', 'm'], 1, length),
  centiMeter('cm', ['cm'], 0.01, length),
  deciMeter('dm', ['dm'], 0.1, length),
  decaMeter('dam', ['dam'], 10, length),
  hectoMeter('hm', ['hm'], 100, length),
  kiloMeter('km', ['km'], 1000, length),

  // Time
  second('s', ['s'], 1, time),
  minute('min', ['min'], 60, time),
  hour('h', ['h'], 3600, time),

  // Current
  ampere('A', ['A'], 1, current),

  // Temperature
  kelvin('K', ['K'], 1, temperature),
  celsius('°C', ['oC', 'degC'], 1, temperature, offset: 273.15),

  // Force
  newton('N', ['N'], 1, force),
  kiloNewton('kN', ['kN'], 1000, force);

  const Unit(this.name, this.names, this.multiplier, this.dim, {this.offset});

  final String name;
  final List<String> names;
  final num multiplier;
  final num? offset;
  final DimensionSignature dim;

  @override
  String toString() => name;
}

Parser<List<Unit>> unitParser() => Unit.values
    .map(
      (e) => (e.names.map(string).toChoiceParser().flatten() &
              digit().star().flatten())
          .map((token) {
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
