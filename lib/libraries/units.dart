import 'package:tac/units/unit.dart';
import 'package:tac/units/unitset.dart';
import 'package:tac/utils/errors.dart';
import 'package:tac/value/value.dart';

final unitsLibrary = {
  'siUnit': _siUnit,
  'baseUnit': _baseUnit,
  // TODO: explainUnit, explainDimension
};

final _siUnitMap = {
  Unit.mass: const UnitSet({Unit.kiloGram: 1}),
  Unit.length: const UnitSet({Unit.meter: 1}),
  Unit.time: const UnitSet({Unit.second: 1}),
  Unit.current: const UnitSet({Unit.ampere: 1}),
  Unit.temperature: const UnitSet({Unit.kelvin: 1}),
  Unit.force: const UnitSet({Unit.newton: 1}),
  Unit.pressure: const UnitSet({Unit.pascal: 1}),
  Unit.power: const UnitSet({Unit.watt: 1}),
  Unit.energy: const UnitSet({Unit.joule: 1}),
  Unit.velocity: const UnitSet({Unit.meter: 1, Unit.second: -1}),
  Unit.acceleration: const UnitSet({Unit.meter: 1, Unit.second: -2}),
  Unit.frequency: const UnitSet({Unit.hertz: 1}),
};

final _siUnit = DartFunctionValue.from1Param(
  (state, arg) async {
    if (arg case NumberValue(:final unitSet)) {
      final dimention = unitSet.dimensions;
      final normalizedUnit = _siUnitMap[dimention];
      if (normalizedUnit == null) {
        throw MyError('No SI unit for dimension $dimention');
      }
      final number = arg.convertToUnit(normalizedUnit);
      return NumberValue(number, normalizedUnit);
    } else {
      throw MyError.unexpectedType('number', arg.type);
    }
  },
  'number',
);

final _baseUnit = DartFunctionValue.from1Param(
  (state, arg) async {
    if (arg case NumberValue(:final unitSet)) {
      final dimension = unitSet.dimensions;
      final normalizedUnit = UnitSet({
        if (dimension.mass != 0) Unit.kiloGram: dimension.mass,
        if (dimension.length != 0) Unit.meter: dimension.length,
        if (dimension.time != 0) Unit.second: dimension.time,
        if (dimension.current != 0) Unit.ampere: dimension.current,
        if (dimension.temperature != 0) Unit.kelvin: dimension.temperature,
      });
      final number = arg.convertToUnit(normalizedUnit);
      return NumberValue(number, normalizedUnit);
    } else {
      throw MyError.unexpectedType('number', arg.type);
    }
  },
  'number',
);
