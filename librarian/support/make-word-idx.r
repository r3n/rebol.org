REBOL [
    Title: "Make Word Index File"
    Type: 'link-app ; -> link-root
    Purpose: {
        Build a simple cross-reference script file index.
        Outputs an index file in a special format that can
        be used for REBOL, CGI, and other purposes.
    }
    Author: "Carl Sassenrath, Volker Nitsch"
    Version: 1.1.2
    Note: {
        The index-string function can be modified to better index
        strings based on your requirements.
    }
    History: [
        1.0.0 ["by Carl"]
        1.1.0 ["changed output-format for faster loading, -Volker"
        "added 'suffix? , was lacking in my /link"]
        1.1.1 [09-mar-2003 {Uses %scripts.lst to get list of files to index now.} GSI]
        1.1.2 [15-Jul-2003 {Adapted to run CGI or IOS or user machine -- not finished!.} Sunanda]
        1.2.0 [14-aug-2003
            {Uses system/script/args in place of shared globals now.}
            {Added default config settings if none are provided.}
            {Lots of changes for config setup. Experimental for comment.}
            {Lots of code reorganization.}
            {Rolled back from gen-print to print.}
            GSI
        ]
    ]
    TBD: {
        Add logging capability for remote troubleshooting?
    }
    Usage: {
        Call with do/args and pass a block containing an object spec.
        Example:
            do/args %make-header-idx.r compose [
            	;in-dir:  %../../scripts/              ; Librarian
                ;in-dir:   (join link-root %library/)  ; IOS
                %../library/scripts/                   ; CGI
                out-dir:  %./
                out-file: %word-index.rix
                script-list-file: %scripts.lst
                quiet:    true
            ]
    }
]

;?? How bad would it be to remove this dependency? Do we need the
;   demo search to run from this script? By including librarian-lib,
;   we also need the filter files and header index, which don't, or
;   shouldn't, have any impact on this script.
;do %librarian-lib.r ; constants for chars, 'run for demo-search

;?? Do we want and need this to be an object? Whatever we do, it should
;   be made consistent with make-header-idx.
; word-search comes from librarian-lib.r
make object! [ ;word-search [
    env?: ;emit
    prefs: ;out-data def-idx files start-time err
    ;hdr src idx lib couldnt-load-count error-count
    words:
        none

    ;set 'cx self ;for probes    ; This is not used anywhere. GSI 14-aug-2003

    ; == General Functions ======================================

shred-script: func [script [string!]
			/local
			script-copy
			unquoted-text
			token
			word-list
			letters-rule
			word-rule
			block-rule
			winnowed-list
			]
[
 ;;	Returns a block with all the indexable words in a script
 ;;	--------------------------------------------------------


script-copy: copy script

;;	Remove everything but a-z, 0-9, "-" and "/" "!" and "?"
;;	-------------------------------------------------------

lowercase script-copy
token: copy ""
word-list:  copy []

letters-rule: charset [ #"a"  -  #"z"
                        #"0" - #"9"
                        #"/"
                        #"-"
                        #"?"
                        #"!"
                        #"."
                        ]


word-rule:    [some letters-rule]
block-rule:   [copy Token word-rule
                    (append word-list Token token: copy "")
                    | skip]

parse/all script-copy [some block-rule]

word-list: unique word-list



;;	Now dump any word that breaks the rules
;;	---------------------------------------
winnowed-list: copy []

foreach word word-list
	[
	 if all [20 > length? word		;; too long
	         1 < length? word			;; too short
	         #"a" <= word/1				;; doesn't start with two letters
	         #"z" >= word/1
	 			   #"a" <= word/2
	 			   #"z" >= word/2
	 			  ]
	 			  [append winnowed-list word]

	]

return winnowed-list

]

;;	----------------------------------

    env?: does [
        ;;either link? ['ios][either view? ['view]['cgi]]	;; sunanda nov-2003
        either link? ['view][either view? ['view]['cgi]]	;; sunanda nov-2003
    ]

    patch-filename: func [file] [
        lowercase replace/all file " " "-"
    ]

    patch-filenames: func [files] [
        forall files [change files patch-filename first files]
    ]

    time-diff: func [a b] [
        ; See if the spec block for the first param in DIFFERENCE's
        ; interface will accept a date! value. This is only necessary
        ; if we want to use the native DIFFERENCE function internally
        ; on newer versions of REBOL.
        either find first find third :difference block! date! [
            difference a b
        ][
            a: either date? a [a/time][a]
            b: either date? b [b/time][b]
            a - b
        ]
    ]

    ;== Index Functions  and Constants ==========================

    ;-- From librarian-lib.r -------
    end-tag: "^/"
    word-end: join end-tag "^-"
    files-end: join end-tag " "
    word-end-tag: second word-end
    files-end-tag: second files-end
    ;-------------------------------

    good-chars: complement charset [#"^(0)" - #"^(20)" #"^(80)" - #"^(ff)"]
    no-letters: complement charset [#"a" - #"z" #"A" - #"Z"]
    no-letter-string: copy ""
    for i 0 255 1 [
        if find no-letters i [append no-letter-string to-char i]
    ]
    dirty-words: copy []

index-script: func [text /local word-list]
[

 word-list: shred-script text
 foreach w word-list [index-word w]

]


index-word: func [
        "Add a word reference to the index"
        str /local pos
    ][
        ;!! file-num is used here, but is set in the main processing loop.
        ;   Can we pass it in as a parameter instead? GSI 14-aug-2003
        ;   Ahh, I see now that it would have to trickle down through
        ;   index-value and index-string after we passed it to index-script.
        ;   Still, it's pretty ugly this way. GSI

        either pos: find words str [
            if not find second pos file-num [append second pos file-num]
        ] [
            repend words [str reduce [file-num]]
        ]
    ]


COMMENT [



    ;------------------------------------------------------------

    index-comment: func [comment'] [index-string comment']

    ; parse-code a bit modified
    index-script: func [
        "Parse REBOL source code."
        text /local str new
    ] [
        parse text blk-rule: [
            any [; repeat until done
                str:
                newline |
                #";" [thru newline | to end] new: (
                    index-comment copy/part str new) |
                [#"[" | #"("] blk-rule |
                [#"]" | #")"] |
                skip (set [value new] load/next str index-value :value) :new
            ]
        ]
    ]

    index-string: func [str] [
        ; Index words of a string.
        ; THIS IS JUST AN EXAMPLE. Needs to be much smarter.?
        ; detecting urls and such?
        foreach word parse/all str no-letter-string [
            index-word word
        ]
    ]

    index-value: func [value /l] [

        parse head change/only [none] value [
            set value string! (index-string value)
            | set value tag! (index-string value)
            | set value skip (
                index-word v: mold value
                index-string v
            )
        ]
    ]

    index-word: func [
        "Add a word reference to the index"
        str /local pos
    ][
        ;!! file-num is used here, but is set in the main processing loop.
        ;   Can we pass it in as a parameter instead? GSI 14-aug-2003
        ;   Ahh, I see now that it would have to trickle down through
        ;   index-value and index-string after we passed it to index-script.
        ;   Still, it's pretty ugly this way. GSI
        if not parse/all str [some good-chars] [
            ;if not empty? str [append dirty-words str ]
            return
        ]
        either pos: find words str [
            if not find second pos file-num [append second pos file-num]
        ] [
            repend words [str reduce [file-num]]
        ]
    ]

]	;;COMMENT

    ; == Setup ==================================================

    ; Start with best-guess defaults.
    prefs: make object! [
        in-dir: switch env? [
            ios  [join link-root %library/]
            view [%../../scripts/]
            cgi  [%../library/scripts/]
        ]
        out-dir:  %./
        out-file: %word-index.rix
        script-list-file: %scripts.lst
        quiet:    false
    ]
    ; Use system/script/args to override defaults
    attempt [prefs: make prefs system/script/args]

    ;print: get in system/words either prefs/quiet ['comment]['print]
    if prefs/quiet [print: :comment]

    ;-- Table that holds word references:
    words: make hash! 50000 ; block of "word" [fn1 fn2 ...]

    ;-- Build list of files:
    files: sort load prefs/script-list-file


    ; == Environment Checks =====================================

    print ["input directory is " prefs/in-dir]
    print ["output file is " join prefs/out-dir prefs/out-file]
    print ["Processing" length? files "files"]
    probe prefs
    if not all [
        exists? prefs/in-dir
        exists? prefs/out-dir
    ][
        print "One of the needed directories does not exist. Unable to continue"
    ]


    ; == Main Loop ==============================================

    print "Analysing all scripts. (May take a minute or two)...."
    start-time: now/precise
    file-num: 1

    foreach file files [

    		data: none
        attempt [data: read prefs/in-dir/:file]
        attempt [print ["Indexing words in " file "length" length? data]]
        if error? set/any 'err try [
            either data
                [index-script data]
                [print join "No indexable content for " [prefs/in-dir file]]
        ][
            print [
                "Error processing" prefs/in-dir/:file newline
                "Error:" mold disarm err
                "Data:" data
            ]
        ]
        file-num: file-num + 1

    ]
    words: to-block words
    sort/skip words 2

    ;-- Print stats:
    time: time-diff now/precise start-time
    print [(length? words) / 2 "words from" length? files "files in" time]


    ; == Output =================================================

    print "Saving data..."
    start-time: now/precise
    patch-filenames files
    out: mold files
    append out files-end ; support precise find rejoin[files-end-tag word end-tag]
    foreach [word files] words [
        ;either parse/all word [[thru end-tag | thru "^-" | thru "~"] to end]
        either parse/all word [some good-chars]
            [repend out [word word-end files files-end]]
            [] ;[print ["illegal chars in word" mold word]]
    ]

    print ["Writing...." join prefs/out-dir prefs/out-file]
    write to-file join prefs/out-dir prefs/out-file out

    ;-- Print stats:
    time: time-diff now/precise start-time
    print ["Time to save data:" time]

    ;? dirty-words

    ; == Finalization / Cleanup =================================

    print "Done.^/"

;     [
;         if view? [
;             view center-face layout [title "fulltext-search"
;                 label "enter some words" inp: field [
;                     files: run parse face/text ""
;                     insert clear f-files/data files
;                     cnt/text: length? f-files/data
;                     show reduce [f-files/update cnt]
;                 ] "carl sassenrath" do [focus inp]
;                 cnt: info "0"
;                 f-files: text-list 200x400 [
;                     view/new layout [
;                         area 600x400 read dir/:value wrap
;                     ]
;                 ]
;             ]
;         ]
;     ]

]
