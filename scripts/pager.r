REBOL [
    Title: "Simple pager"
    File: %pager.r    Version: 0.9.4    Date: 26-Mar-2008
    Author: "Brian Tiffin"   Rights: "Copyright 2008, Brian Tiffin"
    Purpose: {
        A more less page pager; 
        support b, r, /, ?, >, <, q and /options [rows: cols: num: eof:]
    }
    Comment: {Not perfect, but functional}
    History: [
        08-Feb-2008 0.0.1 'btiffin "First cut"
        14-Feb-2008 0.9.0 'btiffin "Added clear screen"
        29-Feb-2008 0.9.1 'btiffin "Added Search, capture"
        15-Mar-2008 0.9.2 'btiffin "Anton points out superfluous charsets"
        21-Mar-2008 0.9.3 'btiffin "Less flicky, but still cursor noise"
        26-Mar-2008 0.9.4 'btiffin "Comments and tweaks, flash 'not found'"
    ]
    Library: [
        level: 'intermediate
        platform: 'all    type: [tool function]   domain: [files text]
        tested-under: [1.3.2.3.1 Win98]    see-also: none    support: none
        license: 'mit
    ]
]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; check for obvious namespace leaks; rest at bottom
if all [system/script/args  find system/script/args "/literate"] [
    query/clear system/words
]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; more
more: less: pager: func ["supports b, <, >, w, /, ?, q while paging" 
    intake [any-type! unset!] "input data or filename"
    /options "rows: cols: integer!, eof: num: logic!" electives [block!]
    /cap "input becomes block to evaluate and capture prin/t]"
    /num "shortcut (and override) for /options [num: on]"
    /local data line con ch cnt opts stay getkey keys csi enter percent
        pad pre0 sea str tmp found pos backlines slice reported
        capture captured sys-print sys-prin print-out prin-out
][
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; define an input that doesn't echo new line or enter history
    enter: func ["Replacement input with no newline echo or history"
        /local console-port buffer char ignore ignore-chars
    ][
        console-port: open/binary [scheme: 'console]
        buffer: make string! 10
        ignore: make binary! 10
        ignore-chars: charset ["^@^["]
        while [
            wait console-port
            char: to-char first console-port
            (char <> newline) and (char <> #"^M")
        ] [
            any [
                all [char = #"^H"
                    either not empty? buffer [
                        clear back tail buffer
                        prin ["^H ^H"]
                    ] [true]
                    true
                ]
                all [find ignore-chars char
                    read-io console-port ignore 3
                    true
                ]
                all [append buffer char
                    prin char
                    false
                ]
            ]
        ]
        close console-port
        buffer
    ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; terminal control code builder; control sequence introducer
    csi: func [ans] ["Terminal control helpers"
        rejoin [escape "[" select [clear "J" home "H" ceol "K" size "7n"] ans]
    ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; capture support by vectoring print and prin
    sys-print: get in system/words 'print  sys-prin: get in system/words 'prin
    print-out: func [value][append captured reform [reduce value newline]]
    prin-out:  func [value][append captured reform value]
    capture: func [flag [logic!]][
        either flag [
            captured: copy ""  set 'print :print-out  set 'prin :prin-out
        ][
            set 'print :sys-print  set 'prin  :sys-prin
        ]
    ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; open the console for keyscans
    con: open/binary/no-wait [scheme: 'console]
    getkey: does [
        until [all [found? wait/all [con 00:00:00.01] ch: copy con]]
    ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; get the terminal size
    prin csi 'size
    str: to string! copy con
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; setup options 
    opts: make object! [
        eof: true    num: false  rows: 24  cols: 80
        rows: attempt [to integer! copy/part next next str find str ";"]
        cols: attempt [to integer! copy/part next find str ";" find str "R"]
    ]
    reported: opts/cols ; for end-of-terminal newline control
    if options [opts: construct/with electives opts]
    if num [opts/num: on]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; helper for status display, show % thru file 
    percent: does [
        any [
            all [zero? length? data  "0%"]
            rejoin [index? back data " / " length? head data " "
              round multiply divide index? back data
              length? head data 100 "%"]
        ]
    ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; main data build. if capturing, intake is code, otherwise best guess
    either cap [
        if error? try [capture on  do intake  capture off] [
            set 'print :sys-print  set 'prin :sys-prin
        ]
        data: parse/all captured "^/"
    ][
        data: switch/default type?/word :intake [
            word! [
                if error? try [
                    capture on  help :intake
                    prin newline  source :intake  capture off
                ][set 'print :sys-print  set 'prin :sys-prin]
                parse/all captured "^/"
            ]
            file! [read/lines intake]
            url! [read/lines intake]
            string! [parse/all intake "^/"]
            block! [parse/all mold intake "^/"]
            object! [parse/all mold intake "^/"]
        ][parse/all mold :intake "^/"]
    ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; variables that float around    
    str: pos: none  tmp: copy ""  ; supporting search
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; zero padding
    pre0: head insert/dup copy "" "0" length? form length? data
    pad: func [n] [ 
        join join copy/part pre0 subtract length? pre0 length? form n n " "
    ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; reformat data into opts/cols sized pieces with optional line nums
;;    this is where the more line numbers (for goto) do not match the newline
;;    lines of the actual input.  Sorry.
    slice: func [incoming [block!] /local line outgoing] [
        outgoing: copy []
        while [not tail? incoming] [
            line: pick incoming 1
            replace/all line tab "    "
            foreach ch reduce [backspace newpage #"^K"] [ 
                replace/all line ch "."
            ]
            if opts/num [insert head line pad index? incoming]
            until [
                insert tail outgoing copy/part line opts/cols
                line: skip line opts/cols
                tail? line
            ]
            incoming: next incoming
        ]
        outgoing
    ]
    data: slice data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; nothing to do, just leave
    if empty? data [prin "--empty--" exit]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; the backwards handler
    backlines: func [lines [integer!] /pages] [
        data: skip data negate either pages [
            subtract multiply opts/rows lines lines
        ][
            subtract add opts/rows lines 1
        ]
    ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; the main key command handler, treated as a block of code used
;;   by both the main loop and the 'stick around at end of file' loop hack
;;   for the finds, ch is read from console as binary 
    keys: [
        case [
            ; q - quit
            find "qQ" ch [close con  exit]
            ; b - back page
            find ["b" "B" "^[[5~"] to string! ch [backlines/pages 2]
            ; up arrow, backspace - up one line
            find [#{08} #{1B5B41}] ch [backlines 1 true]
            ; down arrow, enter - down one line
            find [#{0D} #{1B5B42}] ch [
                data: skip data 1  backlines/pages 1 false
            ]
            ; < - top  #{3C}
            find ["<" "^[[1~"] to string! ch [data: head data  true]
            ; > - bottom #{3E}
            find [">" "^[[4~"] to string! ch [
                data: tail data  backlines/pages 1  true
            ]
            ; w - refresh
            find "wW" ch [backlines/pages 1]
            ; /, f - forward find
            find "/fFnN" ch [
                unless all [not empty? tmp  find "nN" ch] [
                    prin " Forward:" tmp: enter
                ]
                unless empty? tmp [str: tmp]
                backlines/pages 1
                pos: data  sea: next data  found: false
                while [all [not tail? sea  not found]] [
                    if find sea/1 str [data: sea  found: true]
                    sea: next sea
                ]
                unless found [data: pos  prin " - not found" wait 00:00:00.5]
                true
            ]
            ; ?, r - find reverse
            find "?rRpP" ch [
                unless all [not empty? tmp  find "pP" ch] [
                    prin " Backwards:" tmp: enter
                ]
                unless empty? tmp [str: tmp]
                backlines/pages 1
                pos: data  sea: back data  found: false
                until [
                    if find sea/1 str [data: sea  found: true]
                    any [head? sea  found  not sea: back sea]
                ]
                unless found [data: pos  prin " - not found" wait 00:00:00.5]
                true       
            ]
            ; g - go
            find "gG" ch [
                prin " Line: " tmp: enter
                data: skip head data
                  any [attempt [to integer! tmp] index? data]
                backlines/pages 1
            ] 
            ; digit - skip n 1-9
            find charset [#"1" - #"9"] ch [
                data: skip data to integer! to string! ch
                backlines/pages 1
            ] 
            ; h - help
            find "hH" ch [
                prin csi 'clear
                print "Welcome to pager - Up down and all around"
                print ["Supports:"]
                print [tab "q - quit"]
                print [tab "h - this help"]
                print [tab {w - refresh - (or any "invalid" key)}]
                print [tab "b - back a page"]
                print [tab "> - bottom"]
                print [tab "< - top"]
                print [tab "g - goto line"]
                print [tab "f or / - find forward"]
                print [tab tab "n for next"]
                print [tab "r or ? - find reverse"]
                print [tab tab "p for previous"]
                print [tab "up-arrow or backspace - back one line"]
                print [tab "down-arrow or enter - forward one line"]
                print [tab "digit - forward n lines"]
                print ["Command options:"]
                print [tab "rows: and cols: to set rows and columns;"
                  tab as-pair opts/rows opts/cols]
                print [tab "num: on to display line numbers;"
                  tab tab tab opts/num]
                print [tab "eof: false to not wait at end of file;"
                  tab opts/eof]
                print ["Displaying" index? data "of" length? head data]
                getkey  backlines/pages 1
                true
            ] ;; and if not a space or page forward, just refresh
            not find ["^[[6~" " "] to string! ch [backlines/pages 1]
        ]
    ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; loop across file, testing for eof and allowing more keys
    stay: true
    while [stay] [
        cnt: 1  prin csi 'home
        until [
            line: first data
            data: next data
            prin line
            unless equal? length? line reported [prin csi 'ceol prin newline]
            cnt: add cnt 1
            if greater-or-equal? cnt opts/rows [
                if tail? data [break]
                prin ["--more--" percent csi 'ceol]
                getkey  do keys
                cnt: 1  prin csi 'home
            ]
            tail? data
        ]
        either opts/eof [
            prin ["--eof--" index? back data "/" length? head data csi 'ceol]
            while [cnt < opts/rows] [prin [newline csi 'ceol] cnt: cnt + 1] 
            getkey
            stay: to logic! do keys
        ][
            stay: false
        ]
    ]
    close con  exit
]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; check the namespace and produce words doc
if all [system/script/args  find system/script/args "/literate"] [
    literature: does [
        echo %pager-words.txt
        foreach word sort query/clear system/words [
            if all [value? word  not error? word] [
                print word attempt compose [help (word)]
            ]
        ]
        echo none
    ]
    literature
]