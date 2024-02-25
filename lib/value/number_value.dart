// ignore_for_file: unnecessary_this

part of 'value.dart';

class NumberValue extends Value implements ValueWithUnit {
  const NumberValue(this.value, this.unitSet);

  final Number value;
  @override
  final UnitSet unitSet;

  @override
  Value add(Value other) => switch (other) {
        NumberValue(:final value, :final unitSet) => NumberValue(
            this.value + _unitsConvertMultiplier(this.unitSet, unitSet, value),
            _checkUnitsEq(this.unitSet, unitSet),
          ),
        _ => super.add(other),
      };

  @override
  Value sub(Value other) => switch (other) {
        NumberValue(:final value, :final unitSet) => NumberValue(
            this.value - _unitsConvertMultiplier(this.unitSet, unitSet, value),
            _checkUnitsEq(this.unitSet, unitSet),
          ),
        _ => super.sub(other),
      };

  @override
  Value mul(Value other) => switch (other) {
        NumberValue(:final value, :final unitSet) => NumberValue(
            this.value * _unitsConvertMultiplier(this.unitSet, unitSet, value),
            this.unitSet + unitSet,
          ),
        _ => super.mul(other),
      };

  @override
  Value div(Value other) => switch (other) {
        NumberValue(:final value, :final unitSet) => NumberValue(
            this.value / _unitsConvertMultiplier(this.unitSet, unitSet, value),
            this.unitSet - unitSet,
          ),
        _ => super.div(other),
      };

  @override
  Value mod(Value other) => switch (other) {
        NumberValue(:final value, :final unitSet) => NumberValue(
            this.value % _unitsConvertMultiplier(this.unitSet, unitSet, value),
            _checkUnitsEq(this.unitSet, unitSet),
          ),
        _ => super.mod(other),
      };

  @override
  Value pow(Value other) {
    switch (other) {
      case NumberValue(:final value, :final unitSet):
        if (unitSet.isEmpty) {
          return NumberValue(
            this.value.pow(value),
            UnitSet.empty,
          );
        } else {
          throw MyError.unexpectedUnit('', unitSet.toString());
        }
      default:
        return super.pow(other);
    }
  }

  @override
  Value lt(Value other) {
    switch (other) {
      case NumberValue(:final value, :final unitSet):
        _checkUnitsEq(this.unitSet, unitSet);
        return this.value < value;
      default:
        return super.gte(other);
    }
  }

  @override
  Value lte(Value other) {
    switch (other) {
      case NumberValue(:final value, :final unitSet):
        _checkUnitsEq(this.unitSet, unitSet);
        return this.value <= value;
      default:
        return super.gte(other);
    }
  }

  @override
  Value gt(Value other) {
    switch (other) {
      case NumberValue(:final value, :final unitSet):
        _checkUnitsEq(this.unitSet, unitSet);
        return this.value > value;
      default:
        return super.gte(other);
    }
  }

  @override
  Value gte(Value other) {
    switch (other) {
      case NumberValue(:final value, :final unitSet):
        _checkUnitsEq(this.unitSet, unitSet);
        return this.value >= value;
      default:
        return super.gte(other);
    }
  }

  @override
  String toString() {
    if (value.isInteger) {
      return value.toString();
    } else {
      return value.toNum().toString();
    }
  }

  @override
  String toPrettyString() {
    if (value is FloatNumber) {
      final num = value.toNum().toDouble();
      if (num.isNegative) {
        return '-0f${-num}$unitSet';
      } else {
        return '0f$num$unitSet';
      }
    } else if (value.isInteger) {
      return '$value$unitSet';
    } else {
      final valueString = value.toString();
      if (valueString.length > 20) {
        return '${value.toNum()}$unitSet';
      }
      return '$valueString$unitSet ≈ ${value.toNum()}$unitSet';
    }
  }

  @override
  Value neg() => NumberValue(-value, unitSet);

  static final zero = NumberValue(Number.zero, UnitSet.empty);

  static final one = NumberValue(Number.one, UnitSet.empty);

  @override
  String get type => 'number';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumberValue &&
          (value == other.value && unitSet == other.unitSet ||
              unitSet.dimensions == other.unitSet.dimensions &&
                  value * Number.fromNum(unitSet.multiplier) ==
                      other.value * Number.fromNum(other.unitSet.multiplier));

  @override
  int get hashCode => value.hashCode ^ unitSet.hashCode;
}

UnitSet _checkUnitsEq(UnitSet left, UnitSet right) {
  if (left.dimensions == right.dimensions) {
    return left; // also return a multiplier
  } else {
    throw MyError.unexpectedUnit(left.toString(), right.toString());
  }
}

Number _unitsConvertMultiplier(UnitSet left, UnitSet right, Number value) {
  if (left.isEmpty || right.isEmpty) {
    return value;
  }
  final normalized =
      (value + Number.fromNum(right.offset)) * Number.fromNum(right.multiplier);
  return normalized / Number.fromNum(left.multiplier) -
      Number.fromNum(left.offset);
}
