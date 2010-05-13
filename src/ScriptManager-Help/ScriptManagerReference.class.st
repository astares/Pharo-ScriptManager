Class {
	#name : #ScriptManagerReference,
	#superclass : #ScriptManagerHelp,
	#category : #'ScriptManager-Help'
}

{ #category : #accessing }
ScriptManagerReference class >> bookName [
	^'Reference'
]

{ #category : #accessing }
ScriptManagerReference class >> builder [
	^PackageAPIHelpBuilder
]

{ #category : #accessing }
ScriptManagerReference class >> packages [
	^#('ScriptManager-Core')
]
