REBOL [
    Title: "Find Block"
    Date: 3-Jul-2002
    Name: 'Find-Block
    Version: 1.0.0
    File: %find-block.r
    Author: "Andrew Martin"
    Purpose: "Finds a tuple in a block or tuple-space."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'beginner 
        platform: none 
        type: 'tool 
        domain: 'DB 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Find-Block: function [
	"Finds a tuple in a block."
	Space [block!]	"The tuple-space to find it in."
	Tuple [block!]	"The tuple to find."
	] [Index Mark] [
	if none? Index: find/only Space Tuple [
		Index: none
		parse Space [
			any [
				[Mark: into Tuple to end end (Index: Mark)]
				| block!
				]
			end
			]
		]
	Index
	]
