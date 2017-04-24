REBOL [
    Title:  "Library Project support module"
    Author: ["Gregg Irwin" "Volker Nitsch"]
    File:   %library-lib.r
    Version: 1.3.2
    History: [
        1.0.0 [17-jan-2003 {Hacked to use library search engine code with CGI stuff as a test.} GSI]
        1.1.0 [02-feb-2003 {First cleaning pass. Added docs. Removed globals.
            Changed a number of interfaces. Watch for breakage.} GSI]
        1.2.0 [09-feb-2003 {
            Modded for use with new prototype. Cleaning out more stuff to get
            it in line with the goal of having a single version that works for
            both reb and web front-ends.
            _pre-filter and _post-filter stuff removed. They could be left in
            as hook points but, for now, we'll just delegate all that stuff
            to the front end and let them call us to do our specific job.
        } GSI]
        1.3.0 [18-feb-2003 {
            Added update-index-entry and save-index functions.
            Changed header index filename from indexer-0.idx to header-index.rix.
        } GSI]
        1.3.1 [02-mar-2003 {
            update-index-entry replaces spaces with hyphens in filename.
        } GSI]
        1.3.1.1 [02-mar-2003 {
            added "?" -> [err-fn: either view [:alert][:print]]
        } VN]
        1.3.2 [06-mar-2003 {Added total-script-count function} GSI]
        1.3.2.1 [{fix in 'update-index-entry : hdr/file -> header/file} VN]
        1.3.2.2 [21-may-2007 {removed head from parse/all head scripts;
            fix in word-search run function} BWT]
    ]
    Comments: {
        Need to look at whether or not we can make this completely agnostic
        about whether it's used by CGI scripts or the Librarian REBOL app
        (i.e. non-CGI) scripts. That would be very nice.

        Right now it uses a PREFS object to get some path information about
        where files are located, for searching them, etc. It expects that
        the calling script has set the PREFS object up already. If this file
        lives in the support dir, along with the other support files it uses,
        the prefs dependency can be removed.
    }
]

rules:          ; The pre-defined filter rules we use to search.
script-index:   ; The index of scripts in the library.
    none

; Default sort values. These module level values are used to
; allow auto-reverse sorting. I.e. knowing what the current
; sort is to know if we should auto-reverse it on the next
; sort request. Ideally, this would move more to the client
; side of things so they just call our sort routine with the
; refinements they want. We shouldn't keep track of this in
; a general purpose library.
sort-key: 'title
sort-reversed: false


use [msg err-fn][
    if error? try [
        msg: "Loading gen-filters.r"
        rules: load prefs/support-dir/gen-filters.r
        msg: "Loading filter-rules-1.r"
        insert rules load prefs/support-dir/filter-rules-1.r
        msg: "Loading header-index.rix"
        script-index: load prefs/support-dir/header-index.rix

       ][
        ; If we use PRINT and quit with the reb front end, errors effectively
        ; vanish, so we need to know where we're running to be smart about it.
        err-fn: either view? [:alert][:print]
        err-fn join "Unable to read support file: " msg
       halt
    ]
]

total-script-count: does [length? script-index]

idx-match: func [
    {Returns true if the search and target values constitute a match;
    false otherwise. Currently we can have either a block! or word!
    on either side of the comparison, so we blockify both and then see
    if they intersect.}
	value  "The value(s) we're looking for"
	target "The target (i.e. valid) values to match against"
] [
    if any [none? value none? target] [return false]
	not empty? intersect to block! target to block! value
]


search-index: func [
    {Returns a block of items found in the index that match the rule's action.}
    index "The index you want to search"
    rule  "The rule to apply to each index entry"
    /local result item action val
] [
    result: make block! length? index
    foreach item index [
        action: copy rules/:rule/2
        change/only back tail action
            either val: do reduce [join to path! 'item last action] [
                to block! val
            ][
                none
            ]
        if do action [append/only result item]
    ]
    result
]

update-index-entry: func [
    "Updates a single entry in the current index with new values"
    field  "Index field to search"
    value  "Value to look for"
    header "New info for key entry"
    /local fld tmp timestamp
][
    ; Ick. We have to do a linear search right now with our current
    ; index structure.
    foreach item script-index [
        if item/:field = value [
            forskip item 2 [
                fld: item/1
                switch/default fld [
                    file [item/2: lowercase copy replace/all copy header/file " " "-"]
                    ;?? 9-Oct-2003 Gregg
                    ;?? Is FLD the right thing to use here, should it be FILE?
                    size [item/2: size? join prefs/script-dir item/:fld]
                    ; 9-Oct-2003 Changed index to use file timestamp, not header date.
                    ;date [item/2: header/date/date]
                    date [
                        timestamp: modified? join prefs/script-dir item/:file
                        item/2: timestamp/date
                    ]
                    library [
                        lib: item/2
                        forskip lib 2 [
                            lib/2: select header/library to set-word! lib/1
                        ]
                    ]
                ] [item/2: header/:fld]
            ]
            break
        ]
    ]
]

save-index: func [
    "Saves the current index to disk."
][
    save prefs/support-dir/header-index.rix script-index
]

Comment {
    The spec for run-user-search can be juse a simple string (e.g. "Sunanda")
    or a semi-dialected string that specifies a field to search and an
    operator to apply as well (e.g. author is "Volker Nitsch"). Eventually,
    a more complete	and robust query dialect should be built. It's kind of an
    ugly hack right now.
}


; Need a better name for this object?
word-search: context [
    all-files: scripts: none    ; object level so we only load them once.

    end-tag: "^/"
    word-end: join end-tag "^-"
    files-end: join end-tag " "

    word-end-tag: second word-end
    files-end-tag: second files-end

    run: func [
        block [any-block!] "The words you want to look for"
        /local intersection result msg err-fn
    ][
        ; Load the word index if we haven't loaded it previously.
        if none? scripts [
            if error? try [
                msg: "Loading %word-index.rix"
                set [all-files scripts] load/next prefs/support-dir/word-index.rix
            ][
                err-fn: either view? [:alert][:print]
                err-fn join "Unable to read support file: " msg
            ]
        ]
        intersection: none
        foreach word block [
            result: make block 1000
            parse/all scripts [any [
                    thru word thru end-tag
                    [
                        files-end-tag ; do nothing
                        |
                        word-end-tag copy files to files-end 2 skip
                        (
                            append result load files

                        )
                    ]
                ]
            ]
            intersection: either intersection
                [intersect intersection result]
                [copy result]

        ]
        if any [not intersection  empty? intersection][
            return copy []
        ]
        result: intersection
        unique head forall result [
            change result pick all-files first result
        ]
    ]
]


run-user-search: func [
	{Process a user defined query. This routine takes the query and returns
    a block of items in the index that match it.}
    spec [string! block!] {The query specification.}
    /index idx {The index you want to search if a field is specified in the spec.
    The idea here is that we may eventually have more than one index we want to use.}
    /local res data field op item action path files result map
] [
     either error? try [
        if not index [idx: script-index]
        res: parse spec none
        set [data field op] reduce either 1 = length? res [
            [spec none 'find]
        ][
            switch/default res/2 [
                "in" [[res/1 to word! res/3 'find/any]]
                "is" [[res/3 to word! res/1 'equal?]]
                "="  [[res/3 to word! res/1 'equal?]]
                ">"  [[res/3 to word! res/1 'greater?]]
                "<"  [[res/3 to word! res/1 'lesser?]]
                ">=" [[res/3 to word! res/1 'greater-or-equal?]]
                "<=" [[res/3 to word! res/1 'lesser-or-equal?]]
                "<>" [[res/3 to word! res/1 'not-equal?]]
                "contains" [[res/3 to word! res/1 'find/any]]
            ][[spec none 'find]]
        ]
        result: make block! length? idx
         either field [
            map: [size 0 version 0.0.0 date 01-jan-2000]
             foreach item idx [
                action: reduce [op field data]

                change/only at action 2
                    either val: do reduce [join to path! 'item action/2] [
                        form val
                    ][
                        none
                    ]
                attempt [
                    if find/skip map field 2 [
                        action/2: to select map field action/2
                        action/3: to select map field action/3
                    ]
                ]
                if do action [append/only result item]
            ]
        ][
            ; The word search engine returns a list of just filenames, and
            ; we need to return a list of entries from our script index,
            ; so we need to look them up. Since the header index isn't
            ; keyed, we'll just make a pass through it. This is another
            ; good reason to key the index on filename. :)
            files: word-search/run parse spec none
            foreach item idx [
                if remove find files item/file [
                    append/only result item
                ]
            ]
        ]
        ;result
    ] [copy []] [result] ; either error? try [...
]


random-selection: func [
	"Returns a random selection of N items from the script index. N=5 by default."
	/count "Specify the number of items you want displayed"
		number [integer!]
	/local items
] [
    random/seed now
    items: copy []
    loop either count [number][5] [
        append/only items pick script-index random length? script-index
    ]
    sort-by items sort-key
]

; Added this to make it easier on the CGI side.
find-new-and-updated: func [
    "Returns items added or updated recently (1 month by default)."
    /days       "Specify how far back to look for updated items."
        count
][
    do-search rejoin ["date >= " now - either days [count][31]]
]


do-filter: func [
	"Execute a predefined filter and return the results."
	id
] [
    sort-by either id = 'all [
        script-index
    ][
        search-index script-index id
    ] sort-key
]


do-search: func [
	"Execute a user defined search and return the results."
	spec [string! block!]
] [

    sort-by run-user-search spec sort-key
]


sort-by: func [
    items "The list of items to be sorted."
	field "Which field to sort by"
	/auto-reverse {Do they want the items returned in reverse order
	   if the field is the same as the last sort request?}
	/local results
] [
    sort/compare items func [a b] [
        if 'none = a/:field [return true]
        if 'none = b/:field [return false]
        either error? res: try [lesser? a/:field b/:field] [false] [res]
    ]
    sort-reversed: either all [auto-reverse sort-key = field]
        [not sort-reversed][false]
    ; This is terribly inefficent. We sort the list, then reverse the
    ; whole thing. I should use sort/reverse, but that ended up adding
    ; a bit of ugly, redundant, code so this is a quick kludge.
    if all [auto-reverse  sort-key = field  sort-reversed][
        reverse items
    ]
    sort-key: field
    head items
]


;-- Function to show file size in KB:
;   This is Carl's function from search.r
kb-size: func [val [integer!] /local d] [
	val: form val / 1024
	if d: find/tail val #"." [clear next next d]
	if val/1 = #"." [insert val #"0"]
	append val " KB"
]

; ; These I pulled in from other places to librarian, then here.
; ; Not in use with CGI at this time.
; mod: func [
;     {Compute a remainder.}
;     value1 [number! money! time!] {The dividend}
;     value2 [number! money! time!] {The divisor}
;     /euclid {Compute a non-negative remainder such that: a = qb + r and r < b}
;     /local r
; ] [
;     either euclid [
;         either negative? r: value1 // value2 [r + abs value2] [r]
;         ;-- Alternate implementation
;         ;value1 // value2 + (value2: abs value2) // value2
;     ][
;         value1 // value2
;     ]
; ]
;
; round: func [
;     {Rounds numeric value with refinements for what kind of rounding
;      you want performed, how many decimal places to round to, etc.}
;     value [number! money! time!] {The value to round}
;     /up         {Round away from 0}
;     /floor      {Round towards the next more negative digit}
;     /ceiling    {Round towards the next more positive digit}
;     /truncate   {Remaining digits are unchanged. (a.k.a. down)}
;     /places     {The number of decimal places to keep}
;         pl [integer!]
;     /to-interval {Round to the nearest multiple of interval}
;         interval [number! money! time!]
;     /local
;         factor
; ][
;     ;-- places and to-interval are redundant. E.g.:
;     ;       places 2 = to-interval .01
;     ;   to-interval is more flexible so I may dump places.
;     ;-- This sets factor in one line, under 80 chars, but is it clearer?
;     ;factor: either places [10 ** (- pl)][either to-interval [interval][1]]
;     factor: either places [
;         10 ** (negate pl)
;     ] [
;         either to-interval [interval] [1]
;     ]
;     ;-- We may set truncate, floor, or ceiling in this 'if block.
;     if not any [up floor ceiling truncate] [
;         ;-- Default rounding is even. Should we take the specified
;         ;   decimal places into account when rounding? We do at the
;         ;   moment.
;         either (abs value // factor) <> (.5 * factor) [
;             value: (.5 * factor) + value
;             return value - mod/euclid value factor
;         ] [
;             ;-- If we get here, it means we're rounding off exactly
;             ;   .5 (at the final decimal position that is).
;             either even? value [
;                 truncate: true
;             ] [
;                 either negative? value [floor: true][ceiling: true]
;             ]
;         ]
;     ]
;     if up       [either negative? value [floor: true][ceiling: true]]
;     if truncate [return value - (value // factor)]
;     if floor    [return value - mod/euclid value factor]
;     if ceiling  [return value + mod/euclid (negate value) factor]
; ]

