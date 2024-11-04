# Operator Precedence

| Precedence | Operator | Description       | Example       | Associativity |
|------------|----------|-------------------|---------------|---------------|
| 10         | `()`     | Parentheses       | `(a + b) * c` | N/A           |
| 9          | `^`      | Power             | `a ^ b`       | Right to Left |
| 8          | `*`      | Multiplication    | `a * b`       | Left to Right |
| 8          | `/`      | Division          | `a / b`       | Left to Right |
| 8          | `%`      | Modulus           | `a % b`       | Left to Right |
| 7          | `+`      | Addition          | `a + b`       | Left to Right |
| 7          | `-`      | Subtraction       | `a - b`       | Left to Right |
| 6          | `<`      | Less Than         | `a < b`       | Left to Right |
| 6          | `<=`     | Less Than or Equal| `a <= b`      | Left to Right |
| 6          | `>`      | Greater Than      | `a > b`       | Left to Right |
| 6          | `>=`     | Greater Than or Equal | `a >= b`  | Left to Right |
| 6          | `==`     | Equal             | `a == b`      | Left to Right |
| 6          | `!=`     | Not Equal         | `a != b`      | Left to Right |
| 5          | `&&`     | Logical AND       | `a && b`      | Left to Right |
| 4          | `\|\|`   | Logical OR        | `a \|\| b`    | Left to Right |
| 3          | `=`      | Assignment        | `a = b`       | Right to Left |
| 3          | `+=`     | Addition Assignment | `a += b`    | Right to Left |
| 3          | `-=`     | Subtraction Assignment | `a -= b` | Right to Left |
| 3          | `*=`     | Multiplication Assignment | `a *= b` | Right to Left |
| 3          | `/=`     | Division Assignment | `a /= b`    | Right to Left |
| 2          | `\|`     | Pipe              | `a | b`       | Left to Right |
| 2          | `\|?`    | Pipe-Where        | `a |? b`      | Left to Right |
| 2          | `->`     | Unit Convert      | `a -> b`      | Left to Right |
| 1          | `=>`     | Function Create   | `a => b`      | Right to Left |
