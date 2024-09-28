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
        // FunValue(:final args, :final body) => FunValue(
        //     args,
        //     OperatorExpr(
        //       ValueExpr(other),
        //       Operator.mul,
        //       body,
        //     ),
        //   ),
        // DartFunctionValue(:final args, :final function) => FunValue(
        //     args,
        //     OperatorExpr(
        //       ValueExpr(other),
        //       Operator.mul,
        //       SequencialExpr(
        //         ValueExpr(other),
        //         SequenceExpr(args),
        //       ),
        //     ),
        //   ),
        VectorValue(:final values) => VectorValue(
            values.map((v) => v.mul(this)).toList(),
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
          '${ConsoleColors.gray('[', color)}${ConsoleColors.purple(unitString, color)}${ConsoleColors.gray(']', color)}';
    }
    if (value is FloatNumber) {
      final num = value.toNum().toDouble();
      final postfix = ConsoleColors.blue('?', color);
      if (num.isNegative) {
        final numString = ConsoleColors.blue((-num).toString(), color);
        final negSign = ConsoleColors.blue('-', color);
        return '$negSign$numString$postfix$unitString';
      } else {
        final numString = ConsoleColors.blue(num.toString(), color);
        return '$numString$postfix$unitString';
      }
    } else if (value.isInteger) {
      final valueString = ConsoleColors.blue(value.toString(), color);
      return '$valueString$unitString';
    } else {
      final valueString = ConsoleColors.blue(value.toString(), color);
      final valueNumString =
          ConsoleColors.blue(value.toNum().toString(), color);
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
