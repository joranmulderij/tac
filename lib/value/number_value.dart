// ignore_for_file: unnecessary_this

part of 'value.dart';

class NumberValue extends Value {
  const NumberValue(this.value, this.unitSet);

  final Rational value;
  final UnitSet unitSet;

  @override
  Value add(Value other) => switch (other) {
        NumberValue(:final value, :final unitSet) =>
          NumberValue(this.value + value, checkUnitsEq(this.unitSet, unitSet)),
        _ => super.add(other),
      };

  @override
  Value sub(Value other) => switch (other) {
        NumberValue(:final value, :final unitSet) =>
          NumberValue(this.value - value, checkUnitsEq(this.unitSet, unitSet)),
        _ => super.sub(other),
      };

  @override
  Value mul(Value other) => switch (other) {
        NumberValue(:final value, :final unitSet) =>
          NumberValue(this.value * value, this.unitSet + unitSet),
        _ => super.mul(other),
      };

  @override
  Value div(Value other) => switch (other) {
        NumberValue(:final value, :final unitSet) =>
          NumberValue(this.value / value, this.unitSet - unitSet),
        _ => super.div(other),
      };

  @override
  Value mod(Value other) => switch (other) {
        NumberValue(:final value, :final unitSet) =>
          NumberValue(this.value % value, checkUnitsEq(this.unitSet, unitSet)),
        _ => super.mod(other),
      };

  @override
  Value pow(Value other) => switch (other) {
        NumberValue(:final value, :final unitSet) => NumberValue(
            this.value.pow(value.toBigInt().toInt()),
            checkUnitsEq(this.unitSet, unitSet),
          ),
        _ => super.pow(other),
      };

  @override
  Value lt(Value other) {
    switch (other) {
      case NumberValue(:final value, :final unitSet):
        checkUnitsEq(this.unitSet, unitSet);
        return BoolValue(this.value < value);
      default:
        return super.gte(other);
    }
  }

  @override
  Value lte(Value other) {
    switch (other) {
      case NumberValue(:final value, :final unitSet):
        checkUnitsEq(this.unitSet, unitSet);
        return BoolValue(this.value <= value);
      default:
        return super.gte(other);
    }
  }

  @override
  Value gt(Value other) {
    switch (other) {
      case NumberValue(:final value, :final unitSet):
        checkUnitsEq(this.unitSet, unitSet);
        return BoolValue(this.value > value);
      default:
        return super.gte(other);
    }
  }

  @override
  Value gte(Value other) {
    switch (other) {
      case NumberValue(:final value, :final unitSet):
        checkUnitsEq(this.unitSet, unitSet);
        return BoolValue(this.value >= value);
      default:
        return super.gte(other);
    }
  }

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
      return '$value$unitSet';
    } else {
      return '$value$unitSet = ${value.toDouble()}$unitSet';
    }
  }

  @override
  Value neg() => NumberValue(-value, unitSet);

  static final zero = NumberValue(Rational.zero, UnitSet.empty);

  static final one = NumberValue(Rational.one, UnitSet.empty);

  @override
  String get type => 'number';

  @override
  List<Object> get props => [value];
}

UnitSet checkUnitsEq(UnitSet left, UnitSet right) {
  if (left == right) {
    return left;
  } else {
    throw UnitsNotEqualError(left.toString(), right.toString());
  }
}
