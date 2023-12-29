import 'dart:math' as math;

import 'package:rational/rational.dart';
import 'package:tac_dart/value/value.dart';

sealed class Number {
  const Number();

  factory Number.fromInt(int value) => RationalNumber(Rational.fromInt(value));

  factory Number.fromString(String source) =>
      RationalNumber(Rational.parse(source));

  double toDouble();
  int toInt();
  bool get isInteger;

  Number operator +(Number other);
  Number operator -(Number other);
  Number operator *(Number other);
  Number operator /(Number other);
  Number operator %(Number other);
  BoolValue operator <(Number other);
  BoolValue operator >(Number other);
  BoolValue operator <=(Number other);
  BoolValue operator >=(Number other);
  Number operator -();
  Number pow(Number other);

  static final Number zero = RationalNumber(Rational.zero);
  static final Number one = RationalNumber(Rational.one);
}

class RationalNumber implements Number {
  const RationalNumber(this._value);

  final Rational _value;

  @override
  double toDouble() => _value.toDouble();

  @override
  int toInt() {
    if (!isInteger) throw Exception('Not an integer');
    return _value.toBigInt().toInt();
  }

  @override
  bool get isInteger => _value.isInteger;

  @override
  Number operator +(Number other) => switch (other) {
        RationalNumber(_value: final value) => RationalNumber(_value + value),
        DoubleNumber(_value: final value) =>
          DoubleNumber(_value.toDouble() + value),
      };

  @override
  Number operator -(Number other) => switch (other) {
        RationalNumber(_value: final value) => RationalNumber(_value - value),
        DoubleNumber(_value: final value) =>
          DoubleNumber(_value.toDouble() - value),
      };

  @override
  Number operator *(Number other) => switch (other) {
        RationalNumber(_value: final value) => RationalNumber(_value * value),
        DoubleNumber(_value: final value) =>
          DoubleNumber(_value.toDouble() * value),
      };

  @override
  Number operator /(Number other) => switch (other) {
        RationalNumber(_value: final value) => RationalNumber(_value / value),
        DoubleNumber(_value: final value) =>
          DoubleNumber(_value.toDouble() / value),
      };

  @override
  Number operator %(Number other) => switch (other) {
        RationalNumber(_value: final value) => RationalNumber(_value % value),
        DoubleNumber(_value: final value) =>
          DoubleNumber(_value.toDouble() % value),
      };

  @override
  Number pow(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          RationalNumber(_value.pow(value.toBigInt().toInt())),
        DoubleNumber(_value: final value) =>
          DoubleNumber(math.pow(_value.toDouble(), value.toInt()).toDouble()),
      };

  @override
  BoolValue operator <(Number other) => switch (other) {
        RationalNumber(_value: final value) => BoolValue(_value < value),
        DoubleNumber(_value: final value) =>
          BoolValue(_value.toDouble() < value),
      };

  @override
  BoolValue operator >(Number other) => switch (other) {
        RationalNumber(_value: final value) => BoolValue(_value > value),
        DoubleNumber(_value: final value) =>
          BoolValue(_value.toDouble() > value),
      };

  @override
  BoolValue operator <=(Number other) => switch (other) {
        RationalNumber(_value: final value) => BoolValue(_value <= value),
        DoubleNumber(_value: final value) =>
          BoolValue(_value.toDouble() <= value),
      };

  @override
  BoolValue operator >=(Number other) => switch (other) {
        RationalNumber(_value: final value) => BoolValue(_value >= value),
        DoubleNumber(_value: final value) =>
          BoolValue(_value.toDouble() >= value),
      };

  @override
  Number operator -() => RationalNumber(-_value);

  @override
  String toString() => _value.toString();
}

class DoubleNumber implements Number {
  const DoubleNumber(this._value);

  final double _value;

  @override
  double toDouble() => _value;

  @override
  int toInt() {
    if (!isInteger) throw Exception('Not an integer');
    return _value.toInt();
  }

  @override
  // TODO: check if this works
  bool get isInteger => _value == _value.toInt();

  @override
  Number operator +(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          DoubleNumber(_value + value.toDouble()),
        DoubleNumber(_value: final value) => DoubleNumber(_value + value),
      };

  @override
  Number operator -(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          DoubleNumber(_value - value.toDouble()),
        DoubleNumber(_value: final value) => DoubleNumber(_value - value),
      };

  @override
  Number operator *(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          DoubleNumber(_value * value.toDouble()),
        DoubleNumber(_value: final value) => DoubleNumber(_value * value),
      };

  @override
  Number operator /(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          DoubleNumber(_value / value.toDouble()),
        DoubleNumber(_value: final value) => DoubleNumber(_value / value),
      };

  @override
  Number operator %(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          DoubleNumber(_value % value.toDouble()),
        DoubleNumber(_value: final value) => DoubleNumber(_value % value),
      };

  @override
  Number pow(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          DoubleNumber(math.pow(_value, value.toDouble()).toDouble()),
        DoubleNumber(_value: final value) =>
          DoubleNumber(math.pow(_value, value).toDouble()),
      };

  @override
  BoolValue operator <(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          BoolValue(_value < value.toDouble()),
        DoubleNumber(_value: final value) => BoolValue(_value < value),
      };

  @override
  BoolValue operator >(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          BoolValue(_value > value.toDouble()),
        DoubleNumber(_value: final value) => BoolValue(_value > value),
      };

  @override
  BoolValue operator <=(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          BoolValue(_value <= value.toDouble()),
        DoubleNumber(_value: final value) => BoolValue(_value <= value),
      };

  @override
  BoolValue operator >=(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          BoolValue(_value >= value.toDouble()),
        DoubleNumber(_value: final value) => BoolValue(_value >= value),
      };

  @override
  Number operator -() => DoubleNumber(-_value);

  @override
  String toString() => _value.toString();
}
