rebol [
	author: "Maxim Olivier-Adlhoch"
	title: "BNF grammar compiler"
	file: %bnf-compiler.r
	date: 2009-12-13
	version: 1.0
	purpose: "convert BNF grammar to REBOL parse rules"
	copyright: "(c)2009 Maxim Olivier-Adlhoch"
	license: 'MIT

	library: [ 
		level: 'advanced 
		platform: 'all 
		type: [dialect tool] 
		domain: [dialects file-handling parse scientific text-processing ] 
		tested-under: [r3-core-beta WXP]
		R3: 'compatible
		R2: 'incompatible
		support: 'Altme 
		license: 'MIT 
	] 
	
	documentation: {
		---
		WHAT IS THIS SCRIPT ABOUT?
		---
		this is a simple bnf grammar rule converter for the rebol language.
		
		
		---
		USAGE:
		---
		Edit the arguments below so that infile: & outfile: words reflect what you want to run it on.
		
		Change any of the markers and string patterns which identify BNF tokens and syntax (if needed).
		
		Then run REBOL 3 on it.
		
		
		---
		WHAT DOES IT DO?
		---
		It will output the bnf grammar rules in rebol's internal parse format, ready to be
		used within your application (the output is R2 & R3 compatible).
	
		the emitter supplied here will convert the rules to REBOL parse format
		
		The default form of BNF used here is essentially that accepted by yacc/bison.
		
		Change the Format rule if you need something else
		
		If bnf-embedded yacc "actions" are detected, they will be included as parse paren actions
		in the outut, directy within the rule.
		
		
		---
		WHAT DOESN'T IT DO?
		---
		process EBNF
		
		it doesn't handle the yacc extensions like includes, header, footer etc.
		
		doesn't convert actions into rebol code.  they become parens with a string of text inside.
		
		doesn't support the @ ending rule which is like a manual mode backtracking.  re-order
		rules to provide the same kind of control.
		
		Cook diner.
		
		Doesn't enforce proper rebol words in output.  In some obscure grammars, tokens might not
		represent valid words.  just try to load output after conversion to know if all words are valid.
		
		It doesn't HANDLE PARSE BACKTRACKING ORDER, REASSEMBLING RULES SO THEY ARE GREEDY...
		This means that the resulting parse expression, in many cases cannot be used directly, because the
		order of statements in BNF rules is arbitrary.  Parse has the added requirements that 
		more complex patterns be placed at the head of rule alternatives, so that they do not
		short-circuit the detection of other expressions which encompass them.
		
		Take care of the kids while you program.
		
		many BNF implementations rely on regexp to do the pattern matching, and thus will not care
		in what order the alternatives are put, but this has a significant speed costs, because you
		will end-up parsing the string over and over until the most complex expression is found.
		
		Make you prettier when you've had a beer too many (or two ;-).
		
		So, once the BNF grammar is converted, you must look at the resulting parse rules and make sure that 
		the order in which the alternatives are declared, satisfy the most-complex first nature of parse, 
		which makes text parsing extremely fast.
		
		Start the coffee brewer when you forget to push the 'on' button.
		
		
		---
		TOKEN TRANSFORMATION
		---
		In order to adapt the source BNF to your own parser formatting taste, two keywords in the arguments
		allow you to transform the token labels.
		
		_to-:  this simply replaces all the underscores to dashes, to make words more REBOL style complient.
		
		token-format: this block serves as a specification in how to make the token take a specific style.
		              since its reduced, you can even rename the tokens!
		
		
		
		---
		IN-GRAMMAR COMMENTS
		---
		there are two types of comments supported.
		
		line comments: 
			These are represented as a character pattern which, when encountered, will
			ignore the rest of the characters in the current-line.
		
			these comments are conserved in the output, as a rebol comment (line starting with ';').
		
		block comments:
			Two character patterns define the start and end of the comment.
		    
		    These comments are discarded and NOT included in the output parse rules.
		    
		by default, '%' is the line pattern and '/*', '*/'  are the block patterns.


		---
		the end-of-rule character:
		---
			this is a yacc addition to BNF (";" by default ).  It is completely ignored (its not 
			part of original BNF notation), and can be there or not in your source grammar files.
		
		
		---
		NOTES: 
		---
			-Whitespace formating of the the input grammar is totally irrelevant.  spaces, tabs, new lines...
			 everything is considered a single whitespace. but there must be at least one space.
			
			-This engine doesn't parse yacc files per say, only provides a few extras which make yacc
			 BNF files easier to use,  but usually, the yacc header and post grammar
			 blocks should be removed from the file prior to parsing it.
			
			-Character case is preserved.
			
			-This engine DOES NOT support the BNF form where terms are not quoted (error prone).
			 By my sampling, it is very rarely used anyways.
			 
			 If your source data is such, then editing the pattern rules below will be required, but it should be
			 pretty easy, as the rules are simple and clear.
			 
			-for a good first read on BNF grammar look at this: http://www.garshol.priv.no/download/text/bnf.html
	}
]



;-------------------------------------------
;  USER ARGUMENTS
;
; change these before running your script
;-------------------------------------------

;- FILE/URL PATHS
infile: http://www.cs.manchester.ac.uk/~pjj/bnf/c_syntax.bnf ; the C language, in BNF
outfile: %kr_c_syntax.r

print-result?: yes ; if set to false, the script is silent and won't ask for enter key
_to-: yes          ; do you want "_" within tokens to be converted to "-"?
token-format: [token "="] ; how do you want your tokens to be formated when emited?
                          ; this block is rejoined for all tokens and rule assignment, and result is emited.


;- FORMAT RULES
; edit these rules so they match the flavour of your BNF notation.
assignment=:  #":" ; is often ":=" or "::="
separator=: "|"  ; separates alternatives in a rule
comment-symbol=: "%"
comment-start=: "/*"
comment-end=: "*/"
action-start=: #"{" ;  note: the parser doesn't try to support nested actions.
action-end=: #"}"   ;  note: the parser doesn't try to support nested actions.
term-start=: #"'"  ; what starts the definition of a terminal, may be "<" or {"}
term-end=: term-start= ; what ends the definition of a terminal, may be ">" or {"}
end-of-rule=: #";" ; marks the end of a rule.  following item should be a rule-assignment (but its not verified).


;--------------------------------------------
;
; PROCESSING STARTS HERE
;
;--------------------------------------------
;- load bnf grammar file
grammar: to-string read infile

;- parse rules storage
token: none
terminal: none
comment: none
action: none


;- utility functions
bits: func [b][make bitset! b]
as-string: func [d][any [attempt [to-string d] copy ""]]

;- symbol rules
eol=: #"^/"
whitespace=: bits " ^/^-"
whitespaces=: [any whitespace=]
digit=: bits "0123456789"
digits=: [some digit=]
letter=: bits [#"a" - #"z" #"A" - #"Z"]
alphabet=: rejoin [digit= letter= bits "_"] ; valid symbols for words
symbol=: complement whitespace= ; any non space char

;- token rules
token=: [copy token some symbol= (token: emitter/xform-token token) ] ; any contiguous symbols are tokens, (note: be carefull, tokens may not be valid rebol words!)


;- pattern rules
rule-assignment=: [ whitespaces= token= whitespaces= assignment=]

line-comment=: [
	comment-symbol= copy comment [
		[thru eol= ]
		| [to end]
	]
]

block-comment=: [
	; block-comments are discarded.  
	; we basically just skip them.
	;(print "!!")
	copy comment [comment-start= thru comment-end=] (print comment comment: none)
]

terminal=: [
	term-start= copy terminal to term-end= thru term-end=
]

action=: [
	action-start= copy action to action-end= thru action-end=
]

item=: [
	here: 
	[terminal=  (emit/litteral-string terminal) ]
	| rule-assignment= reject
	| separator= reject
	| [token= (emit/token token)]
]




;--------------------------------------------
;
;- BNF EMITTER
;
;--------------------------------------------
emit: emitter: context [
	text: none
	rule: none
	words: none

	end-of-rule: func [][
		if rule [
			emit "]^/"
		]
	]
	
	new-rule: func [label][
		append words join label " "
		end-of-rule
		rule: label
		emit rejoin ["^/" label ": ["]
		space
	]
	
	litteral-string: func [label][
		emit mold label
		space
	]
	
	separator: func [][
		emit "|"
		space
	] 
	
	comment: func [comment][
		emit rejoin ["^/;---------^/; " trim/head/tail comment "^/"]
	]
	
	action: func [action][
		emit rejoin [ {(print } mold rejoin ["action: [" action "]"] {)}]
		space
	]
	
	token: func [token][
		emit token
		space
	]
	
	space: func [][
		; space() was added just so that by quickly scanning the emitors, you can see
		; if they emit a space or not before or after their content.
		; as such the space could have been integrated manually in each emitter.
		emit " "
	]
	
	emit: func [data [string!]][
		append any [text text: copy ""] data 
	]

	xform-token: func [token][
		
		if _to- [
			token: replace/all token "_" "-"
		]
		
		if token-format [
			token: rejoin bind token-format 'token
		]
	
	]

	list-words: func [][
		emit rejoin ["^/;-------------------^/; words used by this dialect:^/comment [" words " ]^/"]
	]
	
	reset: func [][
		text: rejoin [
			"rebol [^/"
			"    file: %" outfile "^/"
			"    date: " now/date  "^/"
			"]^/^/"
		]
		rule: none
		words: copy ""
	]
	
	reset
]

;--------------------------------------------
;
;- PARSE THE BNF
;
;--------------------------------------------
result: parse grammar [
	some [
		; temporary
		here:
		;(print ["> " mold as-string first here ])
		
		; litteral text to match
		  terminal= (emit/litteral-string terminal) ; (print ["found terminal: " terminal])
		  
		; ignores rest of this line
		| line-comment= (emit/comment comment)
		
		; detect rule actions
		| action= (emit/action action)
		
		; detect rule actions
		| block-comment=
		
		; create a new parse rule
		| rule-assignment= (emit/new-rule token); (print ["found :::::::::::::::::::"])
		
		; basically ignored.
		| end-of-rule=
		
		; alternate rules, MUST include at least one item
		| separator= 
			(emit/separator)
			whitespaces=
			[item= | return (rejoin ["ERROR: alternate items separator isn't followed by item, here: ^/    " copy/part here 50 ])]
		
		; this rule will match anything
		| [token= (emit/token token)] ;(print ["found token main :" token])
		
		; just skip them
		| whitespaces=
		
	]
	
	(emit/end-of-rule)
]

emitter/list-words


;--------------------------------------------------
;
; if an error was detected in grammar rules...
;
;--------------------------------------------------
if string? result [
	print result
	halt
]


;--------------------------------------------------
;
;- DISPLAY CONVERTED GRAMMAR RULES ?
;
;--------------------------------------------------
either print-result? [
	print "-----------------------"
	print "         result:"
	print "-----------------------^/"
	print emitter/text
	print "^/-----------------------"
	ask "Press enter to save result"
	write outfile emitter/text
][
	write outfile emitter/text
]



