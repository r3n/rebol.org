Rebol [ 
	title: "Wiki entry R3" 
	date: 19-Dec-2012 
	Purpose: {make wikibook/wikipedia/mediawiki entry from defined words, 
	example: my? append (then you can paste directly (CTRL+V), 
	see http://en.wikibooks.org/wiki/REBOL_Programming/append) 
	This works with Rebol3 } 
	file: %wiki-rebol3.r 
	Author: "Massimiliano Vessi" 
	version: 3.0.6 
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
    "Prints information about words and values."
    'word [any-type!]    
    /local temp temp2 temp3 printt
][
   temp: word
   temp3:  copy ""
   printt: func [a] [append temp3 reform a 
	append temp3 newline]
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
        printt either any [object? value port? value] [printt "" dump-obj value] [mold :value]
        exit
    ]
    printt "= USAGE ="
    args: words-of :value
    clear find args /local
    either op? :value [
        printt [ " " args/1 word args/2]
    ] [
        printt [ " " uppercase mold word args]
    ]
    printt ajoin [
        newline "= DESCRIPTION =" newline
        any [title-of :value "(undocumented)"] newline
        uppercase mold word " is " type-name :value " value."
    ]
    unless args: find spec-of :value any-word! [exit]
    clear find args /local
    print-args: func [label list /extra /local str] [
        if empty? list [exit]
        printt label
        foreach arg list [
            str: ajoin ["* '''" arg/1 "'''"]
            if all [extra word? arg/1] [insert str "*"]
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
        print-args "^/= ARGUMENTS =" argl
        print-args/extra "^/= REFINEMENTS =" refl
    ]
    printt "= SOURCE ="
    if not value? temp [printt [temp "undefined"] exit]
    temp2: head insert mold get temp reduce ["<pre>"temp ": " ]
    replace/all temp2 "[[" "[  ["
    replace/all temp2 "]]" "] ]"
    printt [temp2 "</pre>"]
    write clipboard://  temp3
    exit
]