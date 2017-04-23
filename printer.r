REBOL [
    Title: "Printer"
    Date: 3-Jul-2002
    Name: 'Printer
    Version: 1.0.0
    File: %printer.r
    Author: "Andrew Martin"
    Purpose: "Sends text to printer on //prn."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Caution: "Only works on Windows PCs that aren't networked!"
    Example: [
    Printer "This goes to the printer!" 
    Printer/Page "This prints this line and feeds a page!"
]
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

Printer: func [
	"Sends text to printer on //prn."
	[catch]
	Text [string!]	"The text to be printed."
	/Page	"Append Carriage Return (CR) and Page Feed."
	][
	throw-on-error [
		secure [
			%//prn [allow write]
			]
		write %//prn Text
		if Page [write/binary %//prn "^(0D)^(page)"]
		Text
		]
	]
