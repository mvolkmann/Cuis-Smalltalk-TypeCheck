# TypeCheck

## Overview

This is a package for Cuis Smalltalk that provides
run-time type checking of arguments in keyword methods.

It relies on including a class name at the end of argument names.
The first letter in the class name must be uppercase
and it must be the first uppercase letter in the argument name.
For example, consider the following method signature in the `Dog` class.

```smalltalk
purchaseBreed: breedString color: colorSymbol age: ageNumber
```

To perform type checking each time a method is executed,
add `TypeCheck check.` near the beginning of the method code.
This will verify that:

- the type of `breedString` values is `String` or any subclass
- the type of `colorSymbol` values is `Symbol` or any subclass
- the type of `ageNumber` values is `Number` or any subclass

If any of these type checks are violated,
an error will be raised with a message like
"age: ageNumber must be a kind of Number but was String".

## Enabling and Disabling

Type checking is disabled by default,
so adding this will not incur a performance penalty.

To enable type checking, enter `TypeCheck enable` in a Workspace and "Do it".

To disable type checking, enter `TypeCheck disable` in a Workspace and "Do it".

## Is This Needed?

Of course you don't need argument type checking.
You can just rely on "MessageNotUnderstood" errors.
But the errors raised by this package are much more descriptive and
can be very helpful during early development of a new application/package.

## Abbreviations for Common Classes

It can be verbose to include the names of
some commonly used classes in argument names.
In order to keep the names to a reasonable length,
the following abbreviations are supported:

- Coll for Collection
- Dict for Dictionary
- IdDict for IdentityDictionary
- Ord for OrderedCollection
- Seq for SequenceableCollection
- Sorted for SortedCollection
