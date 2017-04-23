REBOL [
	Title:	 "File globbing module and dialect"
	Date:	 19-Oct-2006
	Version: 0.0.2
	File:	 %file-list.r
	Author:  "Gregg Irwin"
	Email:	 greggirwin@acm.org
	Purpose: {
        Given a file spec, and optional criteria for date, size,
        and attributes, the FILE-LIST function returns a block of
        files that match the spec and criteria.

        It is also a test-bed for how to integrate dialects with
        one-another. There are sub-dialects for date, size, and
        attribute tests, and FILE-LIST encapsulates those, along
        with the LIKE? dialect for pattern matching on file names.
        There are things I don't like about the approach, but we
        can learn from it if nothing else (and it does actually
        work, too :).

        You will see commented bits, possible refinements and
        various design decisions. Implementation is not the hard
        part. The hard part is designing something that works
        well, and intuitively (as in the principle of least
        surprise).

        There will undoubtedly also be cross-platform issues that
        need to be addressed.
	}
	History: [
            0.0.1 [15-Oct-2006 "Initial Release." Gregg]
            0.0.2 [19-Oct-2006 "Enhanced date and size comparison dialects slightly." Gregg]
	]
	Comment: {
	}
    library: [
        level: 'advanced
        platform: 'all
        type: [function dialect module]
        domain: [dialects files]
        tested-under: [View 1.3.2 on WinXP by Gregg]
        license: 'BSD
        support: none
    ]
]

; needs: [INCLUDE COLLECT LIKE?]
include/check %collect.r
include/check %like.r

file-date-ctx: context [
    =negate-op?:
    =or-equal?:
    =op:
    =parse-end-mark:
    =date:
        none
    =attr: 'modification-date

    make-lit-word: func [val] [to lit-word! :val]
    lit-equal: make-lit-word "="
    lit-lesser: make-lit-word "<"
    lit-greater: make-lit-word ">"
    lit-lesser-or-equal: make-lit-word "<="
    lit-greater-or-equal: make-lit-word ">="

    on?=: [opt 'on]
    of?=: [opt 'of]

    attr=: [
        ['changed on?= | 'modified on?= | 'upated on?= | 'modification-date of?=]
        | ['created on?= | 'creation-date of?= | 'create-date of?=] (=attr: 'creation-date)
        | ['accessed on?= | 'access-date of?= ] (=attr: 'access-date)
    ]
    date=: [
        [
            set =date date!
            | set =date file! (=date: get-modes =date =attr) ; =date refers to a file in this sub-rule
            | 'yesterday      (=date: now/date - 1)
            | 'today          (=date: now/date)
            | 'tomorrow       (=date: now/date + 1)
;             | set =date integer! ; implies year. Actual date used for comparison
;                                  ; will depend on operator. 'greater ops imply
;                                  ; 31-Dec; 'lesser ops imply 1-Jan; negation
;                                  ; reverses those implications.
;             | 'this 'year   (=date: now/year)
;           ; TBD add month (and week?) comparisons; needs a 'between op.
        ]
    ]
    word-comparison=: [
        [
            ['after | 'since | 'newer 'than] (=op: 'greater)
            | ['before | 'up 'to | 'older 'than] (=op: 'lesser)
            | (=op: 'equal)
        ]
        opt ['or 'equal 'to (=or-equal?: true)]
    ]
    lit-comparison=: [
        lit-equal              (=or-equal?: false  =op: 'equal)
        | lit-lesser           (=or-equal?: false  =op: 'lesser)
        | lit-greater          (=or-equal?: false  =op: 'greater)
        | lit-lesser-or-equal  (=or-equal?: true   =op: 'lesser)
        | lit-greater-or-equal (=or-equal?: true   =op: 'greater)
    ]
    ; TBD - add a 'between op
    rules=: [
        (
            =negate-op?: =or-equal?: =parse-end-mark: =date: none
            =attr: 'modification-date
            =op:   'equal
        )
        opt 'if opt ['date | 'date?] opt 'is
        opt [['no | 'not] (=negate-op?: true)]
        opt ['date | 'date?]
        opt attr=
        [word-comparison= | lit-comparison=]
        (if =negate-op? [=op: pick [greater lesser] =op = 'lesser])
        (=op: to word! rejoin [=op either =or-equal? ['-or-equal] [""] '?])
        date=
        =parse-end-mark:
    ]

    ; This is an experiment in how to design a nested dialect. The idea is
    ; that you try to parse the input, and return the end point of what you
    ; were able to parse, if successful; otherwise, return none. In this
    ; case, there is not an interface to say what this dialect did, so you
    ; need to "know" (i.e. read the code) that it will set certain vars in
    ; this context.
    comparison-cmd?: func [input [block!]] [
        parse input rules=
        return =parse-end-mark
    ]
    set 'date-comparison-cmd? :comparison-cmd?


    ; Make a function that returns true if the file it is given matches the
    ; spec parsed from the dialected input.
    set 'make-file-date-comparison-func func [spec] [
        if date-comparison-cmd? spec [
            func [file [file! url!]] reduce [
                =op  'get-modes 'file to lit-word! =attr  =date
            ]
        ]
    ]

    set 'file-date-match func [
        "Return files that match the specified criteria."
        files [block!] "List of files to check"
        spec  [block!] "Dialected comparison criteria"
        /help "Show more detailed help on usage"
        /local match?
    ][
		if help [print usage  exit]
        if match?: make-file-date-comparison-func spec [
            collect 'keep [
                foreach file files [if match? file [keep: file]]
            ]
        ]
    ]

    usage: {
        There are three main elements to a comparison: attribute,
        operator, and date. These can be specified in a number of
        ways, and you can use 'not in front, to negate them as well.

        Attribute:
            This is the specific date you want to check on the file.
            By default, the modification-date is used, but you can
            also check the date created or last accessed.

        Operator:
            The boolean comparison you want to perform. You may prefer
            to use standard symbols (=, <>, <, >, <=, >=) or words like
            before, after, newer than, older than.

        Date:
            This is either a literal date, a file (whose date is to be
            used), or a word (yesterday, today, tomorrow).

        Examples:
            [accessed after 1-jan-2006]
            [created before 1-jan-2006]
            [newer than %test-files.r]
            [older than %file-list.r]
    }
]


file-size-ctx: context [
    =negate-op?: none
    =or-equal?: none
    =op: none
    =size: 0
    =size-mul: 1
    =parse-end-mark: none

    make-lit-word: func [val] [to lit-word! :val]
    lit-lesser: make-lit-word "<"
    lit-greater: make-lit-word ">"
    lit-lesser-or-equal: make-lit-word "<="
    lit-greater-or-equal: make-lit-word ">="

    size=: [
        (=size-mul: 1)
        [
            set =size number!
            | set =size file! (=size: size? =size)
        ]
        opt [
            'bytes ; no change to size-mul
            | ['kilobytes | 'KB] (=size-mul: 1024.0)
            | ['megabytes | 'MB] (=size-mul: 1048576.0)
            | ['gigabytes | 'GB] (=size-mul: 1073741824.0)
        ]
        (=size: =size * =size-mul)
    ]
    word-comparison=: [
        [
            ['more | 'larger | 'greater] (=op: 'greater)
            | ['less | 'smaller] (=op: 'lesser)
            | (=op: 'equal)
        ] 'than
        opt ['or 'equal 'to (=or-equal?: true)]
    ]
    lit-comparison=: [
        lit-lesser             (=or-equal?: false  =op: 'lesser)
        | lit-greater          (=or-equal?: false  =op: 'greater)
        | lit-lesser-or-equal  (=or-equal?: true   =op: 'lesser)
        | lit-greater-or-equal (=or-equal?: true   =op: 'greater)
    ]
    ; TBD - add a 'between op
    rules=: [
        (=negate-op?: =or-equal?: =op: =parse-end-mark: none)
        opt 'if opt ['size | size?] opt 'is
        opt [opt 'but ['no | 'not] (=negate-op?: true)]
        [word-comparison= | lit-comparison=]
        (if =negate-op? [=op: pick [greater lesser] =op = 'lesser])
        (=op: to word! rejoin [=op either =or-equal? ['-or-equal] [""] '?])
        size=
        =parse-end-mark:
    ]

    ; This is an experiment in how to design a nested dialect. The idea is
    ; that you try to parse the input, and return the end point of what you
    ; were able to parse, if successful; otherwise, return none. In this
    ; case, there is not an interface to say what this dialect did, so you
    ; need to "know" (i.e. read the code) that it will set certain vars in
    ; this context.
    comparison-cmd?: func [input [block!]] [
        parse input rules=
        return =parse-end-mark
    ]
    set 'size-comparison-cmd? :comparison-cmd?

    ; Make a function that returns true if the file it is given matches the
    ; spec parsed from the dialected input.
    set 'make-file-size-comparison-func func [spec] [
        if size-comparison-cmd? spec [
            func [file [file! url!]] reduce [=op 'size? 'file =size]
        ]
    ]

    set 'file-size-match func [
        "Return files that match the specified criteria."
        files [block!] "List of files to check"
        spec  [block!] "Dialected comparison criteria"
        /help "Show more detailed help on usage"
        /local match?
    ][
		if help [print usage  exit]
        if match?: make-file-size-comparison-func spec [
            collect 'keep [
                foreach file files [if match? file [keep: file]]
            ]
        ]
    ]

    usage: {
        There are two main elements to a comparison: operator, and
        size. These can be specified in a number of ways, and you
        can use 'not in front, to negate them as well.

        Operator:
            The boolean comparison you want to perform. You may prefer
            to use standard symbols (=, <>, <, >, <=, >=) or phrases
            like: smaller than, less than, more than, larger than.

        Size:
            This is either a size in bytes, a size followed by a
            unit size (KB, MB, GB) to specify kilobytes, megabytes,
            and gigabytes respectively, or a file whose size is used
            for comparison.

        Examples:
            [size >= 1024]
            [less than or equal to 1024 bytes]
            [>= 64 kb]
            [smaller than 2 MB]
            [greater than .5 MB]
            [larger than %file-list.r]
    }
]


file-attr-ctx: context [
    ; This deals with actual file attributes, not timestamp and size.
    
    ; Need to decide how to deal with non-existent attributes.
    
    ; Should read-only only consider owner-write, or should it also
    ; consider group-write and world-write?

    read-only?: func [file] [not get-modes file 'owner-write]
    archived?:  func [file] [get-modes file 'archived]
    hidden?:    func [file] [get-modes file 'hidden]
    system?:    func [file] [get-modes file 'system]

    get-attr: func [
        {Return current attributes for the file.}
        file [file! url!]
        /with   {Retrieve only selected attributes.}
            sel {Selected attributes to retrieve.}
        /avail  {Return a list of attributes available for the file.}
    ][
        get-modes file either avail ['file-modes] [
            any [sel get-modes file 'file-modes]
        ]
    ]

    ; Block support is here because get-modes returns an object spec block
;     attr?: func [attrs [object! block!] name [word!]] [
;         if block? attrs [attrs: construct attrs]
;         ; The "get in" syntax gives us none, rather than erroring out, if
;         ; the word doesn't exist in the object.
;         either name <> 'read-only [get in attrs name] [
;             not get in attrs 'owner-write
;         ]
;     ]

    =parse-end-mark: none
    =not?: none
    =attr-checks: none

    attr-word=: [   ; updates =attr-checks
        (=attr-word: none)
        set =attr-word [
              'archived   | 'hidden      | 'system
            | 'owner-read | 'owner-write | 'owner-execute
            | 'group-read | 'group-write | 'group-execute
            | 'world-read | 'world-write | 'world-execute
            ; added words, that are not standard REBOL attribute words
            | 'read-only  ; = not owner-write
            | 'archive  ; just in case they forget the 'd
        ] (
            if =attr-word [
                ; replace and handle any special words we defined.
                if =attr-word = 'archive [=attr-word: 'archived]

                repend =attr-checks either =attr-word = 'read-only [
                    ; read-only is a special case; it equals "not owner-write"
                    [to set-word! 'owner-write either =not? [true] [false]]
                ][
                    ; This is the normal case, for a standard REBOL attribute word
                    [to set-word! =attr-word   either =not? [false] [true]]
                ]
            ]
        )
    ]

    attr=: [
        (=not?: none)
        opt [opt 'but 'not (=not?: true)] [into [some attr-word=] | attr-word=]
    ]

    rules=: [
        (=parse-end-mark: none  =attr-checks: copy [])
        some attr=
        =parse-end-mark:
    ]

    ; This is an experiment in how to design a nested dialect. The idea is
    ; that you try to parse the input, and return the end point of what you
    ; were able to parse, if successful; otherwise, return none. In this
    ; case, there is not an interface to say what this dialect did, so you
    ; need to "know" (i.e. read the code) that it will set certain vars in
    ; this context.
    comparison-cmd?: func [input [block!]] [
        parse input rules=
        return =parse-end-mark
    ]
    set 'attr-comparison-cmd? :comparison-cmd?

    attr-match?: func [file-attr ref-attr name] [
        equal? select file-attr name select ref-attr name
    ]

    ; Make a function that returns true if the file it is given matches the
    ; spec parsed from the dialected input.
    make-file-attr-comparison-func: func [spec] [
        if attr-comparison-cmd? spec [
            ; This guy is simple. We've parsed the test spec and created
            ; a list of attrs they want to check, along with the expected
            ; value for each. We just check each one we care about to see
            ; if it's the same for the given file. That is, the attr
            ; criteria are ANDed together.
            func [file [file! url!] /local attrs] [
                attrs: get-attr file
                foreach [name val] =attr-checks [
                    if not attr-match? attrs =attr-checks name [return false]
                ]
                ; if we didn't bail out due to a mismatch, we've got a match.
                return true
            ]
        ]
    ]

    set 'file-attr-match func [
        "Return files that match the specified criteria."
        files [block!] "List of files to check"
        spec  [block!] "Dialected comparison criteria"
        /help "Show more detailed help on usage"
        /local match?
    ][
		if help [print usage  exit]
        if match?: make-file-attr-comparison-func spec [
            collect 'keep [
                foreach file files [if match? file [keep: file]]
            ]
        ]
    ]

    usage: {
        Attributes are logic! values, so you only need to specify the
        name of the attribute(s) to check. These can be specified in
        a number of ways, and you can use 'not in front, to negate
        them as well. Available attributes vary by operating system.
        The only "extra" attribute name added to the dialect is
        'read-only, which equates to "not owner-write".

        You can group attribute names in blocks, for easier use with
        the 'not operator.

        Examples:
            [hidden]
            [archived]
            [system]
            [system hidden]
            [read-only]
            [not read-only]
            [not system not group-read]
            [not [system read-only]]
            [not [system world-read group-execute]]
            [hidden not archived]
            [world-execute]
            [not [hidden system archive read-only]]
            [not [group-write world-write]]
    }

]


file-spec-ctx: context [

    change-all: func [
        "Change each value in the series by applying a function to it"
        series  [series!]
        fn      [any-function!] "Function that takes one arg"
        /only
    ][
        either only [
            forall series [change/only series fn first series]
        ][
            forall series [change series fn first series]
        ]
        head series
    ]

    =parse-end-mark: none
    =not?: none
    =include: none
    =exclude: none

    pattern=: [   ; updates =include or =exclude
        (=pattern: none)
        set =pattern [file! | url! | string!] (
            if =pattern [
                if string? =pattern [=pattern: to-rebol-file =pattern]
                repend either =not? [=exclude] [=include] =pattern
            ]
        )
    ]

    spec=: [
        (=not?: none)
        opt ['include | [opt 'but ['not | 'exclude | 'excluding] (=not?: true)]]
        [into [some pattern=] | pattern=]
    ]

    rules=: [
        (
            =parse-end-mark: none
            =include: copy []
            =exclude: copy []
        )
        some spec=
        =parse-end-mark:
    ]

    ; This is an experiment in how to design a nested dialect. The idea is
    ; that you try to parse the input, and return the end point of what you
    ; were able to parse, if successful; otherwise, return none. In this
    ; case, there is not an interface to say what this dialect did, so you
    ; need to "know" (i.e. read the code) that it will set certain vars in
    ; this context.
    comparison-cmd?: func [input [block!]] [
        parse input rules=
        return =parse-end-mark
    ]
    set 'spec-comparison-cmd? :comparison-cmd?

    spec-match?: func [
        spec
        incl-pat "Include patterns"
        excl-pat "Exclude patterns"
    ][
        foreach pat excl-pat [if like? spec pat [return none]]
        ; This is like an OR on for any spec match
        foreach pat incl-pat [if like? spec pat [return true]]
        return false
    ]

    expand: func [spec [any-string!]] [like-ctx/expand-pattern spec]

    ; Make a function that returns true if the file it is given matches the
    ; spec parsed from the dialected input.
    set 'make-file-spec-comparison-func func [spec] [
        if spec-comparison-cmd? spec [
            ; "pre-expand" patterns, so they don't have to be expanded
            ; each time this function is called.
            change-all/only =include :expand
            change-all/only =exclude :expand
            func [file [file! url!]] [
                spec-match? file =include =exclude
            ]
        ]
    ]

    ; Does this need a case-senstive switch? Probably so.
    set 'file-spec-match func [
        "Return files that match the specified criteria."
        files [block!] "List of files to check"
        spec  [block!] "Dialected comparison criteria"
        /help "Show more detailed help on usage"
        /local match?
    ][
		if help [print usage  exit]
        if match?: make-file-spec-comparison-func spec [
            collect 'keep [
                foreach file files [if match? file [keep: file]]
            ]
        ]
    ]

    usage: {
        The spec contains file glob patterns; see help on the LIKE?
        function for syntax details. Multiple patterns can be
        specified, and you can group them in blocks for easier use
        with the 'not operator.

        Examples:
            [%*.txt]
            [%read*]
            [%*archive*]
            [%read* not [%*System.txt]]
            [%*.txt excluding [%System.txt %notes.txt]]
    }

]


find-file-ctx: context [

    =spec: copy []
    =date: copy []
    =size: copy []
    =attr: copy []

    use-defaults: true  ; set to false if you don't want to use the
                        ; default specs below.
    ; are these common enough to include? [%*/BitKeeper/* %*/SCCS/*]
    def-file-spec: [not [%*/CVS/* %*/.svn/* %*.bak %.*]]
    def-attr-spec: [not [hidden system]]


    compare: func [obj 'input target] [
        all [
            obj/comparison-cmd? get input
            mark: obj/=parse-end-mark
            append target copy/part get input mark
            set input mark
        ]
    ]

    ; This is an experiment in how to design a nested dialect. The idea is
    ; that you try to parse the input, and return the end point of what you
    ; were able to parse, if successful; otherwise, return none. In this
    ; case, there is not an interface to say what this dialect did, so you
    ; need to "know" (i.e. read the code) that it will set certain vars in
    ; this context.
    find-comparison-cmd?: func [input [block!]] [
        foreach series reduce [=spec =date =size =attr] [clear series]
        while [not tail? input] [
            any [
                compare file-spec-ctx input =spec
                compare file-date-ctx input =date
                compare file-size-ctx input =size
                compare file-attr-ctx input =attr
                input: next input      ; skip stuff we don't know about?
            ]
        ]
        foreach series reduce [=spec =date =size =attr] [
            if not empty? series [return true]
        ]
        return false
    ]

    find-match?: func [
        files [block!] "Files to test"
        spec "File-spec matching rule"
        date "Date matching rule"
        size "Size matching rule"
        attr "Attribute matching rule"
        /local res
    ][
        if use-defaults [   ; use-defaults is an object level var
            spec: append copy/deep spec def-file-spec
            attr: append copy/deep attr def-attr-spec
        ]

        ;print [mold file  mold spec  file-spec-match file spec]
        ;probe fn: make-file-spec-comparison-func spec
        ;print [tab fn first file]

        foreach [test fn] reduce [
            spec :file-spec-match
            date :file-date-match
            size :file-size-match
            attr :file-attr-match
        ][
            if all [test not empty? test] [files: fn files test]
        ]
        files
    ]

    ; Make a function that returns true if the file it is given matches the
    ; spec parsed from the dialected input.
    make-find-file-comparison-func: func [
        spec
    ][
        if find-comparison-cmd? spec [
            func [files [block!]] [
                find-match? files =spec =date =size =attr
            ]
        ]
    ]

    set 'find-file-match func [
        "Return files that match the specified criteria."
        files [block!] "List of files to check"
        spec  [block!] "Dialected comparison criteria"
        /help "Show more detailed help on usage"
        /local match?
    ][
		if help [print usage  exit]
        ;print [#### mold files mold spec]
        if match?: make-find-file-comparison-func spec [match? files]
    ]

    usage: {
        This function combines the date, size, attribute, and spec
        comparison functions into a single command. See the related
        functions for details:

        See also:
            file-date-match file-size-match file-attr-match file-spec-match

        Examples:
            [%*.txt]
            [%*.txt  changed after  1-Aug-1998]
            [%*.txt  changed before 1-Aug-1998]
            [%*.txt  changed after  1-Aug-1998 >= 10 kb]
            [%*.txt  changed after  1-Aug-1998 <  10 kb]
            [%*.txt  changed after  1-Aug-1998 >= 10 kb  system]
            [%*.txt  changed after  1-Aug-1998 >= 10 kb  not system]
            [%*.txt  changed after  1-Aug-1998 <  10 kb  read-only]
            [%*.txt  changed after  1-Aug-1998 <  10 kb  not read-only]
            [ <  10 kb  %*.txt  not read-only  changed after  1-Aug-1998]
            [not read-only   < 10 kb   changed after 1-Aug-1998  %*.txt]
            [not read-only   < 10 kb   changed after 1-Aug-1998  %*a*.txt]
    }
]


file-list-ctx: context [

    abs-path?: func [file [file!]] [#"/" = first file]

    change-all: func [
        "Change each value in the series by applying a function to it"
        series  [series!]
        fn      [any-function!] "Function that takes one arg"
        /only
    ][
        either only [
            forall series [change/only series fn first series]
        ][
            forall series [change series fn first series]
        ]
        head series
    ]

    dirs-in: func [path] [
        remove-each file read path [
            any [not dir? file  file-attr-ctx/hidden? file]
            ;any [not dir? file]
        ]
    ]

    dirs-only: func [block] [remove-each item block [not dir? item]]

    do-in-dir: func [
        "Execute a block while in a certain directory"
        dir block /make /local orig res
    ][
        orig: what-dir
        if all [make  not exists? dir] [make-dir/deep dir]
        change-dir dir
        res: do block
        change-dir orig
        res
    ]

    files-only: func [block] [remove-each item block [dir? item]]

    prepend: func [
        {Inserts a value at the head of a series and returns the series head.}
        series [series! port!]
        value
        /only "Prepends a block value as a block"
    ][
        head either only [
            insert/only head series :value
        ] [
            insert head series :value
        ]
    ]

    ; split the absolute part of a path that has wildcard chars in it
    ; from the rest of the path, kind of like split-path does.
    split-abs-path: func [file [file!] /local a b dir] [
        if not abs-path? file [return reduce [%"" file]]
        if dir? file [return file]
        a: file
        while [all [not dir? a  a <> %/]] [set [a b] split-path a]
        either dir? a [reduce [a find/match file a]] [none]
    ]


    ;!! If you are writing something, like grep or awk, that may
    ;   operate on a large number of files, you may not want it
    ;   to spend time finding all the files before starting to
    ;   search each one; that implies a callback mechanism for
    ;   each file found, rather than returning a result block.
    ; if spec has path, use spec on clean-path'd filename;
    ; otherwise, use spec on filename only.
    add-files: func [
        spec  [block! file!]   "Rules for what files to include"
        callback [none! function!] "Instead of returning a block of files, call this function for each file (if not none)"
        /deep  "Recurse sub-directories."
        ;/all  "Don't ignore hidden directories"
        /local path spec* files res want-dirs? rtn-abs? do-callback
    ][
        do-callback: func [files] [
            foreach file files [
                callback either rtn-abs? [clean-path file] [file]
            ]
        ]
        ;print [type? spec mold spec]
        either file? spec [
            set [path spec] split-abs-path spec
            spec: compose [(spec)]
        ][
            set [path spec*] split-abs-path first spec
            change spec spec*
        ]
        if empty? path [path: %./]
        rtn-abs?: abs-path? path
        ; the first item in the spec is the file spec, so
        ; we look at that to determine if they want to return
        ; dirs instead of files.
        want-dirs?: #"/" = last first spec
        ;print [### mold path mold spec mold read path]
        do-in-dir path [
            res: collect item [
                ; If the spec ends with a slash, they want dirs back
                ; instead of files.
                files: do either want-dirs? [:dirs-only] [:files-only] read %.
                ; We need the intermediate 'res var, to work around an issue
                ; with COLLECT, where adding an empty block causes a problem.
                res: find-file-match files spec

                either :callback [do-callback res] [if not empty? res [item: res]]
                ;!! If we have a callback scenario, this is where we would call
                ;   it for each file, rather than adding to the result block.
                if deep [
                    ; Have to figure out how, and if, we want to match dir
                    ; names in the spec. Not matching them gives us more
                    ; intuitive results at a basic level. Then we also need
                    ; to consider how dirs-in treats hidden directories.
                    foreach dir dirs-in path [
                    ;foreach dir find-file-match dirs-in path spec [
                        ;print [#### mold path mold dir]
                        do-in-dir dir [res: add-files/deep spec :callback]
                        ; relatively qualify the files from the sub-dir
                        change-all res func [file] [prepend file dir]
                        either :callback [do-callback res] [if not empty? res [item: res]]
                    ]
                ]
            ]
            ; If they gave us an absolute path, should we return fully
            ; qualified filenames? Right now we do.
            either not abs-path? path [res] [
                change-all res func [file] [clean-path file]
            ]
        ]
    ]

    file-list?: func [series [block!]] [
        parse series [some [file! | url!]]
    ]

    set 'refresh-file-list func [
        "Remove any item from the list that no longer exists."
        list [block!] "Must be a list of files; file! or url! values."
    ][
        if not file-list? list [return none]
        remove-each file list [not exists? file]
    ]

    set 'file-list func [
        "Returns a block of files matching spec, date, size, or attribute criteria."
        input [any-string! block!] "Spec matching the syntax used by find-file-match"
        /remove "Remove items from an existing file list"
            list [block!] "The list to remove items from"
        /deep   "Recurse when adding files"
        ;/case   "Use case-sensitive name matching"
        ; Could/should the callback take a block of files, e.g. found in a given dir?
        /callback "Instead of returning a block of files, call this function for each file"
            fn [function!] "Callback function must take one file! parameter"
        ;/absolute  "Use clean-path on the results, so all names are fully qualified"
        ;/no-defaults "Turn default specs off"
        /local res
    ][
        ; Blockify input for passing to find-file-match
        if remove [
            res: find-file-match list compose [(input)]
            ;?? use EXCLUDE here?
            return remove-each file list [found? find res file]
        ]
        res: either deep [add-files/deep input :fn] [add-files input :fn]
        either res [res] [none]
    ]

]

