REBOL [
	Title: "REBOL Heavy Script Cleaner (Pretty Printer)"
	Date: 27-Mar-2005
	File: %clean-script-heavy.r
	Author: ["Carl Sassenrath" "Volker Nitsch"]
	Purpose: {
        Based on Carls %clean-script.r
        Cleans (pretty prints) REBOL scripts by parsing the REBOL code
        and supplying standard indentation and spacing.
      Breaks now every bracket/paren it finds (thus "heavy").
        If you have a really messed up script, 
        like %ascii-chart.r from the library, 
        you have a chance to make it readable. 
        Don't use with already readable Scripts..
        -Volker
    }
	History: [
		"Volker Nitsch" 1.2.0 27-Mar-2005 "Added heavy breaking of brackets"
		"Carl Sassenrath" 1.1.0 29-May-2003 {Fixes indent and parse rule.}
		"Carl Sassenrath" 1.0.0 27-May-2000 "Original program."
	]
	library: [
		level: 'intermediate
		platform: all
		type: [tool]
		domain: [text text-processing]
		tested-under: none
		support: none
		license: none
		see-also: none
	]
]

script-cleaner: make object! [

	out: none ; output text
	spaced: off ; add extra bracket spacing
	indent: "" ; holds indentation tabs

	emit-line: func [] [append out newline]

	emit-space: func [pos] [
		append out either newline = last out [indent] [
			pick [#" " ""] found? any [
				spaced
				not any [find "[(" last out find ")]" first pos]
			]
		]
	]

	emit: func [from to] [emit-space from append out copy/part from to]

	set 'clean-script func [
		"Returns new script text with standard spacing (pretty printed)."
		script "Original Script text"
		/spacey "Optional spaces near brackets and parens"
		/local str new
	] [
		spaced: found? spacey
		clear indent
		out: append clear copy script newline
		parse script blk-rule: [
			some [
				str:
				newline (emit-line) |
				#";" [thru newline | to end] new: (emit str new) |
				[#"[" | #"("] (
					if all [
						newline = last out #"|" <> pick tail out -2
					] [
						remove back tail out
					]
					emit str 1
					if newline <> second str [emit-line]
					append indent tab
				) blk-rule |
				[#"]" | #")"] (
					if all [newline <> last out] [emit-line]
					remove indent emit str 1
					if newline <> second str [emit-line]
				) break |
				skip (set [value new] load/next str emit str new) :new
			]
		]
		remove out ; remove first char

		if (load script) <> load out [
			make error! "script-semantic changed"
		]
		out

	]
]

;example:
print clean-script read %clean-script-heavy.r
halt