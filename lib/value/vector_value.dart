part of 'value.dart';

class VectorValue extends Value {
  // ignore: avoid_positional_boolean_parameters
  const VectorValue(this.value);
  final List<Value> value;

  @override
  Value sub(Value other) {
    if (other is VectorValue) {
      if (other.value.length != value.length) {
        throw ArgumentError(
          'Cannot sub vectors of different lengths: ${value.length} and ${other.value.length}',
        );
      }
      return VectorValue([
        for (var i = 0; i < value.length; i++) value[i].sub(other.value[i]),
      ]);
    }
    return super.sub(other);
  }

  @override
  Value add(Value other) {
    if (other is VectorValue) {
      if (other.value.length != value.length) {
        throw ArgumentError(
          'Cannot add vectors of different lengths: ${value.length} and ${other.value.length}',
        );
      }
      return VectorValue([
        for (var i = 0; i < value.length; i++) value[i].add(other.value[i]),
      ]);
    }
    return super.add(other);
  }

  @override
  Value mul(Value other) {
    if (other is VectorValue) {
      if (other.value.length != value.length) {
        throw ArgumentError(
          'Cannot add vectors of different lengths: ${value.length} and ${other.value.length}',
        );
      }
      var sum = NumberValue.zero;
      for (var i = 0; i < value.length; i++) {
        sum = sum.add(value[i].mul(other.value[i])) as NumberValue;
      }
      return sum;
    }
    return super.mul(other);
  }

  @override
  Value getProperty(String name) {
    return switch (name) {
      'length' => NumberValue(Number.fromInt(value.length), UnitSet.empty),
      'cross' =>
        DartFunctionValue.from1Param((state, arg) => _cross(arg), 'other'),
      _ => throw MyError.propertyAccessError(this, name),
    };
  }

  Value _cross(Value other) {
    if (other is VectorValue) {
      if (other.value.length != value.length) {
        throw ArgumentError(
          'Cannot cross vectors of different lengths: ${value.length} and ${other.value.length}',
        );
      }
      if (value.length != 3) {
        throw ArgumentError(
          'Cannot cross vectors of length ${value.length}',
        );
      }
      return VectorValue([
        value[1].mul(other.value[2]).sub(value[2].mul(other.value[1])),
        value[2].mul(other.value[0]).sub(value[0].mul(other.value[2])),
        value[0].mul(other.value[1]).sub(value[1].mul(other.value[0])),
      ]);
    }
    return super.mul(other);
  }

  @override
  String toString() => '<${value.join(', ')}>';

  @override
  String get type => 'vector';

  @override
  List<Object> get props => [value];
}
