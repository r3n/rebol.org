REBOL [
    Title:  "Load ini file"
    Date:   26-Aug-2010
    Author: "Marco Antoniazzi"
    File:   %load-ini.r
    Purpose: "Parses a Window's ini file."
    library: [
        level: 'beginner
        platform: 'windows
        type: 'Tool
        domain: [file-handling parse win-api]
        tested-under: 'windows
        support: none
        license: 'bsd
        see-also: none
    ]
    Version: 1.0.0
    History: [
        [1.0.0 26-Aug-2010 "First version"]
    ]
]

ini-str: {
; for 16-bit app support
[fonts]
[extensions]
[mci extensions]
[files]

[Mail]
MAPI=1
CMCDLLNAME32=mapi32.dll
CMC=1
MAPIX=
MAPIXVER=1.0.0.1
OLEMessaging=1
; for ...
[MCI Extensions.BAK]
3g2=MPEGVideo
3gp=MPEGVideo
3gp2=MPEGVideo
ts=MPEGVideo
tts=MPEGVideo
[ResponseResult]
ResultCode=0
}

context [
	set 'load_ini func [ini-file [string!] /nocomments] [
		ini-file-rule: [any [
			  newline
			| comment_
			| section-header ; must place this before attr rule
			| attr-value
			]
			to end
		]
		comment_: 		[";" copy name to newline newline
							(if not nocomments [repend parsed-ini-str [ {comment ";} name {" } newline]] )
						]
		section-header: ["[" copy name to "]" "]" newline
							(repend parsed-ini-str [to-tag name " [] " newline ] ) ; use tag to be sure it's a valid name
						]
		attr-value: 	[copy attr to "=" "=" copy value to newline newline
							(insert back back back tail parsed-ini-str reduce [newline to-tag attr " " value " " newline] ) ; use tag to be sure it's a valid name
						]

		parsed-ini-str: copy "["
		parse/all ini-str ini-file-rule
		append parsed-ini-str "]"
		;print parsed-ini-str
		load parsed-ini-str
	]
]

;test
ini-block: load_ini ini-str
insert ini-block/<Mail> [<attr_1> 3] ; or to-block load {^/ <attr_1> 3}
print ini-block/<Mail>/<attr_1>
ini-block/<Mail>/<attr_1>: 4
print ini-block/<Mail>/<attr_1>
remove/part find ini-block/<Mail> <attr_1> 2

probe ini-block

halt