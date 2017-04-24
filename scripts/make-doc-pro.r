Rebol [
	Title: "make-doc-pro"
	Version: 1.0.8
	Date: 13-Jan-2004
	File: %make-doc-pro.r
	Author: "Robert M. Münch"
	Email: robert.muench@robertmuench.de
	Home: http://www.robertmuench.de/projects/mdp/
	Copyright: {This parser can be freely used for non-commercial purposes.
		For commercial use, you have to contact the author.
	}
	Purpose: {Parses the make-doc-pro markup language into a
		datastructure that can be into other
		document formats (such as HTML) with good titles, table
		of contents, section headers, indented fixed-spaced
		examples, bullets and definitons.
	}
	Category: [file markup text util 4]
	Library: [
		level: 'advanced
		platform: 'all
		type: [dialect tool]
		domain: [dialects files html markup parse text text-processing web xml]
		tested-under: [view 1.2.8 [W2K XP]]
                   support: "See Rebol header"
                   license: "See Rebol header"
	]
	Note: {Based on make-doc.r from Carl Sassenrath, Rebol Technologies Inc.}
]

; do %../rm_library.r

;{
;-- Library paste BEGIN
split: func ["Splits value" v [series!] rest [series!] /last] [
    rest: either last [find/last v: copy v rest][find v: copy v rest]
    if rest [clear rest] v
]

; Stack Datastructure Object
stack!: make object! [
	stack: make block! []

	push: func['value][
		either (type? value) == block!
			[insert/only stack value]
			[insert stack value]
	]

	pop: does [
		either (length? stack) > 0
		[
			value: first stack
			remove stack
			return value
		]
		[return none]
	]

	top: does [
		if not empty? [return first stack]
	]

	empty?: does [
		either (length? stack) == 0 [return true][return false]
	]

	ontop?: func ['value][
		either value == top [return true][return false]
	]

	instack?: func ['value][
		either result: find stack value [return index? result][return none]
	]

	reset: does [
		clear stack
	]

	size: does [
		return length? stack
	]

	debug: does [
		foreach entry stack [probe entry]
	]

; 	insert: func ['value][
; 		either (type? value) == block!
; 			[insert/only tail stack value]
; 			[insert tail stack value]
; 	]
]


;--- Additional Functions

assert: func[ test [block!] text [string!]][
	if not reduce test [
		print reduce ["Asssert:" text "failed!"]
	]

	exit
]

pif: func [[throw] {polymorphic if, minimum checking, no default, compatible
	with:
	  computed blocks,
	  Return
	  Exit
	  Break
	  non-logic conditions
  }
	args [block!]] [
    if not unset? first args: do/next args [
        either first args
        	[either block? first args: do/next second args
        		[do first args]
        		[first args]
        	]
        	[pif second do/next second args]
    ]
]

;-- Library paste END
;}


;-- global data
; debug_mode: true
debug_mode: false
; light_mode: true
; light_mode: false

;--- make-doc-pro parser
mdp-parser: context [
	mdp-stack: 		make stack! []	; storage to hold the mdp datastructure that will be the result of the parsing
	inline-stack: make stack! []	; storage to hold mdp inline markup block
	active-stack: mdp-stack				; reference to active stack

	skip-counter: 0								; counter how many chars of the input stream have been skipped (should be 0)
	rule-names: 	make stack! [] 	; used to store rule-names for debugging
	lastemitted: none							; stores the last emitted name
	lastcode: none								; last parsed code

	;--Flags
	debugparse: true				; if true the mdp-parser will print debug messages
	debugparse: false				; if true the mdp-parser will print debug messages
	flags: make stack! []		; stack of flags that are used to control the parser

	;--MDP-Stack handling
	emit: func ['name value /local tmp] [
		; trim all obsolete spaces
	  if string? value [
	  	if (back tail value) == " " [
	  		trim/tail value
	  		if value = "" [exit]
	  		append value " "
	  	]
	  ]

		; pack name value into a block
		tmp: reduce to-block [name value]

		; and push this as block onto the stack
		active-stack/push 	:tmp

		lastemitted: name
	]

	emit-section: func [num /local tmp] [tmp: to-word join "sect" num emit :tmp text]

	;--Helper functions
	init: does [
		mdp-stack/reset
		inline-stack/reset
		active-stack/reset
		rule-names/reset
		flags/reset

		lastcode: lastemitted: none
		skip-counter: 0

		; reset parse rule as this rule is altered after parsing the header
;		titlerule: either light_mode [copy ["~~~"]][copy [opt "~~~"]]
		titlerule: copy [opt "~~~"]
	]

	inputstream: func [width [integer!]][print ["###" mold copy/part mark width]]

	; debug just pushes the rule-name onto the stack
	; this function might be called many times more than debugo that pops a value from the stack
	; therefore we first make a pop and then a push, the first pop will be on an empty stack but that's ok per definition: nothing will happen

	debug: func ['rule-name][]
;	debug: func ['rule-name][rule-names/pop rule-names/push rule-name]

	; debug-out prints the rule-name; this indicates that the rule was called
	debugo: func [value][]
;	debugo: func [value][print reduce ["-->" rule-names/pop "--" mold value]]

	insert-file: func [str file /local text] [
      if file/1 = "%" [remove file]

			; try to read the include file
      pif [
      	exists? file 								[text: read file]
      	exists? join mdp-path file	[text: read join mdp-path file]
      	true												[alert reform ["Missing include file:" file] exit]
			]


			; insert the text from the include file up the end specifier or to the end
      insert/part str text any [find text "^/###" tail text]
  ]

	inline-parsing: func [text][
		if none? text [exit]

		lastemitted_tmp: lastemitted
		active-stack: inline-stack

		either debugparse
			[
				print ["Inline-Parsing:" text]
				print ["Inline-Parsing correct:" parse/all text inlinemarkup]
			]
			[parse/all text inlinemarkup]

		active-stack: mdp-stack
		lastemitted: lastemitted_tmp

		either debugparse
			[reverse inline-stack/stack print ["Inline-Stack:" mold inline-stack/stack]]
			[reverse inline-stack/stack]
	]

  ;
	;--make-doc-pro parsing rules
	;

	pdebug: [here: (prin "pdebug:" probe copy/part here 35)]

	;Parsing storage variables
	text: none		; stores parsed text sequences
	para: none		; stores paragraph parts

	;Charactersets
	space: 	charset " ^-"
	spaces: [any space]

	nochar: charset " ^-^/"
	chars: 	complement nochar

	;Helper rules
	line: 		[copy text to newline]		; copy the text from the actual stream position up to | or 'newline' (not including these chars) into 'text. The | is need because of table handling
	paragraph:[copy para some [chars [to newline | to end]]]
	word: 		[some space copy text some chars] 	; skip spaces and copy all characters until the next whitespace

	example:   	[copy code some [indented | some newline indented] (lastcode: copy code)]
	indented:  	[some space chars to newline ]

	; this rule is used to parse the first line of a document which is the title. The title can either
	; be marked with ~~~ or nothing. A title starting with no markup is only allowed once in a document.
	; This rule is changed to ["~~~"] after the title has been parsed by removing 'opt
	titlerule: [opt "~~~"]

;--- Main rules
	mdp: [
		some [
			;--Debug point
			mark:

			;--Title and End of document
				titlerule (debug title) line (debugo text emit title text if (first titlerule) == 'opt [remove titlerule])
			| "###" to end

			;--Section Headers
			| ["===" | "-1-"] line (emit-section 1)
			| ["---" | "-2-"] line (emit-section 2)
			| ["+++" | "-3-"] line (emit-section 3)
			| ["..." | "-4-"] line (emit-section 4)

			;--Special common notations:
			| (debug define) define	(
					debugo text

					inline-parsing text

					; really a define or only the : character es first char in a line
					either none? defword
						[emit paragraph copy inline-stack/stack]
						[	; if there are several defines in a row, join them all in one table
							if lastemitted == 'define [emit define-join none]
							emit define reduce [defword copy inline-stack/stack]
						]

					inline-stack/reset
				)
			| "#" (debug numberitem) 	numberitem 	(debugo text
							; parse inline markup chars
							inline-parsing text

							; and emit the parsed stack
							emit number copy inline-stack/stack

							; clear inline stack
							inline-stack/reset
						)
			| (debug bulletitem) 	bulletitem 	(
					debugo text

					; remember numbered-bullets
					if lastemitted == 'number [flags/push number-bullets]

					; parse inline markup chars, this will handle tables as well, solution see below
					inline-parsing text

					; it could be that we entered this rule because the first character was a * but didn't introduced
					; a bullet sequence but a bold sequence, this is the case if the length of bulles is 0
					either (length? bullets) == 0
					[emit paragraph copy inline-stack/stack]
					[
						; inline-stack could now contain a newcell or newrow command, which would be emitted as a bullet item
						; resulting in a wrong output because the closing bullet markup </LI> would be emitted after the newcell/newrow
						; markup. The following code handles this situation be spliting out the tablehandling code

						; split stack newcell or newrow as this ends our bulletitem
						newcell_split: split inline-stack/stack [[newcell #[none]]]
						newrow_split:  split inline-stack/stack [[newrow #[none]]]

						; the shorter of both will be emitted as bullet
						either (length? newcell_split) < (length? newrow_split)
							[bullet_emit: newcell_split]
							[bullet_emit: newrow_split]

						either flags/top == 'number-bullets
							[emit bullet reduce [(length? bullets) - 1 bullet_emit]]
							[emit bullet reduce [length? bullets bullet_emit]]

						; the rest will be emitted as paragraph
						rest: exclude inline-stack/stack bullet_emit
						if not empty? rest [emit paragraph rest]
					]

					; clear inline stack
					inline-stack/reset
				)
			| ";" to newline	; comment

			;--Translator options
			| "=include" 	word here: (insert-file here to-file text)
			| "=meta" word (emit meta text)
			| (debug file) "=file" 		word (debugo text emit file text)
			| "=toc" 			(debug TOC) to newline (debugo "" emit toc none)
			| "=outline"	(debug TOC) to newline (debugo "outline" emit toc 'outline)
			| "=language" word
			| "=options" 	some space some [
					"faq"
					| "debug" (debug_mode: true) ; (debug: debug_d debugo: debugo_d)
				] to newline

			;--Special output
			| "=" copy bars some "-" (emit bar length? bars)
			| "=image" image to newline
			| "=url" 	 some space [{"} copy url to {"} 1 skip | copy url some chars] copy text to newline (either text == none [emit url reduce [url form url]][emit url reduce [url trim text]])
			| "=view" (
					; we use first as the stack isn't reversed yet. So the newest emitted stuff comes first.
					replace first mdp-stack/stack 'example 'view
				)

			;--Special sections:
			| "\in" 		to newline 	(emit indent-in none)
			| "/in" 		to newline	(emit indent-out none)
			| "\note" 	line 				(emit note-in text)
			| "/note" 	to newline 	(emit note-out none)
			| "\table" 	[some space "header" (emit table-in 'tableheader) | (emit table-in none)] to newline (
					flags/push intable		; keep track of tablemode on stack
					table: tablehandling)	; change table rule to handle table characters
			| "/table" (
					emit table-out none
					if flags/pop <> 'intable [print "Flags-Stack not correct!"]
					table: notablehandling)	; change table rule to emit normal table characters

			;--Example Text
			| (debug example) example (debugo code
					; remove starting newlines
					while [(first code) == newline] [remove code]

					pif [
						; header flag is pushed in newline rule below
						flags/instack? header	[emit example code]
						true									[emit header  code]
					]
				)

			;--Text
			| (debug paragraph) paragraph (debugo para

					; parse inline markup chars
					inline-parsing para

					pif [

						lastemitted == 'bullet 		[emit bullet-join reduce [length? bullets copy inline-stack/stack] lastemitted: 'bullet]
						lastemitted == 'number 		[emit number-join para lastemitted: 'number]
						lastemitted == 'paragraph	[emit paragraph-join none emit paragraph copy inline-stack/stack]
						true											[emit paragraph copy inline-stack/stack]
					]

					; clear inline stack
					inline-stack/reset
				)

			;--Newline and join handling
			| newline [some newline
					; This is the section handling 'newline 'newline
					; If nothing special is needed, we reset lastemitted to none, so the rest of the parser behaves
					; in default mode (for example bullet emitting in rule 'TEXT will be reset to normal text output.
					(
						; remember that we did / should have emited a header already because the header text
						; has to follow the newline character of the titleline
						flags/push header

						; if we reach this point do some clean-up work as 'newline 'newline is the termination sequence
						; for bullet lists, numbered lists etc.
						lastemitted: lastemitted_tmp: none

						if flags/top == 'number-bullets [flags/pop]
					)
				|
					; This is the section handling 'newline
				 	(
				 		pif [lastemitted 					 == 'header	 		[emit header-join none]]
					)
				]

			; This rule will skip everything from the input stream that we couldn't handle yet with any other rule
			| skiped: skip (print ["SKIP:"  mold copy/part skiped 1] skip-counter: skip-counter + 1)
		]
		( ; cleanup stack
			if find to-string mdp-stack/top "join" [
				mdp-stack/pop
			]
		)
	]

	; Tricky rules: These rules have to handle all kind of special cases for the defineword because a defineword can contain
	; the seperator character '-' as well. The trick is to use a break-rule to exit the any rule part in defineword and reset the
	; input stream after the any rule. Than the defineseparator will be parsed again splitting the text into the two pieces
	; defword and line that we need. (Thanks to Gabriele Santilli for this trick).
	define:    				[definestart: ":" copy defword defineword defineseparator copy text definition]

	definechars: 			complement charset " ^/"
	defineseparator: 	[spaces "-" spaces | #"^/" (defword: none) :definestart]
	defineword: 			[any
		[ ; consume as much chars as possible
			some definechars (break-rule: none)
			[ ; if we have a defineseperator break-out -> defineseperator will be consumed in rule 'define
					tmp: defineseparator (break-rule: [end skip])
				| #" "
			]
			; execute break-rule that will exit this rule
			break-rule
		]
		; reposition input stream to 'defineseperator position so this will be parsed
		:tmp
		]

	definitionchars: 			complement charset "^/"
	definitionseparator: 	["^/:" | "^/^/"]
	definition: 					[any [
				; read as much chars as possible
				some definitionchars (break-rule: none)
				[
					; if there is a definitionseperator found exit rule
					tmp: definitionseparator (break-rule: [end skip])
					| "^/"
				]
				break-rule
			]
			; reposition to 'definitionseperator for furthe parsing
			:tmp
		]

	numberitem: [line]

	bulletitem: [
		boldstart: copy bullets some "*" opt [some boldchars] opt [ "*" ["^/" | "^-" | "|" | " " | "," | ";" | "." | "!" | "?"] (remove bullets)]
		(boldstart: skip boldstart length? bullets)
		:boldstart
		line
	]

	;-- Inline markup character handling
	parachars:  		complement charset "|~_-*=" ; ^/" ; |="
	markupdelimiters:	[[" " | "." | "," | ";" | "|" | "||" | newline | none]]
	boldchars: 			complement charset "*|^/"
	underlinechars: complement charset "_^/"
	italicchars:		complement charset "~^/"
	strikechars:		complement charset "-^/"

	parapart:	[copy inline_para some parachars]

	tablehandling: [
		(debug newrow) "||" (debugo none emit newrow none lastemitted_tmp: none) ; emit paragraph [[newrow ""]])

		; This will handle empty cells at the begin of a line
		| (debug newcell) "|" (debugo none emit newcell none lastemitted_tmp: none) ; emit paragraph [[newcell ""]])
	]

	notablehandling: ["|" (emit parapart "|")]

	table: notablehandling

	; mark: (mark: skip mark -1) :mark -> Move input cursor one char to front to check special chars
	inlineprolog: [mark: (mark: skip mark -1) :mark markupdelimiters]
	inlineepilog: [mark: (mark: skip mark -1) :mark chars]
	inlineend:		[mark:	(if (length? mark) == 0 [insert markupdelimiters 'opt]) markupdelimiters (if (length? mark) == 0 [remove markupdelimiters]) :mark]

	inlinemarkup:	[
		some [
			(debug parapart) parapart (debugo inline_para emit parapart inline_para)
			; Tricky rules:
			; 	1. we parse 'markupdelimiter AND inline markup character
			;		2. Next we check for a char, a whitespace is not allowed as this would indicate that the markup char should be emitted
			;		3. and reposition the input stream to get this char in the following copy sequence as well
			;		4. we catch all characters that are not the inline markup character
			;		5. we check for a char AND the closing inline markup character
			;		6. we check if this closing inline markup character is followed by delimiter so that we can be sure it's not the inline character we should emit
			| (debug bold) inlineprolog "*" mark: chars :mark copy boldtext some boldchars
				[
						; the if part is needed as the string could directly end with an inlinemerkup character
						inlineepilog "*" inlineend (debugo none emit bold boldtext)
					| newline	(debugo none emit parapart rejoin ["*" boldtext])
				]
			| (debug italic) inlineprolog "~" mark: chars :mark copy italictext some italicchars
				[
						inlineepilog "~" inlineend (debugo none emit italic italictext)
					| newline	(debugo none emit parapart rejoin ["~" italictext])
				]
			| (debug strike) inlineprolog "-" mark: chars :mark copy striketext some strikechars
				[
						; if the inlinemarkup char is the last in the line we have to make the check for the markupdelimiters optional
						; and reposition the input-sequence pointer
						inlineepilog "-" inlineend (debugo none emit strike striketext)
					| newline (debugo none emit parapart rejoin ["-" striketext])
				]
			| (debug underline) inlineprolog "_" mark: chars :mark copy underlinetext some underlinechars
				[
						inlineepilog "_" inlineend (debugo none emit underline underlinetext)
					| newline (debugo none emit parapart rejoin ["_" underlinetext])
				]
			| (debug star) "*" (debugo none emit parapart "*")
			| (debug snail) "~" (debugo none emit parapart "~")
			| (debug minus) "-" (debugo none emit parapart "-")
			| (debug under) "_" (debugo none emit parapart "_")

			; --Special handling
			| (debug image) "=image" image
			| (debug url) "=url" some space [{"} copy url to {"} 1 skip | copy url some chars] copy text to "=" (either text == none [emit url reduce [url form url]][emit url reduce [url trim text]])

			;--Table handling
			| table

			; This rule will skip everything from the input stream that we couldn't handle yet with any other rule
			| skiped: skip (print ["Inline SKIP:"  mold copy/part skiped 1] skip-counter: skip-counter + 1)
		]
	]

	; check alignment
	alignement: [
		some space [
				"left"		(emit align 'left)
			| "right"		(emit align 'right)
			| "center"	(emit align 'center)
			| "float"		(emit paragraph-join none emit align 'float)
		]
	]

	; handles images
  image: [opt alignement some space copy text some chars (emit image to-file text)]
]

;--- HTML Emitter
; Character-Level Formatting
; -------------------------------------------------------------------##
html-format: context [
    pos: marked: href: ""
    ascii-charset: make bitset! #{
    000000003B9EFFAFFEFFFFF7FFFFFF7F00000000000000000000000000000000
    }
    html-charset: make bitset! #{
    FFFFFFFFC46100500100000800000080FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    }
    special-charset: make bitset! #{
    0004000000610000000000080000000000000000000000000000000000000000
    }
    space: make bitset! #{
    0002000001000000000000000000000000000000010000000000000000000000
    }
    html-map: [
        34 #quot 38 #amp 60 #lt 62 #gt
        64 ##064 128 #euro ##8364 130 ##8218 131 ##402 132 ##8222 133 ##8230 134 ##8224 135 ##8225 136 ##710
        137 ##8240 138 ##352 139 ##8249 140 ##338 145 ##8216 146 ##8217 147 ##8220
        148 ##8221 149 ##8226 150 ##8211 151 ##8212 152 ##732 153 ##8482 154 ##353
        155 ##8250 156 ##339 159 ##376 160 #nbsp 161 #iexcl 162 #cent 163 #pound
        164 #curren 165 #yen 166 #brvbar 167 #sect 168 #uml 169 #copy 170 #ordf
        171 #laquo 172 #not 173 #shy 174 #reg 175 #macr 176 #deg 177 #plusmn 178 #sup2
        179 #sup3 180 #acute 181 #micro 182 #para 183 #middot 184 #cedil 185 #sup1
        186 #ordm 187 #raquo 188 #frac14 189 #frac12 190 #frac34 191 #iquest
        192 #Agrave 193 #Aacute 194 #Acirc 195 #Atilde 196 #Auml 197 #Aring
        198 #AElig 199 #Ccedil 200 #Egrave 201 #Eacute 202 #Ecirc 203 #Euml
        204 #Igrave 205 #Iacute 206 #Icirc 207 #Iuml 208 #ETH 209 #Ntilde
        210 #Ograve 211 #Oacute 212 #Ocirc 213 #Otilde 214 #Ouml 215 #times
        216 #Oslash 217 #Ugrave 218 #Uacute 219 #Ucirc 220 #Uuml 221 #Yacute
        222 #THORN 223 #szlig 224 #agrave 225 #aacute 226 #acirc 227 #atilde
        228 #auml 229 #aring 230 #aelig 231 #ccedil 232 #egrave 233 #eacute
        234 #ecirc 235 #euml 236 #igrave 237 #iacute 238 #icirc 239 #iuml 240 #eth
        241 #ntilde 242 #ograve 243 #oacute 244 #ocirc 245 #otilde 246 #ouml
        247 #divide 248 #oslash 249 #ugrave 250 #uacute 251 #ucirc 252 #uuml
        253 #yacute 254 #thorn 255 #yuml
    ]

    to-entity: func [ent [string! issue!]][return rejoin ["&" ent ";"]]
    to-encode: func [doc /local old new ent][
        old: doc/1
        new: switch/default to-integer old [
            34 [to-entity either any [head? doc doc/-1 = #" " doc/-1 = #"^(A0)" doc/-1 = #"^/"][##8220][##8221]]
            39 [to-entity either any [head? doc doc/-1 = #" " doc/-1 = #"^(A0)" doc/-1 = #"^/"][##8216][##8217]]
        ][
            either ent: select html-map to-integer old [to-entity ent]["?"]
        ]
        change/part doc new length? to-string old
    ]

    to-pre: func [doc /local old new ent][
        old: doc/1
        new: either ent: select html-map to-integer old [to-entity ent]["?"]
        change/part doc new 1
    ]

    regular-rule: [
        any [
            some ascii-charset |
            #"&" ["amp" | "copy" | "nbsp" | "quot" | "gt" | "lt"] #";" |
            #"<" opt "/" pos: [
                "em" | "strong" | "code" | "br /" |
                "br/"  (change/part pos "br /" 3) :pos "br /" |
                "br"  (change/part pos "br /" 2) :pos "br /" |
                "b" (change/part pos "strong" 1) :pos "strong" |
                "i" (change/part pos "em" 1) :pos "em"
            ] #">" |
            #"." pos: [
                2 space (change/part pos "&nbsp; " 2) skip |
                #"." #"." (change/part back pos "&#8230; " 3)
            ] |
            #"(" pos: [
                "c)" (change/part back pos "&copy;" 3) |
                "r)" (change/part back pos "&reg;" 3) |
                "o)" (change/part back pos "&deg;" 3) |
                "tm)" (change/part back pos "&#8482;" 4) |
                "br)" (change/part back pos <br /> 4) :pos 5 skip |
                "e)" (change/part back pos "&#8364;" 3)
            ] |
            #"-" pos: #"-" (change/part back pos "&#8212;" 2) |
            #"[" pos: [
                "TM]" (change/part back pos "&#8482;" 4) |
                "break]" (change/part back pos "<br /> " 7) :pos 5 skip
            ] |
            special-charset | #"^/" |
            html-charset pos: (to-encode back pos) :pos
        ]
    ]
    pre-rule: [
        any [
            some ascii-charset |
            #"^/" pos: (change/part back pos <br /> 1) 5 skip |
            #"'" | special-charset |
            html-charset pos: (to-pre back pos) :pos
        ]
    ]

    url-rule: [
        "[url " copy href to #"]" #"]" copy marked to "[/url]"
        (
            replace pos rejoin ["[url " href "]" marked "[/url]"] rejoin [
                {<a href="} href {" title="} marked {">} marked </a>
            ]
        )
    ]
    bold-rule: [
        "[b]" copy marked to "[/b]"
        (replace pos rejoin ["[b]" marked "[/b]"] rejoin ["" <strong> marked </strong>])
    ]
    italic-rule: [
        "[i]" copy marked to "[/i]"
        (replace pos rejoin ["[i]" marked "[/i]"] rejoin ["" <em> marked </em>])
    ]
    markup-rule: [
        some [pos: to #"[" [url-rule | bold-rule | italic-rule | #"[" pos:]]
        to end
    ]

    set 'escape-html func [text /tags][
;        pos: doc
;        parse/all pos either tags [pre-rule][regular-rule]
			if any [word? text none? text empty? text] [return text]
        if not tags [parse/all text markup-rule] ; trim/lines text]
        text
    ]
]

html-emitter: context [
	html: []
	flags: make stack! []
	alignment: none 			; used to temporarly store an alignment hint

	name: none						; these two hold the current item (name/value) of the parsed mdp-stack
	value: none
	path: none						; used for site_mode
	sects: [0 0 0 0] 			; this is the counter for our 4 level sections
	toc-title: "Contents"	; text to use for TOC
	img-num: 0						; counter for generated images

	;--Helper functions
	init: does [
		clear html
		flags/reset
		alignment: name: value: none
		img-num: 0
		clear-sects ; sects: [0 0 0 0]
	]

	nsp: "^/ " ; nsp = newline-space

	html-codes: [
    "&" "&amp;"
    "<" "&lt;"
    ">" "&gt;"
    {"} "&quot;"

		"Á"	"&Aacute;"
		"á"	"&aacute;"
		"À"	"&Agrave;"
		"à"	"&agrave;"
		"Â"	"&Acirc;"
		"â"	"&acirc;"
		"Ä"	"&Auml;"
		"ä"	"&auml;"
		"Ã"	"&Atilde;"
		"ã"	"&atilde;"
		"Å"	"&Aring;"
		"å"	"&aring;"
		"Æ"	"&AElig;"
		"æ"	"&aelig;"
		"Ç"	"&Ccedil;"
		"ç"	"&ccedil;"
		"Ð"	"&ETH;"
		"ð"	"&eth;"
		"É"	"&Eacute;"
		"é"	"&eacute;"
		"È"	"&Egrave;"
		"è"	"&egrave;"
		"Ê"	"&Ecirc;"
		"ê"	"&ecirc;"
		"Ë"	"&Euml;"
		"ë"	"&euml;"
		"Í"	"&Iacute;"
		"í"	"&iacute;"
		"Ì"	"&Igrave;"
		"ì"	"&igrave;"
		"Î"	"&Icirc;"
		"î"	"&icirc;"
		"Ï"	"&Iuml;"
		"ï"	"&iuml;"
		"Ñ"	"&Ntilde;"
		"ñ"	"&ntilde;"
		"Ó"	"&Oacute;"
		"ó"	"&oacute;"
		"Ò"	"&Ograve;"
		"ò"	"&ograve;"
		"Ô"	"&Ocirc;"
		"ô"	"&ocirc;"
		"Ö"	"&Ouml;"
		"ö"	"&ouml;"
		"Õ"	"&Otilde;"
		"õ"	"&otilde;"
		"Ø"	"&Oslash;"
		"ø"	"&oslash;"
		"ß"	"&szlig;"
		"Þ"	"&THORN;"
		"þ"	"&thorn;"
		"Ú"	"&Uacute;"
		"ú"	"&uacute;"
		"Ù"	"&Ugrave;"
		"ù"	"&ugrave;"
		"Û"	"&Ucirc;"
		"û"	"&ucirc;"
		"Ü"	"&Uuml;"
		"ü"	"&uuml;"
		"Ý"	"&Yacute;"
		"ý"	"&yacute;"
		"ÿ"	"&yuml;"
	]

comment {
	escape-html: func [text][
			if any [word? text none? text empty? text] [return text]
	    foreach [from to] html-codes [replace/all/case text from to]
	    return text
	]
}

	emit: func [data] [append html reduce data]

	; Reset all section counter to 0
	clear-sects: does [change/dup sects 0 4]

	; Increase section counters, create section counter string and return this string
	sect-num?: func [num /local n sn] [
		; increase section counter at num place by 1
		change at sects num n: sects/:num + 1

		; reset all section counters behind 'num to 0
		change/dup at sects num + 1 0 4 - num

		; initialize local variable
		sn: copy ""

		; append num times the section counter to form a w.x.y.z number
		repeat n num [append sn join sects/:n "."]

		; remove trailing point
		remove back tail sn

		; return the created number
		copy sn
	]

;--- Predefined HTML emitter objects
	html-copyright: [<p class="end">
		; -- add your footer information stuff below --
		; ---add your footer information stuff above --
    "Document formatter copyright " <a href="http://www.robertmuench.de"> "Robert M. Münch" </a> ". All Rights Reserved." <br />
    "XHTML 1.0 Transitional formatted with Make-Doc-Pro Version:" system/script/header/version " on " now/date " at " now/time </p>
	]

	stylesheets: [
		"@media screen {"
			"h1,h2,h3,h4,h5,p,a,br,li,td, .underline {font-family:Arial, Helvetica, sans-serif;text-align:justify}"
			"hr {text-align:center}"
			"p,table {margin-left: 10px;margin-right:10px}"

			".defword {white-space:nowrap}"
			".deftable {border-style:none;vertical-align:top}"
			".deftablefaq {border-style:solid;border-width:thin}"
			".end {font-size:8pt}"
			".example {margin-left:50px;margin-right:50px;border:2px solid;padding: 10px;background-color:#EEEEEE}"
			".header {margin-left:50px;margin-right:50px;border:2px solid;padding: 10px;background-color:yellow}"
			".indented {margin-left: 50px}"
			".litable {text-align:left}"
			".new {border-right: 10px solid; padding-right: 10px; font-family:Arial}"
			".note {margin-left:50px;margin-right:50px;border:2px solid;padding: 10px;background-color:#F0F0D0}"
			".tocindent {margin-left: 20px}"
			".top {font-size:8pt;text-align:right}"
			".underline {text-decoration:underline}"
		"}"

		"@media print {"
			"h1,h2,h3,h4,h5,p,a,br,li, #underline {font-family:Arial;text-align:justify;orphans:5;widows:5}"
			"p,li,td {font-size:10pt}"
			"ul,ol {page-break-after:avoid;orphans:5;widows:5}"
		"}"
	]

	;--HTML code generation functions (sorted alphaticaly)

	align: does [alignment: value]

	bar: does [emit [{<hr width="50%" size="} value {" />}]]

	bullet: has [counter][

		counter: 0

		; is this a numbered list?
		if (back tail html) == [</ol>] [remove back tail html flags/push number-list-end]

		; how far do we need to go back in the hierarchy?
		until [
			counter: counter - 1
			(pick tail html counter) <> </ul>
		]

		; add one and make positiv
		counter: (counter + 1) * -1

		; first remove as few </UL> as possible
		loop min counter value/1 [remove back tail html] ; deletes counter times </UL>

		; if necessary add a new <UL>
		loop value/1 - counter [
			; there could be a </li> which must be removed too
			if (back tail html) == [</li>] [remove back tail html]

			emit <ul>
		]

		; reuse counter to store value/1 as we are going to set value to something else below
		counter: value/1

		emit <li>
		if flags/top == 'intable [emit <div class="litable">]

		; now use the normal paragraph emitter without a paragraph-start and paragraph-end
		; and emit the text
		flags/push no-paragraph-end
		flags/push no-paragraph-start

		value: value/2
		paragraph

		if flags/top = 'intalbe [emit </div>]
		emit </li>

		; close counter (a.k.a value/1) lists
		loop counter [emit [</ul></li>]]

		; now there is one </li> to much
		remove back tail html

		if flags/top == 'number-list-end [
			flags/pop
			emit </ol>
		]
	]

	bullet-join: has [counter num-list] [
		; do we have a numbered-list? This is the case if the last tag is a </OL>
		either (back tail html) == [</ol>][num-list: true][num-list: false]

		loop counter: value/1 [remove back tail html] ; delete value/1 times </UL> (the first remove might be </OL> tag)
		remove back tail html ; deletes </LI>

		emit " "

		; now use the normal paragraph emitter without a paragraph-start and paragraph-end
		; and emit the text
		flags/push no-paragraph-end
		flags/push no-paragraph-start

		value: value/2
		paragraph

		emit </li>

		; emit counter (a.k.a value/1) times
		loop counter [emit </ul>]

		; replace closing tag </UL> with </OL> for numbered lists
		if num-list [
			remove back tail html
			emit </ol>
		]
	]

	define: does [
		either site_mode
		[
			either flags/top == 'no-define-start
				[flags/pop]
	 			[emit <dl>]

	 		;now emit the definition word
	 		emit [<dt> any [escape-html value/1 "&nbsp;"] </dt>]

	 		;emit the definition text
	 		emit <dd>

			; now use the normal paragraph emitter without a paragraph-start and paragraph-end
			; and emit the text
			flags/push no-paragraph-end
			flags/push no-paragraph-start

			; emit inline markup
	 		value: value/2
	 		paragraph

			; and close definition
	 		emit [</dd></dl>]
		]
		[
			either flags/top == 'no-define-start
				[flags/pop]
	 			[emit [{<p><table width="85%" class="deftable">}]]

	 		;now emit the definition word
	 		emit [<tr><td style="vertical-align:top" class="defword" width="25%"> <strong> any [escape-html value/1 "&nbsp;"] </strong></td>]

	 		;emit the definition text
	 		emit <td style="vertical-align:top;text-align:justify">

			; emit inline markup
	 		value: value/2
	 		paragraph

			; and close definition
	 		emit [</td></tr></table></p>]
	 	]
	]

	define-join: does [
		"In normal mode, we use tables and need to reopen the table to add more defines"
		if not site_mode [
			remove back tail html ; deletes </TABLE>
			remove back tail html ; deletes </P>
		]
	]

	epilog: does [
		emit [<div class="top"> "[ " <a href="#top"> "back to top" </a> " ]" </div>]
		emit <hr />
		emit html-copyright
		emit [</body></html>]
	]

	example: does [
		either flags/top == 'no-example-start
			[emit [newline escape-html value </pre>] flags/pop]
			[emit [<pre class="example"> escape-html value </pre>]]
	]

	example-join: does [
		assert [(back tail html) == [</pre>]] "Indented end expected"
		remove back tail html ; deletes </PRE>
	]

	file: does [
		; emit epilog and write output file
		epilog
		write destinationfile html

		; set new output filename with HTML extension
		destinationfile: either (pick parse value "." 2) == "html" [value][to-file join value ".html"]

		; clear old HTML output
		html: clear head html

		; write prolog
		prolog

		; reset section counters. Either a new TOC will be emitted and section counter will be reset there too
		; but if not we are save with this call
;		clear-sects
	]

  footer: func [path [path!] /local node short-path][
      emit <p>
      repeat node length? path [
          short-path: copy/part path node
          if node > 1 [emit " / "]
          emit [<span>]
          emit [
              build-tag compose [
                  a href (rejoin [anchor-root next short-path either node > 1 ["/"][""]])
                  title (either node = 1 ["home"][mold short-path/:node])
              ]
              short-path/:node
              </a> </span>
          ]
      ]
      emit [</p><p>"last update: " now </p>]
      return ""
  ]

	header: does [
		either flags/top == 'no-header-start
			[emit [newline <strong> escape-html value </strong></pre>] flags/pop]
			[emit [<pre class="header"> <strong> escape-html value </strong></pre>]]
	]

	header-join: does [
		assert [(back tail html) == [</pre>]] "Header end expected"
		remove back tail html	; deletes </PRE>
	]

	image: func [value][
		; check if image file exists
		if all [not light_mode not exists? value] [print ["Image file:" value "not found."]]

		switch/default alignment [
			left  	[emit [<p style="text-align:left"> {<img src="} value {">} </img></p>]]
			right 	[emit [<p style="text-align:right"> {<img src="}  value {">} </img></p>]]
			center  [emit [<p style="text-align:center"> {<img src="}  value {">} </img></p>]]
			float 	[emit [" " {<img src="} value {">} </img> " "]]
		][emit [<p> {<img src="} value {">} </img></p>]]
	]

	indent-in: does [
		emit <div class="indented">
	]

	indent-out: does [
		emit </div>
	]

  menu: func [path [path!] /local short-path menu href marked tag][
      menu: make block! 20
      short-path: copy/part path 1
      foreach [menu-path menu-content] menus [
          if short-path = menu-path [append menu menu-content]
      ]
      remove-each [style content] menu [style <> 'url]
      if empty? menu [return none]

      emit [
          newline
          newline <!-- Begin Menu -->
          newline <ul id="menu">
      ]
      foreach [style content] menu [
          href: content/1
          marked: either content/2 [content/2][href]
          tag: reduce ['a 'href join anchor-root href]
          if content/2 [repend tag ['title marked]]
          emit [nsp " " <li> build-tag tag marked </a></li>]
      ]
      emit [
          newline </ul>
          newline <!-- End Menu -->
      ]
  ]

	note-in: does [
	  emit [<div class="note"><table cellpadding="5" cellspacing="0" width="75%">]

		if found? value [emit [<tr><td width="100%" bgcolor="#F0F040"><strong> value </strong></td></tr>]]

		emit [<tr><td width="100%">]
	]

	note-out: does [
		emit [</td></tr></table></div>]
	]

	number: does [
		either all [flags/top <> 'sequence-ended (back tail html) == [</ol>]]
			[remove back tail html]
			[
				emit <ol>
				if flags/top == 'sequence-ended [flags/pop]
			]

		; emit start of list item
		emit <li>

		; now use the normal paragraph emitter without a paragraph-start and paragraph-end
		flags/push no-paragraph-end
		flags/push no-paragraph-start
		paragraph

		; emit list item and list end
		emit [</li></ol>]
	]

	number-join: does [
		remove back tail html ; deletes </OL>
		remove back tail html ; deletes </LI>

		emit [" " escape-html value </li></ol>]
	]

	paragraph: has [name pvalue] [
		; no paragraph start if inside a table or a tableheader
		if any [flags/top == 'intable flags/top == 'tableheader] [flags/push no-paragraph-start]

		; emit paragraph start?
		either flags/top <> 'no-paragraph-start
			[emit <p>]
			[flags/pop]

		; value now has a name/value structure itself
		foreach tmp value [
			name: tmp/1
			pvalue: escape-html tmp/2

			switch/default name [
				paragraph-join []
				url				[url/plain pvalue]
				image			[image pvalue]
				align			[alignment: pvalue]
				parapart 	[either any [none? pvalue empty? parse pvalue ""][emit "&nbsp;"][emit pvalue]] ; handle explicit spaces and none values
				bold			[emit [<strong> pvalue </strong>]]
				italic		[emit [<em> pvalue </em>]]
				strike		[emit [<strike> pvalue </strike>]]
				underline [emit [<span class="underline"> pvalue </span>]]
				newcell		[either flags/top == 'tableheader	; This is the code for the second cell an on. First cell is handled in table-in
										[
											emit [</td><td style="font-weight:bold;text-align:center;border-bottom:double">]

											; keep track of number of cells
										 	number_of_table_cells: 					number_of_table_cells + 1
											number_of_emitted_table_cells: 	number_of_emitted_table_cells + 1
										]
										[
											; handle empty cells
											if (back tail html) == [<td>] [emit "&nbsp;"]
											emit [</td><td>]

											number_of_emitted_table_cells: 	number_of_emitted_table_cells + 1
										]
									]
				newrow		[
										either flags/top == 'tableheader
											[flags/pop] ; did we handled a tableheader directive?
											[
												; fill in missing table cells
												loop (number_of_table_cells - number_of_emitted_table_cells) [emit [</td><td> "&nbsp;"]]
											]

										emit [</td></tr><tr><td>]

										; reset counter to 0, this will keep counting consistens because function paragraph will be called
										; more than one time for one cell if the cell text was typed with linebreak. In this case one cell
										; consists of serveral [paragraph [parapart...]] blocks
										number_of_emitted_table_cells: 0
									]
			][print ["1: Unknown INLINE-TAG found:" name]]
		]

		; no paragraph end if inside a table or a tableheader
		if any [flags/top == 'intable flags/top == 'tableheader] [flags/push no-paragraph-end]

		; if no paragraph-start was emitted than normally no paragraph-end is required
		either flags/top <> 'no-paragraph-end
			[emit </p>]
			[flags/pop]
	]

	paragraph-join: does [
;		prin "--->" probe flags/stack

		; no tag removing if inside a table
		if (back tail html) == [</p>]
			[
				remove back tail html ; deletes </P> and keeps no-paragaph-start on the stack
				emit " " ; add space around text
			]

;		prin "<---" probe flags/stack
	]

	prolog: does [
		emit <?xml version="1.0" encoding="UTF-8"?>
		emit <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "DTD/xhtml1-transitional.dtd">
;		emit <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

		; Start HTML document
		emit [<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en"><head>]

		; Emit general stylesheets
		emit [<style type="text/css"> stylesheets </style>]

		; closing head is emitted in title rule
		; title rule is only called if light_mode = false
	]

	section: func [num /local sn] [
		either site_mode
		[
      if num = 1 [emit newline]
      sn: sect-num? num

      emit [nsp "<h" num { id="sect} sn {">}]
      ; if toc? [emit [sn " "]]
      emit value
      emit [ "</h" num ">"]
    ]
		[
			; Include a horizontal line before a new section starts
	    if all [num = 1 sects <> [0 0 0 0]][
	    	emit [<div class="top"> "[ " <a href="#top"> "back to top" </a> " ]" </div>]
	    	emit <hr />
	    ]

	    ; create correct section number string
	    sn: sect-num? num

	    ; emit section tags, section number, section string and closing tag
	    emit ["<h" num + 1 ">" {<a id="sect} sn {" name="sect} sn {">} either (length? sn) == 1 [join sn "."][sn] " " escape-html value </a> "</h" num + 1 ">"]
	  ]
	]

	sitemode-epilog: func [mdp-stack][
		; Begin Extras Column
    emit [
        newline newline <!-- Begin Extras Column -->
        newline <div id="subcol">
        nsp <h1> sitename siteext " Web Site"</h1>
    ]

    sitetoc mdp-stack
    sub-menu path

    emit [
        nsp <!-- Begin Notes -->
        nsp <h2>"Notes"</h2>
    ]

;    emit-tag 'ul {^/  <li>Site design by <a href="http://www.ross-gill.com/" title="Christopher Ross-Gill">Christopher Ross-Gill</a></li>^/ }

    emit [
        nsp <!-- End Notes -->
        newline </div>
        newline <!-- End Extras Column -->
    ]

		; Page Footer
    emit [
        newline
        newline <!-- Begin Page Footer -->
        newline <div id="footer">
    ]
    footer path
    emit [
        newline </div>
        newline <!-- End Page Footer -->
        newline
        newline </div>
        newline <!-- END PAGE -->
        newline
        newline <!-- Begin Site Banner -->
        newline <div> build-tag compose [a href (anchor-root) title "Home"]
        build-tag compose [
            img id (join sitename siteext2)
            src (join anchor-root [%style/ sitename '- siteext2 '.png])
            width 310 height 55
            alt (uppercase join sitename siteext) /
        ]
        </a></div>
        newline <!-- End Site Banner -->
        newline </body></html>
    ]
	]

	sitemode-prolog: does [
		; Page Header
		; -------------------------------------------------------------------##
	  emit [
	      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
	      newline <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
	      newline <head>
	      newline <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1" />
	      newline <meta http-equiv="pragma" content="no-cache" />
	      newline
	      build-tag compose [link rel "shortcut icon" href (join anchor-root %style/favicon.ico) /]
	      newline
	      build-tag compose [link rel "stylesheet" type "text/css" href (join anchor-root %style/basic.css) /]
	      newline
	      build-tag compose [link rel "stylesheet" type "text/css" href (join anchor-root [%style/ sitename '.css]) media "screen" /]
	      newline
	      build-tag compose [link rel "stylesheet" type "text/css" href (join anchor-root %style/print.css) media "print" /]
	      newline
	      build-tag compose [script type "text/javascript" src (join anchor-root [%style/ sitename '-logo.js])] </script>
	  ]
	]

  sitetoc: func [doc /local sects hdrs ts ls ns sn][
    clear-sects
    ls: 1
    hdrs: copy []
    sects: [sect1 sect2]
    foreach entry head doc [
        if find sects entry/1 [repend hdrs [entry/1 entry/2]]
    ]
    if empty? hdrs [return none]

    emit [
        nsp <!-- Begin Page Contents -->
;        nsp <h2>"Table of Contents"</h2>
        nsp <ul id="menu-contents">
    ]

    while [not tail? hdrs][
        ts: index? find sects hdrs/1
        sn: sect-num? ts
        emit [
            nsp <li> {<a href="#sect} sn {">} hdrs/2 </a> </li>
        ]
        hdrs: skip hdrs 2
    ]
    emit [
        nsp </ul>
        nsp <!-- End Contents -->
    ]
  ]

	sub-menu: func [path [path!] /local menu short-path][
      menu: make block! 20
      ; iterate over each path part beginning with first path
      repeat node length? path [
          short-path: copy/part path node
          if node > 1 [append menu compose/deep [split [(node) (short-path)]]]
          foreach [menu-path menu-content] menus [
              if all [node <> 1 short-path = menu-path][append menu menu-content]
          ]
      ]
      remove-each [style content] menu [all [style <> 'split style <> 'url]]
      if empty? menu [return none]

      emit [
          newline
          nsp <!-- Begin Related -->
          nsp <h2>"Related"</h2>
          nsp <ul id="menu-related">
      ]
      foreach [style content] menu [
      	switch style [
      		url [
	          href: content/1
	          marked: either content/2 [content/2][href]
	          tag: reduce ['a 'href join anchor-root href]
	          if content/2 [repend tag ['title marked]]
	          emit [nsp " " <li> build-tag tag marked </a></li>]
	        ]
	        split [
							if content/1 > 0 [emit [nsp <li> content/2 </li>]]
	        ]
        ]
      ]
      emit [
          nsp </ul>
          nsp <!-- End Related -->
      ]
  ]

	table-in: does [
		; Table start
		flags/push intable
		number_of_table_cells: number_of_emitted_table_cells: 0

		emit <p>

		either value == 'tableheader
			[
				; handle code for first cell here. Follwoing cells code is handled in paragraph:
				emit [<table border="1" cellpadding="5" cellspacing="0" width="85%"><tr><td style="font-weight:bold;text-align:center;border-bottom:double">]
				flags/push tableheader
			]
			[emit [<table border="1" cellpadding="5" cellspacing="0" width="85%"><tr><td>]]


	]

	table-out: does [
		; handle missing table cells for last line of a table. This is needed because there is no 'newrow emitted after the
		; last line and therefore the special handling for missing table cells didn't get called.
		loop (number_of_table_cells - number_of_emitted_table_cells) [emit [</td><td> "&nbsp;"]]

		emit [</td></tr></table></p>]

		; depending off the number of newlines until /table there might be no-paragraph-start flag on the stack
		if flags/top == 'no-paragraph-start [flags/pop]

		either flags/top <> 'intable
			[print "Table-Out: Stack not correct" probe flags/stack]
			[flags/pop]
	]

	title: func [mdp-stack /local meta file][
		either site_mode
		[
				emit [
		      <title>
		      sitename siteext ": " value
		      </title>
		      </head>
		      newline
		      newline <body>
		      newline <!-- BEGIN HEADER -->
		      newline <div id="header">
		      newline <div id="top-image"><p> sitename siteext </p></div>
	  		]

	  		menu path

				; End Header and Begin Page
				; -------------------------------------------------------------------##
			  emit [
			      newline
			      newline </div>
			      newline <!-- END HEADER -->
			      newline
			      newline <!-- BEGIN PAGE -->
			      newline <div id="content">
			      newline
			      newline <!-- Begin Main Column -->
			      newline <div id="main">
			  ]

				emit [<h1> value </h1>]
        emit [nsp <div class="block">]
		]
		[
		; should we include meta data?
		foreach entry mdp-stack [
			if entry/1 == 'meta [
				file: to-file entry/2

				; try to read the meta file
				pif [
					exists? file								[meta: load file]
					exists? join mdp-path file	[meta: load join mdp-path file]
					true												[alert reform ["Missing META include file:" file] exit]
				]

				; emit meta data
				foreach [name entry] meta [
					emit [{<meta name="} name {" content="} entry {" />}]
				]

				emit [{<meta name="date" content="} now {" />}]
				emit <meta name="generator" content="make-doc-pro" />

				break
			]
		]

		; Emit Title of HTML document -> Shown in Browser Title line
		emit [<title> value: escape-html value </title>]
		emit </head>

		; Start body and emit Title into HTML document
		emit <body>
		emit [<a id="top" name="top"></a>]
		emit [<h2> value </h2>]
		]
	]

	toc: func [mdp-stack /local sn level old_level filename seperator old_sects] [
		; TOC or OUTLINE mode?
		either none? value
			[emit [<hr /> <h2> toc-title </h2>]]
			[emit [<hr /> <p> "outline: "]]

		filename: make file! none
		old_level: 0
		old_sects: copy sects
		clear-sects

		foreach entry mdp-stack [

			; check to see if there is an other file name used?
			if entry/1 == 'file [
				filename: either (pick parse entry/2 "." 2) == "html" [entry/2][to-file join entry/2 ".html"]
;				clear-sects ; reset section counter to start over by 1

				emit [<br /><em> "references into file: " filename </em><br />]
			]

			; check each word to find a section
			if level: find [sect1 sect2 sect3 sect4] entry/1 [
				sn: sect-num? level: index? level	; get index of position we found and calculate section number

				; handle TOC indention or OUTLINE
				either none? value
				[
					if old_level < level	[emit <div class="tocindent">]
					if old_level > level  [loop (old_level - level) [emit </div>]]

					emit [
					  {<a href="} filename {#sect} sn {">}
						pick [<strong> ""] level <= 2
						either (length? sn) == 1 [join sn "."][sn] " " entry/2
						pick [</strong> ""] level <= 2
						</a><br />
					]

					; keep level
					old_level: level
				]
				[
					emit [{<a href="} filename {#sect} sn {">} entry/2 </a> " ,"]
				]
			]
		]

		either none? value
			[if old_level > 0 [loop old_level [emit </div>]]]
			[
				remove back tail html ; removes " ,"
				emit </p>
			]

		; reset section counters so that the counters for the sections
		; will be emitted corretly for the rest of the text because normal section emitting follows
;		clear-sects
		sects: copy old_sects
	]

	url: func [value /plain][
		if not plain [emit <p>]
		emit [{<a href="} value/1 {">} escape-html value/2 </a>]
		if not plain [emit </p>]
	]

	view-image: has [last-code code file] [
		if error? last-code: try [load/all value] [
			request/ok reform ["ERROR in VIEW CODE:^/" mold disarm :last-code]
			exit
		]

		; is  a layout command present, else add one
		code: find last-code 'layout
		if none? code [code: compose/deep [layout [(last-code)]]]

		; now exectue the code to get a graphic
		code: do code

		; create filename
		file: join %graphics/ ["image" img-num ".png"]

		; view code and save as graphics file
		if object? code [
			view/new code
			img: to-image code
			unview/only code
			if not exists? %graphics [make-dir %graphics]
			save/png file img
		]

		; increase counter
		img-num: img-num + 1

		; emit HTML code
		emit [{<p><img border="1" src="} file {">} </img></p>]
	]

	generate: func [mdp-stack][
		; emit HTML prolog
		if not light_mode [prolog]
		if site_mode [sitemode-prolog]

		; iterate through the MDP stack and emit the HTML code. The stack uses a name/value pair in a block.
		; this block is assigned to entry, that is used within the HTML emiter functions
		foreach tmp mdp-stack [
			name: tmp/1
			value: tmp/2
			switch/default name [
				align							[align]
				bar								[bar]
;				bold							[bold]
				bullet						[bullet]
				bullet-join				[bullet-join]
				define						[define]
				define-join				[define-join flags/push no-define-start]
				example						[example]
				example-join			[example-join flags/push no-example-start]
				file							[file]
				header						[header]
				header-join				[header-join flags/push no-header-start]
				image							[image value]
				indent-in					[indent-in]
				indent-out				[indent-out]
				meta							[] ; is  handled in title emitter function
				note-in						[note-in]
				note-out					[note-out]
				number						[number]
				number-join				[number-join]
				paragraph					[paragraph]
				paragraph-join		[flags/push no-paragraph-start paragraph-join]
				sect1							[section 1]
				sect2							[section 2]
				sect3							[section 3]
				sect4							[section 4]
				sequence-end			[flags/push sequence-ended]
				table-in					[table-in]
				table-out					[table-out]
				title							[title mdp-stack]
				toc								[toc mdp-stack]
				url								[url value]
				view							[view-image]
			][print ["Unknown TAG found:" name]]
		]

		if not light_mode [epilog]
		if site_mode [
			emit [nsp </div>	newline </div> newline <!-- End Main Column -->]
			sitemode-epilog mdp-stack
		]
	]
]

;--- PDF emitter -----------------------------------------------------------------------------------
pdf-emitter: context [
	pdf: []
	sects: [0 0 0 0] 			; this is the counter for our 4 level sections

	y-textpos: 280

	emit:  func [data /local tmp] [
		foreach [dialectword item] reduce data [
			pif [
				dialectword == 'textbox	[
					if (type? item) = string! [item: reduce [item]]
					tmp: precalc-textbox 200 item
					append pdf reduce [dialectword 10 y-textpos 200 10 item] y-textpos: y-textpos - tmp
				]
				true [print ["Unknown tag found:" dialectword item]]
			]
		]
	]

	block: func [data] [rejoin [{["} data {"]}]]

	; Reset all section counter to 0
	clear-sects: does [change/dup sects 0 4]

	; Increase section counters, create section counter string and return this string
	sect-num?: func [num /local n sn] [
		; increase section counter at num place by 1
		change at sects num n: sects/:num + 1

		; reset all section counters behind 'num to 0
		change/dup at sects num + 1 0 4 - num

		; initialize local variable
		sn: copy ""

		; append num times the section counter to form a w.x.y.z number
		repeat n num [append sn join sects/:n "."]

		; remove trailing point
		remove back tail sn

		; return the created number
		copy sn
	]

	pt2mm: func [pt][return pt * 0.49]

;--- Emitting parts
	header: does [
		emit ['textbox compose [font Courier 4.23 (value) font Helvetica 4.23]]
	]

	paragraph: has [name pvalue toemit][
		toemit: copy/deep ['textbox []]

		; value now has a name/value structure itself
		foreach tmp value [
			name: tmp/1
			pvalue: tmp/2

			switch/default name [
				parapart 	[append last toemit pvalue]
				bold			[append last toemit compose [font Helvetica-Bold 4.23 (pvalue) font Helvetica 4.23]]
			][print ["2: Unknown INLINE-TAG found:" name]]
		]

		; end this paragraph
		append last toemit 'p

		emit toemit
	]

	title: does [
		; space after is in cm (?)
		emit ['textbox compose [font Helvetica-Bold (pt2mm 15) (value) font Helvetica 4.23 p]]
	]

	section: func[num /local sn][
		; Include a horizontal line before a new section starts
		if num = 1 [
		]

		; create correct section number string
		sn: sect-num? num

		; emit section number, section string and
		pif [
			num = 1 [emit ['textbox compose [font Helvetica-Bold (pt2mm 12) (sn) " " (value) p]]]
			num = 2 [emit ['textbox compose [font Helvetica-Bold (pt2mm 10) (sn) " " (value) p]]]
			num = 3 [emit ['textbox compose [font Helvetica-Bold (pt2mm  8) (sn) " " (value) p]]]
			num = 4 [emit ['textbox compose [font Helvetica-Bold (pt2mm  6) (sn) " " (value) p]]]
		]
	]

	generate: func [mdp-stack][
		; iterate through the MDP stack and emit the PDF code. The stack uses a name/value pair in a block.
		; this block is assigned to entry, that is used within the PDF emiter functions
		foreach tmp mdp-stack [
			name: tmp/1
			value: tmp/2
			switch/default name [
				align							[align]
				bar								[bar]
;				bold							[bold]
				bullet						[bullet]
				bullet-join				[bullet-join]
				define						[define]
				define-join				[define-join flags/push no-define-start]
				example						[example]
				example-join			[example-join flags/push no-example-start]
				file							[file]
				header						[header]
				header-join				[header-join flags/push no-header-start]
				image							[image]
				indent-in					[indent-in]
				indent-out				[indent-out]
				meta							[] ; is  handled in title emitter function
				note-in						[note-in]
				note-out					[note-out]
				number						[number]
				number-join				[number-join]
				paragraph					[paragraph]
				paragraph-join		[flags/push no-paragraph-start paragraph-join]
				sect1							[section 1]
				sect2							[section 2]
				sect3							[section 3]
				sect4							[section 4]
				sequence-end			[flags/push sequence-ended]
				table-in					[table-in]
				table-out					[table-out]
				title							[title mdp-stack]
				toc								[toc mdp-stack]
				url								[url]
				view							[view-image]
			][print ["Unknown TAG found:" name]]
		]
	]
] ; PDF-Emitter


;--- Main Program
if unset? system/words/site_mode 	[site_mode: false]
if unset? system/words/light_mode [light_mode: false]

mdp-path: copy system/script/path
mdp-startup-dir: join mdp-path %mdp-startup-dir.txt

files: any [
    system/options/args
    system/script/args
    either light_mode
    	[false]
    	[
    		light_mode: false
				if exists? mdp-startup-dir [
					change-dir to-file read mdp-startup-dir
				]
    		request-file/keep/filter "*.txt"
    	]
]

mdp-parser/init

generate-files: func [files /path _path /formats out-formats [block!]][
	foreach file compose [(files)] [
		; do we have source-text or files?
		either (type? file) == file!
			[
		    either exists? file
		    	[ ; only generate HTML code?
						either light_mode
							[parse/all detab read file mdp-parser/mdp]
							[
								; remember file selection for next run
								file: to-file file
								change-dir first split-path file
								write join mdp-path %mdp-startup-dir.txt first split-path file
								print ["Parsing done correct:" parse/all detab read file mdp-parser/mdp]
								print ["Input chars skipped:" mdp-parser/skip-counter]
							]
					]
		      [print ["File:" file "doesn't exist."] halt]
		  ]
			[parse/all detab file mdp-parser/mdp]

		; reverse the stack, so that the emitter can iterator front to back, ALWAYS REQUIRED
		reverse mdp-parser/mdp-stack/stack

		; debug_mode: true
		if debug_mode [
			if (type? file) == file!	[
				destinationfile: join first split-path file append first parse/all second split-path file "." ".mdp"
				save destinationfile mdp-parser/mdp-stack/stack
			]
			print ["Reversed MDP-Stack:" mdp-parser/mdp-stack/debug]
		]

		; emit HTML code if nothing special is given
		if any [not formats found? find out-formats 'html] [
			if path [html-emitter/path: _path]

			html-emitter/generate mdp-parser/mdp-stack/stack

			; write output to file
			either all [not light_mode (type? file) == file!]
				[
					destinationfile: join first split-path file append first parse/all second split-path file "." ".html"
					write destinationfile html-emitter/html
					html-emitter/init
				]
				[
					mdp-parser/init
					return html-emitter/html
				]
		]

		; emit PDF code
		if all [formats found? find out-formats 'pdf] [
			do %pdf-maker.r
			destinationfile: join first split-path file append first parse/all second split-path file "." ".pdf"
			pdf-emitter/generate mdp-parser/mdp-stack/stack
			pdf-input: []
			append/only pdf-input pdf-emitter/pdf
			probe pdf-input
			write/binary destinationfile layout-pdf to-block pdf-input
		]

		; reset parser
		mdp-parser/init
 	] ; foreach

	if all [debug_mode not light_mode any [user-prefs/name == "Robert" user-prefs/name == "Robby"]][change-dir mdp-path halt]
]

if not light_mode [generate-files files]
