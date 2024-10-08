import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:rational/rational.dart';
import 'package:tac/utils/errors.dart';
import 'package:tac/value/value.dart';

@immutable
sealed class Number {
  const Number();

  factory Number.fromInt(int value) => RationalNumber(Rational.fromInt(value));

  factory Number.fromDouble(double value) =>
      FloatNumber(double.parse(value.toString()));

  factory Number.fromNum(num value) => switch (value) {
        int() => Number.fromInt(value),
        double() => Number.fromDouble(value),
      };

  factory Number.fromString(String source) =>
      RationalNumber(Rational.parse(source));

  num toNum();
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
  @override
  bool operator ==(Object other);
  @override
  int get hashCode;
  Number operator -();
  Number pow(Number other);

  static final Number zero = RationalNumber(Rational.zero);
  static final Number one = RationalNumber(Rational.one);
}

class RationalNumber extends Number {
  const RationalNumber(this._value);

  final Rational _value;

  @override
  num toNum() =>
      _value.isInteger ? _value.toBigInt().toInt() : _value.toDouble();

  @override
  int toInt() {
    if (!isInteger) {
      throw MyError.notAnInteger();
    }
    return _value.toBigInt().toInt();
  }

  @override
  bool get isInteger => _value.isInteger;

  @override
  Number operator +(Number other) => switch (other) {
        RationalNumber(_value: final value) => RationalNumber(_value + value),
        FloatNumber(_value: final value) =>
          FloatNumber(_value.toDouble() + value),
      };

  @override
  Number operator -(Number other) => switch (other) {
        RationalNumber(_value: final value) => RationalNumber(_value - value),
        FloatNumber(_value: final value) =>
          FloatNumber(_value.toDouble() - value),
      };

  @override
  Number operator *(Number other) => switch (other) {
        RationalNumber(_value: final value) => RationalNumber(_value * value),
        FloatNumber(_value: final value) =>
          FloatNumber(_value.toDouble() * value),
      };

  @override
  Number operator /(Number other) => switch (other) {
        RationalNumber(_value: final value) when value == Rational.zero =>
          throw MyError.divisionByZero(),
        RationalNumber(_value: final value) => RationalNumber(_value / value),
        FloatNumber(_value: final value) =>
          FloatNumber(_value.toDouble() / value),
      };

  @override
  Number operator %(Number other) => switch (other) {
        RationalNumber(_value: final value) => RationalNumber(_value % value),
        FloatNumber(_value: final value) =>
          FloatNumber(_value.toDouble() % value),
      };

  @override
  Number pow(Number other) => switch (other) {
        RationalNumber(_value: final value) => value.isInteger
            ? RationalNumber(_value.pow(value.toBigInt().toInt()))
            : FloatNumber(math.pow(_value.toDouble(), value.toDouble())),
        FloatNumber(_value: final value) =>
          FloatNumber(math.pow(_value.toDouble(), value).toDouble()),
      };

  @override
  BoolValue operator <(Number other) => switch (other) {
        RationalNumber(_value: final value) => BoolValue(_value < value),
        FloatNumber(_value: final value) =>
          BoolValue(_value.toDouble() < value),
      };

  @override
  BoolValue operator >(Number other) => switch (other) {
        RationalNumber(_value: final value) => BoolValue(_value > value),
        FloatNumber(_value: final value) =>
          BoolValue(_value.toDouble() > value),
      };

  @override
  BoolValue operator <=(Number other) => switch (other) {
        RationalNumber(_value: final value) => BoolValue(_value <= value),
        FloatNumber(_value: final value) =>
          BoolValue(_value.toDouble() <= value),
      };

  @override
  BoolValue operator >=(Number other) => switch (other) {
        RationalNumber(_value: final value) => BoolValue(_value >= value),
        FloatNumber(_value: final value) =>
          BoolValue(_value.toDouble() >= value),
      };

  @override
  Number operator -() => RationalNumber(-_value);

  @override
  String toString() => _value.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RationalNumber && other._value == _value);

  @override
  int get hashCode => _value.hashCode;
}

class FloatNumber extends Number {
  const FloatNumber(this._value);

  final num _value;

  @override
  num toNum() => _value;

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
          FloatNumber(_value + value.toDouble()),
        FloatNumber(_value: final value) => FloatNumber(_value + value),
      };

  @override
  Number operator -(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          FloatNumber(_value - value.toDouble()),
        FloatNumber(_value: final value) => FloatNumber(_value - value),
      };

  @override
  Number operator *(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          FloatNumber(_value * value.toDouble()),
        FloatNumber(_value: final value) => FloatNumber(_value * value),
      };

  @override
  Number operator /(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          FloatNumber(_value / value.toDouble()),
        FloatNumber(_value: final value) => FloatNumber(_value / value),
      };

  @override
  Number operator %(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          FloatNumber(_value % value.toDouble()),
        FloatNumber(_value: final value) => FloatNumber(_value % value),
      };

  @override
  Number pow(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          FloatNumber(math.pow(_value, value.toDouble()).toDouble()),
        FloatNumber(_value: final value) =>
          FloatNumber(math.pow(_value, value).toDouble()),
      };

  @override
  BoolValue operator <(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          BoolValue(_value < value.toDouble()),
        FloatNumber(_value: final value) => BoolValue(_value < value),
      };

  @override
  BoolValue operator >(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          BoolValue(_value > value.toDouble()),
        FloatNumber(_value: final value) => BoolValue(_value > value),
      };

  @override
  BoolValue operator <=(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          BoolValue(_value <= value.toDouble()),
        FloatNumber(_value: final value) => BoolValue(_value <= value),
      };

  @override
  BoolValue operator >=(Number other) => switch (other) {
        RationalNumber(_value: final value) =>
          BoolValue(_value >= value.toDouble()),
        FloatNumber(_value: final value) => BoolValue(_value >= value),
      };

  @override
  Number operator -() => FloatNumber(-_value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FloatNumber && other._value == _value);

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => '$_value?';
}
