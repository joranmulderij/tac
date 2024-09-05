# Number

The `number` type in TAC is used for integers and decimal number.
Numbers are preferably stored as infinite precision numbers.
These are internally stored as a ratio of two arbirary size integers.
Some numbers cannot be stored as a ratio, such as `sqrt(2)`. These are stored as floating point numbers.
