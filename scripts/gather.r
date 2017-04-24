REBOL[
	Title: "gather"
	File: %gather.r
	Author: "ReBolek"
	Date: 30-6-2006
	Version: 0.2.0
	Purpose: {Eliminate the "result: copy [] ... append result value" dance.
		Similar to Gregg's 'collect but does not require the set-word notation.}
	library: [
		level: 'intermediate
		platform: 'all
		type: [function tool]
		domain: [shell]
		tested-under: [View 1.3.2 on WinXP]
		license: 'public-domain
		support: none
    ]
]

use [data][
	data: copy []
	gather: func [
		"Appends a value to the tail of a internal buffer and returns the buffer head."
		value "Value to append"
		/cmd "Treat value as command ('init, 'return, 'remove-first, 'remove-last)"
		/only "Append a block value as a block"
	][
		either cmd [
			switch value [
				init [clear data]
				return [return data]
				remove-first [remove head data]
				remove-last [remove back tail data]
			]
		][
			either only [
				append/only data value
			][
				append data value
			]
		]
		data
	]
]

;Examples

comment [
	
	gather/cmd 'init repeat i 10 [gather i]
	gather/cmd 'init repeat i 10 [gather/only reduce [i i * i]]
	
]