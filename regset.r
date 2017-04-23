REBOL[
	Title: "Regset - Regular expression convertor to bitset!"
	Purpose: "Make bitset from simple regex-like dialect."
	Date: 31-5-2007
	File: %regset.r
	Author: "Boleslav Brezovsky"
	Version: 0.1.0
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tutorial function dialect]
		domain: [dialects  parse shell text text-processing files]
		tested-under: none
		support: none
		license: 'public-domain
		see-also: none
	]
]

ctx-regex: context [

	make-subrule: func [pairs /local out][
		out: copy []
		foreach [i o] pairs [
			repend out [i to paren! compose either paren? o [[out: union out (do o)]][[insert out (o)]] '| ]
		]
		head remove back tail out
	]

	whitespaces-: make-subrule [
		"\t" #"^-"	;TAB
		"\r" #{0D}	;CR
		"\n" #{0A}	;LF
		"\a" #{07}	;bell
		"\e" #{1B}	;escape
		"\f" #{0C}	;form feed
		"\v" #{0B}	;vertical tab
	]
	char-groups-: make-subrule [
		"\d" (regset "0-9")
		"\D" (regset "~\d")
		"\w" (regset "0-9a-zA-Z_")
		"\W" (regset "~\w")
		"\s" (regset "\t\n\r\f\v")
		"\S" (regset "~\s")
	]
	escaped-chars-: make-subrule [
		"\*" #"*"
		"\+" #"+"
		"\." #"."
		"\?" #"?"
		"\[" #"["
		"\]" #"]"
		"\(" #"("
		"\)" #")"
		"\{" #"{"
		"\/" #"/"
		"\|" #"|"
		"\\" #"\"
		"^^" #"^^"
]

	set 'regset func [
		"Translates regex group to bitset! (case-sensitive by default)"
		expression [string!] "Regex group (i.e.: [a-z], [0-9-] ...). Square brackets are optional."
		/local out negate? b e c x
	] [
		negate?: false
		out: make bitset! []
		bind char-groups- 'out
		bind whitespaces- 'out
		bind whitespaces- 'out
		parse/all/case expression [
			opt #"["
			opt [["~" | "^^"] (negate?: true)]
			some [
				copy c [escaped-chars-] (c)
			|	copy c [char-groups-] (c)
			|	copy c [whitespaces-] (c)
			|	"-" (insert out #"-")
			|	"\x" c: 2 skip (insert out load head append insert head copy/part c 2 "#{" "}" )
			|	b: skip "-" e: skip (
					b: first b  e: first e
					either b > e [
						insert out e
						repeat x b - e [insert out e + x]
					] [
						insert out b
						repeat x e - b [insert out b + x]
					]
				) |
				x: skip (insert out first x)
			]
			opt #"]"
		]
		if negate? [out: complement out]
		out
	]
]