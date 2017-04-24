REBOL [
    Title: "eText"
    Date: 3-Sep-2002
    Name: 'eText
    Version: 1.2.1
    File: %etext.r
    Author: "Andrew Martin"
    Needs: [
    %Common%20Parse%20Values.r 
    %ML.r
]
    Purpose: "Processes plain text to HTML."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: [file-handling text-processing] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

make object! [
	Link_Base: none
	Link_Wiki: false
	Space: charset [#" " #"^-"]
	Separator: charset [#"." #"!" #" " #"," #"?" #";" #":"]
	Empty: [any Space newline]
	Inline!: make object! [
		Text: Block: Before: After: none
		Plain: function [Value [block! string! tag! none!]][String][
			String: copy/part Before After
			if not empty? String [
				append Block String
				]
			if not none? Value [
				repend Block Value
				]
			]
		Pair: function [Mark [char!] HtmlDialect [block!]][NonMark Temporary][
			NonMark: exclude Graphic charset to string! Mark
			compose/deep [
				Temporary: (Mark) copy Text [some (NonMark) any [opt #" " some (NonMark)]]
				(Mark)
				(to-paren reduce ['Plain HtmlDialect])
				(to-paren [After: Temporary])
				Before:
				]
			]
		Link: make object! [
			Word: [Alpha any [AlphaDigit | #"-"] opt {'s} opt #"/"]
			Text: Link: URL: none
			URL_Mail: func [URL [string!]] [
				if 2 <= length? URL [
					URL: first load/next URL
					if email? URL [URL: join "mailto:" URL]
					]
				URL
				]
			ImageAnchor: func [Text [string!] URL [string!]][
				URL: URL_Mail URL
				all [
					file? URL
					URL: join Link_Base URL
					]
				Plain either any [
					found? find/last URL %.jpg
					found? find/last URL %.gif
					found? find/last URL %.png
					][
					['img/src URL]
					][
					['a/href URL Text]
					]
				]
			Rule: [
				[
					After: [
						#"^"" copy Text to #"^"" skip
						#" " [
							#"%" #"^"" copy Link to #"^"" skip (
								insert replace/all Link #" " "%20" #"%"
								)
							| copy Link URI
							]
						#" " copy URL URI
						](
						Link: first load/next Link
						all [
							file? Link
							Link: join Link_Base Link
							]
						Plain [
							'a/href URL_Mail URL reduce [
								'img/src Link Text
								]
							]
						) Before:
					]
				| [
					After: [
						{"} copy Text to {" } {" } [
							#"%" #"^"" copy Link to #"^"" skip (
								insert replace/all Link #" " "%20" #"%"
								)
							| copy Link URI
							]
						] (ImageAnchor Text Link) Before:
					]
				| After: copy Link URI (ImageAnchor copy Link Link) Before:
				| [
					After: [
						{?"} copy Link to {"} skip
						| "?" copy Link Word
						](
						Text: copy Link
						Link: rejoin [
							Link_Base
							to-file replace/all Link #" " "%20"
							either Link_Wiki [""] [
								either #"/" = last Link [%index.html][%.html]
								]
							]
						Plain ['a/href Link Text]
						) Before:
					]
				]
			]
		DoubleQuote: make object! [
			Mark: #"^""
			NonMark: exclude Graphic charset to-string Mark
			Rule: [
				After: Mark copy Text [NonMark any [NonMark | #" "]] Mark (
					Plain [rejoin ["&#147;" Text "&#148;"]]
					) Before:
				]
			]
		SingleQuote: make object! [
			Mark: #"'"
			Div: none
			NonMark: exclude Graphic charset to-string Mark
			Rule: [
				After: #" " Mark copy Text [NonMark some [NonMark | #" "]]
					Mark copy Div Separator(
					Plain [rejoin [#" " "&#145;" Text "&#146;" Div]]
					) Before:
				]
			]
		Superscript: make object! [
			Rule: [
				After: #"^^" copy Text [some Alpha | Digits] (
					Plain reduce [<sup> <small> Text </small> </sup>]
					) Before:
				]
			]
		Single: func [Mark [string! char!] Replacement [string!]][
			compose [After: (Mark) (to-paren compose [Plain (Replacement)]) Before:]
			]
		Rules: compose [
			(Link/Rule)
			| (DoubleQuote/Rule)
			| (SingleQuote/Rule)
			| (Pair #"_" ['u Text])
			| (Pair #"~" ['i Text])
			;| (Pair #"+" ['ins Text])
			;| (Pair #"-" ['del Text])	; Need a better choice for 'Del, not hyphen.
			| (Pair #"*" ['b Text])
			| (Single newline "<br />")
			| (Single {---} "&mdash;")
			| (Single {--} "&ndash;")
			| (Single {&} "&amp;")
			| (Single {<} "&lt;")
			| (Single {>} "&gt;")
			| (Single {(c)} "&copy;")	| (Single {(C)} "&copy;")
			| (Single {(r)} "&reg;")	| (Single {(R)} "&reg;")
			| (Single {(tm)} "&trade;")	| (Single {(TM)} "&trade;")
			| (Single {-tm} "&trade;")	| (Single {-TM} "&trade;")
			| (Single {A^^`} {&Agrave;}) |	(Single {a^^`} {&agrave;})
			| (Single {A^^'} {&Aacute;}) |	(Single {a^^'} {&Aacute;})
			| (Single {A^^~} {&Atilde;}) |	(Single {a^^~} {&atilde;})
			| (Single {A^^"} {&Auml;}) |	(Single {a^^"} {&auml;})
			| (Single {A^^*} {&Aring;}) |	(Single {a^^*} {&aring;})
			| (Single {A^^E} {&AElig;}) |	(Single {a^^e} {&aelig;})
			| (Single {,C} {&Ccedil;}) |	(Single {,c} {&ccdel;})
			| (Single {E^^`} {&Egrave;}) |	(Single {e^^`} {&egrave;})
			| (Single {E^^'} {&Eacute;}) |	(Single {e^^'} {&eacute;})
			| (Single {E^^"} {&Euml;}) |	(Single {e^^"} {&euml;})
			| (Single {I^^`} {&Igrave;}) |	(Single {i^^`} {&igrave;})
			| (Single {I^^'} {&Iacute;}) |	(Single {i^^'} {&iacute;})
			| (Single {I^^"} {&Iuml;}) |	(Single {i^^"} {&iuml;})
			| (Single {D^^-} {&ETH;}) |	(Single {d^^-} {&eth;})
			| (Single {N^^~} {&Ntilde;}) |	(Single {n^^~} {&ntilde;})
			| (Single {O^^`} {&Ograve;}) |	(Single {o^^`} {&ograve;})
			| (Single {O^^'} {&Oacute;}) |	(Single {o^^'} {&oacute;})
			| (Single {O^^~} {&Otilde;}) |	(Single {o^^~} {&otilde;})
			| (Single {O^^"} {&Ouml;}) |	(Single {o^^"} {&ouml;})
			| (Single {O^^/} {&Oslash;}) |	(Single {o^^/} {&oslash;})
			| (Single {O^^E} {&OElig;}) |	(Single {o^^e} {&oelig;})
			| (Single {U^^`} {&Ugrave;}) |	(Single {u^^`} {&ugrave;})
			| (Single {U^^'} {&Uacute;}) |	(Single {u^^'} {&uacute;})
			| (Single {U^^"} {&Uuml;}) |	(Single {u^^"} {&uuml;})
			| (Single {Y^^'} {&Yacute;}) |	(Single {y^^'} {&yacute;})
			| (Single {Y^^"} {&Yuml;}) |	(Single {y^^"} {&yuml;})
			| (Single {S^^z} {&szlig;})
			| (Single {P|} {&THORN;}) |	(Single {p|} {&thorn;})
			| (Single {~!} {&iexcl;}) |	(Single {~?} {&iquest;})
			| (Single {c^^/} {&cent;}) |	(Single {L^^-} {&pound;})
			| (Single {Y^^-} {&Yen;})
			| (Single {o^^$} {&curren;})
			| (Single {||} {&brvbar;})
			| (Single {<<} {&laquo;})	| (Single {>>} {&raquo;})
			| (Single {-,} {&not;})
			| (Single {^^-} {&macr;})	| (Single {^^o} {&deg;}) | (Single {^^o-} {&ordm;})
			; { 1/4 } { &frac14; }	{ 1/2 } { &frac12; }	{ 3/4 } { &frac34; }
			| (Single {''} {&acute;})
			| (Single {^^/u} {&micro;})
			| (Single {P^^!} {&para;})
			| (Single {sO} {&sect;})
			| (Single {^^.} {&middot;})
			| (Single {,,} {&cedil;})
			| (Single {...} {&hellip;})
			| (Single { +- } { &plusmn; })
			| (Single { * } { &times; })
			| (Single {-:} {&divide;})
			;| (Single { / } { &divide; })	; Slash is often used as a divider or alternative.
			| (Single {A^^} {&Acirc;})	| (Single {a^^} {&acirc;})
			| (Single {E^^} {&Ecirc;})	| (Single {e^^} {&ecirc;})
			| (Single {I^^} {&Icirc;})	| (Single {i^^} {&icirc;})
			| (Single {O^^} {&Ocirc;})	| (Single {o^^} {&ocirc;})
			| (Single {U^^} {&Ucirc;})	| (Single {u^^} {&ucirc;})
			;{ pi } {&pi;}
			| (Single {sqrt} {&radic;})	; {<font face="symbol">&#214;</font>}
			| (Superscript/Rule)
			| skip
			]
		Dialect: func [String [string!]][
			Block: make block! 10
			Before: String
			After: none
			parse/case/all String [some Rules (Plain None) end]
			either empty? Block [
				String
				][
				Block
				]
			]
		Literal-Rules: compose [
			(Single {&} "&amp;")
			| (Single {<} "&lt;")
			| (Single {>} "&gt;")
			| skip
			]
		Literal: func [String [string!]][
			Block: make block! 10
			Before: String
			After: none
			parse/case/all String [some Literal-Rules (Plain None) end]
			either empty? Block [
				String
				][
				Block
				]
			]
		]
	Inline: get in Inline! 'Dialect
	Literal: get in Inline! 'Literal
	Line: Heading: Block: Previous: none
	Text-Line: [Graphic any Printable]
	Text: [copy Line Text-Line empty]
	H: [
		opt Empty
		Text
		[
			some "*" (Heading: 'h1)
			| some "=" (Heading: 'h2)
			| some "-" (Heading: 'h3)
			| some "~" (Heading: 'h4)
			| some "_" (Heading: 'h5)
			| some "." (Heading: 'h6)
			] empty (repend Block [Heading Inline Line])
		]
	IP: [Text (repend Block ['p/class "Initial" Inline Line])]
	RP: [2 Empty Text (repend Block [<br /> 'p/class "Initial" Inline Line])]
	P: [[Empty | tab | #" "] Text (repend Block ['p Inline Line])]
	Align!: make object! [
		Type: 'left
		Rule: [#" " (Type: 'center) | tab (Type: 'right) | none (Type: 'left)]
		]
	Align: Align!/Rule
	Center: make object! [
		Lines: make block! 10
		Rule: [
			some [
				#" " copy Line [Graphic any Printable] empty (
					if not empty? Lines [
						append Lines <br />
						]
					append Lines Inline Line
					)
				](
				repend Block ['div/align "center" Lines]
				Lines: make block! 10
				)
			]
		]
	Table: make object! [
		Type: 'th
		Mark: #"|"
		NonBar: exclude Printable charset to-string Mark
		Cells: make block! 10
		BarCell: [Align copy Line any NonBar any [#" " | tab]]
		TabCell: [Align copy Line any Printable]
		Append-Cell: does [
			repend Cells [
				make path! reduce [Type 'align] Align!/Type
				either none? Line [""][Inline trim Line]
				]
			]
		Row: [
			[
				opt [some [Mark some #"-"] opt Mark empty]
				some [Mark BarCell (Append-Cell)] opt Mark empty
				]
			| TabCell (Append-Cell) some [tab TabCell (Append-Cell)] empty
			]
		Rows: make block! 10
		Rule: [
			opt Empty
			(
				Type: 'th
				Rows: make block! 10
				Cells: make block! 10
				)
			some [
				Row (
					repend Rows ['tr Cells]
					Type: 'td
					Cells: make block! 10
					)
				] (
				repend Block ['table Rows]
				)
			]
		]
	Quote: make object! [
		Quotes: make string! 100
		Rule: [
			opt Empty
			some [
				2 [tab | #" "] copy Line some [Printable | tab] empty (
					append Quotes rejoin [trim/tail Line newline]
					)
				] (
				repend Block ['blockquote reduce ['pre Literal detab Quotes]]
				clear Quotes
				)
			]
		]
	BlockQuote: make object! [
		Center: no
		NonQuote: exclude Graphic charset {"}
		Lines: make block! 10
		Common: function [L [string! block!]] [bq] [
			bq: [
				'i reduce [
					'blockquote either string? L [inline L] [L]
					]
				]
			repend Block either Center [
				[
					'div/align "center" reduce bq
					]
				] [
				bq
				]
			Center: no
			]
		Rule: [
			[
				opt [#" " (Center: true)] (Lines: make block! 10)
				#"^"" copy Line [some [NonQuote | { "} | {" } | { }]] #"^"" empty (
					Common Line
					)
				]
			| [
				opt [#" " (Center: true)] (Lines: make block! 10)
				#"^"" copy Line [some [NonQuote | { "} | {" } | { }]] empty (
					repend Lines [Line <br />]
					)
				any [
					opt #" " copy Line [some [NonQuote | { "} | {" } | { }]] empty (
						repend Lines [Line <br />]
						)
					]
				opt #" " copy Line [some [NonQuote | { "} | {" } | { }]] #"^"" empty (
					append Lines Line
					Common Lines
					)
				]
			]
		]
	List: make object! [
		ULI: [#"*" [tab | #" "] Text]
		OLI: [#"0" [tab | #" "] Text]
		Term: Definition: none
		DT: [copy Term Text-Line empty]
		DD: [[tab | #" "] copy Definition Text-Line empty]
		Br: [opt Empty]
		Item: func [Block [block!] /DL][
			repend Block either DL [
				['dt Inline Term 'dd Inline Definition]
				] [
				['li Inline Line]
				]
			]
		Nest: func [Outer [block!] 'Word [word!] Items [block!]][
			repend Outer [Word Items]
			make block! length? Items
			]
		LIs: make block! 1
		UL: [some [Br ULI (Item LIs) | UL1 | OL1 | DL1] (LIs: Nest Block ul LIs)]
		OL: [some [Br OLI (Item LIs) | OL1 | UL1 | DL1] (LIs: Nest Block ol LIs)]
		DL: [some [Br DT DD (Item/DL LIs) | DL1 | UL1 | OL1] (LIs: Nest Block dl LIs)]
		Tab1: [tab | #" "]
		LI1s: make block! 1
		UL1: [some [Br Tab1 ULI (Item LI1s) | UL2 | OL2 | DL2] (LI1s: Nest LIs ul LI1s)]
		OL1: [some [Br Tab1 OLI (Item LI1s) | OL2 | UL2 | DL2] (LI1s: Nest LIs ol LI1s)]
		DL1: [some [Br Tab1 DT Tab1 DD (Item/DL LI1s) | DL2 | UL2 | OL2] (LI1s: Nest LIs dl LI1s)]
		Tab2: [2 Tab1]
		LI2s: make block! 1
		UL2: [some [Br Tab2 ULI (Item LI2s) | UL3 | OL3 | DL3] (LI2s: Nest LI1s ul LI2s)]
		OL2: [some [Br Tab2 OLI (Item LI2s) | OL3 | UL3 | DL3] (LI2s: Nest LI1s ol LI2s)]
		DL2: [some [Br Tab2 DT Tab2 DD (Item/DL LI2s) | DL3 | UL3 | OL3] (LI2s: Nest LI1s dl LI2s)]
		Tab3: [3 Tab1]
		LI3s: make block! 1
		UL3: [some [Br Tab3 ULI (Item LI3s) | UL4 | OL4 | DL4] (LI3s: Nest LI2s ul LI3s)]
		OL3: [some [Br Tab3 OLI (Item LI3s) | OL4 | UL4 | DL4] (LI3s: Nest LI2s ol LI3s)]
		DL3: [some [Br Tab3 DT Tab3 DD (Item/DL LI3s) | DL4 | UL4 | OL4] (LI3s: Nest LI2s dl LI3s)]
		Tab4: [4 Tab1]
		LI4s: make block! 1
		UL4: [some [Br Tab4 ULI (Item LI4s) | UL5 | OL5 | DL5] (LI4s: Nest LI3s ul LI4s)]
		OL4: [some [Br Tab4 OLI (Item LI4s) | OL5 | UL5 | DL5] (LI4s: Nest LI3s ol LI4s)]
		DL4: [some [Br Tab4 DT Tab4 DD (Item/DL LI4s) | DL5 | UL5 | OL5] (LI4s: Nest LI3s dl LI4s)]
		Tab5: [5 Tab1]
		LI5s: make block! 1
		UL5: [some [Br Tab5 ULI (Item LI5s) | UL6 | OL6 | DL6] (LI5s: Nest LI4s ul LI5s)]
		OL5: [some [Br Tab5 OLI (Item LI5s) | OL6 | UL6 | DL6] (LI5s: Nest LI4s ol LI5s)]
		DL5: [some [Br Tab5 DT Tab5 DD (Item/DL LI5s) | DL6 | UL6 | OL6] (LI5s: Nest LI4s dl LI5s)]
		Tab6: [6 Tab1]
		LI6s: make block! 1
		UL6: [some [Br Tab6 ULI (Item LI6s) | UL7 | OL7 | DL7] (LI6s: Nest LI5s ul LI6s)]
		OL6: [some [Br Tab6 OLI (Item LI6s) | OL7 | UL7 | DL7] (LI6s: Nest LI5s ol LI6s)]
		DL6: [some [Br Tab6 DT Tab6 DD (Item/DL LI6s) | DL7 | UL7 | OL7] (LI6s: Nest LI5s dl LI6s)]
		Tab7: [7 Tab1]
		LI7s: make block! 1
		UL7: [some [Br Tab7 ULI (Item LI7s)] (LI7s: Nest LI6s ul LI7s)]
		OL7: [some [Br Tab7 OLI (Item LI7s)] (LI7s: Nest LI6s ol LI7s)]
		DL7: [some [Br Tab7 DT Tab7 DD (Item/DL LI7s)] (LI7s: Nest LI6s dl LI7s)]
		Rule: [opt Empty [UL | OL | DL]]
		]
	VerticalSpace: [some [empty (append Block 'br)]]
	Statements: make object! [
		Lines: make block! 1
		Rule: [
			some [Text (append Lines append Inline Line <br />)] (
				remove back tail Lines
				repend Block ['p/class "Initial" Lines]
				Lines: make block! 10
				)
			]
		]
	BulletDivider: [
		Empty " *" empty Empty (
			append Block [
				<br /> div/align "center" "&#149;" <br />
				]
			)
		]
	LineDivider: [
		Empty 3 #"-" any #"-" empty Empty (append Block <hr />)
		]
	Rules: compose/deep [
		any [
			BulletDivider
			| LineDivider
			| H opt [(Quote/Rule) | (List/Rule)| (Table/Rule) | (BlockQuote/Rule) | IP]
			| (Quote/Rule)
			| (List/Rule)
			| (Table/Rule)
			| (BlockQuote/Rule)
			| (Center/Rule)
			| RP
			| P
			| VerticalSpace
			| (Statements/Rule)
			]
		end
		]
	set 'eText func [
		"Processes plain text into HTML."
		eText [string!]	"The plain text."
		/Wiki	"Format for a Wiki."
		/Base Base_URL [url! file! string!]	"Base URL for references."
		][
		Link_Wiki: Wiki
		Link_Base: either Base [Base_URL] [""]
		Block: make block! 1000
		if not empty? eText [
			if newline <> last eText [append eText newline]
			parse/all eText Rules
			]
		Block
		]
	]
