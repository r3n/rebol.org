Rebol [
	Name: 'Patches
	Title: "Patches"
	File: %patches.r
	Author: "A J Martin"
	Owner: "Aztecnology"
	Rights: "Copyright © 2003 A J Martin, Aztecnology."
	eMail: Rebol@orcon.net.nz
	Web: http://www.rebol.it/Valley/
	Tabs: 4
	Purpose: "Various patches to Rebol."
	Language: 'English
	Date: 11/August/2003
	Version: 1.4.0
    library: [level: 'intermediate
                platform: 'all
               type: [ tool]
               domain: [patch]
               tested-under: none
               support: none
               license: none
              see-also: none
            ]
	]

; Replacement 'Extract to work with series!, and better initial length.
Extract: function [
	"Extracts every n-th value from a series."
	Series [series!]
	Width [integer!] "Size of each entry (the skip)."
	/Index "Position to extract from." N [number! logic!]
	] [New] [
	if not Index [N: 1]
	New: make Series (length? Series) / Width
	forskip Series Width [
		insert/only tail New pick Series N
		]
	New
	]

; Replacement 'Alter.
Alter: function [
	{If a value is not found in a series, append it; otherwise, remove it.}
	Series [series! port!]
	Value [any-type!]
	] [Temp] [
	either Temp: find/only :Series :Value [
		remove Temp
		] [
		insert/only tail :Series :Value
		]
	:Series
	]

; Replacement 'Append.
Append: func [
    {Appends a value to the tail of a series and returns the series.}
    Series [series! port!]
    Value [any-type!]
    /Only "Appends a block value as a block."
    ][
    head either only [
        insert/only tail :Series :Value
        ] [
        insert tail :Series :Value
        ]
    :Series
    ]

; Replacement 'Repend.
Repend: func [
	{Appends a reduced value to a series and returns the series.}
	Series [series! port!]
	Value [any-type!]
	/Only "Appends a block value as a block."
	][
	either only [
		insert/only tail :Series reduce :Value
		] [
		insert tail :Series reduce :Value
		]
	:Series
	]

; Replacement 'function that adds 'throw-on-error.
Function: func [
	"Defines a user function with local words."
	[catch]
	Spec [block!] {Optional help info followed by arg words (and optional type and string)}
	Vars [block!] "List of words that are local to the function"
    Body [block!] "The body block of the function"
    ] [
	throw-on-error [make function! head insert insert tail copy spec /local vars body]
	]

; Enhanced 'Charset function to allow 'char! values.
Charset: func [
	"Makes a bitset of chars for the parse function."
	Chars [string! block! char!]
	][
	make bitset! Chars
	]

; Needed until very latest versions of Rebol are released.
if not value? 'as-pair [
	as-pair: func [
		"Combine X and Y values into a pair."
		x [number!] y [number!]
		][
		to-pair reduce [to-integer x to-integer y]
		]
	]

; Needed until very latest versions of Rebol are released.
decode-cgi: func [
	{Converts CGI argument string to a block of set-words and value strings.}
	args [any-string!] "Starts at first argument word."
	/local block name value here tmp
	][
	block: make block! 7
	parse/all args [
		any [
			copy name [to #"=" | to #"&" | to end] skip here: (
				if tmp: find name #"&" [
					here: skip here (offset? tmp name) - 2
					clear tmp
					]
				append block to-set-word name
				) :here [
				[copy value to #"&" skip | copy value to end]
				(
					append block either none? value [copy ""] [
						replace/all dehex replace/all value #"+" #" " crlf newline
						]
					)
				]
			]
		end
		]
	block
	]

; Needed until very latest versions of Rebol are released.
array: func [
	"Makes and initializes a series of a given size."
	size [integer! block!] "Size or block of sizes for each dimension"
	/initial "Specify an initial value for all elements"
	value "Initial value"
	/local block rest
	][
	if not initial [value: none]
	if block? size [
		rest: next size
		if tail? rest [rest: none]
		size: first size
		if not integer? size [make error! "Integer size required"]
		]
	block: make block! size
	either not rest [
		either series? value [
			loop size [insert/only block copy/deep value]
			] [
			insert/dup block value size
			]
		] [
		loop size [
			if series? value [value: copy/deep value]
			block: insert/only block array/initial rest value
			]
		]
	head block
	]

; Needed until very latest versions of Rebol are released.
if not value? 'sign? [
	sign?: func [
		{Returns sign of number as 1, 0, or -1 (to use as multiplier).}
		number [number! money! time!]
		][
		either positive? number [1] [either negative? number [-1] [0]]
		]
	]

; Needed until very latest versions of Rebol are released.
if not value? 'attempt [
	attempt: func [
		{Tries to evaluate and returns result or NONE on error.}
		value [block!]
		][
		if not error? set/any 'value try value [get/any 'value]
		]
	]

; Needed until very latest versions of Rebol are released.
if not value? 'build-markup [
	build-markup: func [
		{Return markup text replacing <%tags%> with their evaluated results.}
		content [string! file! url!]
		/quiet "Do not show errors in the output."
		/local out eval value
		][
		content: either string? content [copy content] [read content]
		out: make string! 126
		eval: func [val /local tmp] [
			either error? set/any 'tmp try [do val] [
				if not quiet [
					tmp: disarm :tmp
					append out reform ["***ERROR" tmp/id "in:" val]
					]
				] [
				if not unset? get/any 'tmp [append out :tmp]
				]
			]
		parse/all content [
			any [
				end break
				| "<%" [copy value to "%>" 2 skip | copy value to end] (eval value)
				| copy value [to "<%" | to end] (append out value)
				]
			]
		out
		]
	]

; Needed until very latest versions of Rebol are released.
if not value? 'component? [
	component?: func [
		"Returns specific REBOL component info if enabled."
		name [word!]
		][
		find system/components name
		]

]



