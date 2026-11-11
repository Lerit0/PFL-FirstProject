# PFL – First Project

Project for the course **PFL – Programação Funcional e Lógica** (FEUP, 3rd year).

## What `main.hs` does

`main.hs` is a Haskell program that reads propositional logic formulas, one per line, from standard input and classifies each one as:

- **TAUTOLOGY**: true for every assignment of its variables
- **CONTRADICTION**: false for every assignment
- **CONTINGENT**: neither of the above

If a line can't be parsed, it prints `parse error; try again`.

## How it works

1. **Representation**: formulas are values of the `Prop` data type (`Const`, `Var`, `And`, `Or`, `Not`).
2. **Parsing (Task 1)**: a recursive-descent parser built with the `Parsing` module follows this grammar:

   ```
   prop      ::= term propCont
   propCont  ::= '|' term propCont | ε
   term      ::= factor termCont
   termCont  ::= '&' factor termCont | ε
   factor    ::= '!' factor | constant | '(' prop ')' | name
   constant  ::= 'T' | 'F'
   ```

   So `!` binds tightest, then `&`, then `|`. Both binary operators are left-associative.
3. **Evaluation**: `vars` collects the distinct variables in a formula, `environments` builds every True/False assignment for them (the truth table), and `eval` evaluates the formula under one assignment.
4. **Classification (Task 2)**: `classify` checks whether the formula is true in all, none, or some of those assignments.

## Syntax notes

- Variables are single characters (e.g. `a`, `p`). `T` and `F` are reserved for the constants true and false.
- Whitespace isn't supported, so write formulas without spaces.

## Example

```
$ runghc main.hs
a|!a
TAUTOLOGY
a&!a
CONTRADICTION
(a|b)&c
CONTINGENT
```