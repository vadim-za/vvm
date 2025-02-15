- See also [`Instruction set docs`](instruction_set.md)
- See also [`Command line docs`](command_line.md)
- See [`asm/examples`](asm/examples) for real examples

## Syntax and semantics

- Label definitions must be positioned at the very beginning of the line, start with a letter and continue with letters/digits (no underscore). Maximum length is 8 characters. Case-sensitive. Must contain `:` at the end.

- Assembler commands must start after the beginning of the line (after some whitespace and/or a label definition). They are case-insensitive.

- Register operands of assembler commands are case-insensitive.

- Byte and word operands can be expressions involving integer literals, string literals and label literals. These can be combined using unary and binary `+` and `-` operations, as well as parentheses. The expressions are computed in 16 bit 2's complement wrapping arithmetic and then, if necessary, truncated to a smaller size.

- Integer literals can be decimal or hex (the latter are prefixed with `$`)

- String literals are enclosed in apostrophes. Currently you cannot "escape" an apostrophe within a string, you need to find another way to get it in there (e.g. use the `.DB` metacommand)

- Metacommands are like normal assembler commands, but prefixed with the '.'

| Metacommand | Semantics |
| ----------- | --------- |
| .DB Byte | Put `Byte` into the machine code |
| .DW Word | Put `Word` (low byte, then high byte) into the machine code |
| .DS StringLiteral | Put string literal's byte into the machine code |
| .REP (N) Metacommand | Repeat the metacommand N times |
| .ORG N | Set the formal current address to N |

- String literals are not zero terminated, you need to manually add `.DB 0` at the end if you have to.
- `N' must be an integer literal (general form expressions not supported)
