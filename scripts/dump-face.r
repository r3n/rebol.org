REBOL [
    Title: "Dump-Face"
    Date: 4-Jun-2002
    Version: 1.0.0
    File: %dump-face.r
    Author: "Romano Paolo Tenca"
    Purpose: {Dump a face and its subfaces and deep find shared faces in a pane (for debugging)
Returns the face itself, so can be used like probe. Overwrite the standard Rebol function.
}
    History: {
^-^-1.0.0 04/06/02 first public release
^-}
    Email: rotenca@libero.it
    Web: http://web.tiscali.it/anarkick/index.r
    library: [
        level: 'intermediate 
        platform: []
        type: 'tool 
        domain: [GUI debug] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
context [
    found: depth: none
    p: func [face depth flag n] [
        print [
            depth
            "N." n
            "Var:" all [in face 'var face/var]
            "Sty:" all [in face 'style face/style]
            "Off:" face/offset
            "Siz:" face/size
            "Edg:" all [face/edge face/edge/size]
            either flag [join "Flg: " all [in face 'flags copy/part form face/flags 15]][""]
            either face/text [rejoin [{Txt: "} copy/part form face/text 15 {"}]][""]
        ]
    ]
    system/words/dump-face: func [
        "Dump a face or a pane and its subfaces (for debugging)"
        face [object! block!]
        /flag "Show also flags"
    ][
        found: copy []
        depth: copy "^-"
        dump-face face flag
    ]
    dump-face: func [
        face [object! block!]
        flag [logic! none!]
        /local f
    ][
        either block? face [
            print [depth type? face]
            foreach f face [either object? f [dump-face f] [print [depth "Styles Name:" f]]]
        ][
            if f: find found face [
                print ["*** The face N." 1 + length? found "is in more than one pane. See the N." index? f]
            ]
            append found face
            p face depth flag length? found
            insert depth tab
            either function? get in face 'pane [
                if all [in face 'subface object? face/subface] [
                    print [depth "-- Subface (List):"]
                    dump-face face/subface flag
                ]
            ][
                if object? face/pane [
                    print [depth "-- Pane: object!"]
                    dump-face face/pane flag
                ]
                if block? face/pane [
                    print [depth "-- Pane: block! [" length? face/pane "]"]
                    foreach f face/pane [dump-face f flag]
                ]
            ]
            remove depth
        ]
        if 1 = length? depth [clear found]
        face
    ]
]
;all what follow can be commented out or cancelled 
if system/user/name <> "Romano Paolo Tenca" [
    print "Example of 'face in more than one pane':"
    x: make-face/size/spec 'text 3x3 [text: "Duplicated face"]
    y: layout [p1: panel [ p2: panel []]]
    append y/pane x
    append p1/parent-face/pane x
    append p2/parent-face/pane x
    dump-face/flag y
    halt
]
                                                                                       