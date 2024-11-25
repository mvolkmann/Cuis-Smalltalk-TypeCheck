# TypeCheck

This is a package for Cuis Smalltalk that provides
run-time type checking of arguments in keyword methods.

It relies on including a class name at the end of argument names.
For example, consider the following method signature in the `Dog` class.

```smalltalk
purchaseBreed: breedString color: colorSymbol age: ageNumber
```

To add type checking, add `TypeCheck check.` at the beginning of the method code.
This will verify that:
- the type of `breedString` values is `String` or any subclass
- the type of `colorSymbol` values is `Symbol` or any subclass
- the type of `age` values is `Number` or any subclass

If any of these are violated, an error will be raised with a message like
"someKeyword: someArgument must be a kind of Number but was String".s

Type checking is disabled by default, so adding this will not incur a performance penalty.

To enable type checking, enter `TypeCheck enable` in a Workspace and "Do it".

To disable type checking, enter `TypeCheck disable` in a Workspace and "Do it".

Of course you don't need this. You can also just rely on MessageNotUnderstood errors.
But the errors raised by this package are must more descriptive
and can be very helpful during early development of a new application/package.


