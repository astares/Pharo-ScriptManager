Class {
	#name : #ScriptManagerHelp,
	#superclass : #CustomHelp,
	#category : #'ScriptManager-Help'
}

{ #category : #accessing }
ScriptManagerHelp class >> bookName [
	^'Script Manager'
]

{ #category : #pages }
ScriptManagerHelp class >> bringIn [
	"This method was automatically generated. Edit it using:"
	"ScriptManagerHelp edit: #bringIn"
	^HelpTopic
		title: 'Bring in'
		contents: 
'By selecting "bring in" from the context menu in the upper right pane it is possible to bring in existing workspaces so their contents is managed as scripts within the ScriptManager.!' readStream nextChunkText
]

{ #category : #pages }
ScriptManagerHelp class >> export [
	"This method was automatically generated. Edit it using:"
	"ScriptManagerHelp edit: #export"
	^HelpTopic
		title: 'Export your scripts'
		contents: 
'You can export your scripts by selecting "export" from the context menu in the upper left pane.

!' readStream nextChunkText
]

{ #category : #pages }
ScriptManagerHelp class >> import [
	"This method was automatically generated. Edit it using:"
	"ScriptManagerHelp edit: #import"
	^HelpTopic
		title: 'Import your scripts'
		contents: 
'You can import your scripts by selecting "import" from the context menu in the upper left pane.

!' readStream nextChunkText
]

{ #category : #pages }
ScriptManagerHelp class >> introduction [
	"This method was automatically generated. Edit it using:"
	"ScriptManagerHelp edit: #introduction"
	^HelpTopic
		title: 'Introduction'
		contents: 
'The Script Manager offers a way to organize workspaces. It allows you to 
define "folders" in which you can store your scripts/workspaces. The folder 
menu provides options to import and export whole collections of scripts to
a file. The script menu offers options to "tear off" a script into a workspace, 
"bring in" workspaces, and to dump and load individual scripts to files.

Comments are appreciated.
- Joseph Pelrine
jpelrine@acm.org' readStream nextChunkText
]

{ #category : #accessing }
ScriptManagerHelp class >> key [
	^'ScriptManager'
]

{ #category : #accessing }
ScriptManagerHelp class >> pages [
	^#(introduction start export import bringIn)
]

{ #category : #pages }
ScriptManagerHelp class >> start [
	"This method was automatically generated. Edit it using:"
	"ScriptManagerHelp edit: #start"
	^HelpTopic
		title: 'Getting started'
		contents: 
'The Script manager can be started by selecting "Tools" -> "Script Manager".

A new window with three panes should show up. In the upper left pane (folder pane) you can create new folders by selecting "new folder..." from the context menu. You have to enter a new name for the folder.

If you select a folder in the folder pane you can add new scripts to it in the upper right pane (script pane) by selecting "new script..." from its context menu. If a script name is selected in the script pane you can enter text for it in the bottom pane (code pane). By hitting CMD+s you can accept the script.






 !' readStream nextChunkText
]
