REBOL [
    Title: "Delete Directory"
    Date: 20-Dec-2002
    Name: 'Delete-Directory
    Version: 1.1.1
    File: %delete-directory.r
    Author: "Andrew Martin"
    Purpose: "Deletes the specified files(s) or directory."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'beginner
        platform: none
        type: 'tool
        domain: 'file-handling
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

DD: Delete-Directory: func [
	"Deletes the specified files(s) or directory."
	Target [file! url!] "The file to delete."
	/Any "Allow wild cards."
	] [
	if exists? Target [
		none either Any [
			delete/any Target
			] [
			if dir? Target [
				foreach File read Target [
					Delete-Directory Target/:File
					]
				]
			delete Target
			]
		]
	]

