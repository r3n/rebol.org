REBOL [
    Title: "REBOL/AI Image linker"
    Date: 26-Mar-2002/15:44:25+1:00
    Version: 1.0.0
    File: %ai.r
    Author: "Oldes"
    Purpose: {Simple dialect for creating AdobeIllustrator files (ai) with linked images}
    Comment: {I have no spec on the AI file structure so here are just a few things I needed}
    Email: oliva.david@seznam.cz
    library: [
        level: 'advanced 
        platform: none 
        type: 'dialect 
        domain: 'graphics 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

dialect-example: [
    artsize A4
    layer "images" [
        group [
            group [
                at 0x0 image %/M/xicht/l-006.gif 300x350
                at 300x0 image %/M/xicht/l-007.gif 300x350
            ]
            group [
                at 0x350 image %/M/xicht/l-008.gif 300x350
                at 300x350 image %/M/xicht/l-009.gif 300x350
            ]
        ]
    ]
    layer "shapes" [
        fill color 255.0.0
        edge color 0.255.0 width 10 join round
        at 100x100 box 0x0 100x100
        edge join bevel dashed [12 6 3 10]
        at 100x200 box 0x0 100x100
    ]
] 

;this is the ai-file template:
ai: decompress 64#{
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
}

;and here comes the code:

make-warning!: func[val /msg m][
    prin "WARNING: "
    print either msg [m][
        rejoin [
            "misplaced item: " mold first val newline
            "   NEAR: " copy/part val 4 " ..."
        ]
    ]
]

aicreate: make object! [
    layer: func[name content][
        rejoin [
            {%AI5_BeginLayer} CRLF
            {1 1 1 1 0 0 1 255 79 79 Lb} CRLF
            {(} name {) Ln} CRLF
            {0 A} CRLF
            {0 O} CRLF
            ;{0 g} CRLF
            ;{0 R} CRLF
            {800 Ar} CRLF
            ;{0 J 0 j 1 w 4 M []0 d} CRLF
            {%AI3_Note:} CRLF
            {0 D} CRLF
            {0 XR} CRLF
            content CRLF
            "LB" CRLF
            {%AI5_EndLayer--} CRLF
        ]
    ]
    image: func[src size pos /local sz][
        sz: rejoin [size/1 " " size/2]
        pos: rejoin [pos/1 " " pos/2]
        rejoin [
            {%AI5_File:} CRLF
            {%AI5_BeginRaster} CRLF
            {(} replace/all to-local-file src "\" "\\" {) 0 XG} CRLF
            {[ 1 0 0 1 } pos { ] } sz { 0 Xh} CRLF
            {[ 1 0 0 1 } pos { ] 0 0 } sz { } sz { 8 3 0 0 0 0} CRLF
            {XF} CRLF
            {XH} CRLF
            {%AI5_EndRaster} CRLF
            {S^M}
        ]
    ]
]

buff-layer: make string! 1000
buff-content: make string! 1000
ofs: copy [0 0]
TileBox: [30 31 582 759]
ArtSize: [612 792]
layers: 0
edge: make object! [color: 0.0.0 width: 0]

draw-lines: func[corners /local buff][
    buff: make string! 1000
    insert buff reform [ofs/1 + corners/1/1 ofs/2 + corners/1/2 "m^M^/"]
    corners: next corners
    forall corners [
        append buff reform [ofs/1 + corners/1/1 ofs/2 + corners/1/2 "L^M^/"]
    ]
    buff
]
ai-layer-rules: [
    any [
        'at set ofs [pair! | block!] (
            ofs: reduce [
                ofs/1 + TileBox/1
                TileBox/4 - ofs/2
            ]
        )
        | 'image set src file! set size [block! | pair!] (
            append buff-layer aicreate/image src size ofs
        )
        | 'group set tmp block! (
            append buff-layer join "u" CRLF
            parse tmp ai-layer-rules
            append buff-layer join "U" CRLF
        )
        | 'fill 'color set tmp [block! | tuple!] (
            if tuple? tmp [
                tmp: reduce [tmp/1 / 255 tmp/2 / 255 tmp/3 / 255]
            ]
            append tmp "Xa"
            append buff-layer join reform tmp CRLF
        )
        | 'edge [
            some [
                'color set tmp [block! | tuple!] (
                    if tuple? tmp [
                        tmp: reduce [tmp/1 / 255 tmp/2 / 255 tmp/3 / 255]
                    ]
                    append tmp "XA"
                    append buff-layer join reform tmp CRLF
                )
                | 'width set tmp number! (
                    edge/width: tmp
                    append buff-layer join tmp " w^M^/"
                )
                | 'join set tmp ['round | 'bevel | 'none] (
                    append buff-layer join either found? tmp: find [round bevel] tmp
                        [index? tmp][0] " j^M^/"
                )
                | 'dashed set tmp block! (
                    append buff-layer rejoin ["[" reform tmp "]0 d^M^/"]
                )
            ]
        ]
        | 'box copy tmp any pair! (
            foreach [b-min b-max] tmp [
                append buff-layer draw-lines reduce [
                    b-min
                    to-pair reduce [b-max/1 b-min/2]
                    b-max
                    to-pair reduce [b-min/1 b-max/2]
                    b-min
                ]
                append buff-layer rejoin [
                    either edge/width = 0 ["f"]["b"] CRLF
                ]
            ]
        )
        | val: any-type! (make-warning! val)
    ]   
]
ai-main-rules: [
    any [
        'layer set name [string! | none] set content block! (
            parse content ai-layer-rules
            append buff-content copy aicreate/layer name buff-layer
            clear buff-layer
            layers: layers + 1
        )
        | 'artsize copy tmp [block! | pair! | word!] (
            artsize: switch type?/word first tmp [
                word! [
                    switch tmp/1 [
                        Letter [
                            TileBox: [30 31 582 759]
                            [612 792]
                        ]
                        A4 [
                            TileBox: [38 56 590 784]
                            [595.2756 841.8898]
                        ]
                    ]
                ]
                pair! [reduce [tmp/1/1 tmp/1/2]]
            ]
        )
    ]
]

parse dialect-example ai-main-rules

ai-data: compose [
    creator (system/script/title)
    for     (system/user/name)
    title   "aitest.ai"
    creationdate (rejoin ["(" now/month "/" now/day "/" skip mold now/year 2 ") (" now/time ")"])
    pageorigin (reform copy/part tilebox 2)
    tilebox (reform tilebox)
    artsize (reform artsize)
    layers  (layers)
    content (buff-content)
]

foreach [par val] ai-data [
    par: uppercase rejoin ["!!" mold par "!!"]
    replace/case ai par val 
]

write/binary %aitest.ai ai                                                                                                                                                                                                                                                                                                                                                                       