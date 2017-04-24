REBOL [
	Title: "Minify"
	Date: 21-Aug-2012
	File: %minify.r
	Author: "Christopher Ross-Gill"
	Purpose: "Strips Whitespace and Comments from a Script"
	Library: [
		Level: 'beginner
		Platform: 'all
		Type: [function idiom module tool]
		Domain: [ldc parse text-processing]
		License: 'cc-by-sa
	]
]

minify: func [
	"Strips Whitespace and Comments from a Script." [catch]
	script [file! url! string!] "Script to be minified."
	/feed "Use newlines instead of spaces to separate values."
	/local out val rule ws mk ex
][
	throw-on-error [
		case/all [
			any [file? script url? script][script: read script]
			string? script [
				if error? val: try [load script][
					; to correctly report a minify failure
					val: disarm val
					make error! reduce ['syntax val/id val/arg1 val/arg2]
				]
			]
			not string? script [make error! "Unable to read script"]
		]
	]

	out: copy ""
	ws: charset "^/^-^M "
	script: trim/head/tail copy script

	either parse/all script rule: [
		some [
			mk:
			#";" [thru newline | to end] ex:
			; (append out copy/part mk ex])
			| [#"[" | #"("] any ws (append out mk/1) rule
			| any ws mk: [#"]" | #")"] (append out mk/1) break
			| some ws (append out either feed ["^/"][" "])
			| #"^@" to end
			| skip (
				set [val ex] load/next mk
				append out copy/part mk ex
			) :ex
		]
	][
		:out
	][
		throw make error! "Unable to Parse Script"
	]
]