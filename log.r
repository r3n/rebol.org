REBOL [
    Title: "Log"
    Date: 20-Dec-2002
    Name: 'Log
    Version: 1.0.0
    File: %log.r
    Author: "Andrew Martin"
    Purpose: "Logs Rebol values to a file."
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

Log: function [
	{Logs Rebol values to a file.}
	Value [any-type!] "The value to log."
	/Clear "Clears (by deleting) the current log file."
	] [File] [
	File: %Log.txt
	if Clear [
		delete File
		]
	write/append/lines File reform [
		now/time mold :Value
		]
	:Value
	]

