# TypeCheck

## Overview

A hallmark feature of Smalltalk is that any object can be
passed as an argument to any method and it's only wrong if
the object does not support every message that is sent to it.
When this is not the case, a "MessageNotUnderstood" error is raised.
While this is beautiful in theory, in practice it would nice if
a more explicit error was raised, perhaps one like the following:

```text
age: ageNumber must be a kind of Number but was String"
```

This is a Cuis Smalltalk package that provides
run-time type checking of arguments in keyword methods.
When arguments with unexpected types are passed,
errors like the one above are raised.

This relies on including a class name at the end of argument names.
In order for an argument to be type checked,
the first letter in the class name must be uppercase
and it must be the first uppercase letter in the argument name.
For example, consider the following method signature in the `Dog` class.

```smalltalk
purchaseBreed: breedString color: colorSymbol age: ageNumber
```

Arguments whose names do not end in a known class
(or one of the supported abbreviations described later)
will not be type checked.

To perform type checking each time a method is executed,
add `TypeCheck check.` near the beginning of the method code.
This will verify that:

- the type of `breedString` values is `String` or any subclass
- the type of `colorSymbol` values is `Symbol` or any subclass
- the type of `ageNumber` values is `Number` or any subclass

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
