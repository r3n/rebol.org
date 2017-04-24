REBOL [
    Title: "Simple file manager"
    Date: 12-Dec-1999
    Purpose: "A simple file manager"
    Version: 2.0.1.3
    File: %ropus.r
    Author: "Gabriele Santilli"
    History: [
    12-Dec-1999 1.0.1.1 "First working version"
    12-Dec-1999 1.0.1.2 "Now get-input keeps a buffer, and it's way smarter"
    12-Dec-1999 2.0.1.3 "Finished ask-user; posting to the list"
]
    library: [
        level: 'intermediate
        platform: none
        type: none
        domain: 'file-handling
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

system/options/quiet: true

; -- text interface (requires REBOL 2.2)

restring: func [b] [make string! reduce b]

control-sequences: make object! [
    csi: "^(1B)["
    sequence: func [
        "Creates a sequence"
        s [block!]
    ] [
        restring bind s 'self
    ]
    left: func [
        "Moves the cursor n chars left"
        n [integer!]
    ] [
        sequence [csi n "D"]
    ]
    right: func [
        "Moves the cursor n chars right"
        n [integer!]
    ] [
        sequence [csi n "C"]
    ]
    up: func [
        "Moves the cursor n rows up"
        n [integer!]
    ] [
        sequence [csi n "A"]
    ]
    down: func [
        "Moves the cursor n rows down"
        n [integer!]
    ] [
        sequence [csi n "B"]
    ]
    move-to: func [
        "Moves the cursor to the given position"
        row [integer!]
        column [integer!]
    ] [
        sequence [csi row ";" column "H"]
    ]
    home: sequence [csi "H"]  ; goto (1, 1)
    delete: func [
        "Deletes n chars to the right"
        n [integer!]
    ] [
        sequence [csi n "P"]
    ]
    insert: func [
        "Inserts n spaces"
        n [integer!]
    ] [
        sequence [csi n "@"]
    ]
    cls: sequence [csi "J"] ; clear screen
    clear-to-end-of-line: sequence [csi "K"]
    cursor-pos: sequence [csi "6n"]
    dimensions: sequence [csi "7n"]
]

control-chars: charset [#"^(00)" - #"^(1F)"  #"^(7F)" - #"^(9F)"]

control-char?: func [
    "Is it a control character?"
    char [char!]
] [
    find control-chars char
]

emit: func [
    "Emit to the console"
    value
] [
    write/binary console:// value
]

read-con: func [
    "Read from the console"
] [
    read/binary/wait console://
]

input-buffer: make block! 100

get-input: func [
    "Waits keyboard input and parses it"
    /local char
] [
    if empty? input-buffer [
        parse/all read-con [
            some [
                "^(1B)[A" (insert tail input-buffer 'up) |
                "^(1B)[B" (insert tail input-buffer 'down) |
                "^(1B)[C" (insert tail input-buffer 'right) |
                "^(1B)[D" (insert tail input-buffer 'left) |
                "^(1B)[5~" (insert tail input-buffer 'page-up) |
                "^(1B)[6~" (insert tail input-buffer 'page-down) |
                "^(7F)" (insert tail input-buffer 'delete) |
                "^-" (insert tail input-buffer 'tab) |
                "^M" (insert tail input-buffer 'enter) |
                "^(08)" (insert tail input-buffer 'backspace) |
                copy char skip (insert tail input-buffer to-char char)
            ]
        ]
    ]
    char: input-buffer/1
    remove input-buffer
    char
]

input-loop: func [
    "Input loop"
    body [block!]
    /local input
] [
    forever [
        switch get-input body
    ]
]

send-sequence: func [
    "Sends a sequence to the console"
    seq [block!]
] [
    emit control-sequences/sequence seq
]

digits: charset "1234567890"

console-get: func [
    "Reads cursor position or console dimensions"
    'what [word!]
    /local row col
] [
    send-sequence reduce [what]
    parse/all read-con [
        "^(1B)["
        copy row some digits
        ";"
        copy col some digits
        "R" end
    ]
    reduce [to-integer row to-integer col]
]

get-cursor: func [] [console-get cursor-pos]
get-dimensions: func [] [console-get dimensions]

footer: restring [
    "ROpus " system/script/header/version/3 "." system/script/header/version/4
    " (release " system/script/header/version/1
    pick [" ALPHA" " BETA" ""] system/script/header/version/2 + 1 ")"
    " --- ©1999 Gabriele Santilli --- Press H for help"
]

redraw: func [
    "Redraws the screen"
    /local width height
] [
    set [height width] get-dimensions
    send-sequence [
        cls
        move-to height 1
        copy/part footer width
        home
    ]
    lister1/set-rect 1 1 to-integer width / 2 height - 1
    lister2/set-rect (to-integer width / 2) + 1 1 to-integer width / 2 height - 1
    lister1/redraw
    lister2/redraw
]

show-text: func [
    "Shows a text on screen (used by view-text)"
    lines [block!] "Block of lines"
    sk [integer!] "Horizontal scroll"
    rows [integer!] "Numbers of rows to show"
    margin [integer!] "Maximum line length"
    /local line x
] [
    rows: min rows length? lines
    line: make paren! [copy/part skip lines/1 sk margin]
    x: margin + 2
    for y 2 rows + 1 1 [
        send-sequence [
            move-to y 2
            line clear-to-end-of-line
            move-to y x "|"
        ]
        lines: next lines
    ]
]

show-box: func [
    "Shows a box on screen"
    x [integer!]
    y [integer!]
    lines [block!]
] [
    for y y (y + length? lines) - 1 1 [
        send-sequence [
            move-to y x
            lines/1
        ]
        lines: next lines
    ]
]

message: func [
    "Shows a message"
    msg [string! block!] "Line or block of lines"
    /confirm "Ask confirmation to the user"
    /local scrw scrh boxw boxh boxx boxy box border blank res
] [
    set [scrh scrw] get-dimensions
    if string? msg [msg: reduce [msg]]
    boxh: length? msg
    boxw: 13
    foreach line msg [if boxw < length? line [boxw: length? line]]
    box: make block! 100
    border: make string! 100
    blank: make string! 100
    insert insert/dup insert border "+" "-" boxw "+"
    insert/dup blank " " boxw
    boxx: to-integer ((scrw - boxw) / 2) - 1
    boxy: to-integer ((scrh - boxh) / 2) - 1
    insert box border
    foreach line msg [
        insert tail box restring [
            "|" head change copy blank copy/part line boxw "|"
        ]
    ]
    insert tail box border
    res: either confirm [
        insert tail box restring [
            "| [Y]es" head insert/dup copy "" " " (boxw - 11) "[N]o |"
        ]
        insert tail box border
        boxy: boxy - 1
        show-box boxx boxy box
        select [#"Y" true #"N" false] get-input
    ] [
        show-box boxx boxy box
        get-input
    ]
    redraw
    res
]

lister: make object! [
    x: y: w: h: 0
    border: make string! 100
    blank: make string! 100
    set-rect: func [
        xx yy ww hh
    ] [
        set [x y w h] reduce [xx yy ww hh]
        clear border
        clear blank
        insert insert/dup insert border "+" "-" w - 2 "+"
        insert insert/dup insert blank "| " " " w - 3 "|"
    ]
    list: make block! 0
    current: 1
    redraw: func [
        "Disegna il lister"
        /local line row
    ] [
        send-sequence [
            move-to y x
            border
            move-to y + h - 1 x
            border
        ]
        row: y + 1
        foreach element copy/part list h - 2 [
            line: head
                change
                    next next copy blank
                    copy/part form element w - 3
            send-sequence [
                move-to row x
                line
            ]
            row: row + 1
        ]
        for row row y + h - 2 1 [
            send-sequence [
                move-to row x
                blank
            ]
        ]
        draw-pointer
    ]
    draw-pointer: func [] [
        send-sequence [
            move-to y + current x + 1
            ">"
        ]
    ]
    clear-pointer: func [] [
        send-sequence [
            move-to y + current x + 1
            " "
        ]
    ]
    down: func [] [
        if current < length? list [
            clear-pointer
            either current < (h - 2) [
                current: current + 1
                draw-pointer
            ] [
                list: next list
                redraw
            ]
        ]
    ]
    up: func [] [
        either current > 1 [
            clear-pointer
            current: current - 1
            draw-pointer
        ] [
            if not head? list [
                list: back list
                redraw
            ]
        ]
    ]
    get-current: func [] [
        pick list current
    ]
]

lister1: make lister []
lister2: make lister []

ask-user: func [
    "Asks a question to the user"
    question [string!]
    /local scrw scrh buffer bc cpos maxlen xpos key refresh
] [
    bc: buffer: make string! 256
    set [scrh scrw] get-dimensions
    send-sequence [
        move-to scrh 1
        question
        clear-to-end-of-line
    ]
    xpos: 1 + length? question
    cpos: xpos
    maxlen: scrw - xpos
    refresh: make paren! [
        send-sequence [
            move-to scrh xpos
            copy/part buffer maxlen
            clear-to-end-of-line
            move-to scrh cpos
        ]
    ]
    while ['enter <> key: get-input] [
        either all [char? key not control-char? key] [
            bc: insert bc key
            either cpos >= scrw [
                buffer: next buffer
                refresh
            ] [
                cpos: cpos + 1
                either not tail? bc [
                    refresh
                ] [
                    emit key
                ]
            ]
        ] [
            switch key [
                left [
                    either all [cpos = xpos not head? buffer] [
                        bc: buffer: back buffer
                        refresh
                    ] [
                        if cpos > xpos [
                            cpos: cpos - 1
                            bc: back bc
                            send-sequence [left 1]
                        ]
                    ]
                ]
                right [
                    either all [cpos = scrw maxlen < length? buffer] [
                        buffer: next buffer
                        bc: next bc
                        refresh
                    ] [
                        if all [cpos < scrw not tail? bc] [
                            cpos: cpos + 1
                            bc: next bc
                            send-sequence [right 1]
                        ]
                    ]
                ]
                delete [
                    if not tail? bc [
                        remove bc
                        refresh
                    ]
                ]
                backspace [
                    either all [cpos = xpos not head? buffer] [
                        bc: buffer: back buffer
                        remove bc
                        refresh
                    ] [
                        if cpos > xpos [
                            cpos: cpos - 1
                            bc: back bc
                            remove bc
                            refresh
                        ]
                    ]
                ]
            ]
        ]
    ]
    head buffer
]

; -- file manager

change-active-dir: func [
    "Changes the active directory"
    dir [file! url!]
] [
    source-dest/2: dir
    source-dest/1/list: sort read dir
    source-dest/1/current: 1
    source-dest/1/redraw
]

refresh: func [
    "Refreshes the listers and redraws the screen"
] [
    source-dest/1/list: sort read source-dest/2
    source-dest/3/list: sort read source-dest/4
    redraw
]

swap: func [
    "Exchange source and destination"
    sd [block!]
] [
    change sd reduce [sd/3 sd/4 sd/1 sd/2]
]

cases-dialect: make object! [
    "Dialect for do-cases"
    else-if: if: func [
        condition
        body [block!]
    ] [
        system/words/if condition [
            do body
            true
        ]
    ]
    else: :do
]

do-cases: func [
    "Executes the case whose condition is true"
;   example for cases:
;       if cond1 [code1] else-if cond2 [code2] ... else [default]
    cases [block!]
] [
    any bind cases in cases-dialect 'self
]

form-error: func [
    "Forms an error message"
    error [error!]
    /local id type
] [
    error: disarm error
    id: error/id
    type: error/type
    reduce [
        "*** Error message"
        reform ["*** Type:" system/error/:type/type]
        reform ["*** Why:" reform bind system/error/:type/:id in error 'self]
        reform ["*** Near:" trim/lines mold error/near]
    ]
]

execute-script: func [
    "Executes the given script"
    script [file! url!]
    /local result id type
] [
    send-sequence [cls]
    print "Trying to execute the script..."
    either error? result: try [do script] [
        foreach line form-error result [
            print line
        ]
    ] [
        if value? 'result [print ["Result:" mold result]]
    ]
    print "Press any key to continue..."
    get-input
    refresh
]

text?: func [
    "Is it a text file?"
    file [file! url!]
    /local freq sum
] [
    file: read/binary/part file 512
    freq: array/initial 256 0
    foreach byte file [
        byte: byte + 1
        poke freq byte freq/:byte + 1
    ]
    sum: 0
    for i 32 126 1 [sum: sum + freq/:i]
    sum > ((4 * length? file) / 5)
]

view-text: func [
    "Text file viewer --- slow but nice ;-)"
    textfile [file! url!]
    /local scrh scrw border footer sk refresh maxskip maxindex
] [
    set [scrh scrw] get-dimensions
    border: make string! 100
    insert insert/dup insert border "+" "-" scrw - 2 "+"
    footer: restring [
        "Q to quit --- " textfile
    ]
    send-sequence [
        cls
        border CRLF
        down scrh - 3
        border CRLF
        copy/part footer scrw
    ]
    for i 2 scrh - 2 1 [
        send-sequence [
            move-to i 1 "|"
            right scrw - 2 "|" CRLF
        ]
    ]
    textfile: parse/all detab/size read textfile 4 "^/"
    maxskip: 0
    foreach line textfile [if maxskip < length? line [maxskip: length? line]]
    maxskip: max 0 maxskip - (scrw - 2)
    maxindex: (4 + length? textfile) - scrh
    show-text textfile 0 scrh - 3 scrw - 2
    sk: 0
    refresh: make paren! [
        show-text textfile sk scrh - 3 scrw - 2
    ]
    input-loop [
        #"Q" [break]
        up [
            if not head? textfile [
                textfile: back textfile
                refresh
            ]
        ]
        down [
            if maxindex > index? textfile [
                textfile: next textfile
                refresh
            ]
        ]
        left [
            if sk > 0 [
                sk: sk - 1
                refresh
            ]
        ]
        right [
            if sk < maxskip [
                sk: sk + 1
                refresh
            ]
        ]
        page-up [
            if not head? textfile [
                textfile: skip textfile negate scrh - 4
                refresh
            ]
        ]
        page-down [
            if maxindex > index? textfile [
                textfile: skip textfile min scrh - 4 maxindex - index? textfile
                refresh
            ]
        ]
    ]
    redraw
]

show-info: func [
    "Shows file info"
    file [file! url!]
    /local name maxlen info
] [
    maxlen: to-integer (pick get-dimensions 2) / 2
    name: form file
    if maxlen < length? name [
        name: restring ["..." skip tail name negate (maxlen - 3)]
    ]
    info: info? file
    message reduce [
        restring ["Informations on " name]
        restring ["Size: " info/size]
        restring ["Last modification: " info/date]
    ]
]

source-dest: reduce [
    lister1 system/script/path
    lister2 system/script/path
]

refresh

show-message-on-error: func [
    "Shows a message in case of error"
    code [block!]
    /local error
] [
    if error? set/any 'error try code [
        message form-error error
    ]
]

; main input loop
input-loop [
    #"Q" [
        send-sequence [cls]
        break
    ]
    up [
        source-dest/1/up
    ]
    down [
        source-dest/1/down
    ]
    tab [
        swap source-dest
    ]
    enter [
        show-message-on-error [
            file: join source-dest/2 source-dest/1/get-current
            do-cases [
                if dir? file [
                    change-active-dir file
                ]
                else-if script? file [
                    execute-script file
                ]
                else-if text? file [
                    view-text file
                ]
                else [
                    show-info file
                ]
            ]
        ]
    ]
    #"P" [
        show-message-on-error [
            change-active-dir first split-path source-dest/2
        ]
    ]
    delete [
        show-message-on-error [
            file: source-dest/1/get-current
            if message/confirm reduce [
                "Please confirm deletion"
                reform ["of" file]
            ] [
                delete join source-dest/2 file
                refresh
            ]
        ]
    ]
    #"V" [
        show-message-on-error [
            view-text join source-dest/2 source-dest/1/get-current
        ]
    ]
    #"C" [
        show-message-on-error [
            use [source dest file] [
                source: join source-dest/2 file: source-dest/1/get-current
                dest: join source-dest/4 file
                write/binary dest read/binary source
            ]
            refresh
        ]
    ]
    #"M" [
        show-message-on-error [
            use [source dest file] [
                source: join source-dest/2 file: source-dest/1/get-current
                dest: join source-dest/4 file
                write/binary dest read/binary source
                delete source
            ]
            refresh
        ]
    ]
    #"R" [refresh]
    #"G" [ ; goto
        show-message-on-error [
            file: load ask-user "Go to dir: "
            if any [file? file url? file] [
                if dir? file [
                    change-active-dir file
                ]
            ]
        ]
        use [w h] [
            set [h w] get-dimensions
            send-sequence [
                move-to h 1
                copy/part footer w
            ]
        ]
    ]
    #"H" [
        message [
            " KEY | FUNCTION"
            "-----+------------------------------------"
            "  Q  | Quit ROpus"
            "  H  | Show this help"
            "  G  | Change directory (accepts URLs too)"
            "  R  | Refresh the screen"
            "  M  | Move file"
            "  C  | Copy file"
            "  V  | View text file"
            " DEL | Delete file"
            "  P  | Go to parent directory"
            "ENTER| Perform action based on file type"
            " TAB | Exchange source/destination lister"
            "ARROW| Select file"
        ]
    ]
]
