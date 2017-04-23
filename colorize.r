REBOL [
    Title: "Html Pretty Print REBOL"
    Date: 30-Jun-1999
    File: %colorize.r
    Author: "Jeff Kreis"
    Purpose: {Syntax highlighting for HTML display of REBOL scripts}
    Organization: "REBOL Technologies"
    Email: jeff@rebol.com
    library: [
        level: 'advanced 
        platform: none 
        type: none 
        domain: [text-processing markup] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

find-replace: func [str init fina /spacer /local mark][
    mark: str
    while [mark: find mark init][
        insert remove/part mark length? init fina
        mark: skip mark length? fina
    ]
]

find-end-header: func [point][
    braces: 1
    point: find/tail point "["
    if none? point [
        return make error! [user message "No ENDING BRACE of HEADER!!!"]
    ]
    while [braces >= 1][
        s1: find/tail point "["
        s2: find/tail point "]"
        either all [s1 s2][
            either (index? s1) < index? s2 [
                braces: braces + 1 
                point: s1
            ][
                braces: braces - 1 
                point: s2
            ]
        ][
            any [
                all [s1 point: s1 braces: braces + 1]
                all [s2 point: s2 braces: braces - 1]
            ]
        ]
    ]
    point
]

colorize: func [file /lpoint][
    point: entab read file

    insert point {*_LT_*FONT COLOR="#666699"*_GT_*}
    point: insert find-end-header point "*_LT_*/FONT*_GT_*" 

    pre-escapes: [
        "^^"  "*_HT_*"
    ]
    foreach [from to] pre-escapes [
        find-replace point from to
    ]
    lpoint: load copy point
    if not any [none? lpoint empty? lpoint][meta lpoint]

    escapes: [
        "&amp;" "&"  "&lt;" "<" 
        "&gt;" ">" "    " "^-"
        "<" "*_LT_*" ">" "*_GT_*" 
        "^^" "*_HT_*" 
    ]
    foreach [to from] escapes [
        find-replace head point from to
    ]

    insert head point copy reform [
        <HTML><HEAD><TITLE> file </TITLE></HEAD>
        <BODY BGCOLOR="#FFFFFF"> newline <PRE>
    ]
    append point reduce [newline </PRE></BODY></HTML>]
    head point
]

soak-white: func [mark][
    ws: charset " ^-^/"
    while [find ws first mark][mark: next mark]
    mark
]

font: func [mark length color][
    insert mark color 
    insert skip mark length + length? color {*_LT_*/FONT*_GT_*}
]

tag-color: func [col][rejoin [copy {*_LT_*FONT COLOR="} mold col {"*_GT_*}]]
meta: func [stuff /e/s1/s2][
    if empty? stuff [exit]
    foreach item load stuff [
        ;print ["***" mold :item "*** (" index? point ")"]
        catch [
            if paren? :item  [meta append copy [] :item throw]
            if block? :item  [meta :item throw]
            if path? :item [meta append copy [] first :item throw]
            if string? :item [
                s1: find point rejoin ["{" :item "}"] 
                s2: find point rejoin [{"} :item {"}]
                if all [none? s1 none? s2][
                    print ["Couldn't find this string: " :item] throw
                ]
                ;print ["S1:" mold either s1 [reform [copy/part s1 20 index? s1]][none] newline newline "S2:" mold  
                ; either s2 [reform [copy/part s2 20 index? s2] ][none] newline newline]
                point: font back either all [s1 s2][at point min index? s1 index? s2][any [s1 s2]] 3 + length? :item tag-color #336666 throw
            ]
            any [
                all [
                    tag? :item 
                    point: font find point form :item length? form :item tag-color #996633
                ]
                all [
                    word? :item value? :item 
                     point: font find point form :item length? form :item tag-color #990033
                ]
                all [
                    any [refinement? :item word? :item not value? :item] 
                    point: soak-white point
                     point: skip point length? form :item
                ]
            ]
        ]
    ]
]

