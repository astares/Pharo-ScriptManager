"
Configuration for ScriptManager

http://smalltalkhub.com/#!/~TorstenBergmann/ScriptManager
"
Class {
	#name : #ConfigurationOfScriptManager,
	#superclass : #Object,
	#instVars : [
		'project'
	],
	#classVars : [
		'LastVersionLoad'
	],
	#category : #ConfigurationOfScriptManager
}

{ #category : #private }
ConfigurationOfScriptManager class >> bootstrapPackage: aString from: aPath [ 
	| repository version |
	repository := MCHttpRepository
				location: aPath
				user: ''
				password: ''.
	repository
		versionReaderForFileNamed: aString , '.mcz'
		do: [:reader | 
			version := reader version.
			version load.
			version workingCopy repositoryGroup addRepository: repository]
]

{ #category : #catalog }
ConfigurationOfScriptManager class >> catalogChangeLog [
	"Returns a paragraph describing the most important changes in the configuration class."
	^ ''
]

{ #category : #catalog }
ConfigurationOfScriptManager class >> catalogContactInfo [
	"Returns a paragraph describing contact information such as email, mailing lists and website."
	^ 'You can contact the author on the pharo mailinglist.'
]

{ #category : #catalog }
ConfigurationOfScriptManager class >> catalogDescription [
	"Returns a paragraph describing the project"
	^ 'A simple tool to manage scripts. Still based on Morphic. We would recommend users to switch to QuickAccess which is a better script manager than this tool.'
]

{ #category : #catalog }
ConfigurationOfScriptManager class >> catalogKeyClassesAndExample [
	"Returns a paragraph or more describing the key classes of your project. You can use Pillar/Pier syntax to layout out the text i.e., ==Code== and - for bullet."
	^ ' '
]

{ #category : #catalog }
ConfigurationOfScriptManager class >> catalogKeywords [
	"Returns an array of symbols"
	^ #(script fun) 
]

{ #category : #private }
ConfigurationOfScriptManager class >> ensureMetacello [
	"Bootstrap Gofer (if necessary), bootstrap ConfigurationOfMetacello (using old Gofer API), then load the latest 
	version of Metacello itself."

	Smalltalk at: #MetacelloProject ifAbsent: [
		Smalltalk at: #Gofer ifAbsent: [
			"Current version of Gofer from which to bootstrap - as of 1.0-beta.21"
			self bootstrapPackage: 'Gofer-Core-lr.115' from: 'http://seaside.gemstone.com/ss/metacello' ].
		Smalltalk at: #Gofer ifPresent: [:goferClass | | gofer |
			gofer := goferClass new
				url: 'http://seaside.gemstone.com/ss/metacello';
				yourself.
			[ gofer addPackage: 'ConfigurationOfMetacello' ] on: Warning do: [:ex | ex resume ].
			gofer load ].
		"load 'default' group of Metacello"
		(Smalltalk at: #ConfigurationOfMetacello) perform: #load ]
]

{ #category : #'metacello tool support' }
ConfigurationOfScriptManager class >> isMetacelloConfig [
	"Answer true and the Metacello tools will operate on you"
	
	^true
]

{ #category : #'metacello tool support' }
ConfigurationOfScriptManager class >> lastMetacelloVersionLoad [
	"Answer the last version loaded and the list of packages loaded for that version."

	LastVersionLoad == nil ifTrue: [ LastVersionLoad := nil -> 'default' ].
	^LastVersionLoad
]

{ #category : #loading }
ConfigurationOfScriptManager class >> load [
	"self load"

	^self project latestVersion load
]

{ #category : #'metacello tool support' }
ConfigurationOfScriptManager class >> metacelloVersion: versionString loads: anArrayOrString [
	"Stash the last version loaded and the list of packages loaded for that version. The list
	 of packages will be used by the tools when doing 'Load Package Version'"

	LastVersionLoad := versionString -> anArrayOrString
]

{ #category : #accessing }
ConfigurationOfScriptManager class >> project [

	^self new project
]

{ #category : #baselines }
ConfigurationOfScriptManager >> baseline10: spec [ 
	<version: '1.0-baseline'>
	
	spec for: #common do: [
		spec blessing: #baseline.
		spec repository: 'http://smalltalkhub.com/mc/TorstenBergmann/ScriptManager/main'.	
		spec 
			package: 'ScriptManager-Core'.
		spec
			group: 'default' with: #('Core');
			group: 'Core' with: #('ScriptManager-Core')].
]

{ #category : #baselines }
ConfigurationOfScriptManager >> baseline11: spec [ 
	<version: '1.1-baseline'>
	
	spec for: #common do: [
		spec blessing: #baseline.
		spec repository: 'http://smalltalkhub.com/mc/TorstenBergmann/ScriptManager/main'.	
		spec 
			package: 'ScriptManager-Core';
			package: 'ScriptManager-Help'.
		spec
			group: 'default' with: #('Core');
			group: 'Core' with: #('ScriptManager-Core')].
]

{ #category : #accessing }
ConfigurationOfScriptManager >> project [

	^ project ifNil: [ | constructor |
		"Bootstrap Metacello if it is not already loaded"
		self class ensureMetacello.
		"Construct Metacello project"
		constructor := (Smalltalk at: #MetacelloVersionConstructor) on: self.
		project := constructor project.
		project loadType: #linear. "change to #atomic if desired"
		project ]
]

{ #category : #'symbolic versions' }
ConfigurationOfScriptManager >> stable: spec [ 
	<symbolicVersion: #'stable'>
	
	spec for: #'pharo1.1.x' version: '1.2'. 
	spec for: #'pharo1.2.x' version: '1.2'. 
	spec for: #'pharo1.3.x' version: '1.3'.
	spec for: #'pharo1.4.x' version: '1.4'.
	spec for: #'pharo2.0.x' version: '1.6'.
	spec for: #'pharo3.0.x' version: '1.7'.
	spec for: #'pharo4.0.x' version: '1.8'.
	spec for: #'pharo5.0.x' version: '1.9'.
	spec for: #'common' version: '1.10'.
	
]

{ #category : #versions }
ConfigurationOfScriptManager >> version10: spec [ 
	<version: '1.0' imports: #('1.0-baseline') >
	
	spec for: #common do: [
		spec blessing: #release.
		spec 
			package: 'ScriptManager-Core' with: 'ScriptManager-Core-tbn.9'].
]

{ #category : #versions }
ConfigurationOfScriptManager >> version110: spec [ 
	<version: '1.10' imports: #('1.1-baseline') >
	
	spec for: #common do: [
		spec blessing: #development.
		spec 
			package: 'ScriptManager-Core' with: 'ScriptManager-Core-TorstenBergmann.28';
			package: 'ScriptManager-Help' with: 'ScriptManager-Help-tbn.1']
]

{ #category : #versions }
ConfigurationOfScriptManager >> version11: spec [ 
	<version: '1.1' imports: #('1.0-baseline') >
	
	spec for: #common do: [
		spec blessing: #release.
		spec 
			package: 'ScriptManager-Core' with: 'ScriptManager-Core-tbn.11'].
]

{ #category : #versions }
ConfigurationOfScriptManager >> version12: spec [ 
	<version: '1.2' imports: #('1.1-baseline') >
	
	spec for: #common do: [
		spec blessing: #release.
		spec 
			package: 'ScriptManager-Core' with: 'ScriptManager-Core-tbn.11';
			package: 'ScriptManager-Help' with: 'ScriptManager-Help-tbn.1'].
]

{ #category : #versions }
ConfigurationOfScriptManager >> version13: spec [ 
	<version: '1.3' imports: #('1.1-baseline') >
	
	spec for: #common do: [
		spec blessing: #development.
		spec 
			package: 'ScriptManager-Core' with: 'ScriptManager-Core-tbn.13';
			package: 'ScriptManager-Help' with: 'ScriptManager-Help-tbn.1'].
]

{ #category : #versions }
ConfigurationOfScriptManager >> version14: spec [ 
	<version: '1.4' imports: #('1.1-baseline') >
	
	spec for: #common do: [
		spec blessing: #release.
		spec 
			package: 'ScriptManager-Core' with: 'ScriptManager-Core-GuillermoPolito.15';
			package: 'ScriptManager-Help' with: 'ScriptManager-Help-tbn.1']
]

{ #category : #versions }
ConfigurationOfScriptManager >> version15: spec [ 
	<version: '1.5' imports: #('1.1-baseline') >
	
	spec for: #common do: [
		spec blessing: #release.
		spec 
			package: 'ScriptManager-Core' with: 'ScriptManager-Core-tbn.17';
			package: 'ScriptManager-Help' with: 'ScriptManager-Help-tbn.1']
]

{ #category : #versions }
ConfigurationOfScriptManager >> version16: spec [ 
	<version: '1.6' imports: #('1.1-baseline') >
	
	spec for: #common do: [
		spec blessing: #release.
		spec 
			package: 'ScriptManager-Core' with: 'ScriptManager-Core-TorstenBergmann.19';
			package: 'ScriptManager-Help' with: 'ScriptManager-Help-tbn.1']
]

{ #category : #versions }
ConfigurationOfScriptManager >> version17: spec [ 
	<version: '1.7' imports: #('1.1-baseline') >
	
	spec for: #common do: [
		spec blessing: #release.
		spec 
			package: 'ScriptManager-Core' with: 'ScriptManager-Core-TorstenBergmann.25';
			package: 'ScriptManager-Help' with: 'ScriptManager-Help-tbn.1']
]

{ #category : #versions }
ConfigurationOfScriptManager >> version18: spec [ 
	<version: '1.8' imports: #('1.1-baseline') >
	
	spec for: #common do: [
		spec blessing: #development.
		spec 
			package: 'ScriptManager-Core' with: 'ScriptManager-Core-TorstenBergmann.27';
			package: 'ScriptManager-Help' with: 'ScriptManager-Help-tbn.1']
]

{ #category : #versions }
ConfigurationOfScriptManager >> version19: spec [ 
	<version: '1.9' imports: #('1.1-baseline') >
	
	spec for: #common do: [
		spec blessing: #development.
		spec 
			package: 'ScriptManager-Core' with: 'ScriptManager-Core-TorstenBergmann.27';
			package: 'ScriptManager-Help' with: 'ScriptManager-Help-tbn.1']
]
