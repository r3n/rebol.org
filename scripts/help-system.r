REBOL [
   Title: "Help Patch"
   Author: "Ingo Hohmann"
   Version: 0.0.1
   Date: 2003-11-20
   File: %help-system.r
   Purpose: {
      Allows to add the following info to functions:
      return: [datatypes to be returned]
      category: [a function category e.g. math series]
      author: [author initials email what you want
   }

   
	library: [
   	level: 'intermediate
    	platform: 'all
    	type: [ tool ]
    	domain: [patch]
    	tested-under: [view linux]
    	support: none
    	license: none
 	]

   TODO: {
      add todo and date fields?       
   }
]



func: func [
    {Defines a user function with given spec and body.
    *PATCHED* iho
    Allows in the spec the following additional info:
      return: [list of types]
      category: [list of categories]
      author: [author info]
    these additiona are purely informational
}
    [catch] 
    spec [block!] {Help string (opt) followed by arg words (and opt type and string)} 
    body [block!] "The body block of the function"
    /local returns categories author fun pos
][
   if all [pos: find spec first [return:] block? next pos] [
      returns: pos/2
      remove/part pos 2
   ]
   if all [pos: find spec first [category:] block? next pos] [
      categories: pos/2
      remove/part pos 2
   ]
   if all [pos: find spec first [author:] block? next pos] [
      author: pos/2
      remove/part pos 2
   ]

   fun: throw-on-error [make function! spec body]
   
   pos: any [find third :fun /local tail third :fun ] 

   if returns [insert pos compose/only [return: (returns)]]
   if categories [insert pos compose/only [category: (categories)]]
   if author [insert pos compose/only [author: (author)]]

   :fun
]


add-function-info: func [
   {Add additional info to an already defined function}
   [catch]
   :fun [function! native! action!] "The function to add info to"
   info [block!] "block of info blocks"
   return: [none]
   category: [help]
   author: ["Ingo Hohmann"]
   /local pos
][
   either parse info [
      some [
         set-word! block!
      ]
   ][
      insert any [find third :fun /local tail third :fun] info
   ][
      throw make error! "info block has wrong contents"
   ]
]


add-function-info func [
   return: [function!]
   category: [development]
   Author: [RT "Ingo Hohmann"]
]
   
help: func [
    {Prints information about words and values.
    *PATCHED* iho
    Returns additional info on functions
    }
    'word [any-type!] 
    return: ["Does not return a value"]
    category: [help]
    author: [RT "Ingo Hohmann"]
    /local value args item name refmode types attrs rtype categorized author
][
    if unset? get/any 'word [
        print trim/auto {
^-^-^-^-To use HELP, supply a word or value as its
^-^-^-^-argument:
^-^-^-^-
^-^-^-^-^-help insert
^-^-^-^-^-help system
^-^-^-^-^-help system/script

^-^-^-^-To view all words that match a pattern use a
^-^-^-^-string or partial word:

^-^-^-^-^-help "path"
^-^-^-^-^-help to-

^-^-^-^-To see words with values of a specific datatype:

^-^-^-^-^-help native!
^-^-^-^-^-help datatype!

^-^-^-^-Word completion:

^-^-^-^-^-The command line can perform word
^-^-^-^-^-completion. Type a few chars and press TAB
^-^-^-^-^-to complete the word. If nothing happens,
^-^-^-^-^-there may be more than one word that
^-^-^-^-^-matches. Press TAB again to see choices.

^-^-^-^-^-Local filenames can also be completed.
^-^-^-^-^-Begin the filename with a %.

^-^-^-^-Other useful functions:

^-^-^-^-^-about - see general product info
^-^-^-^-^-usage - view program options
^-^-^-^-^-license - show terms of user license
^-^-^-^-^-source func - view source of a function
^-^-^-^-^-upgrade - updates your copy of REBOL
^-^-^-^-
^-^-^-^-More information: http://www.rebol.com/docs.html
^-^-^-} 
        exit
    ] 
    if all [word? :word not value? :word] [word: mold :word] 
    if any [string? :word all [word? :word datatype? get :word]] [
        types: dump-obj/match system/words :word 
        sort types 
        if not empty? types [
            print ["Found these words:" newline types] 
            exit
        ] 
        print ["No information on" word "(word has no value)"] 
        exit
    ] 
    type-name: func [value] [
        value: mold type? :value 
        clear back tail value 
        join either find "aeiou" first value ["an "] ["a "] value
    ] 
    if not any [word? :word path? :word] [
        print [mold :word "is" type-name :word] 
        exit
    ] 
    value: either path? :word [first reduce reduce [word]] [get :word] 
    if not any-function? :value [
        prin [uppercase mold word "is" type-name :value "of value: "] 
        print either object? value [print "" dump-obj value] [mold :value] 
        exit
    ] 
    args: third :value 
    prin "USAGE:^/^-" 
    if not op? :value [prin append uppercase mold word " "] 
    while [not tail? args] [
        item: first args 
        if :item = /local [break] 
        if any [all [any-word? :item not set-word? :item] refinement? :item] [
            prin append mold :item " " 
            if op? :value [prin append uppercase mold word " " value: none]
        ] 
        args: next args
    ] 
    print "" 
    args: head args 
    value: get word 
    print "^/DESCRIPTION:" 
    either string? pick args 1 [
        print [tab first args newline tab uppercase mold word "is" type-name :value "value."] 
        args: next args
    ] [
        print "^-(undocumented)"
    ] 
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
            all [set-word? :item :item = first [return:] block? first args rtype: first args] 
            all [set-word? :item :item = first [category:] block? first args categorized: first args] 
            all [set-word? :item :item = first [author:] block? first args author: first args] 
            if none? refmode [
                print "^/ARGUMENTS:" 
                refmode: 'args
            ]
        ] [
            if refmode <> 'refs [
                print "^/REFINEMENTS:" 
                refmode: 'refs
            ]
        ] 
        either refinement? :item [
            prin [tab mold item] 
            if string? pick args 1 [prin [" --" first args] args: next args] 
            print ""
        ] [
            if all [any-word? :item not set-word? :item] [
                if refmode = 'refs [prin tab] 
                prin [tab :item "-- "] 
                types: if block? pick args 1 [args: next args first back args] 
                if string? pick args 1 [prin [first args ""] args: next args] 
                if not types [types: 'any] 
                prin rejoin ["(Type: " types ")"] 
                print ""
            ]
        ]
    ] 
    if rtype [print ["^/RETURNS:^/^-" rtype]] 
    if categorized [print ["^/CATEGORIES:^/^-" categorized]] 
    if attrs [
        print "^/(SPECIAL ATTRIBUTES)" 
        while [not tail? attrs] [
            value: first attrs 
            attrs: next attrs 
            if any-word? value [
                prin [tab value] 
                if string? pick attrs 1 [
                    prin [" -- " first attrs] 
                    attrs: next attrs
                ] 
                print ""
            ]
        ]
    ] 
    exit
]



