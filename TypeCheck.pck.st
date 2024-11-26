'From Cuis7.1 [latest update: #6817] on 26 November 2024 at 6:04:30 am'!
'Description '!
!provides: 'TypeCheck' 1 6!
SystemOrganization addCategory: #TypeCheck!


!classDefinition: #TypeCheck category: #TypeCheck!
Object subclass: #TypeCheck
	instanceVariableNames: ''
	classVariableNames: 'Enabled'
	poolDictionaries: ''
	category: 'TypeCheck'!
!classDefinition: 'TypeCheck class' category: #TypeCheck!
TypeCheck class
	instanceVariableNames: ''!


!TypeCheck class methodsFor: 'accessing' stamp: 'RMV 11/24/2024 18:21:02'!
disable
	Enabled := false.! !

!TypeCheck class methodsFor: 'accessing' stamp: 'RMV 11/24/2024 18:20:55'!
enable
	Enabled := true.! !

!TypeCheck class methodsFor: 'class initialization' stamp: 'RMV 11/24/2024 18:22:38'!
initialize
	Enabled := false.! !

!TypeCheck class methodsFor: 'class initialization' stamp: 'RMV 11/26/2024 06:04:12'!
parseDemo
	| block code methodNode parser |
	
	code := '
	sumOf: firstNumber and: secondNumber
		"Answer the sum of two numbers."
		| sum |

		"This demonstrates using backticks for a compile-time expression."
		sum := `2 + 3`.

		sum := firstNumber + secondNumber.
		^ sum.
	'.
	parser := Parser new.
	methodNode := parser parse: code class: TypeCheck.
	block := methodNode block.
	Transcript clear.
	"TODO: Recursively print the statements in each statement with increasing indentation."
	block statements do: [:statement |
		Transcript newLine.
		statement class name print.
		statement printSourceCode print.
	].
	
! !

!TypeCheck class methodsFor: 'utility' stamp: 'RMV 11/25/2024 18:25:34'!
argNamesinReceiver: anObject selector: selectorSymbol
	"Answer an OrderedCollection of the argument names in a given method."
	| argNodes code implementor methodNode |
	
	implementor := anObject class lookupClassImplementingSelector: selectorSymbol.
	code := implementor sourceCodeAt: selectorSymbol.
	methodNode := Parser new parse: code class: implementor.
	argNodes := methodNode arguments.
	^ argNodes collect: [:node | node name].! !

!TypeCheck class methodsFor: 'utility' stamp: 'RMV 11/25/2024 18:25:53'!
check
	"Raise error if any argument has the wrong type."
	| argNames argValues keywords receiver selector sender |
	
	Enabled ifFalse: [^self].

	sender := thisContext sender.
	receiver := thisContext sender receiver.
	selector := sender selector.
	keywords := selector keywords.
	argNames := self argNamesinReceiver: receiver selector: selector.
	argValues := sender arguments.
		
	argNames withIndexDo: [:argName :index |
		| class className |
		className := argName substringFromFirstUpper asSymbol.
		class := self classFromName: className.
		class ifNotNil: [
			| argValue keyword |
			keyword := keywords at: index.
			argValue := argValues at: index.
			argValue isKindOf: class :: ifFalse: [
				| template values |
				template := '{1} {2} must be kind of {3} but was {4}'.
				values := {keyword. argName. className. argValue class name}.
				Error signal: (template format: values).
			].
		]
	].! !

!TypeCheck class methodsFor: 'utility' stamp: 'RMV 11/24/2024 15:29:17'!
classFromName: nameSymbol
	"Answer class object corresponding to a class name string."
	| class globalDict |

	globalDict := Smalltalk globals at: #Smalltalk.
	class := globalDict at: nameSymbol ifAbsent: nil.
	
	class ifNil: [
		| className |
		className := nameSymbol caseOf: {
			[#Coll] -> [#Collection].
			[#Dict] -> [#Dictionary].
			[#IdDict] -> [#IdentityDictionary].
			[#Ord] -> [#OrderedCollection].
			[#Seq] -> [#SequenceableCollection].
			[#Sorted] -> [#SortedCollection].
		} otherwise: nil.
		className ifNotNil: [
			class := globalDict at: className ifAbsent: nil.
		]
	].
		
	^class.! !

!Object methodsFor: '*TypeCheck' stamp: 'RMV 11/25/2024 08:39:47'!
logAs: aString
	"Writes logging information about receiver to the Transcript."
	| message sender template |

	sender := thisContext sender.
	template := 'In {1}, {2} is a {3} = {4}'.
	message := template format: {sender. aString. self class name. self}.
	message print.! !

!Object methodsFor: '*TypeCheck' stamp: 'RMV 11/21/2024 18:31:44'!
validateAssoc
	"Raise error if self is not an Association object."

	self isKindOf: Association ::
		ifFalse: [Error signal: 'requires Association object'].! !

!Object methodsFor: '*TypeCheck' stamp: 'RMV 11/22/2024 18:53:57'!
validateAssocSeq
	"Raise error if self is not a SequenceableCollection of Association objects."

	self validateSeq.

	self allSatisfy: [:element | element isKindOf: Association] ::
		ifFalse: [Error signal: 'requires SequenceableCollection of Association objects'].! !

!Object methodsFor: '*TypeCheck' stamp: 'RMV 11/22/2024 18:54:27'!
validateSeq
	"Raise error if anObject is not a SequenceableCollection."

	self isCollection and: [self isSequenceable] ::
		ifFalse: [Error signal: 'requires SequenceableCollection like Array'].! !

!Behavior methodsFor: '*TypeCheck' stamp: 'RMV 11/23/2024 21:21:57'!
lookupClassImplementingSelector: selectorSymbol
	"Look up the given selector in my methodDictionary.
	Return the class that implements it if found.
	Otherwise chase the superclass chain and try again.
	Return nil if no implementing class is found."
	| class |

	class := self.
	[class == nil] whileFalse: [
		class includesSelector: selectorSymbol :: ifTrue: [^ class].
		class := class superclass
	].
	^ nil! !
TypeCheck initialize!
