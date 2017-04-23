Rebol [ 
	title: "Markdown entry for R3" 
	date: 3-Jan-2013
	Purpose: {make markdown entry from defined words, 
	example: my? append (then you can paste directly (CTRL+V), 
	see https://github.com/hostilefork/r3-hf/wiki/Random) 
	This works with Rebol3 } 
	file: %markdown-rebol3.r 
	Author: "Massimiliano Vessi" 
	version: 4.0.12
	;following data are for www.rebol.org library 
	;you can find a lot of rebol script there 
	library: [ 
		level: 'beginner 
		platform: 'all 
		type: [tutorial tool] 
		domain: [markup ] 
		tested-under: [windows linux] 
		support: none 
		license: [gpl] 
		see-also: none 
		] 
	]




my?: func  [
    "Copy to clipboard the defitionion of a word in Markdown markup style."
    'word [any-type!]    
    /local temp temp2 temp3 printt
][
   temp: word
   temp3:  copy ""
   printt: func [a /code /local b] [	
	b: copy a
	if  code [			
		insert b newline
		replace/all b newline "^/    "
		] 	
	append temp3 reform b
	append temp3 newline	
	]
   if all [word? :word not value? :word] [word: mold :word]

    if any [string? :word all [word? :word datatype? get :word]] [
        if all [word? :word datatype? get :word] [
            value: spec-of get :word
            printt [
                mold :word "is a datatype" newline
                "It is defined as" either find "aeiou" first value/title ["an"] ["a"] value/title newline
                "It is of the general type" value/type newline
            ]
        ]
        if any [:word = 'unset! not value? :word] [exit]
        types: dump-obj/match lib :word
        sort types
        if not empty? types [
            printt ["Found these related words:" newline types]
            exit
        ]
        if all [word? :word datatype? get :word] [
            printt ["No values defined for" word]
            exit
        ]
        printt ["No information on" word]
        exit
    ]
    type-name: func [value] [
        value: mold type? :value
        clear back tail value
        join either find "aeiou" first value ["an "] ["a "] value
    ]
    if not any [word? :word path? :word] [
        printt [mold :word "is" type-name :word]
        exit
    ]
    either path? :word [
        if any [
            error? set/any 'value try [get :word]
            not value? 'value
        ] [
            printt ["No information on" word "(path has no value)"]
            exit
        ]
    ] [
        value: get :word
    ]
    unless any-function? :value [
        printt [uppercase mold word "is" type-name :value "of value: "]
	printt/code either any [object? value port? value] [ form dump-obj value] [mold :value]
         write clipboard://  temp3
        exit
    ]
    printt "# USAGE"
    args: words-of :value
    clear find args /local
    either op? :value [
        printt/code [ " " args/1 word args/2]
    ] [
        printt/code [ " " uppercase mold word args]
    ]
    printt ajoin [
        newline "^/# DESCRIPTION" newline
        any [title-of :value "(undocumented)"] 
        newline newline	
        uppercase mold word " is " type-name :value " value."
    ]
    unless args: find spec-of :value any-word! [exit]
    clear find args /local
    print-args: func [label list /extra /local str] [
        if empty? list [exit]
        printt label
        foreach arg list [
            str: ajoin ["* **" arg/1 "**"]
            if all [extra word? arg/1] [insert str "    "]
            if arg/2 [append append str " -- " arg/2]
            if all [arg/3 not refinement? arg/1] [
                repend str [" (" arg/3 ")"]
            ]
            printt str
        ]
    ]
    use [argl refl ref b v] [
        argl: copy []
        refl: copy []
        ref: b: v: none
        parse args [
            any [string! | block!]
            any [
                set word [refinement! (ref: true) | any-word!]
                (append/only either ref [refl] [argl] b: reduce [word none none])
                any [set v block! (b/3: v) | set v string! (b/2: v)]
            ]
        ]
        print-args "^/# ARGUMENTS" argl
        print-args/extra "^/# REFINEMENTS" refl
    ]    
    printt "^/#SOURCE "
    if not value? temp [printt [temp "undefined"] exit]
    temp2: head insert mold get temp reduce [temp ": " ]
    replace/all temp2 "[[" "[  ["
    replace/all temp2 "]]" "] ]"
    printt/code  temp2 
    write clipboard://  temp3
    exit
]