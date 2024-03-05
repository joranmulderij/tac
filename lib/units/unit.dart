import 'package:tac/number/number.dart';
import 'package:tac/units/unitset.dart';

enum Unit {
  // Mass
  microGram('µg', ['ug'], _millionth, mass),
  milliGram('mg', [], _thousandth, mass),
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
  microSecond('µs', ['us'], _millionth, time),
  milliSecond('ms', [], _thousandth, time),
  second('s', [], _one, time),
  minute('min', [], _sixty, time),
  hour('hour', ['h', 'hours'], _thirtySixHundred, time),
  day('day', ['d', 'days'], _thirtySixHundred, time),
  year('year', ['years'], _thirtySixHundred, time),

  // Temperature
  kelvin('K', [], _one, temperature),
  celsius(
    '°C',
    ['oC', 'degC'],
    _one,
    temperature,
    offset: _celciusOffset,
    isSI: false,
  ),
  fahrenheit(
    '°F',
    ['oF', 'degF'],
    _fahrenheitToKelvin,
    temperature,
    offset: _fahrenheitOffset,
    isSI: false,
  ),

  // Force
  newton('N', [], _one, force),
  kiloNewton('kN', [], _thousand, force),

  // Pressure
  milliPascal('mPa', [], _thousandth, pressure),
  pascal('Pa', [], _one, pressure),
  kiloPascal('kPa', [], _thousand, pressure),
  megaPascal('MPa', [], _million, pressure),
  gigaPascal('GPa', [], _billion, pressure),

  // Power
  watt('W', [], _one, power),
  kiloWatt('kW', [], _thousand, power),
  megaWatt('MW', [], _millionth, power),

  // Energy
  joule('J', [], _one, energy),
  kiloJoule('kJ', [], _thousand, energy),
  megaJoule('MJ', [], _million, energy),
  gigaJoule('GJ', [], _billion, energy),

  // Frequency
  hertz('Hz', [], _one, frequency),
  kiloHertz('kHz', [], _thousand, frequency),
  megaHertz('MHz', [], _million, frequency),
  gigaHertz('GHz', [], _billion, frequency),

  // Current
  milliAmpere('mA', [], _thousandth, current),
  ampere('A', [], _one, current),
  kiloAmpere('kA', [], _thousand, current),

  // Voltage
  milliVolt('mV', [], _thousandth, voltage),
  volt('V', [], _one, voltage);

  const Unit(
    this.name,
    this.otherNames,
    this.multiplier,
    this.dim, {
    this.offset,
    this.isSI = true,
  });

  final String name;
  final List<String> otherNames;
  final Number Function() multiplier;
  final Number Function()? offset;
  final bool isSI;
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
  static Number _million() => Number.fromInt(1000000);
  static Number _billion() => Number.fromInt(1000000000);

  static Number _sixty() => Number.fromInt(60);
  static Number _thirtySixHundred() => Number.fromInt(3600);

  static Number _fahrenheitToKelvin() => Number.fromDouble(5 / 9);
  static Number _fahrenheitOffset() => Number.fromDouble(459.67);
  static Number _celciusOffset() => Number.fromDouble(273.15);

// Base
  static const mass = DimensionSignature(mass: 1);
  static const length = DimensionSignature(length: 1);
  static const time = DimensionSignature(time: 1);
  static const temperature = DimensionSignature(temperature: 1);

// Mechanics
  static const force = DimensionSignature(mass: 1, length: 1, time: -2);
  static const pressure = DimensionSignature(mass: 1, length: -1, time: -2);
  static const energy = DimensionSignature(mass: 1, length: 2, time: -2);
  static const power = DimensionSignature(mass: 1, length: 2, time: -3);
  static const frequency = DimensionSignature(time: -1);
  static const velocity = DimensionSignature(length: 1, time: -1);
  static const acceleration = DimensionSignature(length: 1, time: -2);

// Electricity
  static const current = DimensionSignature(current: 1);
  static const voltage =
      DimensionSignature(mass: 1, length: 2, time: -3, current: -1);
  static const electricCharge = DimensionSignature(time: 1, current: 1);
  static const resistance =
      DimensionSignature(mass: 1, length: 2, time: -3, current: -2);
  static const capacitance =
      DimensionSignature(mass: -1, length: -2, time: 4, current: 2);
  static const inductance =
      DimensionSignature(mass: 1, length: 2, time: -2, current: -2);
}
