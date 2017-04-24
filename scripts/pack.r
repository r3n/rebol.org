REBOL [
    Title: "Pack"
    Date: 10-Sep-2002
    Name: 'Pack
    Version: 1.1.2
    File: %pack.r
    Author: "Andrew Martin"
    Purpose: "Self-extracting file packer & unpacker."
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

make object! [
	Unpacker: [
		Rebol [
			Name: 'Unpacker
			Title: "Self-extracting file unpacker."
			Date: (now)
			]
		Unpack: func [Pack [block!]][
			parse Pack [
				some [
					set File file! set Data binary! (
						make paren! [
							write/binary File decompress Data
							]
						)
					| set File file! (
						make paren! [make-dir/deep File]
						)
					]
				end
				]
			]
		Unpack	; 'Case goes here.
		]
	set 'Pack function [
		{Self-extracting File packer & unpacker.}
		File [file! block!]	"File can directory or block of file!"
		/Deep	"Copy subdirectories as well."
		] [
		Files Block Directory
		] [
		append/only compose/deep Unpacker any [
			if block? File [
				Block: File
				map Block func [File [file!]] [
					either #"/" = last File [
						File
						] [
						reduce [File compress read/binary File]
						]
					]
				]
			if #"/" = last File [
				Directory: File
				map either Deep [recursive-read Directory] [read Directory] func [File [file!]] [
					either #"/" = last File [
						File
						] [
						reduce [File compress read/binary Directory/:File]
						]
					]
				]
			reduce [File compress read/binary File]
			]
		]
	]
