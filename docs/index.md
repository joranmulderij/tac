## About TAC

TAC stands for "TAC Advanced Calculator". It is a command line calculator geared towards scientific and engineering applications.

## Features

- Infinite precision numbers
- Units

## Basic syntax

The basic syntax of TAC is very intuitive:

```tac
> 1 + 2
3
> 3 * 4
12
> 5 / 2
2.5
> 2 ^ 3
8
```

## Units

Units are stored as part of numbers and vectors. Units can be attached to numbers using square brackets. The exponent of the unit can be added directly after the unit.

```tac
> 1[meter]
1[m]
> 1[m] + 2[m]
3[m]
> 1[m-1] + 2[m-1]
3[m]
> 1[m s-1]
1[m s-1]
```

### Unit operations

Numbers with units can be multiplied. Then the units are handled automatically.

```tac
> 1[m] * 2[m]
2[m^2]
> 1[m] * 2[m s-1]
2[m s-1]
```

## Types

### Number

The `number` type in TAC is used for integers and decimal number.
Numbers are preferably stored as infinite precision numbers.
These are internally stored as a ratio of two arbirary size integers.
Some numbers cannot be stored as a ratio, such as `sqrt(2)`. These are stored as floating point numbers.
