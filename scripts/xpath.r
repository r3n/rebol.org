REBOL [
   Library: [
        level: 'intermediate
        platform: 'all
        type: tool
        domain: [ai xml]
        tested-under: none
        support: none
        license: none
        see-also: none
        ]
	History: [
                [0.1 04-mar-2007 "First version"]
                [0.2 05-mar-2007 "Minor modification"]
		[0.3 06-mar-2007 "Improvement of the xpath_rules. Thanks to Marco."]
		[0.4 08-mar-2007 "Modification to remove a small bug introduced in v0.3."]
		[1.0 10-mar-2007 "handle attributes and empty elements"]
		]

    Title: "xpath.r"

    Date: 03-march-2007

    File: %xpath.r

    Author: "Alban Gabillon"
    Version: 1.0

    Purpose: {
    This script shows how to implement an XPath interpreter in Rebol/Prolog.
    This interpreter is not complete. 
    It is only a kind of "Proof of Concept". It lacks some features.
    Currently it can parse a document containing elements, attributes and pcdata. 
    In this script I see an xml document as a tree of UNTYPED nodes. 
    Consequently,
	- all nodes are treated the same, In particular attributes of an element are seen as child nodes of that element
	- the syntax DOES NOT FOLLOW exactly the XPath syntax (See the EXAMPLES below to understand how it works).
    Note1: It could be perfectly possible to directly parse XML data instead of rebxml data 
    but it would be more difficult to write the parse_doc function. A solution could be to adapt xml2rebxml so that it produces the db atomic facts.}]


samplexml: {
<movie>
    <title>Star Trek: Insurrection</title>
    <star sex="M" age="35">Patrick Stewart</star>
    <star sex="M" age="25">Brent Spiner</star>
    <theater opening_year="2005">
        <theater-name>MonoPlex 2000</theater-name>
        <showtime>14:15</showtime>
        <showtime>16:30</showtime>
        <showtime>18:45</showtime>
        <showtime>21:00</showtime>
        <price>
            <adult>$8.50</adult>
            <child>$5.00</child>
        </price>
    </theater>
    <theater opening_year="2006">
        <theater-name>Bigscreen 1</theater-name>
        <showtime>19:30</showtime>
	<showtime/>
        <price>$6.00</price>
    </theater>
    <theater opening_year="2010" />
</movie>
}



examples: {EXAMPLES:

For selecting the theaters
---------------------------------------------.
XPath==> /movie/theater

For selecting all the stars
----------------------------------------
XPath==> //star

For selecting the first showtime of all theaters
------------------------------------------------------------------------
XPath==>//theater/showtime(1)

For selecting all the showtimes of the second theater
------------------------------------------------------------------------------------
XPath==>//theater(2)/showtime

For selecting all the male stars
------------------------------------------------
XPath==> //star[./sex/M]

For selecting all the showtimes of the Bigscreen1 theater
-----------------------------------------------------------------------------------------
XPath==>//theater[./theater-name/Bigscreen 1]/showtime
OR
XPath==>//theater[.//Bigscreen 1]/showtime

For selecting the theaters with a showtime at 21:00
--------------------------------------------------------------------------------
XPath==>//theater[./showtime/21:00]

}


do http://perso.orange.fr/alban.gabillon/rebsite/xpath/xml2rebxml.r
do http://perso.orange.fr/alban.gabillon/rebsite/xpath/prolog.r

parsepath: func [
"parse an xpath expression - output is a block [pathup axis nodetest predicate position]"
string [string!]
/local workstring pathup test predicate position axis result][
either string = "root" [result: copy ["root" "" "" "" ""]][
predicate: position: ""
workstring: reverse copy string
switch first workstring [
	#"]" [; there is a predicate tied to the nodetest
		predicate: copy ""
		rec: 1
		while [rec > 0][
			workstring: next workstring 
			if workstring/1 = #"]" [rec: rec + 1]
			if workstring/1 = #"[" [rec: rec - 1]
			either rec > 0 [append predicate workstring/1][workstring: next workstring]]
		reverse predicate]
	#")" [; there is a position tied to the nodetest
		position: copy ""
		workstring: next workstring 
		parse workstring [copy position to  "(" thru "(" mark:]
		position: to-integer reverse position
		workstring: mark]]
; nodetest
parse workstring [copy test to  "/" mark:]
reverse test
; pathup and axis
workstring: mark
workstring: next  workstring
either workstring/1 = #"/" [axis: copy "//" pathup: copy next workstring][axis: copy "/" pathup: copy workstring]
reverse pathup
result: copy reduce [pathup axis test predicate position]]]

parse-doc: func [
"parse the rebxml block and create db atomic facts"
parent [block!]
"parent block"
data [block!]
"child block"
/local element pcdata attribute value subtree elementlist search pos][
element: pcdata: attribute: value: subtree: none
elementlist: copy []
parse data  [ 
	any [element: word!  ; element
			(either search: find elementlist element/1 [
				pos: search/2: search/2 + 1][
				pos: 1
				append elementlist reduce [element/1 1]]
			append db_facts compose/deep/only [index [(element) (pos)]]
			append db_facts compose/deep/only [child [(element) (parent)]])
		any [attribute: word! value: string! ; attribute/value
			(append db_facts compose/deep/only [child [(attribute) (element)]]
			append db_facts compose/deep/only [child [(value) (attribute)]])] 
		[subtree: block!  (parse-doc element subtree/1) ; subtree
			| skip]  ; empty tag (skip is for parsing /)
		| pcdata: string! ;pcdata
			(append db_facts compose/deep/only [child [(pcdata) (parent)]])
		] ]
]

prompt: has [expression s e][
	expression: copy ""
	expression: ask "XPath==> "
	either not empty? expression [
		r: 0
		for-which db [X][
			xpath [expression X]
		][	
			parse X compose/deep [
				; element (empty or not)
				s: word! 
				any [word! string!]
				[block! | (to-lit-word "/")] e: 
				|
				;attribute
				s: word! string! e: 
				|
				;pcdata or attribute value
				s: string! e: 
				] 
			probe copy/part s e
			r: r + 1
		]
		print [r "solution(s)"]
		false
	][true]
]
	
db_facts: copy []
xmldata: copy samplexml
space: charset " ^/^M^-"
parse xmldata [any [
	">" s: some space e: (s: remove/part s e) :s
|
	s: some space e: "<" (s: remove/part s e) :s
|
	skip
]]

print ""
print "INITIALIZATION OF THE KNOWLEDGE BASE - PLEASE BE PATIENT"
print ""

; create the document root (not to confuse with the element root)
doc: copy [/]
doc: append/only doc xml2rebxml xmldata
probe doc

;create database atomic facts
parse-doc doc doc/2
db: assert none [xml [doc]]
assert db db_facts

comment 
{COMMENT lines between ============ 
and UNCOMMENT  lines between *************** 
if you want as much deduction as possible (but low performances)}
;=======================================
tree_geometry_rules: assert none [
    descendant [X Y][
        db/child [X Y]
    ]
    descendant [X Y][
        db/child [X Z]
        descendant[Z Y]
    ]
]

for-which tree_geometry_rules [X Y] [
	descendant [X Y]
][
	assert db compose/deep/only [descendant [(X) (Y)]]
]
;=======================================
;****************************************************************
;tree_geometry_rules: [
;	descendant [X Y][
;		child [X Y]]
;	descendant [X Y][
;		child [X Z]
;		descendant[Z Y]]]
; assert db tree_geometry_rules
;****************************************************************

;create xpath rules
xpath_rules: [
	xpath ["/" X][
		xp [["root" "" "" "" ""] X]]	
	xp [["root" "" "" "" ""] doc][
		xml [X]]
	; for not having path starting with / (would be more difficult to handle in the parsepath function) 
	xpath [P X][
		xp [(parsepath join "root" P) X]]		
	; child axis		
	xp [[Pathup "/" Test "" ""] X][
		xp [(parsepath Pathup) Y]	
		child [X Y]
		equal? [(to-string X/1) Test]]
	; descendant axis
	xp [[Pathup "//" Test "" ""] X][
		xp [(parsepath Pathup) Y]		
		descendant [X Y]
		equal? [(to-string X/1) Test]]
	; nodetest tied with a position
	xp [[P1 P2 P3 _ Pos] X][
		not-equal? ["" Pos]	
		xp [(parsepath join P1 [P2 P3]) X]		
		index [X Pos]]
	; nodetest tied with a predicate (i.e. a path relative to the context node . (dot))	
	xp [[P1 P2 P3 P4 _] X][
		not-equal? ["" P4]		
		xp [(parsepath join P1 [P2 P3]) X]
		xp [(parsepath join P1 [P2 P3 next P4]) Y]
		descendant[Y X]]
]
assert db xpath_rules

print samplexml
print examples
print "press ENTER to leave the interpreter"
until [prompt]