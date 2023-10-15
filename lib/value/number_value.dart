part of 'value.dart';

class NumberValue extends Value {
  const NumberValue(this.value);
  final Rational value;

  @override
  Value add(Value other) => switch (other) {
        NumberValue(:final value) => NumberValue(this.value + value),
        _ => other.add(this),
      };

  @override
  Value sub(Value other) => switch (other) {
        NumberValue(:final value) => NumberValue(this.value - value),
        _ => other.add(this),
      };

  @override
  Value mul(Value other) => switch (other) {
        NumberValue(:final value) => NumberValue(this.value * value),
        _ => other.add(this),
      };

  @override
  Value div(Value other) => switch (other) {
        NumberValue(:final value) => NumberValue(this.value / value),
        _ => other.add(this),
      };

  @override
  Value mod(Value other) => switch (other) {
        NumberValue(:final value) => NumberValue(this.value % value),
        _ => other.add(this),
      };

  @override
  Value pow(Value other) => switch (other) {
        NumberValue(:final value) =>
          NumberValue(this.value.pow(value.toBigInt().toInt())),
        _ => other.add(this),
      };

  @override
  Value lt(Value other) => switch (other) {
        NumberValue(:final value) => BoolValue(this.value < value),
        _ => other.add(this),
      };

  @override
  Value lte(Value other) => switch (other) {
        NumberValue(:final value) => BoolValue(this.value <= value),
        _ => other.add(this),
      };

  @override
  Value gt(Value other) => switch (other) {
        NumberValue(:final value) => BoolValue(this.value > value),
        _ => other.add(this),
      };

  @override
  Value gte(Value other) => switch (other) {
        NumberValue(:final value) => BoolValue(this.value >= value),
        _ => other.add(this),
      };

  @override
  String toString() {
    if (value.isInteger) {
      return value.toString();
    } else {
      return value.toDouble().toString();
    }
  }

  @override
  String toPrettyString() {
    if (value.isInteger) {
      return value.toString();
    } else {
      return '$value = ${value.toDouble()}';
    }
  }

  @override
  Value neg() => NumberValue(-value);

  static final zero = NumberValue(Rational.zero);

  static final one = NumberValue(Rational.one);

  @override
  String get type => 'number';

  @override
  List<Object> get props => [value];
}

class UnitSet {
  UnitSet();

  final Map<Unit, int> _units = {};

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
  newton('N', 1, mass: 1, length: 1, time: -2);

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
