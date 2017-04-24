rebol [
	File: %echos.r
	Date: 6-Jan-2005
	title: "echos"
	Author: "Anton Reisacher"
	Library: [
		Level: 'beginner
		platform: []
		Type: 'function
		Domain: patch
		tested-under: [some]
		support: none
		license: none
	]
	Purpose: "allows reusing of an already existing echo file "
	Description: {I use echo/append to-file now/date instead of the normal echo command
		to write one contiguous log file per day}
]
echo: func [
    "Copies console output to a file."
    [catch]
    target [file! none! logic!]
    /append
][
    if port? system/ports/echo [
        close system/ports/echo
        system/ports/echo: none
    ]
    if target = true [target: %rebol-echo.txt]
    if file? target [
		system/ports/echo: throw-on-error [
			either not append [
				 open/write/new/direct target
			] [
				target: open/direct target
				skip target 4294967295 ; highest int should move to the end
				target
		   ]
		]
	]
]