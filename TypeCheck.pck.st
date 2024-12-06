'From Cuis7.1 [latest update: #6876] on 5 December 2024 at 7:01:06 pm'!
'Description '!
!provides: 'TypeCheck' 1 40!
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

!TypeCheck class methodsFor: 'class initialization' stamp: 'RMV 11/30/2024 16:26:27'!
initialize
	Enabled := false.! !

!TypeCheck class methodsFor: 'class initialization' stamp: 'RMV 11/27/2024 20:08:25'!
parseDemo
	| code methodNode parser |
	
	code := '
	rectangleAreaWidth: widthNumber height: heightNumber
		"Answer the area of a rectangle."
		| area doubleHeight doubleWidth sum |

		"This demonstrates using backticks for a compile-time expression."
		sum := `2 + 3`.

		area := widthNumber * heightNumber.
		doubleWidth := self double: widthNumber.
		doubleHeight := self double: heightNumber.
		area := doubleWidth * doubleHeight * 2.
		^ area.
	'.
	parser := Parser new.
	methodNode := parser parse: code class: TypeCheck.
	Transcript clear.
	methodNode printTree.
	
! !

!TypeCheck class methodsFor: 'class initialization' stamp: 'RMV 11/27/2024 12:18:39'!
printCodeNode: aParseNode indent: indentString
	| hasBlock nextIndent singleIndent |
	
	singleIndent := '    '.
	nextIndent := indentString, '    '.

	Transcript newLine.
	indentString, aParseNode class name :: print.
	

	aParseNode isMethodNode ifTrue: [
		Transcript show: indentString.
		aParseNode printSelectorAndArgumentsOn: Transcript.
		Transcript cr.
	] ifFalse: [
		indentString, aParseNode printSourceCode :: print.
	].

	"TODO: When the RHS of an assignment is a message send,
	how can you follow that parse tree?
	IT IS A MessageNode!!"
	aParseNode isAssignmentNode ifTrue: [
		| value |
		value := aParseNode value.
		value isMessageNode ifTrue: [
			self printCodeNode: value indent: nextIndent.

			"value receiver may be a LiteralVariableNode."
			Transcript show: nextIndent, 'receiver: '.
			value receiver printOn: Transcript.
			Transcript cr.

			"value selector may be a SpecialSelectorNode."
			Transcript show: nextIndent, 'selector: '.
			value selector printOn: Transcript indent: ''.
			Transcript cr.

			"value arguments is an Array."
			Transcript show: nextIndent, 'arguments '.
			value arguments printOn: Transcript.
			Transcript cr.
		] ifFalse: [
			indentString, 'value is a ', value class name :: print.
		].
	].

	hasBlock := aParseNode isBlockNode or: [aParseNode isMethodNode].
	hasBlock ifTrue: [
		aParseNode block statements do: [:statement |
			self printCodeNode: statement indent: nextIndent.
		]
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

!TypeCheck class methodsFor: 'utility' stamp: 'RMV 11/28/2024 09:54:18'!
classFromName: nameSymbol
	"Answer class object corresponding to a class name string."
	| class globalDict |

	globalDict := Smalltalk globals at: #Smalltalk.
	class := globalDict at: nameSymbol ifAbsent: nil.
	
	class ifNil: [
		| className |
		className := nameSymbol caseOf: {
			[#Block] -> [#BlockClosure].
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
TypeCheck initialize!
