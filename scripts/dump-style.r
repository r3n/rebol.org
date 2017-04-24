REBOL [
    Title: "Dump-Style"
    Date: 11-Jun-2002
    Version: 1.0.0
    File: %dump-style.r
    Author: "Romano Paolo Tenca"
    Purpose: {Dump style facets and returns a block which can be passed to stylize
to create a clone of the style.
}
    History: {
^-^-1.0.0 11/06/02 first public release
^-}
    Email: rotenca@libero.it
    Web: http://web.tiscali.it/anarkick/index.r
    Note: {
^-^-It is based on undocumented features and can fail in future Rebol versions
^-^-or with some custom styles
^-}
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
dump-style: func [
    style [word!]
    /quiet "Do not print the style"
    /clip "Copy the style to the clipboard"
    /name "Use this name for the cloned style" new [word!]
    /styles ss "Stylesheet"
    /local facets h
][
    if none? styles [ss: svv/vid-styles]
    if not name [new: style]
    if ss: select ss style [
        either ss/facets [
            parse/all facets: copy/deep ss/facets [
                thru 'with into [
                    any [
                        thru words: into [
                            any [
                                h: function! (change/only h second first h)
                                | skip
                            ]
                        ]
                    ]
                ]
            ]
            ss: compose [
                (to-set-word new) (ss/style) (facets)
            ]
            if not quiet [
                print mold/only ss
            ]
            if clip [
                write clipboard:// mold/only ss
            ]
            ss
        ][
            print ["Facets not found. Base style: " ss/style]
            ss/style
        ]
    ]
]
;this can be cancelled or commented out
if system/user/name <> "Romano Paolo Tenca" [
    print "First example: dump of the 'field style:^/"
    dump-style 'field
    print "^/Second example: code which creates a 'text-list clone:"
    do probe [
        x: dump-style/quiet/name 'text-list 'text-list-clone
        comment {Vid styles are bound to svv}
        x: bind x in svv 'self 
        my-styles: stylize x
        view center-face layout [
            backcolor silver
            styles my-styles
            text-list-clone 300x100 data [
                "This is the style:"
                "'text-list-clone"
                "in the stylesheet"
                "'my-styles"
            ]
        ]
    ]
    halt
]

                                                                                    