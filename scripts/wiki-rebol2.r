Rebol [
title: "Wiki entry R2"
date: 17-Dec-2012
Purpose: {make wikibook/wikipedia/mediawiki entry from defined words, example:
my? append
(then you can paste directly (CTRL+V), see http://en.wikibooks.org/wiki/REBOL_Programming/append)
This works with Rebol2 }
file: %wiki-rebol2.r
Author: "Max Vessi"
version: 3.1.4
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
see-also: none ] 
]
my?: func [
    "Prints information about words and values."
    'word [any-type!]
    /local value args item type-name refmode types attrs rtype temp
][       
    temp:  copy ""
    if all [word? :word not value? :word] [word: mold :word]
 
    type-name: func [value] [
        value: mold type? :value
        clear back tail value
        join either find "aeiou" first value ["an "] ["a "] value
    ]
    ;end function
    if not any [word? :word path? :word] [
        append temp reduce [mold :word " is " type-name :word]	
        write clipboard://  temp
        exit
    ]
    value: either path? :word [first reduce reduce [word]] [get :word]
    if not any-function? :value [
        append temp reduce [uppercase mold word " is " type-name :value " of value: "]
        append temp either object? value [ reduce ["^/" dump-obj value] ] [mold :value]	
	write clipboard://  temp
        exit
    ]
    args: third :value
    append temp  "= USAGE: = ^/ "
    if not op? :value [append temp reduce [ uppercase mold word " "] ]
    while [not tail? args] [
        item: first args
        if :item = /local [break]
        if any [all [any-word? :item not set-word? :item] refinement? :item] [
            append temp reduce [append mold :item " "]
            if op? :value [append temp reduce [append uppercase mold word " "]
	    value: none]
        ]
        args: next args
    ]
    append temp  "^/" 
    args: head args
    value: get word
    append temp "^/= DESCRIPTION: = ^/"
    either string? pick args 1 [
        append temp reduce [first args]
        args: next args
    ] [
        append temp "^/''(undocumented)''^/"
    ]
    append temp reduce [ "^/^/"uppercase mold word " is " type-name :value " value."]
    if block? pick args 1 [
        attrs: first args
        args: next args
    ]
    if tail? args [exit]
    while [not tail? args] [
        item: first args
        args: next args
        if :item = /local [break]
        either not refinement? :item [
            all [set-word? :item :item = to-set-word 'return block? first args rtype: first args]
            if none? refmode [
		append temp "^/= ARGUMENTS: =^/"
                refmode: 'args
            ]
        ] [
            if refmode <> 'refs [
                append temp "^/= REFINEMENTS: =^/"
                refmode: 'refs
            ]
        ]
        either refinement? :item [	   	  
            append temp reduce ["*'''" mold item "'''"]
            if string? pick args 1 [append temp reduce [" -- " first args] 
	    args: next args]
            append temp "^/"
        ] [
            if all [any-word? :item not set-word? :item] [
                if refmode = 'refs [append temp "*"]
                append temp reduce ["*'''" :item "''' -- "]
                types: if block? pick args 1 [args: next args first back args]
                if string? pick args 1 [append temp reduce [first args ""] 
		args: next args]
                if not types [types: 'any]
                append temp rejoin [" (Type: " types ")"]
                append temp "^/"
            ]
        ]
    ]
    if rtype [append temp reduce ["^/RETURNS:^/^-" rtype]]
    if attrs [
        append temp "^/= (SPECIAL ATTRIBUTES) =^/"
        while [not tail? attrs] [
            value: first attrs
            attrs: next attrs
            if any-word? value [
                append temp reduce  ["*'''" value "'''"]
                if string? pick attrs 1 [
                    append temp reduce [" -- " first attrs]
                    attrs: next attrs
                ]
                append temp "^/"
            ]
        ]
    ]
    append temp "^/= SOURCE CODE =^/"
    append temp  reduce ["<pre>" join word ": "]
    if not value? word [print "''undefined''" exit]
    either any [native? get word op? get word action? get word] [
        append temp reduce ["native" mold third get word "</pre>"]
    ] [append temp reduce  [ mold get word "</pre>"] ]
    ;editor temp
    write clipboard://  temp
    exit
]