// ignore_for_file: unnecessary_this

part of 'value.dart';

class NumberValue extends Value implements ValueWithUnit {
  const NumberValue(this.value, this.unitSet);

  NumberValue.fromNum(num value, [UnitSet? unitSet])
      : value = Number.fromNum(value),
        unitSet = unitSet ?? UnitSet.empty;

  final Number value;
  @override
  final UnitSet unitSet;

  static final zero = NumberValue(Number.zero, UnitSet.empty);

  static final one = NumberValue(Number.one, UnitSet.empty);

  @override
  Value add(Value other) => switch (other) {
        NumberValue() => NumberValue(
            this.value + other.convertToUnit(this.unitSet),
            this.unitSet,
          ),
        _ => super.add(other),
      };

  @override
  Value sub(Value other) => switch (other) {
        NumberValue() => NumberValue(
            this.value - other.convertToUnit(this.unitSet),
            this.unitSet,
          ),
        _ => super.sub(other),
      };

  @override
  Value mul(Value other) => switch (other) {
        NumberValue(:final value, :final unitSet) => NumberValue(
            this.value * value,
            this.unitSet + unitSet,
          ),
        _ => super.mul(other),
      };

  @override
  Value div(Value other) => switch (other) {
        NumberValue(:final value, :final unitSet) => NumberValue(
            this.value / value,
            this.unitSet - unitSet,
          ),
        _ => super.div(other),
      };

  @override
  Value mod(Value other) => switch (other) {
        NumberValue() => NumberValue(
            this.value % other.convertToUnit(this.unitSet),
            this.unitSet,
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
    return switch (other) {
      NumberValue() => this.value < other.convertToUnit(unitSet),
      _ => super.gte(other)
    };
  }

  @override
  Value lte(Value other) {
    switch (other) {
      case NumberValue():
        return this.value <= other.convertToUnit(unitSet);
      default:
        return super.gte(other);
    }
  }

  @override
  Value gt(Value other) {
    switch (other) {
      case NumberValue():
        return this.value > other.convertToUnit(unitSet);
      default:
        return super.gte(other);
    }
  }

  @override
  Value gte(Value other) {
    switch (other) {
      case NumberValue():
        return this.value >= other.convertToUnit(unitSet);
      default:
        return super.gte(other);
    }
  }

  @override
  Value neg() => NumberValue(-value, unitSet);

  @override
  String get type => 'number';

  Number convertToUnit(UnitSet otherUnitSet) {
    if (otherUnitSet == unitSet) {
      return this.value;
    }
    if (otherUnitSet.dimensions != unitSet.dimensions) {
      throw MyError.unexpectedUnit(otherUnitSet.toString(), unitSet.toString());
    }
    final normalized = (value + otherUnitSet.offset) * unitSet.multiplier;
    final newNumber = normalized / otherUnitSet.multiplier - unitSet.offset;
    return newNumber;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumberValue &&
          (value == other.value && unitSet == other.unitSet ||
              unitSet.dimensions == other.unitSet.dimensions &&
                  value * unitSet.multiplier ==
                      other.value * other.unitSet.multiplier);

  @override
  int get hashCode => value.hashCode ^ unitSet.hashCode;

  @override
  String toConsoleString(bool color) {
    var unitString = unitSet.toString();
    if (unitString.isNotEmpty) {
      unitString =
          '${Console.gray('[', color)}${Console.purple(unitString, color)}${Console.gray(']', color)}';
    }
    if (value is FloatNumber) {
      final num = value.toNum().toDouble();
      final prefix = Console.gray('0f', color);
      if (num.isNegative) {
        final numString = Console.green((-num).toString(), color);
        final negSign = Console.green('-', color);
        return '$negSign$prefix$numString$unitString';
      } else {
        final numString = Console.green(num.toString(), color);
        return '$prefix$numString$unitString';
      }
    } else if (value.isInteger) {
      final valueString = Console.green(value.toString(), color);
      return '$valueString$unitString';
    } else {
      final valueString = Console.green(value.toString(), color);
      final valueNumString = Console.green(value.toNum().toString(), color);
      if (valueString.length > 20) {
        return '$valueNumString$unitString';
      }
      return '$valueString$unitString ≈ $valueNumString$unitString';
    }
  }

  @override
  String toString() {
    var unitString = unitSet.toString();
    if (unitString.isNotEmpty) {
      unitString = '[$unitString]';
    }
    return '$value$unitString';
  }

  @override
  String toExpr() => toString();
}
