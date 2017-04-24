REBOL [
	Title: "Foreach-file"
        File: %foreach-file.r
	Author: "Rebolek"
	Date: 20-6-2006
	Version: 1.0.2
        Purpose: "Perform function on each file in selected directory recursively"
	library: [
		level: 'beginner
		platform: 'all
		type: [function tool]
		domain: [shell]
		tested-under: [View 1.3.2 on WinXP]
		license: 'public-domain
		support: none
        ]
] 

foreach-file: func [
	"Perform function on each file in selected directory recursively"
	dir [file! url!] "Directory to look in"
	act [function!] "Function to perform (filename is unput to fuction)"
	/directory "Perform function also on directories"
	/local f files
][
	files: attempt [read dir] 
	either none? files [return][
		foreach file files [
			f: join dir file 
			either dir? f [
				either directory [
					act f 
					foreach-file/directory f :act
				][
					foreach-file f :act
				]
			][act f]
		]
	]
]

;Example

Comment [

file-func: func [file][probe file]
foreach-file %./ :file-func

]