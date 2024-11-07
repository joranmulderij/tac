# TAC Advanced Calculator

## About TAC

TAC stands for "TAC Advanced Calculator". It is a command line calculator geared towards scientific and engineering applications.

## Defining Features

- Infinite precision numbers
- Units
- Variables
- Functions
- Vectors

## Basic syntax

The basic syntax of TAC is very intuitive:

```javascript
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

```javascript
> 1[meter]
1[m]
> 1[m] + 2[m]
3[m]
> 1[m-1] + 2[m-1]
3[m]
> 1[m s-1]
1[m s-1]
```

Numbers with units can be multiplied. Then the units are handled automatically.

```javascript
> 1m * 2m
2[m2]
> 1m * 2m s^-1
2[m2 s-1]
```

They can also be converted to other units with equal dimensions.

```javascript
> 1[m] -> [cm]
100[cm]
> 1[m] -> [km]
0.001[km]
```

## Variables

Variables can be defined and used in calculations.

```javascript
> a = 1
1
> b = 2
2
> a + b
3
```

## Functions

Functions can be defined in multiple ways. The `=>` operator is used to define a lambda function. Alternatively the `f(x) =` syntax can be used to define a function. This is an example of the language being math and engineering oriented.

```javascript
> f = (x) => x^2
> f(x) = x^2
> f(2)
4
```

## Types

### Number

The `number` type in TAC is used for integers and decimal number.
Numbers are preferably stored as infinite precision numbers.
These are internally stored as a ratio of two arbirary size integers.
Some numbers cannot be stored as a ratio, such as `sqrt(2)`. These are stored as floating point numbers.
Floating point numbers are indicated by a question mark at the end of the number.

```javascript
> 1
1
> 1.0
1
> 1/3
1/3 ≈ 0.3333333333333333
> sqrt(2)
1.4142135623730951?
```
