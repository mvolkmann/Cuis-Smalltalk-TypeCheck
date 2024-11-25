'From Cuis7.1 [latest update: #6817] on 24 November 2024 at 7:12:36 pm'!
'Description '!
!provides: 'TypeCheck' 1 1!
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

!TypeCheck class methodsFor: 'utility' stamp: 'RMV 11/24/2024 18:41:31'!
argNamesinReceiver: anObject selector: selectorSymbol
	"Answer an OrderedCollection of the argument names in a given method."
	| argNodes code implementor method |
	
	implementor := anObject class lookupClassImplementingSelector: selectorSymbol.
	code := implementor sourceCodeAt: selectorSymbol.
	method := Parser new parse: code class: implementor.
	argNodes := method arguments.
	^ argNodes collect: [:node | node name].! !

!TypeCheck class methodsFor: 'utility' stamp: 'RMV 11/24/2024 18:44:29'!
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
TypeCheck initialize!
