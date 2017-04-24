REBOL [
	File: %zip-fix.r
	Date: 23-Dec-2003
	Title: "Zip-Fix"
	Author: "Vincent Ecuyer"
	Purpose: {Fixing broken zip archives}
	Notes: {
		- fix broken zip archives (partial downloads / disk errors ...)
		- extract data part from auto-extractible archive files
		- extract zip files from disk images, sectors dumps, ...
	}
	Usage: {
		Select the broken file,
		new files named <filename>-fixed.zip, <filename>-fixed-2.zip, ...
		will be builded in the same directory.
	}
 	Library: [
	        level: 'advanced
	        platform: 'all
	        type: [tool]
	        domain: [file-handling files compression]
	        tested-under: [
	        	view 1.2.1.3.1 on [Win2K]
	        	view 1.2.1.1.1 on [AmigaOS30]
	        	core 2.5.6.3.1 on [Win2K]
	        	core 2.5.0.1.1 on [AmigaOS30]
	        	base 2.5.4.3.1 on [Win2K]
	        ]
	        support: none
	        license: none
	        see-also: none
 	]
]

;signatures
local-file-sig: to-string #{504B0304}
central-file-sig: to-string #{504B0102}
end-of-central-sig: to-string #{504B0506}
data-descriptor-sig: to-string #{504B0708}

;funcs
to-ilong: func [value][
	to-binary rejoin [
    	to-char value and 255
    	to-char to-integer (value and 65280) / 256
    	to-char to-integer (value and 16711680) / 65536
    	to-char to-integer (value / 16777216)
    ]
]
to-iword: func [value][
	to-binary rejoin [
    	to-char value and 255
    	to-char to-integer value / 256
    ]
]
get-ilong: func [value][
	(to-integer value/4) * 256 +
	(to-integer value/3) * 256 +
	(to-integer value/2) * 256 +
	to-integer value/1
]
get-iword: func [value][
	(to-integer value/2) * 256 +
	to-integer value/1
]

entries: copy []
files: copy []
either all [value? 'view? view?] [
	if none? file: request-file/only/filter [
		"*.zip" "*.jar" "*.chk" "*.exe" "*.part"
	][quit]
][
	if empty? file: to-file ask "Archive name: " [quit]
]
if error? try [data: read/binary file][quit]
parse/all data [any [
	to local-file-sig
	(
		if any [empty? entries not empty? last entries][
			append/only entries copy []
		]
	)
	any [[
		local-file-sig
		a:
		copy version 2 skip
		copy flag    1 skip #"^@"
		copy method  1 skip #"^@"
		copy time    2 skip
		copy date    2 skip
		copy crc32   4 skip
 		copy size    4 skip
		copy uc-size 4 skip
		copy fn-size 2 skip (fn-size: get-iword fn-size)
		copy ef-size 2 skip (ef-size: get-iword ef-size)
		copy filename fn-size skip
		ef-size skip
		pos: (
			either all [
 				"^@^@^@^@" = size
				"^@^@^@^@" = uc-size
				(flag/1 and 8) <> #"^@"
			][
				append last entries to-binary copy/part a pos
				p: pos
				either size: find pos data-descriptor-sig [
					change (skip last last entries 10) (copy/part skip size 4 12)
					size: (index? size) - index? pos
					pos: skip pos size + 16
					change (skip last last entries 2) to-char flag/1 xor 8
					append last entries to-binary copy/part p size
				][
					size: (index? tail pos) - index? pos
                    if method/1 = #"^@" [
                    	append files to-file filename
                    	append files to-binary copy pos
                    	remove back tail last entries
					]
					pos: tail pos
				]
			][
				either ((flag/1 and 8) = #"^@") and not error? try [
					size: get-ilong size
					uc-size: get-ilong uc-size
				][
					append last entries to-binary copy/part a pos
            		append last entries to-binary copy/part pos size
            		if size <> length? last last entries [
            			if method/1 = #"^@" [
            				append files to-file filename
            				append files to-binary copy pos
            			]
            			remove/part skip tail last entries -2 2
    				]
            		pos: skip pos size
        		][
        			pos: find/case pos local-file-sig
        			if none? pos [pos: tail pos]
    			]
    		]
		) :pos
	] | local-file-sig]
]]

i: 1
foreach entry entries [
    result: copy #{}
    offsets: reduce [to-string #{00000000}]
    foreach [header content] entry [
        append result local-file-sig
    	append result header
    	append result content
        append offsets to-ilong length? result
    ]
    cd-offset: to-string to-ilong length? result
    cd-size: length? result
    foreach [header content] entry [
    	append result central-file-sig
    	append result copy/part header 2
    	append result copy/part header 26
    	append result #{00000000000000000000}
    	append result offsets/1
    	offsets: next offsets
    	append result skip header 26
    ]
    cd-size: to-string to-ilong (length? result) - cd-size
    nb-files: to-string to-iword to-integer (length? entry) / 2
    append result rejoin [
    	end-of-central-sig
    	to-string #{00000000}
    	nb-files nb-files
    	cd-size cd-offset
    	to-string #{0000}
    ]
    d-file: copy file
    change find/last d-file %. join %-fixed [either i = 1 [""][join %- i] %.zip]
    if not empty? entry [write/binary d-file result]
    i: i + 1
]

d-file: copy file
change find/last d-file %. %-fixed/

foreach [filename content] files [
	if not exists? join d-file first split-path filename [
		make-dir/deep join d-file first split-path filename
	]
	write/binary d-file/:filename content
]

quit
