REBOL [
	Title:	 "VB Like Operator Module/pattern-matcher"
	Date:	 10-Sep-2003
	Version: 0.0.3
	File:	 %like.r
	Author:  "Gregg Irwin"
	Email:	 greggirwin@acm.org
	Purpose: {
            The LIKE? function is a first crack at something like
            VB's Like operator. i.e. a *very* simple RegEx engine as you
            would use in shells for file globbing. The real purpose was to 
            help me get acquainted with parse.
	}
	History: [
            0.0.1 [03-Sep-2001 "Initial Release." Gregg]
            0.0.2 [19-Mar-2002 "Fixed negated char class syntax" Gregg]
            0.0.3 [10-Sep-2003
                {Rediscovered this and beefed up the char group syntax so it
                 matches the VB spec better. Still in progress though.}
                {Renamed some things too.}
                {Cleaned things up (a little) and reorganized.}
                Gregg
            ]
	]
	Comment: {
		May need to add escape for wildcard chars in patterns.
		
		Other file glob systems support a couple other patterns you can use 
		in the syntax: ** and { , }. Something to consider. ** is, I think, 
		just the equivalent of a /deep refinement in file-list for us, but 
		we don't have a { , } equivalent, which seems useful. The ** syntax
		is very powerful in this kind of context. e.g.:
		
			c:/Src/**/*Grid*/**/ABC/**/Readme.txt  	
			
			Recursively matches all directories under c:/Src/ that 
			contain Grid. From the found directory, recursively 
			matches directories until ABC/ is found. From there, 
			the file Readme.txt is searched for recursively.
			(From http://www.codeproject.com/file/FileGlob.asp.)
			
		Consider how to deal with ~ (home dir) and env-var expansion.
	}
    library: [
        level: 'intermediate
        platform: 'all
        type: [function dialect]
        domain: [dialects]
        tested-under: [View 1.3.2 on WinXP by Gregg "And under a lot of other versions and products"]
        license: 'BSD
        support: none
    ]
]

like-ctx: context [
	usage: {
	Pattern syntax: 
			
		A hyphen (-) can appear either at the beginning (after an
		exclamation point if one is used) or at the end of charlist
		to match itself. In any other location, the hyphen is used to
		identify a range of characters.
	
		When a range of characters is specified, they must appear in
		ascending sort order (from lowest to highest). [A-Z] is a valid
		pattern, but [Z-A] is not.
	
		The character sequence [] is considered a zero-length string ("").
	
		  *     Zero or more characters
		  ?     Any single character
		  #     Any single digit
		[list]	Any single char in list (character class)
		[!list] Any single char not in list
	
		Meta chars, except "]", can be used in character classes.
	
		"]" can be used by itself, as a regular char, but not in a
		character class.
	}
	
	any-char: complement charset ""
	digit: charset [#"0" - #"9"]
	non-digit: complement digit
	any-single-digit: [1 digit]
	any-single-char: 'skip ; [1 any-char]
	;any-multi-char:  [any any-char]
	;any-multi-char-to:  [any any-char to]
	wild-chars: charset "*?![#"
	non-wild-chars: complement wild-chars
	valid-group-chars: complement charset "]"
	to-next-real-char: 'thru
	to-end: [to end]

	last-expanded-rule: none

    expand-pattern: func [
        {Convert a VB Like operator spec into a set of parse rules for use with LIKE?.}
        pattern [any-string!]
        /local plain-chars dig star any-one char-group emit tmp result
    ][
        emit: func [arg] [
            ; OK, this is ugly. If you put *[ in your pattern, it causes
            ; problems because * = thru (right now) and you can't say
            ; "thru bitset!" in a parse rule. So, what I do in that case 
            ; is remove the thru and replace it with something I think 
            ; will work.
            either all [
                not empty? result
                'to-next-real-char = last result
                bitset! = type? arg
            ][
                change back tail result reduce ['any complement arg arg]
            ][
                append result arg
            ]
        ]

        plain-chars: [copy tmp some non-wild-chars (emit copy tmp)]
        dig:		 ["#" (emit 'any-single-digit)]
        star:		 ["*" (emit 'to-next-real-char)]
        any-one:	 ["?" (emit 'any-single-char)]
        char-group:  [
            "[" copy tmp some valid-group-chars "]"
            (emit make-group-charset tmp)
        ]

        result: copy []
        parse/all pattern [
            some [char-group | plain-chars | dig | star | any-one]
        ]
        ; If the last thing in our pattern is thru, it won't work so we
        ; remove the trailing thru and replace it with "to end".
        if (last result) =? 'to-next-real-char [
            change back tail result 'to-end
        ]
        last-expanded-rule: result
    ]

    make-group-charset: func [
        {Take a char-group spec and convert it to a charset.}
        string
        /local
            add-group-char add-group-range dash non-dash
            rules group-chars char char-1 char-2 comp result
    ][
        add-group-char: func [char][
            if not none? char [append first group-chars char]
        ]
        add-group-range: func [char-1 char-2][
            append group-chars reduce [to-char char-1 '- to-char char-2]
        ]
    	dash: charset "-"
    	non-dash: complement dash
        rules: [
            [copy char opt #"!" (comp: char)]
            [copy char opt dash (add-group-char char)]
            some [
                  copy char-1 non-dash dash copy char-2 non-dash
                  (add-group-range char-1 char-2)
                | copy char non-dash (add-group-char char)
            ]
            [copy char opt dash (add-group-char char)]
            end
        ]
        group-chars: reduce [copy ""]
        parse string rules
        ;print mold group-chars
        result: charset group-chars
        either comp [complement result] [result]
    ]
    ; "ABCa-z!012" in PARSE rules is ["ABC" #"a" - #"z" "!012"]


    set 'like? func [
        "Matches patterns: *(any) ?(1 char) #(1 digit) [<chars>](char list); or block built by expand-pattern"
        string  [any-string!] "The string you want to check"
        pattern [any-string! block!] "The pattern you want to check the string against"
        /case "Use case sensitive parse"
		/help "Show more detailed synax on patterns; still need to pass two args."
    ][
		if help [print usage  exit]
		; Should we always bind blocks we get, or just assume they were built
		; with expand-pattern and so are already correctly bound?
		;either block? pattern [bind pattern self] [pattern: expand-pattern pattern]
		if not block? pattern [pattern: expand-pattern pattern]
    	either case [
    		parse/all/case string pattern
		][
			parse/all string pattern
		]
    ]


]

