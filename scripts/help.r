rebol [
	 Library: [
        level: 'intermediate
        platform: 'all
        type: [tool]
        domain: [debug]
        tested-under: 'Windows
        support: none
        license: none
        see-also: none
        ]

   Title: "REBOL Mezzanine Functions: Help"
   file: %help.r
     date: 2006/12/01
	Rights: "Copyright REBOL Technologies 1997-2002"
	; You are free to use, modify, and distribute this software with any
	; REBOL Technologies products as long as the above header, copyright,
	; and this comment remain intact. This software is provided "as is"
	; and without warranties of any kind. In no event shall the owners or
	; contributors be liable for any damages of any kind, even if advised
	; of the possibility of such damage. See license for more information.

	; Please help us to improve this software by contributing changes and
	; fixes via http://www.rebol.com/feedback.html - Thanks!

    purpose: {enhance original help with a secure way of showing functions in paths of objects and ports and show information about ports similar to objects}
    usage: {just put "do %help.r" in your user.r file and it will be used instead of the original help}
    example: {help/secure system/schemes/nntp/handler/set-modes}
]
help: func [
    "Prints information about words and values." 
    'word [any-type!] 
	/secure "do not evaluate functions in an object or port path and show just 2048 bytes of molded values"
    /local value args item type-name refmode types attrs rtype
	len inpath
][
    if unset? get/any 'word [
        print trim/auto {
^-^-^-To use HELP, supply a word or value as its
^-^-^-argument:
^-^-^-
^-^-^-^-help insert
^-^-^-^-help system
^-^-^-^-help system/script

^-^-^-To view all words that match a pattern use a
^-^-^-string or partial word:

^-^-^-^-help "path"
^-^-^-^-help to-

^-^-^-To see words with values of a specific datatype:

^-^-^-^-help native!
^-^-^-^-help datatype!

^-^-^-Word completion:

^-^-^-^-The command line can perform word
^-^-^-^-completion. Type a few chars and press TAB
^-^-^-^-to complete the word. If nothing happens,
^-^-^-^-there may be more than one word that
^-^-^-^-matches. Press TAB again to see choices.

^-^-^-^-Local filenames can also be completed.
^-^-^-^-Begin the filename with a %.

^-^-^-Other useful functions:

^-^-^-^-about - see general product info
^-^-^-^-usage - view program options
^-^-^-^-license - show terms of user license
^-^-^-^-source func - view source of a function
^-^-^-^-upgrade - updates your copy of REBOL
^-^-^-
^-^-^-More information: http://www.rebol.com/docs.html
^-^-} 
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
    type-name: func [value /len] [
	  len: any [
		all [
			series? :value
			len: length? :value
			join len " item(s) "
		]
		""
	   ]
        value: mold type? :value 
        clear back tail value 
        join either find "aeiou" first value ["an "] ["a "] [len value]
    ] 
    if not any [word? :word path? :word] [
        print [mold :word "is" type-name :word] 
        exit
    ] 
	
	
	value: either path? :word [
		len: 1
		if secure [
			until [
				value: do  copy/part  head :word  len
				len: len + 1
				any [
					empty? word: next  :word 
					any-function? inpath: either any  [object? value  port?  value] [
						get in value first :word
					] [
						:value
					]
				]
			]
		]
		either any-function? :inpath [
			print [ "^-there is a function inside an object or port" ]
			word: copy/part  head :word len 
			:inpath
		] [
			word: head :word
			first reduce reduce [word]
		]
	] [
		get :word
	] 
	
	
    if not any-function? :value [
        prin [uppercase mold word "is" type-name :value "of value: "] 
	   if port? :value [
		value: context load find mold :value "["
	   ]
        print either object? value [print "" dump-obj value] [ either secure [copy/part mold :value 2048] [mold :value]] 
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
	unless any-function? :inpath [
		value: get word
	]
    print "^/DESCRIPTION:" 
    either string? pick args 1 [
        print [tab first args] 
        args: next args
    ] [
        print "^-(undocumented)"
    ] 
    print [tab uppercase mold word "is" type-name :value "value."] 
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
