part of 'value.dart';

class VectorValue extends Value {
  const VectorValue(this.values);

  VectorValue.fromSingleValue(Value value)
      : values = switch (value) {
          SequenceValue(:final values) => values,
          _ => [value],
        };

  const VectorValue.empty() : values = const [];

  final List<Value> values;

  @override
  Value sub(Value other) {
    if (other is VectorValue) {
      if (other.values.length != values.length) {
        throw ArgumentError(
          'Cannot sub vectors of different lengths: ${values.length} and ${other.values.length}',
        );
      }
      return VectorValue([
        for (var i = 0; i < values.length; i++) values[i].sub(other.values[i]),
      ]);
    }
    return super.sub(other);
  }

  @override
  Value add(Value other) {
    if (other is VectorValue) {
      if (other.values.length != values.length) {
        throw ArgumentError(
          'Cannot add vectors of different lengths: ${values.length} and ${other.values.length}',
        );
      }
      return VectorValue([
        for (var i = 0; i < values.length; i++) values[i].add(other.values[i]),
      ]);
    }
    return super.add(other);
  }

  @override
  Value mul(Value other) {
    if (other is VectorValue) {
      if (other.values.length != values.length) {
        throw ArgumentError(
          'Cannot add vectors of different lengths: ${values.length} and ${other.values.length}',
        );
      }
      var sum = NumberValue.zero;
      for (var i = 0; i < values.length; i++) {
        sum = sum.add(values[i].mul(other.values[i])) as NumberValue;
      }
      return sum;
    }
    return super.mul(other);
  }

  @override
  Value getProperty(String name) {
    return switch (name) {
      'length' => NumberValue(Number.fromInt(values.length), UnitSet.empty),
      'cross' => DartFunctionValue.from1Param(
          (state, arg) async => _cross(arg),
          'other',
        ),
      _ => throw MyError.propertyAccessError(this, name),
    };
  }

  Value _cross(Value other) {
    if (other is VectorValue) {
      if (other.values.length != values.length) {
        throw ArgumentError(
          'Cannot cross vectors of different lengths: ${values.length} and ${other.values.length}',
        );
      }
      if (values.length != 3) {
        throw ArgumentError(
          'Cannot cross vectors of length ${values.length}',
        );
      }
      return VectorValue([
        values[1].mul(other.values[2]).sub(values[2].mul(other.values[1])),
        values[2].mul(other.values[0]).sub(values[0].mul(other.values[2])),
        values[0].mul(other.values[1]).sub(values[1].mul(other.values[0])),
      ]);
    }
    return super.mul(other);
  }

  @override
  String toConsoleString(bool color) =>
      '<${values.map((e) => e.toConsoleString(color)).join(', ')}>';

  @override
  String get type => 'vector';

  @override
  Future<Value> call(Tac state, List<Value> args) async {
    if (args.length != 1) {
      throw MyError.argumentLengthError(1, args.length);
    }
    final arg = args[0];
    if (arg is! NumberValue) {
      throw MyError.unexpectedType('number', arg.type);
    }
    if (!arg.value.isInteger) {
      throw MyError.notAnInteger();
    }
    final index = arg.value.toInt();
    if (index < 0 || index >= values.length) {
      throw MyError.indexOutOfBounds(index, values.length);
    }
    return values[index];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VectorValue &&
          const ListEquality<Value>().equals(values, other.values);

  @override
  int get hashCode => const ListEquality<Value>().hash(values);

  @override
  String toExpr() => '<${values.map((e) => e.toExpr()).join(',')}>';
}
