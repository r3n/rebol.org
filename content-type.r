REBOL [
    Title: "Content-Type"
    Date: 9-Jul-2002
    Name: 'Content-Type
    Version: 1.0.1
    File: %content-type.r
    Author: "Andrew Martin"
    Purpose: "Prints Content-type header for cgi."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'beginner 
        platform: none 
        type: none 
        domain: 'cgi 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Content-Type: func [
	{Prints Content-type header for cgi.}
	Mime [path!]	"Mime type. For example: text/html"
	] [
	print ["Content-Type:" :Mime]
	]
