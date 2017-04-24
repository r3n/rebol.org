REBOL [
    Title: "error-message-finder"
    Date: 6-Dec-2001/22:10:29+1:00
    Version: 1.0.0
    File: %error-message-finder.r
    Author: "Volker"
    Usage: {
^-^-configure script at bottom
^-^-^-either use 'emf-locate-clipboard : 
^-^-^-^-copy search-text to clipboard, start script.
^-^-^-or use emf-trap-error :
^-^-^-^-do this script, then wrap your debug-call with
^-^-^-^-^-emf-trap-error[my-debug-call]
^-^-^-^-pops then up on error.
^-}
    Purpose: {find a text in all %.r files in directory, 
to look up rebol error-messages.
presents all possibilities in nice gui.
}
    Comment: {
^-^-also some tricks for reloading text-lists, moving them with keys
^-^-and finding and positioning text in areas.
^-}
    History: [
    6-Dec-2001 
    18:14 "begin" 19:06 "my-text-list" 20:31 "works" 21:50 "ready"
]
    Email: nitsch-lists@netcologne.de
    todo: "scan functions for locals.."
    library: [
        level: none 
        platform: none 
        type: 'tool 
        domain: [GUI text-processing] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
emf: context [
    ;
    ;GUI, for editing at top, layout below after tools are ready.
    ;
    h: 0x100
    w1: 160x0
    win: [
        styles styling
        key #"^n" [tl-pick-new [pick find tl/data tl/picked/1 2]]
        key #"^p" [tl-pick-new [pick find tl/data tl/picked/1 -1]]
        key #"^s" [
            if not empty? tl/picked [
                write first load tl/picked/1 ta/text
            ]
        ]
        space 12x6 origin 8x8
        backdrop [quit]
        tf: field 0x24 + w1 [do-find face/text]
        tl: my-text-list 160x200 + h [goto-text first tl/picked]
        return
        ta: area para [] 420x200 + 0x30 + h
        return
        at tl/size * 0x1 + tl/offset + 0x10
        te: area ta/size + ta/offset - tl/offset * 1x0 + 0x64
    ]
    ;
    ;FINDER
    ;
    dir: %./
    do-find: func [string] [
        scripts: copy []
        foreach file read dir [
            if parse file [thru %.r] [append scripts dir/:file]
        ]
        positions: copy []
        foreach file scripts [append-findings positions file string]
        insert clear tl/data positions show tl
    ]
    append-findings: func [positions file string] [
        parse read file [
            any [
                to string position: (
                    append positions mold/only reduce [file index? position string]
                ) thru string
            ]
        ]
    ]
    get-line: func [position] [
        start: any [find/reverse/tail position newline head position]
        end: any [find position newline tail position]
        copy/part start end
    ]
    ;
    ;MORE GUI, the tools and starts
    ;
    tl-pick-new: func [finder] [
        if not empty? tl/picked [
            pick-new: any [do finder tl/picked/1]
            insert clear tl/picked pick-new
            show tl
            goto-text first tl/picked
        ]
    ]
    styling: stylize [
        my-text-list: text-list with [
            "add size-change scrolling"
            last-shown-lines: -1
            update-slider: does [
                either 0 = length? data [sld/redrag 1] [
                    sld/redrag lc / length? data]
            ]
            append init [
                sub-area/feel/redraw: does [
                    l: length? data
                    if l <> last-shown-lines [
                        last-shown-lines: l
                        update-slider
                    ]
                ]
            ]
        ]
    ]
    win: layout win
    ;probe
    min-size: win/size + 20x20
    if not equal? min-size minimum min-size system/view/screen-face/size [
        alert reform ["minimal resolution:" min-size] quit
    ]
    goto-text: func [tl-string] [
        set [file index string] load tl-string
        ta/text: read file
        scroll-to-line ta line: at ta/text index
        focus ta
        sv: system/view
        sv/highlight-start: at ta/text index
        sv/highlight-end: skip sv/highlight-start length? string
        show ta
    ]
    scroll-to-line: func [t1 txt /local xy] [
        xy: (caret-to-offset t1 txt) - t1/para/scroll * 0x1
        t1/para/scroll: min 0x0 t1/size / 2 - xy
    ]
    start: func [string] [
        tf/text: string
        do-find tf/text
        if not empty? tl/data [
            insert tl/picked first tl/data goto-text first tl/picked
        ]
        unview/all
        view center-face win
    ]
    form-error: func [
        error [object!]
        /local arg1 arg2 arg3 message out
    ] [
        out: make string! 100
        set [arg1 arg2 arg3] [error/arg1 error/arg2 error/arg3]
        message: get in get in system/error error/type error/id
        if block? message [bind message 'arg1]
        append out reform reduce message
        append out reform ["^/Near:" mold error/near]
        append out reform ["^/Where:" mold get in error 'where]
    ]
    ;
    ;START VARIANTS
    ;
    set 'emf-locate-clipboard func [
        {start script standalone, get find-text from clipboard}
    ] [
        start read clipboard://
    ]
    set 'emf-trap-error func [
        {does the block and pops up on error}
        block "the block to do"
    ] [
        if error? error: try [do block none] [
            te/text: form-error error: disarm error
            start mold/only error/near
        ]
        error ;rethrow error
    ]
]
;
;uncomment your WAY TO START
;
help emf-locate-clipboard print "" help emf-trap-error
;emf-locate-clipboard
;emf-trap-error [bangme: does [bang] bangme]
emf-trap-error [bangme: does [bang] view center-face layout [button "bang" [bang]]]

                                                                                                                                                                                     