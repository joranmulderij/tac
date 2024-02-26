import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';
import 'package:tac_dart/number/number.dart';
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
  microGram('µg', ['ug'], _millionth, mass),
  gram('g', ['grams', 'gram'], _thousandth, mass),
  kiloGram('kg', ['kilograms', 'kilogram'], _one, mass),

  // Length
  microMeter('µm', ['um'], _millionth, length),
  milliMeter('mm', [], _thousandth, length),
  meter('m', ['meters', 'meter'], _one, length),
  centiMeter('cm', [], _hundredth, length),
  deciMeter('dm', [], _tenth, length),
  decaMeter('dam', [], _ten, length),
  hectoMeter('hm', [], _hundred, length),
  kiloMeter('km', [], _thousand, length),

  // Time
  second('s', [], _one, time),
  minute('min', [], _sixty, time),
  hour('h', [], _thirtySixHundred, time),

  // Current
  ampere('A', [], _one, current),

  // Voltage
  milliVolt('mV', [], _thousandth, voltage),
  volt('V', [], _one, voltage),

  // Temperature
  kelvin('K', [], _one, temperature),
  celsius('°C', ['oC', 'degC'], _one, temperature, offset: _celciusOffset),
  fahrenheit(
    '°F',
    ['oF', 'degF'],
    _fahrenheitToKelvin,
    temperature,
    offset: _fahrenheitOffset,
  ),

  // Force
  newton('N', [], _one, force),
  kiloNewton('kN', [], _thousand, force),

  // Energy
  joule('J', [], _one, energy),
  kiloJoule('kJ', [], _thousand, energy);

  const Unit(
    this.name,
    this.otherNames,
    this.multiplier,
    this.dim, {
    this.offset,
  });

  final String name;
  final List<String> otherNames;
  final Number Function() multiplier;
  final Number Function()? offset;
  final DimensionSignature dim;

  @override
  String toString() => name;

  static Number _millionth() => Number.fromDouble(0.000001);
  static Number _thousandth() => Number.fromDouble(0.001);
  static Number _hundredth() => Number.fromDouble(0.01);
  static Number _tenth() => Number.fromDouble(0.1);
  static Number _one() => Number.one;
  static Number _ten() => Number.fromInt(10);
  static Number _hundred() => Number.fromInt(100);
  static Number _thousand() => Number.fromInt(1000);

  static Number _sixty() => Number.fromInt(60);
  static Number _thirtySixHundred() => Number.fromInt(3600);

  static Number _fahrenheitToKelvin() => Number.fromDouble(5 / 9);
  static Number _fahrenheitOffset() => Number.fromDouble(459.67);
  static Number _celciusOffset() => Number.fromDouble(273.15);
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
