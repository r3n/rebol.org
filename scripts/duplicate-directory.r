REBOL [
    Title: "Duplicate Directory"
    Date: 25-Jul-2002
    Name: 'Duplicate-Directory
    Version: 1.0.1
    File: %duplicate-directory.r
    Author: "Andrew Martin"
    Purpose: "Duplicates the structure and files of a directory."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
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

Duplicate-Directory: func [
	"Duplicates in Write_Directory the structure and files of Read_Directory."
	Write_Directory [file!]	"The written over directory."
	Read_Directory [file!] 	"The read from directory."
	] [
	any [
		exists? Write_Directory
		md Write_Directory
		]
	foreach File recursive-read Read_Directory [
		either #"/" = last File [
			any [
				exists? Write_Directory/:File
				md Write_Directory/:File
				]
			] [
			write/binary Write_Directory/:File read/binary Read_Directory/:File
			]
		]
	]
