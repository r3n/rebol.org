REBOL [
    Title: "File"
    Date: 11-Aug-2002
    Name: 'File
    Version: 1.3.0
    File: %file.r
    Author: "Andrew Martin"
    Purpose: "File and URL manipulation functions."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Acknowledgements: [
    "Romano Paolo Tenca"
]
    library: [
        level: 'beginner 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Extension?: Suffix?: function [File [url! file! string!]] [Ext] [
	parse/all File [
		some [thru #"."]
		[
			thru #"/" | Ext: to end (
				Ext: to file! back Ext
				)
			]
		]
	Ext
	]

Name?: function [
	{Returns the name of the path as a string.}
	Path [file! url!]
	] [Name Period] [
	Name: last parse/all Path "/"
	either any [
		#"/" = last Path
		not found? Period: find/last Name #"."
		] [
		Name
		] [
		copy/part Name Period
		]
	]

Folder?: function [
	"Returns the path's folder or enclosing directory."
	Path [file! url!]
	] [Name] [
	all [
		Name: find/last Path Name? Path
		Path: copy/part Path Name
		either empty? Path [none] [Path]
		]
	]

Extension: function [
	"Changes the extension of the path to the specified extension."
	Path [file! url!]
	Ext [file!]	"Like: %.txt"
	] [Dot] [
	all [
		Dot: any [find/last Path #"." tail Path]
		not find Dot #"/"
		clear Dot
		append Path Ext
		]
	]

Clear_Extension: function [
	"Clears the extension of a path."
	Path [file! url!]	"The path to clear the extension."
	] [Extension] [
	all [
		Extension: find/last Path #"."
		not find Extension #"/"
		clear Extension
		]
	Path
	]
