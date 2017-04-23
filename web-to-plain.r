Rebol[
	Title: "web to plain"
	Author: "Tom Conlin"
	Version: 1.0.0
	File: %web-to-plain.r
	Date:   14-Mar-2003
	Purpose: { to translate htmlized text into plain text in one pass
		markdown?
	}

	Warning: { this does NOT handle ALL char-entites above 255
		or most charsets ... thanks to Chris Ross-Gill
		for help with the chars below 160 and above 255
		http://www.ross-gill.com/techniques/entities/

		unreconized entities are passed as is
	}
	Example: {
	page: load/markup http://www.sandia.gov/sci_compute/iso_symbol.html
	buffer: copy "" foreach thing page[if not tag? thing[append buffer thing]]
	web-to-plain buffer
	probe buffer
	}
	Category: [web]
	library: [
        level: 'intermediate
        platform: none
        type: 'function
        domain: [web markup internet HTML]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
    Usage: [
	web-to-plain {old hat &amp; new hat; red hat &amp; blue hat &amp;&foo;}
    ]
]

web-to-plain: func [ content [string!]
	/local c-e keyset-a keyset-1 entity key value i j][

c-e: [
"euro" "" "sbquo" "fnof" "bdquo" "hellip" "dagger" "Dagger" "circ" "permil"
"Scaron" "lsaquo" "OElig" "" "" "" "" "lsquo" "rsquo" "ldquo" "rdquo" "bull"
"ndash" "mdash" "tilde" "trade" "scaron" "rsaquo" "oelig" "" "" "Yuml"
"nbsp" "iexcl" "cent"  "pound" "curren" "yen" "brvbar" "sect" "uml" "copy"
"ordf" "laquo" "not" "shy" "reg" "macr" "deg" "plusmn" "sup2" "sup3" "acute"
"micro" "para" "middot" "cedil" "sup1" "ordm" "raquo" "frac14" "frac12"
"frac34" "iquest" "Agrave" "Aacute" "Acirc" "Atilde" "Auml" "Aring" "AElig"
"Ccedil""Egrave" "Eacute" "Ecirc" "Euml" "Igrave" "Iacute" "Icirc" "Iuml"
"ETH" "Ntilde" "Ograve" "Oacute" "Ocirc" "Otilde" "Ouml" "times" "Oslash"
"Ugrave" "Uacute" "Ucirc" "Uuml" "Yacute" "THORN" "szlig" "agrave" "aacute"
"acirc" "atilde" "auml" "aring" "aelig" "ccedil" "egrave" "eacute" "ecirc"
"euml" "igrave" "iacute" "icirc" "iuml" "eth""ntilde" "ograve" "oacute"
"ocirc" "otilde" "ouml" "divide" "oslash" "ugrave" "uacute"  "ucirc" "uuml"
"yacute" "thorn" "yuml"]

exception-to-char: [
"gt" 62 "lt" 60 "amp" 38 "quot" 34
"ensp" 32 "emsp" 32 "sp" 32 "ldots" 133
"8364" 128 "8218" 130 "8222" 132 "8224" 134 "8225" 135 "710" 136 "8240" 137
"352" 138 "8249" 139 "338" 140 "8216" 145 "8217" 146 "8220" 147 "8221" 148
"8211" 150 "8212" 151 "732" 152 "8482" 153 "353" 154 "8250" 155 "339" 156
"376" 159]

keyset: charset {abcdefghijklmnopqrstuvwxyz0123456789}

parse content [
	any [ (key: copy ""  value: none)
		to "&" mark:		[
			[ "&"	copy key [some keyset] ";"
			(	either value: select exception-to-char key
				[	remove/part next :mark (length? key) + 1
					change :mark to-string to-char value
				]
				[	if all[key <> "" j: find/case c-e key][
						value: (index? j) + 127
						remove/part next :mark (length? key) + 1
						change :mark to-string to-char value
					]
				]
				mark: next :mark
			):mark
			]|["&#" copy key integer! ";"
			( 	i: to-integer key
				if all[i > 255 j: select exception-to-char key][i: j]
		  		if all[i >= 0 i <= 255][
					remove/part next :mark (length? key) + 2
					change :mark to-string to-char i
				]
				mark: next :mark
			):mark
			]| "&"
		]
	]
]
content
]




