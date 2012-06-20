"
The Script Manager offers a way to organize workspaces. It allows you to 
define ""folders"" in which you can store your scripts/workspaces. The folder 
menu provides options to import and export whole collections of scripts to
a file. The script menu offers options to ""tear off"" a script into a workspace, 
""bring in"" workspaces, and to dump and load individual scripts to files.

Comments are appreciated.
- Joseph Pelrine
jpelrine@acm.org
"
Class {
	#name : #ScriptManager,
	#superclass : #Model,
	#instVars : [
		'scriptListIndex',
		'bindingsList',
		'scriptList',
		'folderSelected',
		'folderList',
		'folderListIndex',
		'scripts',
		'fileName'
	],
	#classVars : [
		'Scripts'
	],
	#category : #'ScriptManager-Core'
}

{ #category : #'instance creation' }
ScriptManager class >> initialize [
	Scripts := Dictionary new.
	self registerInWorldMenu
]

{ #category : #'world menu' }
ScriptManager class >> menuCommandOn: aBuilder [ 
	<worldMenu> 
	(aBuilder item: #'Script Manager')
		parent: #Tools;
		icon: UITheme current smallLeftFlushIcon;
		action:[self open]
]

{ #category : #'instance creation' }
ScriptManager class >> open [

	| newInst window |
	newInst := self new.
	window := (SystemWindow labelled: newInst label) model: newInst.
	newInst addMorphsTo: window.
	^window openInWorld
]

{ #category : #'world menu' }
ScriptManager class >> registerInWorldMenu [
	"This only applies to old Pharo 1.0 and Squeak"
	
	Smalltalk at: #TheWorldMenu ifPresent: [ :class |
		class class methodDict at: #registerOpenCommand: ifPresent: [ :method |
			(method sendsSelector: #deprecated:) 
				ifFalse: [ class registerOpenCommand: (Array with: self title with: (Array with: self with: #open)) ] ] ]
]

{ #category : #'instance creation' }
ScriptManager class >> scripts [
	^Scripts
]

{ #category : #'instance creation' }
ScriptManager class >> scripts: aDictionary [
	Scripts := aDictionary
]

{ #category : #'user-interface' }
ScriptManager class >> taskbarIcon [
	"Answer the icon for the receiver in a task bar."

	^UITheme current smallLeftFlushIcon
]

{ #category : #accessing }
ScriptManager class >> title [
	^'Script Manager'
]

{ #category : #'clean up' }
ScriptManager class >> unload [
	"Called when the class is being removed"

	self unregisterInWorldMenu
]

{ #category : #'world menu' }
ScriptManager class >> unregisterInWorldMenu [
	"This only applies to old Pharo 1.0 and Squeak"
	
	Smalltalk at: #TheWorldMenu ifPresent: [ :class |
		class class methodDict at: #unregisterOpenCommandWithReceiver: ifPresent: [ :method |
			(method sendsSelector: #deprecated:) 
				ifFalse: [ class unregisterOpenCommandWithReceiver: self ] ] ]
]

{ #category : #'drag&drop' }
ScriptManager >> acceptDroppingMorph: transferMorph event: evt inMorph: dstListMorph [ 
	"Here we are fetching informations from the dropped transferMorph and 
	 performing the correct action for this drop."

	| srcListSel dstListSel |
	dstListSel := dstListMorph getListSelector.
	srcListSel := transferMorph source getListSelector.
	(dstListSel == #folderList and: [srcListSel == #scriptList]) ifTrue: [
		| newFolder oldFolder scriptName |
		newFolder := dstListMorph potentialDropItem contents.
		scriptName := transferMorph passenger contents.
		oldFolder := self selectedFolderName.
		oldFolder = newFolder ifFalse: [
			self 
				moveScriptNamed: scriptName
				from: oldFolder
				to: newFolder]]
]

{ #category : #widgets }
ScriptManager >> addMorphsTo: aWindow [
	"Add morphs to <aWindow>."
	 
	folderListIndex := 0.
	scriptListIndex := 0.
	aWindow
		addMorph: (self folderListWidget enableDragNDrop: true)
		frame: (0@0 extent: 0.4@0.4).
	aWindow 
		addMorph: (self scriptListWidget enableDragNDrop: true)
		frame: (0.4 @ 0.0 extent: 0.6 @ 0.4).

	aWindow
		addMorph: self buildTextMorph
		frame: ( 0@0.4 extent: 1@0.6)
]

{ #category : #callbacks }
ScriptManager >> bindingOf: aString [ 
	"store variable bindings per script."
	(self bindingsList
		at: self selectedScript
		ifAbsentPut: [Dictionary new])
		at: aString
		ifAbsentPut: [].
	^ (self bindingsList at: self selectedScript)
		associationAt: aString
]

{ #category : #'script list' }
ScriptManager >> bindingsList [
	^bindingsList ifNil: [ bindingsList := Dictionary new ]
]

{ #category : #callbacks }
ScriptManager >> bringInScripts [
	| wsDictionary selected |
	wsDictionary := self workspaceDictionary.
	wsDictionary isEmpty
		ifTrue: [ UIManager default inform: 'No workspaces currently open.'.
			^ self].
	(selected := self chooseWorkspace: wsDictionary) isNil
		ifTrue: [^ self].
	self installWorkspaceScripts: selected
]

{ #category : #widgets }
ScriptManager >> buildTextMorph [ 

	^( PluggableTextMorph
				on: self
				text: #contents
				accept: #contents:notifying:
				readSelection: #contentsSelection
				menu: #codePaneMenu:shifted:)
			font: StandardFonts codeFont;
			yourself
]

{ #category : #callbacks }
ScriptManager >> changeFolder [
	| newFolder oldFolder scriptName |
	self isScriptSelected ifFalse: [^nil].
	scriptName := self selectedScriptName.
	oldFolder := self selectedFolderName.
	((newFolder := self chooseFolderToMoveTo) isNil 
		or: [oldFolder = newFolder]) ifTrue: [^nil].
	self 
		moveScriptNamed: scriptName
		from: oldFolder
		to: newFolder
]

{ #category : #menus }
ScriptManager >> changeFolderString [
	^'change folder'
]

{ #category : #callbacks }
ScriptManager >> chooseFolderToMoveTo [
	| folders |
	folders := self folderList copyWithout: self selectedFolderName.
	^ UIManager default
		chooseFrom: folders
		values: folders
		title: 'Please select the new folder'
]

{ #category : #callbacks }
ScriptManager >> chooseWorkspace: aDictionary [

	| list |
	list := aDictionary associations asSortedCollection: [ :a :b | a key < b key].
	^ UIManager default
		chooseFrom: (list collect: [ :each | each key]) 
		values: list
		title: 'Please select the workspaces'
]

{ #category : #callbacks }
ScriptManager >> clearUserEditFlag [
	"Clear the hasUnacceptedEdits flag in all my dependent views."
	"don't remove this method.  Just don't."

	self changed: #clearUserEdits
]

{ #category : #editor }
ScriptManager >> codePaneMenu: aMenu shifted: shifted [
	"Note that unless we override perform:orSendTo:, PluggableTextController will respond to all menu items in a text pane"
	| donorMenu |
	donorMenu := shifted
		ifTrue:
			[SmalltalkEditor shiftedYellowButtonMenu]
		ifFalse:
			[SmalltalkEditor yellowButtonMenu].
	^ aMenu addAllFrom: donorMenu
]

{ #category : #editor }
ScriptManager >> contents [
	| script |
	^(script := self selectedScript) = nil 
		ifTrue: ['']
		ifFalse: 	[script]
]

{ #category : #editor }
ScriptManager >> contents: aString notifying: aController [ 
	self selectedFolder
		at: self selectedScriptName
		put: aString string.
	^true
]

{ #category : #editor }
ScriptManager >> contentsSelection [
	"Return the interval of text in the code pane to select when I set the pane's contents"

	(self folderListIndex = 0 and: [scriptListIndex = 0]) 
		ifTrue: [^ 1 to: 500]	"entire empty method template"
		ifFalse: [^ 1 to: 0]  "null selection"
]

{ #category : #callbacks }
ScriptManager >> createFolderNamed: newFolderName [ 
	self scripts at: newFolderName put: Dictionary new.
	self
		changed: #folderList;
		changed: #scriptList
]

{ #category : #callbacks }
ScriptManager >> deleteFolder [
	self isFolderSelected ifFalse: [^nil].
	self scripts 
		removeKey: self selectedFolderName
		ifAbsent: [].
	self folderListIndex: 0

]

{ #category : #callbacks }
ScriptManager >> deleteScript [
	self isScriptSelected ifFalse: [^nil].
	self selectedFolder 
		removeKey: self selectedScriptName
		ifAbsent: [].
	self 
		changed: #scriptList;
		scriptListIndex: 0

]

{ #category : #menus }
ScriptManager >> deleteString [
	^'delete'
]

{ #category : #'drag&drop' }
ScriptManager >> dragTransferTypeForMorph: dragSource [ 
	^(dragSource isKindOf: PluggableListMorph)
		ifTrue: [dragSource getListSelector]
]

{ #category : #callbacks }
ScriptManager >> dumpScriptToFile [
	| aFileName fileStream |
	aFileName := UIManager default request: 'Name of file to dump script to: '.
	aFileName isEmptyOrNil ifTrue: [^ self].
	fileStream := FileStream fileNamed: aFileName.
	fileStream nextPutAll: self contents; close
]

{ #category : #menus }
ScriptManager >> dumpToFileString [
	^'dump to file...'
]

{ #category : #callbacks }
ScriptManager >> exportScripts [

	| rr exportFileName |
	exportFileName := UIManager default 
		request: 'File name? (".fuel" will be added to end)' 
		initialAnswer: self storageFileName.
	exportFileName isEmptyOrNil ifTrue: [^ Beeper beep].
	(exportFileName asLowercase endsWith: '.fuel') ifFalse: [
		exportFileName := exportFileName,'.fuel'].
	
	((FileDirectory default fileExists: exportFileName) 
		and: [(UIManager default confirm: 'Overwrite file ', exportFileName) = false]) ifTrue: [^self].
				
	Cursor wait showWhile: [
		FLSerializer serialize: self scripts toFileNamed: exportFileName].
	self fileName: exportFileName



]

{ #category : #callbacks }
ScriptManager >> fileName [
	fileName isNil ifTrue: [fileName := self storageFileName].
	^fileName
]

{ #category : #callbacks }
ScriptManager >> fileName: aString [
	fileName  := aString.
	(fileName asLowercase endsWith: '.fuel') ifTrue: [
		fileName := fileName copyFrom: 1 to: fileName size - 5].
	self topView setLabel: self label, ' - ', self fileName
]

{ #category : #callbacks }
ScriptManager >> firstLineFor: aString [
	| lines stream |
	lines := OrderedCollection new.
	stream := aString readStream.
	[stream atEnd] whileFalse: [
		lines addLast: stream nextLine trimBoth].
	^lines
		detect: [ :each | each isEmpty not 
			and: [((each size = 1) and: [each first = $"]) not]]
		ifNone: [ nil ]
]

{ #category : #'folder list' }
ScriptManager >> folderList [
	^self scripts keys asSortedCollection
]

{ #category : #'folder list' }
ScriptManager >> folderListIndex [
	folderListIndex == nil
		ifTrue: [^0].
	^folderListIndex
]

{ #category : #'folder list' }
ScriptManager >> folderListIndex: anInteger [ 
	"Set the selected folder index to be anInteger. Update all other 
	selections to be deselected."
	folderListIndex := anInteger.
	scriptListIndex := 0.
	self 
		changed: #folderList;	"update my selection"
		changed: #scriptList;
		changed: #contents.
]

{ #category : #menus }
ScriptManager >> folderListMenu: aMenu [
	^ aMenu
		add: 'new folder ...' action: #newFolder;
		addUpdating: #renameString enablement: #isFolderSelected action: #renameFolder;
		addUpdating: #deleteString enablement: #isFolderSelected action: #deleteFolder;
		addLine;
		add: 'import' action: #importScripts;
		add: 'export' action: #exportScripts;
	yourself

]

{ #category : #widgets }
ScriptManager >> folderListWidget [
	^PluggableListMorph 
		on: self
		list: #folderList
		selected: #folderListIndex
		changeSelected: #folderListIndex:
		menu: #folderListMenu:
		keystroke: nil
]

{ #category : #callbacks }
ScriptManager >> hasBindingOf: aString [ 
 
	(self bindingsList
		at: self selectedScript
		ifAbsent: [ ^false ])
		at: aString
		ifAbsent: [ ^false ].
	^ true
]

{ #category : #'shout support' }
ScriptManager >> hasBindingThatBeginsWith: aString [
	"we dont support bindings here"

	^false

]

{ #category : #callbacks }
ScriptManager >> importScripts [

	| importFileName importedScripts |
	importFileName := UIManager default 
		request: 'File name? (".fuel" will be added to end)' 
		initialAnswer: self fileName.
	importFileName isEmptyOrNil ifTrue: [^ Beeper beep ].
	(importFileName asLowercase endsWith: '.fuel') ifFalse: [
		importFileName := importFileName,'.fuel'].
	
	(FileDirectory default fileExists: importFileName) 
		ifFalse: [^UIManager default inform: 'File ', importFileName, ' does not exist!' ].	
			
	Cursor wait showWhile: [ importedScripts := FLMaterializer materializeFromFileNamed: importFileName ].
	importedScripts ~~ nil ifTrue: [self scripts: importedScripts].
	self
		changed: #folderList;
		folderListIndex: 0;
		fileName: importFileName

]

{ #category : #callbacks }
ScriptManager >> installWorkspaceScripts: selected [
	(self folderList includes: 'workspaces') ifFalse: [
		self createFolderNamed: 'workspaces'].
	(self scripts at: 'workspaces')
		at: selected key put: selected value.
	self selectFolderNamed: 'workspaces'.

]

{ #category : #'folder list' }
ScriptManager >> isFolderSelected [
	^folderListIndex ~= 0
]

{ #category : #'script list' }
ScriptManager >> isScriptSelected [
	^scriptListIndex ~= 0
]

{ #category : #callbacks }
ScriptManager >> label [
	^'Script Manager'
]

{ #category : #callbacks }
ScriptManager >> loadScriptFromFile [
	| aFileName fileStream assoc string |
	aFileName := UIManager default request: 'Name of file to be loaded: '.
	aFileName isEmptyOrNil ifTrue: [^ self].
	(FileDirectory default fileExists: aFileName) ifFalse:
		[^ self inform: 'Sorry -- cannot find that file'].
	fileStream := FileStream readOnlyFileNamed: aFileName.
	string := fileStream contents.
	fileStream close.
	assoc := Association key: aFileName value: string.
	self installWorkspaceScripts: assoc
]

{ #category : #callbacks }
ScriptManager >> localWorkspaces [
	| world systemWindows |
	world := self dependents first world.
	systemWindows := world submorphs
				select: [:each | each model isKindOf: Workspace].
	^ systemWindows
		collect: [:each | each model dependents
				detect: [:e | e isKindOf: PluggableTextMorph]]
]

{ #category : #callbacks }
ScriptManager >> moveScriptNamed: scriptName from: oldFolder to: newFolder [
	| myScript |
	myScript := self selectedFolder at: scriptName.
	(self scripts at: newFolder) at: scriptName put: myScript.
	(self scripts at: oldFolder) removeKey: scriptName.
	self selectFolderNamed: oldFolder
]

{ #category : #callbacks }
ScriptManager >> newFolder [
	| newFolderName |
	(newFolderName := self promptForNewName) isEmptyOrNil ifTrue: [^nil].
	(self folderList includes: newFolderName) ifTrue: [
		^UIManager default inform: 'A folder named ' , newFolderName , ' already exists'].
	self createFolderNamed: newFolderName
]

{ #category : #callbacks }
ScriptManager >> newScript [
	| scriptName index |
	self isFolderSelected ifFalse: [^nil].
	(scriptName := self promptForNewName) isEmptyOrNil ifTrue: [^nil].
	(self scriptList includes: scriptName) ifTrue: [
		^UIManager default inform: 'A script named ', scriptName, ' already exists'].
	self selectedFolder at: scriptName put: ''.
	self changed: #scriptList.
	index := self scriptList indexOf: scriptName.
	self 
		changed: #scriptList;
		scriptListIndex: index

]

{ #category : #menus }
ScriptManager >> newScriptString [
	^'new script ...'
]

{ #category : #callbacks }
ScriptManager >> okToChange [
	self canDiscardEdits ifTrue: [^ true].
	self changed: #wantToChange.  "Solicit cancel from view"
	^self canDiscardEdits
]

{ #category : #editor }
ScriptManager >> perform: selector orSendTo: otherTarget [
	"Selector was just chosen from a menu by a user.  If can respond, then
perform it on myself. If not, send it to otherTarget, presumably the
editPane from which the menu was invoked."

	(self respondsTo: selector)
		ifTrue: [^ self perform: selector]
		ifFalse: [^ otherTarget perform: selector]
]

{ #category : #callbacks }
ScriptManager >> promptForNewName [
	^UIManager default request: 'New name?'

]

{ #category : #callbacks }
ScriptManager >> promptForNewName: aString [
	^UIManager default request: 'New name?' initialAnswer: aString.
	
 
]

{ #category : #callbacks }
ScriptManager >> renameFolder [
	| newName oldName myScripts |
	self isFolderSelected
		ifFalse: [^ nil].
	oldName := self selectedFolderName.
	((newName := self promptForNewName: oldName) isEmptyOrNil
			or: [oldName = newName])
		ifTrue: [^ nil].
	(self folderList includes: newName)
		ifTrue: [^ UIManager default inform: 'a folder named ' , newName , ' already exists'].
	myScripts := self scripts at: oldName.
	self scripts at: newName put: myScripts;
		 at: oldName put: nil.
	self scripts removeKey: oldName.
	self selectFolderNamed: newName
]

{ #category : #callbacks }
ScriptManager >> renameScript [
	| newName oldName index myScript |
	self isScriptSelected
		ifFalse: [^ nil].
	oldName := self selectedScriptName.
	((newName := self promptForNewName: oldName) isEmpty
			or: [oldName = newName])
		ifTrue: [^ nil].
	(self scriptList includes: newName)
		ifTrue: [^ UIManager default inform: 'a script named ' , newName , ' already exists'].
	myScript := self selectedFolder at: oldName.
	self selectedFolder at: newName put: myScript;
		 at: oldName put: nil.
	self selectedFolder removeKey: oldName.
	index := self folderList indexOf: newName.
	self changed: #scriptList;
		 scriptListIndex: index
]

{ #category : #menus }
ScriptManager >> renameString [
	^'rename ...'
]

{ #category : #'script list' }
ScriptManager >> scriptList [
	"Returns the list of scripts in the folder"

	^self selectedFolder isNil 
		ifTrue: [Array new]
		ifFalse: [self selectedFolder keys asSortedCollection]

]

{ #category : #'script list' }
ScriptManager >> scriptListIndex [
	scriptListIndex == nil
		ifTrue: [^0].
	^scriptListIndex

]

{ #category : #'script list' }
ScriptManager >> scriptListIndex: anInteger [
	scriptListIndex := anInteger.
	self 
		changed: #scriptListIndex;
		changed: #contents.


]

{ #category : #menus }
ScriptManager >> scriptListMenu: aMenu [
	^ aMenu
		addUpdating: #newScriptString enablement: #isFolderSelected action: #newScript;
		addUpdating: #renameString enablement: #isScriptSelected action: #renameScript;
		addUpdating: #deleteString enablement: #isScriptSelected action: #deleteScript;
		addUpdating: #changeFolderString enablement: #isScriptSelected action: #changeFolder;
		addLine;
		addUpdating: #tearOffString enablement: #isScriptSelected action: #tearOffScript;
		add: 'bring in' action: #bringInScripts;
		addLine;
		addUpdating: #dumpToFileString enablement: #isScriptSelected action: #dumpScriptToFile;
		add: 'load from file...' action: #loadScriptFromFile;
	yourself

]

{ #category : #widgets }
ScriptManager >> scriptListWidget [
	^PluggableListMorph 
		on: self
		list: #scriptList
		selected: #scriptListIndex
		changeSelected: #scriptListIndex:
		menu: #scriptListMenu:
		keystroke: nil
]

{ #category : #'folder list' }
ScriptManager >> scripts [
	scripts isNil ifTrue: [scripts := self class scripts].
	^scripts
]

{ #category : #'folder list' }
ScriptManager >> scripts: aDictionary [
	scripts := aDictionary
]

{ #category : #callbacks }
ScriptManager >> selectFolderNamed: newName [ 
	| index |
	index := self folderList indexOf: newName.
	self
		changed: #folderList;
		folderListIndex: index
]

{ #category : #'folder list' }
ScriptManager >> selectedFolder [
	self selectedFolderName isNil ifTrue: [^nil].
	^self scripts at: self selectedFolderName ifAbsentPut: [Dictionary new].

]

{ #category : #'folder list' }
ScriptManager >> selectedFolderName [
	self isFolderSelected ifFalse: [^nil].
	^self folderList at: folderListIndex
]

{ #category : #'script list' }
ScriptManager >> selectedScript [
	(self selectedFolder isNil or: [self selectedScriptName isNil])
	  	ifTrue: [^nil].
	^self selectedFolder at: self selectedScriptName
]

{ #category : #'script list' }
ScriptManager >> selectedScriptName [
	^self isScriptSelected 
		ifTrue: [self scriptList at: scriptListIndex]
		ifFalse: []
]

{ #category : #'shout support' }
ScriptManager >> shoutAboutToStyle: aPluggableShoutMorphOrView [
	"set up the compilation class in aPluggableShoutMorphOrView.
	Answer true if styling should go ahead, false otherwise"
	
	aPluggableShoutMorphOrView classOrMetaClass: nil.
	aPluggableShoutMorphOrView styler workspace: self.
	^true
]

{ #category : #callbacks }
ScriptManager >> storageFileName [
	^'scripts'

]

{ #category : #callbacks }
ScriptManager >> tearOffScript [
	| wsClass ws |
	wsClass := (Smalltalk at: #SHWorkspace ifAbsent: [Workspace]).
	ws := wsClass new contents: self contents.
	ws openLabel: 'Workspace' 
]

{ #category : #menus }
ScriptManager >> tearOffString [
	^'tear off'
]

{ #category : #'drag&drop' }
ScriptManager >> wantsDroppedMorph: transferMorph event: anEvent inMorph: destinationLM [ 

	| srcType dstType |
	(destinationLM isKindOf: PluggableTextMorph) ifTrue: [ ^ false ].
	srcType := transferMorph dragTransferType.
	dstType := destinationLM getListSelector.
	dstType == #folderList ifTrue: [^true].
"self hack."	"to-do:  this needs to check that source browser and dest browser are the same"
	(srcType == #scriptList) ifTrue: [^true].
	^false
]

{ #category : #callbacks }
ScriptManager >> workspaceDictionary [
	^ self localWorkspaces
		inject: Dictionary new
		into: [:dictionary :workspace | 
		| key string line |
		line := self firstLineFor: (string := workspace text string).
		line isNil 
			ifFalse: [dictionary at: (line copyFrom: 1 to: (80 min: line size)) put: string].
		dictionary].
]
