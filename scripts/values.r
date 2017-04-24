REBOL [
    Title: "Values"
    Date: 9-Sep-2002
    Name: 'Values
    Version: 1.1.1
    File: %values.r
    Author: "Andrew Martin"
    Purpose: {Loads Values into Rebol. Interprets 'Needs field in header.}
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Values: make object! [
	Problem: none
	Files: make block! 100
	use [Do-File Patches] [
		Do-File: function [File [file!]] [Loaded Needs] [
			File: clean-path File
			if not found? find Files File [
				Loaded: load/header File
				Needs: Loaded/1/Needs
				if all [
					found? Needs
					block? Needs
					] [
					foreach Need Needs [
						if file? Need [
							Do-File Need
							]
						]
					]
				Problem: File
				do File	; Deliberately done to get Rebol to print "Script: " etc from 'do.
				append Files File
				Problem: none
				]
			]
		append Files clean-path Rebol/Script/Header/File
		Patches: %Patches.r
		if exists? Patches [
			Do-File Patches
			]
		foreach File read %. [
			if find/last File %.r [
				Do-File File
				]
			]
		]
	]
