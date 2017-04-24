REBOL [
    Title: "Recursive Read"
    Date: 23-Sep-2002
    Name: 'Recursive-Read
    Version: 1.1.0
    File: %recursive-read.r
    Author: "Andrew Martin"
    Purpose: "Recursively read Directory."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Recursive-Read: function [
	"Recursively read Directory."
	Directory [file! url!]	"The Directory to read."
	] [Files Subdirectory] [
	if exists? Directory [
		Files: read Directory
		if block? Files [
			foreach File Files [
				if #"/" = last File [
					Subdirectory: File
					foreach File read Directory/:Subdirectory [
						append Files Subdirectory/:File
						]
					]
				]
			]
		Files
		]
	]
