import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';
import 'package:tac_dart/parser.dart';
import 'package:tac_dart/utils/errors.dart';

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
const temperature = DimensionSignature(temperature: 1);
const force = DimensionSignature(mass: 1, length: 1, time: -2);
const pressure = DimensionSignature(mass: 1, length: -1, time: -2);
const energy = DimensionSignature(mass: 1, length: 2, time: -2);
const power = DimensionSignature(mass: 1, length: 2, time: -3);

const current = DimensionSignature(time: 1);
const voltage = DimensionSignature(mass: 1, length: 2, time: -3, current: -1);
const electricCharge = DimensionSignature(time: 1, current: 1);
const resistance =
    DimensionSignature(mass: 1, length: 2, time: -3, current: -2);

enum Unit {
  // Mass
  microGram('µg', ['ug'], 0.000001, mass),
  gram('g', ['grams', 'gram'], 0.001, mass),
  kiloGram('kg', ['kilograms', 'kilogram'], 1, mass),

  // Length
  microMeter('µm', ['um'], 0.000001, length),
  milliMeter('mm', [], 0.001, length),
  meter('m', ['meters', 'meter'], 1, length),
  centiMeter('cm', [], 0.01, length),
  deciMeter('dm', [], 0.1, length),
  decaMeter('dam', [], 10, length),
  hectoMeter('hm', [], 100, length),
  kiloMeter('km', [], 1000, length),

  // Time
  second('s', [], 1, time),
  minute('min', [], 60, time),
  hour('h', [], 3600, time),

  // Current
  ampere('A', [], 1, current),

  // Voltage
  milliVolt('mV', [], 0.001, voltage),
  volt('V', [], 1, voltage),

  // Temperature
  kelvin('K', [], 1, temperature),
  celsius('°C', ['oC', 'degC'], 1, temperature, offset: 273.15),
  fahrenheit('°F', ['oF', 'degF'], 5 / 9, temperature, offset: 459.67),

  // Force
  newton('N', [], 1, force),
  kiloNewton('kN', [], 1000, force),

  // Energy
  joule('J', [], 1, energy),
  kiloJoule('kJ', [], 1000, energy);

  const Unit(
    this.name,
    this.otherNames,
    this.multiplier,
    this.dim, {
    this.offset,
  });

  final String name;
  final List<String> otherNames;
  final num multiplier;
  final num? offset;
  final DimensionSignature dim;

  @override
  String toString() => name;
}

Parser<Map<Unit, int>> unitParser() => Unit.values
        .map(
          (e) => ([e.name, ...e.otherNames]
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
