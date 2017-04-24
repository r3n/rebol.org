REBOL [
    Library: [
        level: 'advanced
        platform: 'all
        type: [function module]
        domain: [html markup text text-processing]
        tested-under: none
        support: none
        license: 'mit
        see-also: none
        ]
    Title: {Qtask Markup Language - parser and other common code}
    File: %qml-base.r
    Purpose: {
        This program implements the base for QML (Qtask Markup Language) converters (for example
        it's the base for a QML to XHTML converter used in Qtask), by implementing the parsing
        of a QML text string into a QML document tree.
    }
    Author: "Gabriele Santilli"
    EMail: giesse@rebol.it
    License: {
        Copyright (c) 2006-2007 Prolific Publishing, Inc.

        Permission is hereby granted, free of charge, to any person obtaining a
        copy of this software and associated documentation files (the
        "Software"), to deal in the Software without restriction, including
        without limitation the rights to use, copy, modify, merge, publish,
        distribute, sublicense, and/or sell copies of the Software, and to
        permit persons to whom the Software is furnished to do so, subject to
        the following conditions:

        The above copyright notice and this permission notice shall be included
        in all copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
        OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
        MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
        IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
        CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
        TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
        SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    }
    Date: 6-Apr-2007
    Version: 2.46.1
    History: [
        16-Feb-2006 1.1.0 "History start" 
        16-Feb-2006 1.2.0 "Fixed a bug with escape command parsing" 
        20-Feb-2006 1.3.0 "Moved options parsing from emitters to here" 
        13-Mar-2006 1.4.0 {Options parsing now collects values without a name; =, now treated as end command} 
        13-Mar-2006 1.5.0 "Added second pass to balance commands" 
        17-Mar-2006 1.6.0 "PARSE rules no more eat newlines after commands" 
        17-Mar-2006 1.7.0 "Removed header option for boxes" 
        17-Mar-2006 1.8.0 "=- now eats one newline" 
        18-Mar-2006 1.9.0 "Added args for =row and =column" 
        18-Mar-2006 1.10.0 "Changed box options" 
        18-Mar-2006 1.11.0 "=>>> etc.; fixed space only lines" 
        21-Mar-2006 1.12.0 "Spaces at beginning of lines are now ignored" 
        23-Mar-2006 1.13.0 {Changed handling of =cell, =row and =column in second pass} 
        24-Mar-2006 1.14.0 "Spaces no more required after ]" 
        27-Mar-2006 1.15.0 "New command options handling" 
        27-Mar-2006 1.16.0 "Added comment handling to second pass" 
        29-Mar-2006 1.17.0 {Minor changes to options handling; supports dashed: color etc. too} 
        29-Mar-2006 1.18.0 "Split =c and =center into two separate commands" 
        29-Mar-2006 1.19.0 "=word and =def as aliases for =: and =::" 
        29-Mar-2006 1.20.0 "Added new comma-pair! option type" 
        29-Mar-2006 1.21.0 {Second pass now eats newlines that should be ignored, and handles inline cmds in block mode differently} 
        30-Mar-2006 1.22.1 "Fixed table balancing" 
        30-Mar-2006 1.23.1 "Added boxcenter etc to =table" 
        30-Mar-2006 1.24.1 "Added #FFF etc. as color" 
        30-Mar-2006 1.25.1 "Changed escape commands (=example[end])" 
        30-Mar-2006 1.26.1 "Added =left, =right, =l, =r" 
        30-Mar-2006 1.27.1 "Added =span" 
        1-Apr-2006 1.28.1 "Added =justify, =j" 
        5-Apr-2006 1.29.1 "Added =table[space]" 
        5-Apr-2006 1.30.1 "Added shadow and rounded to =table" 
        6-Apr-2006 1.31.1 "Added all flag for table, row and column" 
        6-Apr-2006 1.32.1 "= and =, now close =left etc. too" 
        18-Apr-2006 1.33.1 "Fixed balancing for =toc" 
        18-Apr-2006 1.34.1 "Added =o and =x" 
        21-Apr-2006 1.35.1 "Added =s and =u" 
        21-Apr-2006 1.36.1 "Now collects font style for =toc" 
        21-Apr-2006 1.37.1 "Now collects font style for headers numbers" 
        22-Apr-2006 1.38.1 {Moved merge-style here (from xhtml emitter) and added /copy (fixes bug)} 
        22-Apr-2006 1.39.1 "Added =font[space]" 
        22-Apr-2006 1.40.1 {Added new color keywords, improved compatibility with older REBOLs} 
        24-Apr-2006 1.41.1 "Added =row. and =column." 
        24-Apr-2006 1.42.1 "New =image (now inline)" 
        24-Apr-2006 1.43.1 "Added =4, =5 and =6" 
        26-Apr-2006 1.44.1 "Added a few missing colors" 
        27-Apr-2006 1.45.1 "The / char is now an alias for . (ending commands)" 
        27-Apr-2006 1.46.1 "Added initial support for =anchor, changed =link" 
        28-Apr-2006 1.47.1 "Finished =anchor support" 
        12-May-2006 2.1.0 "Started rewriting as RLP with new architecture" 
        15-May-2006 2.2.0 "Added table support" 
        15-May-2006 2.3.0 "Added =csv" 
        17-May-2006 2.4.0 "Added =data" 
        17-May-2006 2.5.0 "Added rewriting engine" 
        17-May-2006 2.6.0 "Added parsing for =repeat" 
        17-May-2006 2.7.0 "Added balancing for =repeat" 
        17-May-2006 2.8.0 "Basic =repeat support" 
        18-May-2006 2.9.0 "New table handling, supporting =repeat in =table" 
        18-May-2006 2.10.0 "Initial toc support" 
        19-May-2006 2.11.0 "Added numbering (finished toc), anchors" 
        19-May-2006 2.12.0 "Fixed links and qlinks" 
        19-May-2006 2.13.0 "Fixed =#" 
        19-May-2006 2.14.0 "=data[name] when name is a =table" 
        20-May-2006 2.15.0 "Added search" 
        23-May-2006 2.16.0 "Improved =repeat and =data, testing" 
        24-May-2006 2.17.0 {Rewritten numbering/counting to be =repeat friendly} 
        24-May-2006 2.18.0 "Added optimizations" 
        25-May-2006 2.19.0 "Changed =table[space]" 
        25-May-2006 2.20.1 "Added support for default options" 
        26-May-2006 2.21.1 "Made words optional in the repeat dialect" 
        26-May-2006 2.22.1 "Auto naming for tables and csv" 
        26-May-2006 2.23.1 "Added =table[headerless]" 
        26-May-2006 2.24.1 "=repeat on table now skips header row" 
        29-May-2006 2.25.1 "Fixed box with only a title" 
        2-Jun-2006 2.26.1 "Added defaults for =repeat and =data" 
        7-Jun-2006 2.27.1 {Fixed problem with =data, =image and =anchor as =box title} 
        14-Jun-2006 2.28.1 "Now removes anchors from TOC" 
        14-Jun-2006 2.29.1 "Search now lists anchor exact matches too" 
        14-Jun-2006 2.30.1 "Added =table[horizontal vertical]" 
        16-Jun-2006 2.31.1 {Added =image[space] and changed =image[image: ...] to =image[src: ...]} 
        16-Jun-2006 2.32.1 "Added /keep refinement to scan-doc" 
        16-Jun-2006 2.33.1 {Added process-link function (to be overridden by users)} 
        29-Jun-2006 2.34.1 "Fixed =span" 
        21-Jul-2006 2.35.1 {=l meant both one-line =left and abbreviation for =link; fixed (now =link can be abbreviated as =li)} 
        21-Jul-2006 2.36.1 "Fixed problem with =table[borderless]" 
        21-Aug-2006 2.37.1 "Release 2.0i: first public release" 
        23-Nov-2006 2.38.1 {Fixed a bug with color names (parse rule must be in correct order)} 
        23-Nov-2006 2.39.1 {Fixed a bug with combination of some one-line commands on the same line} 
        23-Nov-2006 2.40.1 {Changed header numbering: added 0, added normalization} 
        23-Nov-2006 2.41.1 "Added default TOC title setting" 
        23-Nov-2006 2.42.1 "Merged changes from Qtask" 
        6-Dec-2006 2.43.1 "Finished documentation of the second stage" 
        22-Dec-2006 2.44.1 {Fixed a bug with =image without options; changed =:: outside dlist to be indent: 3} 
        13-Mar-2007 2.45.1 {Fixed a bug with =row[all] and =column[all] not applying to previously defined cells} 
        6-Apr-2007 2.46.1 "Adding process-image-url hook function"
    ]
]

match: func [
    "Match a pattern over data" 
    data [block! string!] "Data to match the pattern to" 
    rule [block!] "PARSE rule to use as pattern" 
    /local 
    result recurse
] [
    result: false 
    recurse: either block? data [[
            some [
                rule (result: true) 
                | 
                into recurse 
                | 
                skip
            ]
        ]] [[
            some [
                rule (result: true) 
                | 
                skip
            ]
        ]] 
    parse data recurse 
    result
] 
rewrite: func [
    "Apply a list of rewrite rules to data" 
    data [block! string!] "Data to change" 
    rules [block!] "List of rewrite rules" 
    /trace "Trace rewriting process (for debugging)" 
    /local 
    rules* prod mk1 mk2
] [
    if empty? rules [return data] 
    rules*: make block! 16 
    foreach [pattern production] rules [
        insert insert/only insert/only tail rules* pattern make paren! compose/only [
            prod: compose/deep (production)
        ] '|
    ] 
    remove back tail rules* 
    until [
        if trace [probe data ask "? "] 
        not match data [mk1: rules* mk2: (change/part mk1 prod mk2) :mk1]
    ] 
    data
] 
qml-scanner: context [
    qml-rule: [
        some [commands | text]
    ] 
    commands: [
        any spc newline (stage2 "^/" none) 
        | 
        magic-char [
            magic-char (stage2 [text:] magic-char) 
            | [" " | mk: newline :mk] (stage2 " " none) 
            | 
            "alias" some spc copy cmd some cmd-chars any spc (set-magic cmd) 
            | 
            "csv" [
                "[" copy options to "]" skip any spc opt newline (options: refinements/parse-arg-string "csv" any [options ""]) 
                | 
                "{" copy options to "}" skip any spc opt newline (options: refinements/parse-arg-string "csv" any [options ""]) 
                | 
                any spc opt newline (options: context [name: show: none])
            ] (csv: make block! 256) some [[magic-char "csv" ["." | "/"] any spc opt newline | end] (stage2 "csv" make options [contents: csv]) break 
                | [copy txt to newline newline | copy txt to end] (append/only csv parse/all txt ",")
            ] 
            | 
            copy cmd escape-cmd [
                "[" copy options to "]" skip any spc opt newline 
                | 
                "{" copy options to "}" skip any spc opt newline 
                | 
                any spc opt newline (options: rejoin [magic-char cmd "."])
            ] [copy txt to options options any spc opt newline | copy txt to end] (stage2 cmd txt) 
            | 
            some "-" [some spc opt newline | newline | mk: magic-char :mk | end] (stage2 "-" none) 
            | 
            copy cmd some ">" [some spc | mk: [newline | magic-char] :mk | end] (stage2 ">" length? cmd) 
            | 
            "[" copy options to "]" skip (stage2 "" options) 
            | 
            "{" copy options to "}" skip (stage2 "" options) 
            | 
            "," (stage2 "," none) 
            | 
            "repeat" (options: make block! 16) [(opt-open-char: "[" opt-close-char: "]") rebol-options (stage2 "repeat" options) 
                | (opt-open-char: "{" opt-close-char: "}") rebol-options (stage2 "repeat" options) 
                | ["." | "/"] (stage2 "repeat." none)
            ] 
            | 
            end 
            | 
            copy cmd any cmd-chars [
                "[" copy options to "]" skip opt spc (stage2 cmd options) 
                | 
                "{" copy options to "}" skip opt spc (stage2 cmd options) 
                | ["." | "/"] (stage2 join any [cmd ""] "." none) 
                | [some spc | mk: [newline | magic-char] :mk | end] (stage2 cmd none)
            ] 
            | (stage2 [text:] magic-char)
        ]
    ] 
    txt: none 
    txt-chars: none 
    spc: charset " ^-" 
    text: [
        copy txt [any spc some txt-chars any [some spc some txt-chars]] (stage2 [text:] txt) 
        | 
        copy txt some spc (stage2 [whitespace:] txt)
    ] 
    mk: cmd: options: csv: none 
    spc+: charset " ^-^/" 
    cmd-chars: none 
    magic-char: none 
    escape-cmd: ["HTML" | "REBOL" | "MakeDoc" | "Example"] 
    opt-open-char: "[" opt-close-char: "]" 
    rebol-options: [
        opt-open-char 
        txt: (txt: load-next options txt) :txt 
        some [any spc+ opt-close-char break | end break | txt: (txt: load-next options txt) :txt] 
        opt spc
    ] 
    load-next: func [out text /local val] [
        if error? try [
            set [val text] load/next text 
            insert/only tail out val
        ] [
            insert tail out copy/part text text: any [find text opt-close-char tail text]
        ] 
        text
    ] 
    set-magic: func [magic [string!]] [
        if empty? magic [magic: "="] 
        magic-char: magic 
        cmd-chars: complement charset join " ^-^/[]{}./" first magic-char 
        txt-chars: complement charset join " ^-^/" first magic-char
    ] 
    parse-qml: func [text [string!] magic [string! none!]] [
        set-magic any [magic "="] 
        parse/all text qml-rule
    ] 
    parse-command-options: func [cmd options] [
        either all [
            string? options 
            find [
                "table" "row" "column" "cell" "box" 
                "image" "font" "f" "span" "data"
            ] cmd
        ] [
            refinements/parse-arg-string cmd options
        ] [
            options
        ]
    ] 
    refinements: context [
        types: context [
            flag!: [flag-word [some spc | end]] 
            set-word!: [set-word any spc] 
            color!: [[
                    color-keyword 
                    | 
                    tuple 
                    | [opt "#" copy value 6 hex-digits | "#" copy value 3 hex-digits] (value: to issue! value)
                ] [some spc | end]] 
            string!: [[{"} copy value some dquotechars {"} | "'" copy value some quotechars "'" | copy value some chars] [some spc | end]] 
            integer!: [copy value some digits (value: to system/words/integer! value) [some spc | end]] 
            url!: [
                copy value [some urlchars ":" 0 2 "/" some urlchars any ["/" some urlchars]] (value: to system/words/url! value) [some spc | end]
            ] 
            percent!: [copy value 1 3 digits "%" (value: to money! value) [some spc | end]] 
            pair!: [copy value [some digits "x" some digits] (value: to system/words/pair! value) [some spc | end]] 
            comma-pair!: [(value: make block! 4) 
                copy val some digits ["%" (append value to money! val) | none (append value to integer! val)] 
                "," 
                copy val some digits ["%" (append value to money! val) | none (append value to integer! val)] [some spc | end]
            ]
        ] 
        value: val: none 
        chars: complement spc: charset " ^-^/" 
        urlchars: complement charset {"':/ ^-
} 
        dquotechars: complement charset {"} 
        quotechars: complement charset "'" 
        digits: charset "1234567890" 
        hex-digits: union digits charset "ABCDEFabcdef" 
        flag-word: none 
        set-word: none 
        color-keyword: [
            "clear" (value: /transparent) | copy value [
                "lightgoldenrodyellow" | "mediumspringgreen" | "mediumaquamarine" | 
                "mediumslateblue" | "mediumturquoise" | "mediumvioletred" | "blanchedalmond" | 
                "cornflowerblue" | "darkolivegreen" | "lightslateblue" | "lightslategray" | 
                "lightsteelblue" | "mediumseagreen" | "darkgoldenrod" | "darkslateblue" | 
                "darkslategray" | "darkturquoise" | "lavenderblush" | "lightseagreen" | 
                "palegoldenrod" | "paleturquoise" | "palevioletred" | "antiquewhite" | 
                "darkseagreen" | "lemonchiffon" | "lightskyblue" | "mediumorchid" | 
                "mediumpurple" | "midnightblue" | "darkmagenta" | "deepskyblue" | 
                "floralwhite" | "forestgreen" | "greenyellow" | "lightsalmon" | 
                "lightyellow" | "navajowhite" | "saddlebrown" | "springgreen" | 
                "yellowgreen" | "transparent" | "aquamarine" | "blueviolet" | "chartreuse" | 
                "darkorange" | "darkorchid" | "darksalmon" | "darkviolet" | "dodgerblue" | 
                "ghostwhite" | "lightcoral" | "lightgreen" | "mediumblue" | "papayawhip" | 
                "powderblue" | "sandybrown" | "whitesmoke" | "aliceblue" | "burlywood" | 
                "cadetblue" | "chocolate" | "darkgreen" | "darkkhaki" | "firebrick" | 
                "gainsboro" | "goldenrod" | "indianred" | "lawngreen" | "lightblue" | 
                "lightcyan" | "lightgrey" | "lightpink" | "limegreen" | "mintcream" | 
                "mistyrose" | "olivedrab" | "orangered" | "palegreen" | "peachpuff" | 
                "rosybrown" | "royalblue" | "slateblue" | "slategray" | "steelblue" | 
                "turquoise" | "violetred" | "cornsilk" | "darkblue" | "darkcyan" | 
                "darkgray" | "deeppink" | "feldspar" | "honeydew" | "lavender" | "moccasin" | 
                "seagreen" | "seashell" | "crimson" | "darkred" | "dimgray" | "fuchsia" | 
                "hotpink" | "magenta" | "oldlace" | "skyblue" | "thistle" | "bisque" | 
                "indigo" | "maroon" | "orange" | "orchid" | "purple" | "salmon" | "sienna" | 
                "silver" | "tomato" | "violet" | "yellow" | "azure" | "beige" | "black" | 
                "brown" | "coral" | "green" | "ivory" | "khaki" | "linen" | "olive" | 
                "wheat" | "white" | "aqua" | "blue" | "cyan" | "gold" | "gray" | "lime" | 
                "navy" | "peru" | "pink" | "plum" | "snow" | "teal" | "red" | "tan"
            ] (value: to refinement! value)
        ] 
        tuple: [
            copy value [1 3 digits "." 1 3 digits "." 1 3 digits] (value: attempt [to tuple! value])
        ] 
        flag-words: [
            "table" [
                outline | dashed | dotted | solid | borderless | vertical | horizontal | all | hide | headerless | 
                center | left | right | justify | middle | top | bottom | imagecenter | imageleft | 
                imageright | imagemiddle | imagetop | imagebottom | float | space2 | tilev | shadow | rounded | 
                tileh | tileless | tile | boxcenter | boxleft | boxright | times | helv | courier | bold | italic
            ] 
            "cell" "row" "column" [
                outline | dashed | dotted | solid | borderless | all | 
                center | left | right | justify | middle | top | bottom | imagecenter | imageleft | 
                imageright | imagemiddle | imagetop | imagebottom | tilev | 
                tileh | tileless | tile | times | helv | courier | bold | italic
            ] 
            "box" [
                outline | dashed | dotted | solid | borderless | 
                center | left | right | justify | middle | top | bottom | imagecenter | imageleft | 
                imageright | imagemiddle | imagetop | imagebottom | float | tilev | 
                tileh | tileless | tile | boxcenter | boxleft | boxright | times | helv | courier | shadow | rounded | 
                bold | italic
            ] 
            "image" [
                outline | dashed | dotted | solid | borderless | float | 
                boxleft | space
            ] 
            "font" "f" [
                times | helv | courier | bold | italic | space
            ] 
            "span" none 
            "csv" [show] 
            "data" none
        ] 
        bold: ["b" opt "old" (value: 'bold)] 
        italic: ["i" opt ["talic" opt "s"] (value: 'italic)] 
        vertical: [["vertical" | "tablev"] (value: 'vertical)] 
        float: [["float" | "flow"] (value: 'float)] 
        tilev: ["tilev" opt "ertical" (value: 'tilev)] 
        tileh: ["tileh" opt "orizontal" (value: 'tileh)] 
        space2: ["space" (value: 'force-space)] 
        rule: word: none 
        parse flag-words [
            some [
                some string! set rule block! (
                    while [not tail? rule] [
                        either all [rule/1 <> '| not block? get/any word: rule/1] [
                            rule: insert/only change rule 
                            form word to paren! compose [value: (to lit-word! word)]
                        ] [rule: next rule]
                    ]
                ) 
                | 
                some string! rule: 'none (rule/1: [end skip])
            ]
        ] 
        flag-actions: context [
            dashed: [outline-style: 'dashed] 
            dotted: [outline-style: 'dotted] 
            solid: [outline-style: 'solid] 
            outline: [outline-style: 'solid] 
            borderless: [outline-style: 'borderless] 
            rounded: [outline-style: 'rounded] 
            center: [text-halign: 'center] 
            left: [text-halign: 'left] 
            right: [text-halign: 'right] 
            justify: [text-halign: 'justify] 
            middle: [text-valign: 'middle] 
            top: [text-valign: 'top] 
            bottom: [text-valign: 'bottom] 
            imagecenter: [image-halign: 'center] 
            imageleft: [image-halign: 'left] 
            imageright: [image-halign: 'right] 
            imagemiddle: [image-valign: 'center] 
            imagetop: [image-valign: 'top] 
            imagebottom: [image-valign: 'bottom] 
            tile: [image-tiling: 'both] 
            tilev: [image-tiling: 'vertical] 
            tileh: [image-tiling: 'horizontal] 
            tileless: [image-tiling: 'neither] 
            times: [typeface: 'times] 
            helv: [typeface: 'helvetica] 
            courier: [typeface: 'courier] 
            boxcenter: [position: 'center] 
            boxright: [position: 'right] 
            boxleft: [position: 'left]
        ] 
        set-words: [
            "table" [
                color | typeface | fontsize | background | outline | dashed | dotted | solid | image | width | height | 
                name
            ] 
            "cell" "row" "column" [
                color | typeface | fontsize | background | outline | dashed | dotted | solid | image | width | height | 
                column | row
            ] 
            "box" [
                color | typeface | fontsize | background | outline | dashed | dotted | solid | image | width | height
            ] 
            "image" [
                background | outline | dashed | dotted | solid | src | width | height | space
            ] 
            "font" "f" [
                color | typeface | fontsize | background | space
            ] 
            "span" none 
            "csv" [name] 
            "data" [name | index]
        ] 
        color: [["colo" opt "u" "r:" | "foreground:" | "fg:"] (value: first [color:])] 
        typeface: [opt "type" "face:" (value: first [typeface:])] 
        fontsize: ["size" opt "face" ":" (value: first [fontsize:])] 
        background: [["background:" | "bg:"] (value: first [background:])] 
        width: ["w" opt "idth" ":" (value: first [width:])] 
        height: ["h" opt "eight" ":" (value: first [height:])] 
        column: ["c" opt "olumn" ":" (value: first [column:])] 
        row: ["r" opt "ow" ":" (value: first [row:])] 
        parse set-words [
            some [
                some string! set rule block! (
                    while [not tail? rule] [
                        either all [rule/1 <> '| not block? get/any word: rule/1] [
                            rule: insert/only change rule 
                            append form word ":" to paren! compose/deep [value: first [(to set-word! word)]]
                        ] [rule: next rule]
                    ]
                ) 
                | 
                some string! rule: 'none (rule/1: [end skip])
            ]
        ] 
        set-actions: context [
            outline: solid: [outline-color: value outline-style: 'solid] 
            dashed: [outline-color: value outline-style: 'dashed] 
            dotted: [outline-color: value outline-style: 'dotted] 
            column: [position: as-pair value 1] 
            row: [position: as-pair 1 value]
        ] 
        var-types: context [
            color: types/color! 
            typeface: types/string! 
            fontsize: types/integer! 
            space: types/integer! 
            background: types/color! 
            outline: dashed: dotted: solid: types/color! 
            width: height: bind [percent! | integer!] in types 'self 
            column: row: types/integer! 
            image: bind [url! | string!] in types 'self 
            name: types/string! 
            index: bind [pair! | integer!] in types 'self
        ] 
        value-rule: bind [color! | percent! | pair! | comma-pair! | integer! | url! | string!] in types 'self 
        type-map: [
            "table" [
                color! [background color outline-color] 
                string! [image typeface] 
                integer! [width height fontsize] 
                url! [image] 
                percent! [width height] 
                pair! [table-size] 
                comma-pair! [(width: value/1 height: value/2)]
            ] 
            "row" "column" [
                color! [background color outline-color] 
                string! [image typeface] 
                integer! [position width height fontsize] 
                url! [image] 
                percent! [width height] 
                pair! [none] 
                comma-pair! [(width: value/1 height: value/2)]
            ] 
            "cell" [
                color! [background color outline-color] 
                string! [image typeface] 
                integer! [width height fontsize] 
                url! [image] 
                percent! [width height] 
                pair! [position] 
                comma-pair! [(width: value/1 height: value/2)]
            ] 
            "box" [
                color! [background color outline-color] 
                string! [image typeface] 
                integer! [width height fontsize] 
                url! [image] 
                percent! [width height] 
                pair! [none] 
                comma-pair! [(width: value/1 height: value/2)]
            ] 
            "image" [
                color! [outline-color background] 
                string! [src] 
                integer! [width height] 
                url! [src] 
                percent! [width height] 
                pair! [none] 
                comma-pair! [(width: value/1 height: value/2)]
            ] 
            "font" "f" [
                color! [color background] 
                string! [typeface] 
                integer! [fontsize space] 
                url! [none] 
                percent! [none] 
                pair! [none] 
                comma-pair! [none]
            ] 
            "span" [
                color! [none] 
                string! [none] 
                integer! [none] 
                url! [none] 
                percent! [none] 
                pair! [start end] 
                comma-pair! [none]
            ] 
            "csv" [
                color! [none] 
                string! [name] 
                integer! [none] 
                url! [none] 
                percent! [none] 
                pair! [none] 
                comma-pair! [none]
            ] 
            "data" [
                color! [none] 
                string! [name] 
                integer! [index] 
                url! [none] 
                percent! [none] 
                pair! [index] 
                comma-pair! [none]
            ]
        ] 
        parse type-map [
            some [
                some string! set rule block! (
                    foreach [from to] [
                        color! [issue! refinement! tuple!] 
                        percent! money! 
                        comma-pair! block!
                    ] [
                        replace rule from to
                    ]
                )
            ]
        ] 
        object-map: [
            "table" [
                background: color: outline-color: image: typeface: width: height: fontsize: 
                table-size: bold: italic: outline-style: vertical: text-halign: text-valign: 
                image-halign: image-valign: float: image-tiling: position: force-space: shadow: 
                all: hide: name: headerless: horizontal: none
            ] 
            "row" "column" "cell" [
                background: color: outline-color: image: typeface: width: height: fontsize: 
                bold: italic: outline-style: text-halign: text-valign: 
                image-halign: image-valign: image-tiling: position: all: none
            ] 
            "box" [
                background: color: outline-color: image: typeface: width: height: fontsize: 
                bold: italic: outline-style: text-halign: text-valign: 
                image-halign: image-valign: float: image-tiling: position: shadow: none
            ] 
            "image" [
                background: outline-color: src: width: height: outline-style: 
                float: position: space: none
            ] 
            "font" "f" [
                bold: italic: typeface: color: background: fontsize: space: none
            ] 
            "span" [
                start: end: none
            ] 
            "csv" [
                show: name: none
            ] 
            "data" [
                name: index: none
            ]
        ] 
        select*: func [block value] [
            parse block [to value to block! set block block! | (block: none)] 
            block
        ] 
        get-obj: func [cmd] [make object! select* object-map cmd] 
        set-value-from-type: func [tmap obj] [
            foreach word select* tmap type?/word :value [
                if paren? :word [
                    do bind to block! word in obj 'self 
                    break
                ] 
                if all [word <> 'none none? get word: in obj word] [
                    set word value 
                    break
                ]
            ]
        ] 
        parse-arg-string: func [cmd args /local 
            obj tmap var-type last-str vars tset-word! tflag!
        ] [
            flag-word: select* flag-words cmd 
            set-word: select* set-words cmd 
            tmap: select* type-map cmd 
            obj: get-obj cmd 
            tflag!: types/flag! 
            tset-word!: types/set-word! 
            parse/all args [
                any spc some [
                    tflag! (
                        last-str: none 
                        either in flag-actions value [
                            do bind get in flag-actions value in obj 'self
                        ] [
                            set in obj value true
                        ]
                    ) 
                    | (vars: clear []) 
                    some [tset-word! (append vars value: to word! :value)] (var-type: get in var-types value) 
                    var-type (
                        last-str: either string? :value [value] [none] 
                        foreach var vars [
                            either in set-actions var [
                                do bind get in set-actions var in obj 'self
                            ] [
                                set in obj var value
                            ]
                        ]
                    ) 
                    | 
                    value-rule (
                        either string? :value [
                            either last-str [
                                insert insert tail last-str " " value
                            ] [
                                last-str: value 
                                set-value-from-type tmap obj
                            ]
                        ] [
                            last-str: none 
                            set-value-from-type tmap obj
                        ]
                    )
                ]
            ] 
            obj
        ]
    ] 
    default-number-style: 
    default-table: 
    default-row: 
    default-column: 
    default-cell: 
    default-box: 
    default-image: 
    default-toc-title: none 
    default-data: context [name: "csv" index: none] 
    default-repeat: [csv in csv] 
    set-defaults: func [defaults /local w] [
        default-number-style: default-table: default-row: default-column: 
        default-cell: default-box: default-image: default-toc-title: none 
        if block? defaults [
            foreach [cmd opts] defaults [
                if w: select [
                    "toc" default-number-style 
                    "table" default-table 
                    "row" default-row 
                    "column" default-column 
                    "cell" default-cell 
                    "box" default-box 
                    "image" default-image 
                    "toc-title" default-toc-title
                ] cmd [
                    set w parse-command-options cmd opts
                ]
            ]
        ]
    ] 
    stage2-fsm: make fsm! [] 
    stage2: func [cmd opts] [
        if block? cmd [cmd: first cmd] 
        stage2-ctx/opts: parse-command-options stage2-ctx/cmd: cmd :opts 
        stage2-fsm/event cmd 
        if stage2-ctx/close-inline? [
            stage2-fsm/event first [close-inline:] 
            stage2-ctx/close-inline?: no
        ]
    ] 
    stage2-ctx: context [
        cmd: opts: none 
        open-block: func [cmd opts] [
            stage3 cmd opts 
            insert/only insert tail block-stack cmd opts
        ] 
        block-stack: [] 
        close-block: func [cmd /upto noclosecmd /local] [
            remove back tail cmd: copy cmd 
            if local: find/skip/last block-stack cmd 2 [
                if upto [
                    noclosecmd: find/skip/last block-stack noclosecmd 2 
                    if all [noclosecmd (index? local) < index? noclosecmd] [
                        exit
                    ]
                ] 
                block-stack: tail block-stack 
                until [
                    block-stack: skip block-stack -2 
                    stage3 join block-stack/1 "." none 
                    block-stack/1 = cmd
                ] 
                block-stack: head clear block-stack
            ]
        ] 
        remove-all-inline: has [cmd] [
            clear inline-stack 
            block-stack: tail block-stack 
            while [find ["left" "right" "center" "justify"] cmd: pick block-stack -2] [
                stage3 join cmd "." none 
                block-stack: skip block-stack -2
            ] 
            block-stack: head clear block-stack
        ] 
        inline-stack: [] 
        close-all-block: does [
            block-stack: skip tail block-stack -2 
            while [not empty? block-stack] [
                stage3 join block-stack/1 "." none 
                block-stack: skip clear block-stack -2
            ]
        ] 
        remove-last-inline: has [cmd] [
            either empty? inline-stack [
                if find ["left" "right" "center" "justify"] cmd: pick tail block-stack -2 [
                    stage3 join cmd "." none 
                    clear skip tail block-stack -2
                ]
            ] [
                clear skip tail inline-stack -2
            ]
        ] 
        reopen-inline: does [
            foreach [cmd opts] inline-stack [
                stage3 cmd opts
            ]
        ] 
        add-inline: func [cmd opts] [
            insert/only insert tail inline-stack cmd opts
        ] 
        remove-inline: func [cmd] [
            if cmd: find/skip inline-stack cmd 2 [
                remove/part cmd 2
            ]
        ] 
        close-all-inline: does [
            inline-stack: skip tail inline-stack -2 
            while [not empty? inline-stack] [
                stage3 join inline-stack/1 "." none 
                inline-stack: skip clear inline-stack -2
            ] 
            if special [close-special special] 
            block-stack: tail block-stack 
            while [find ["left" "right" "center" "justify"] cmd: pick block-stack -2] [
                if not close-inline? [
                    stage3 "^/" none 
                    close-inline?: yes
                ] 
                stage3 join cmd "." none 
                block-stack: skip block-stack -2
            ] 
            block-stack: head clear block-stack
        ] 
        close-inline?: no 
        close-last-inline: has [cmd] [
            if empty? inline-stack [
                if special [
                    close-special special 
                    exit
                ] 
                if find ["left" "right" "center" "justify"] cmd: pick tail block-stack -2 [
                    stage3 "^/" none 
                    close-inline?: yes 
                    stage3 join cmd "." none 
                    clear skip tail block-stack -2
                ] 
                exit
            ] 
            cmd: pick tail inline-stack -2 
            stage3 join cmd "." none 
            clear skip tail inline-stack -2
        ] 
        open-special: func [cmd opts] [
            if special [close-special special] 
            special: join cmd "." 
            temp-close-inline 
            stage3 cmd opts 
            reopen-inline
        ] 
        special: none 
        close-special: func [cmd] [
            if special = cmd [
                temp-close-inline 
                stage3 cmd none 
                reopen-inline 
                special: none
            ]
        ] 
        temp-close-inline: does [
            if empty? inline-stack [exit] 
            inline-stack: tail inline-stack 
            until [
                inline-stack: skip inline-stack -2 
                stage3 join inline-stack/1 "." none 
                head? inline-stack
            ]
        ] 
        open-inline: func [cmd opts] [
            stage3 cmd opts 
            insert/only insert tail inline-stack cmd opts
        ] 
        close-inline: func [cmd] [
            remove back tail cmd: copy cmd 
            if find/skip inline-stack cmd 2 [
                inline-stack: tail inline-stack 
                until [
                    inline-stack: skip inline-stack -2 
                    stage3 join inline-stack/1 "." none 
                    inline-stack/1 = cmd
                ] 
                remove/part inline-stack 2 
                foreach [cmd opts] inline-stack [
                    stage3 cmd opts
                ] 
                inline-stack: head inline-stack
            ]
        ] 
        close-repeat: func [/only] [
            either find/skip inline-stack "repeat" 2 [
                inline-stack: tail inline-stack 
                until [
                    inline-stack: skip inline-stack -2 
                    stage3 join inline-stack/1 "." none 
                    inline-stack/1 = "repeat"
                ] 
                inline-stack: head clear inline-stack
            ] [
                if all [not only find/skip block-stack "repeat" 2] [
                    if special [close-special special] 
                    temp-close-inline 
                    stage3 "^/" none 
                    close-inline?: yes 
                    close-block "repeat."
                ]
            ]
        ] 
        end-inline: does [
            if special [close-special special] 
            close-repeat/only 
            temp-close-inline 
            stage3 "^/" none
        ] 
        in-block: [
            {"} "'" "`" "&#145;" "&#146;" in-line-comment 
            ";" "comment" "rem" in-comment 
            default: (stage3 cmd opts) 
            "word" (stage3 ":" opts) in-inline 
            "def" (stage3 "::" opts) in-inline 
            "example" "html" "rebol" "makedoc" "csv" (stage3 cmd opts) eat-one-newline 
            "table" "center" "left" "justify" "right" "repeat" (open-block cmd opts) eat-one-newline 
            "box" (open-block cmd opts) 
            "box." "table." "cell." "center." "left." 
            "justify." "right." "toc." "repeat." (close-block cmd) eat-one-newline 
            "toc" (close-block "toc." open-block "toc" opts) 
            "." (remove-all-inline close-all-block) eat-one-newline 
            " " (remove-last-inline) eat-one-newline 
            "," (remove-all-inline) eat-one-newline 
            "" "link" "anchor" "a" "li" "image" "data" text: (reopen-inline) continue in-inline 
            "c" "1" "1'" "2" "2'" "3" "3'" "*" "**" "#" "##" ">" ":" "::" 
            "r" "l" "j" "o" "x" "2&#146;" "1&#146;" "3&#146;" "4" "5" "6" (stage3 cmd opts reopen-inline) in-inline 
            "b" "bold" (add-inline "b" opts) eat-one-newline 
            "u" "underline" (add-inline "u" opts) eat-one-newline 
            "i" "italics" "italic" (add-inline "i" opts) eat-one-newline 
            "font" "f" (add-inline "f" opts) eat-one-newline 
            "s" "strike" "strikethrough" (add-inline "s" opts) eat-one-newline 
            "b." "bold." (remove-inline "b") eat-one-newline 
            "u." "underline." (remove-inline "u") eat-one-newline 
            "i." "italics." "italic." (remove-inline "i") eat-one-newline 
            "font." "f." (remove-inline "f") eat-one-newline 
            "s." "strike." "strikethrough." (remove-inline "s") eat-one-newline 
            "row" "column" "row." "column." "span" (close-block/upto "cell." "table" stage3 cmd opts) eat-one-newline 
            "cell" (close-block/upto "cell." "table" open-block cmd opts) eat-one-newline
        ] 
        in-inline: [
            {"} "'" "`" "&#145;" "&#146;" in-line-comment 
            ";" "comment" "rem" in-comment 
            default: (stage3 cmd opts) 
            "." (close-all-inline stage3 "^/" none) continue return 
            " " (close-last-inline) 
            "," (close-all-inline) 
            "link" "li" (open-special "link" opts) 
            "anchor" "a" (open-special "anchor" opts) 
            "link." "li." (close-special "link.") 
            "anchor." "a." (close-special "anchor.") 
            "b" "bold" (open-inline "b" opts) 
            "u" "underline" (open-inline "u" opts) 
            "i" "italics" "italic" (open-inline "i" opts) 
            "s" "strike" "strikethrough" (open-inline "s" opts) 
            "font" "f" (open-inline "f" opts) 
            "b." "bold." (close-inline "b.") 
            "u." "underline." (close-inline "u.") 
            "i." "italics." "italic." (close-inline "i.") 
            "s." "strike." "strikethrough." (close-inline "s.") 
            "font." "f." (close-inline "f.") 
            "repeat" (open-inline "repeat" opts) 
            "repeat." (close-repeat) 
            "^/" (end-inline) return 
            "box" "table" "c" "center" "center." "box." "table." "-" 
            "1" "1'" "2" "2'" "3" "3'" "*" "**" "#" "##" "csv" 
            ">" ":" "::" "word" "def" "example" "toc" "cell" "cell." 
            "row" "column" "left" "right" "left." "right." "r" "l" "span" 
            "html" "rebol" "makedoc" "justify" "j" "justify." "toc." 
            "o" "x" "2&#146;" "1&#146;" "3&#146;" "row." "column." "4" "5" "6" (end-inline) continue return 
            close-inline: return
        ] 
        in-line-comment: [
            "^/" return
        ] 
        in-comment: [
            ";." "comment." "rem." return
        ] 
        eat-one-newline: [
            "^/" return 
            default: continue return
        ]
    ] 
    init-stage2: does [
        clear stage2-ctx/block-stack 
        clear stage2-ctx/inline-stack 
        stage2-ctx/special: none 
        stage2-fsm/init stage2-ctx/in-block
    ] 
    end-stage2: does [
        stage2-fsm/event "." 
        stage2-fsm/end
    ] 
    stage3: func [cmd opts] [
        if block? cmd [cmd: first cmd] 
        stage3-ctx/cmd: cmd 
        stage3-ctx/opts: opts 
        stage3-fsm/event cmd
    ] 
    stage3-fsm: make fsm! [] 
    stage3-ctx: context [
        cmd: opts: none 
        emit: func [val] [
            repend out val
        ] 
        inherit: func [parent-state new-directives] [
            append new-directives parent-state
        ] 
        blocks: [] 
        open-block: func [name opts /only] [
            insert/only tail blocks out 
            insert/only tail out out: make block! 16 
            emit name 
            if not none? opts [
                if all [object? opts not only] [opts: make-style opts] 
                emit ['opts opts]
            ]
        ] 
        close-block: does [
            if empty? blocks [exit] 
            out: last blocks 
            remove back tail blocks
        ] 
        make-style: func [obj /ignore block /local] [
            local: make block! length? obj: third obj 
            block: any [block []] 
            foreach [word val] obj [
                if all [:val not find block to word! word] [insert/only insert tail local word :val]
            ] 
            local
        ] 
        tabid: 1 
        vars: [] 
        open-table: func [opts] [
            if not object? opts [
                opts: refinements/get-obj "table"
            ] 
            if not opts/name [
                opts/name: join "table" tabid 
                if tabid = 1 [insert insert tail vars "table" context [type: 'alias dest: "table1"]] 
                tabid: tabid + 1
            ] 
            open-block/only 'table-proto opts 
            insert insert tail vars opts/name context [type: 'table-proto name: opts/name contents: out]
        ] 
        csvid: 1 
        handle-csv: func [data] [
            if not object? data [exit] 
            data: make data [type: 'csv] 
            either data/name [
                insert insert tail vars data/name data
            ] [
                insert insert tail vars join "csv" csvid data 
                if csvid = 1 [insert insert tail vars "csv" data] 
                csvid: csvid + 1
            ] 
            if data/show [
                open-block 'table none 
                foreach row data/contents [
                    open-block 'row none 
                    foreach column row [
                        emit [reduce ['cell reduce ['para column]]]
                    ] 
                    close-block
                ] 
                close-block
            ]
        ] 
        anchors: [] 
        header?: func [type col row] [
            switch type [
                horiz [row = 1] 
                vert [col = 1] 
                both [any [row = 1 col = 1]] 
                none [false]
            ]
        ] 
        generate-table: func [opts body /local table result content tmp i j header] [
            result: copy [table] 
            if opts [insert/only insert tail result 'opts make-style/ignore opts [name]] 
            table: make table-state! [
                style: opts 
                if all [object? style style/table-size] [size: style/table-size] 
                table: make block! 16 
                columns: make block! 16
            ] 
            body: rewrite copy body rewrite-rules 
            parse body [
                some [
                    'row set opts skip (add-row table opts) 
                    | 
                    'column set opts skip (add-col table opts) 
                    | 
                    'return (table-go-back table) 
                    | 
                    into ['cell ['opts set opts skip | (opts: none)] content: to end (add-cell table opts content)] 
                    | 
                    'span set opts skip (make-span table opts) opt [
                        into ['cell ['opts set opts skip | (opts: none)] content: to end (set-cell table opts content)]
                    ]
                ]
            ] 
            header: 'horiz 
            if object? table/style [
                if table/style/name [
                    poke find vars table/style/name 2 table
                ] 
                if table/style/hide [return [hidden-table]] 
                if table/style/vertical [header: either table/style/horizontal ['both] ['vert]] 
                if table/style/headerless [header: 'none]
            ] 
            insert/only tail result content: copy [columns] 
            foreach col table/columns [
                insert/only tail content either col [reduce ['column 'opts make-style col]] [[column]]
            ] 
            j: 1 
            foreach row table/table [
                either object? row [
                    i: 1 
                    insert/only tail result content: copy [row] 
                    if row/style [insert/only insert tail content 'opts make-style row/style] 
                    if all [find [horiz both] header j = 1] [insert tail content 'header] 
                    foreach cell row/contents [
                        either object? cell [
                            if cell/type = 'cell [
                                insert/only tail content compose [
                                    cell (either cell/style ['opts] [[]]) (either cell/style [reduce [make-style/ignore cell/style [position]]] [[]]) (either cell/spansize ['span] [[]]) (any [cell/spansize []]) (either header? header i j ['header] [[]]) (cell/out)
                                ]
                            ]
                        ] [
                            tmp: make-cell-style table none row pick table/columns i 
                            insert/only tail content compose [
                                cell (either tmp ['opts] [[]]) (either tmp [reduce [make-style/ignore tmp [position]]] [[]]) (either header? header i j ['header] [[]])
                            ]
                        ] 
                        i: i + 1
                    ] 
                    loop table/size/x - length? row/contents [
                        tmp: make-cell-style table none row pick table/columns i 
                        insert/only tail content compose [
                            cell (either tmp ['opts] [[]]) (either tmp [reduce [make-style/ignore tmp [position]]] [[]]) (either header? header i j ['header] [[]])
                        ] 
                        i: i + 1
                    ]
                ] [
                    insert/only tail result content: copy [row] 
                    if all [find [horiz both] header j = 1] [insert tail content 'header] 
                    if not any [table/style] 
                    repeat i table/size/x [
                        tmp: make-cell-style table none none pick table/columns i 
                        insert/only tail content compose [
                            cell (either tmp ['opts] [[]]) (either tmp [reduce [make-style/ignore tmp [position]]] [[]]) (either header? header i j ['header] [[]])
                        ]
                    ]
                ] 
                j: j + 1
            ] 
            loop table/size/y - length? table/table [
                insert/only tail result content: copy [row] 
                if all [find [horiz both] header j = 1] [insert tail content 'header] 
                repeat i table/size/x [
                    tmp: make-cell-style table none none pick table/columns i 
                    insert/only tail content compose [
                        cell (either tmp ['opts] [[]]) (either tmp [reduce [make-style/ignore tmp [position]]] [[]]) (either header? header i j ['header] [[]])
                    ]
                ] 
                j: j + 1
            ] 
            result
        ] 
        table-state!: context [
            type: 'table 
            table: 
            columns: 
            currow: 
            curcell: 
            curpos: none 
            dir: 0x1 
            size: 0x0 
            style: none 
            savepos: savedir: none
        ] 
        inherit-style: func [dest source words] [
            foreach word words [
                if none? get in dest word [
                    set in dest word get in source word
                ]
            ] 
            dest
        ] 
        make-cell-style: func [table-state style row col] [
            if not style [
                style: context [
                    background: color: outline-color: image: typeface: width: height: fontsize: 
                    bold: italic: outline-style: text-halign: text-valign: 
                    image-halign: image-valign: image-tiling: position: none
                ]
            ] 
            if all [table-state/style table-state/style/all] [
                inherit-style style table-state/style [outline-color outline-style]
            ] 
            either table-state/dir = 1x0 [
                if all [col col/all] [
                    inherit-style style col [
                        background color outline-color typeface height fontsize bold italic outline-style 
                        text-halign text-valign
                    ]
                ] 
                if all [row row/style row/style/all] [
                    inherit-style style row/style [
                        background outline-color width outline-style
                    ]
                ]
            ] [
                if all [row row/style row/style/all] [
                    inherit-style style row/style [
                        background outline-color width outline-style
                    ]
                ] 
                if all [col col/all] [
                    inherit-style style col [
                        background color outline-color typeface height fontsize bold italic outline-style 
                        text-halign text-valign
                    ]
                ]
            ] 
            if parse second style [object! some none! end] [style: none] 
            style
        ] 
        make-row: func [table-state pos style' /local row] [
            if pos/y > length? table-state/table [
                insert/dup tail table-state/table none pos/y - length? table-state/table
            ] 
            either row: pick table-state/table pos/y [
                row/style: merge-style row/style style'
            ] [
                poke table-state/table pos/y row: context [
                    contents: make block! 16 
                    style: style'
                ]
            ] 
            row
        ] 
        make-col: func [table-state pos style /local col] [
            if pos/x > length? table-state/columns [
                insert/dup tail table-state/columns none pos/x - length? table-state/columns
            ] 
            either col: pick table-state/columns pos/x [
                merge-style col style
            ] [
                poke table-state/columns pos/x style 
                style
            ]
        ] 
        add-row: func [table-state args /local pos row] [
            table-state/savedir: table-state/dir 
            if object? args [
                pos: args/position 
                if pair? pos [pos: pos/y]
            ] 
            either pos [
                table-state/savepos: table-state/curpos 
                table-state/curpos: 0x1 * pos
            ] [
                either table-state/curpos [
                    table-state/savepos: table-state/curpos + 0x1 
                    table-state/curpos: table-state/curpos * 0x1 + 0x1
                ] [
                    table-state/savepos: table-state/curpos: 0x1
                ]
            ] 
            args: merge-style/copy default-row args 
            row: make-row table-state table-state/curpos args 
            if all [row/style row/style/all] [
                foreach cell row/contents [
                    if cell [
                        cell/style: make-cell-style table-state cell/style row none
                    ]
                ]
            ] 
            table-state/dir: 1x0
        ] 
        add-col: func [table-state args /local pos col cell] [
            table-state/savedir: table-state/dir 
            if object? args [
                pos: args/position 
                if pair? pos [pos: pos/x]
            ] 
            either pos [
                table-state/savepos: table-state/curpos 
                table-state/curpos: 1x0 * pos
            ] [
                either table-state/curpos [
                    table-state/savepos: table-state/curpos + 1x0 
                    table-state/curpos: table-state/curpos * 1x0 + 1x0
                ] [
                    table-state/savepos: table-state/curpos: 1x0
                ]
            ] 
            args: merge-style/copy default-column args 
            col: make-col table-state table-state/curpos args 
            if all [col col/all] [
                foreach row table-state/table [
                    if row [
                        if cell: pick row/contents table-state/curpos/x [
                            cell/style: make-cell-style table-state cell/style none col
                        ]
                    ]
                ]
            ] 
            table-state/dir: 0x1
        ] 
        table-go-back: func [table-state] [
            if all [table-state/savepos table-state/savedir] [
                table-state/curpos: table-state/savepos 
                table-state/dir: table-state/savedir 
                table-state/currow: pick table-state/table table-state/curpos/y 
                table-state/curcell: pick table-state/currow/contents table-state/curpos/x 
                table-state/savepos: table-state/savedir: none
            ]
        ] 
        make-cell: func [table-state pos style' contents /span spanrc /local row cell] [
            row: make-row table-state pos none 
            if pos/x > length? row/contents [
                insert/dup tail row/contents none pos/x - length? row/contents
            ] 
            table-state/curpos: pos 
            table-state/currow: row 
            either cell: pick row/contents pos/x [
                if cell/type = 'span [
                    either span [
                        either cell/reference/position [
                            break-span table-state cell/reference pos pos + spanrc 
                            return make-cell/span table-state pos style' contents spanrc
                        ] [
                            poke row/contents pos/x none 
                            return make-cell/span table-state pos style' contents spanrc
                        ]
                    ] [
                        either cell/reference/position [
                            cell: cell/reference
                        ] [
                            poke row/contents pos/x none 
                            return make-cell table-state pos style' contents
                        ]
                    ]
                ] 
                cell/style: merge-style cell/style style' 
                if span [
                    if cell/spansize [
                        if any [cell/spansize/y > spanrc/y cell/spansize/x > spanrc/x] [
                            break-span table-state cell pos pos + spanrc 
                            return make-cell/span table-state pos style' contents spanrc
                        ]
                    ] 
                    cell/spansize: spanrc
                ] 
                cell/out: contents 
                table-state/curcell: cell
            ] [
                poke row/contents pos/x table-state/curcell: context [
                    type: 'cell 
                    position: pos 
                    out: contents 
                    style: make-cell-style table-state style' row pick table-state/columns pos/x 
                    spansize: if span [spanrc]
                ] 
                table-state/curcell
            ]
        ] 
        break-span: func [table-state spancell breakstart breakend /local cellstart cellend] [
            cellstart: spancell/position 
            cellend: spancell/position + spancell/spansize 
            spancell/spansize: none 
            spancell/position: none 
            poke get in pick table-state/table cellstart/y 'contents cellstart/x none 
            if spancell/style [spancell/style/position: none] 
            either table-state/dir = 1x0 [
                if breakstart/y > cellstart/y [
                    make-span table-state context [
                        start: cellstart 
                        end: cellend 
                        end/y: breakstart/y - 1
                    ] 
                    cellstart/y: breakstart/y 
                    set-cell table-state spancell/style []
                ] 
                if breakend/y < cellend/y [
                    make-span table-state context [
                        start: cellstart 
                        start/y: breakend/y + 1 
                        end: cellend
                    ] 
                    cellend/y: breakend/y 
                    set-cell table-state spancell/style []
                ] 
                if breakstart/x > cellstart/x [
                    make-span table-state context [
                        start: cellstart 
                        end: cellend 
                        end/x: breakstart/x - 1
                    ] 
                    cellstart/x: breakstart/x 
                    set-cell table-state spancell/style []
                ] 
                if breakend/x < cellend/x [
                    make-span table-state context [
                        start: cellstart 
                        start/x: breakend/x + 1 
                        end: cellend
                    ] 
                    cellend/x: breakend/x 
                    set-cell table-state spancell/style []
                ]
            ] [
                if breakstart/x > cellstart/x [
                    make-span table-state context [
                        start: cellstart 
                        end: cellend 
                        end/x: breakstart/x - 1
                    ] 
                    cellstart/x: breakstart/x 
                    set-cell table-state spancell/style []
                ] 
                if breakend/x < cellend/x [
                    make-span table-state context [
                        start: cellstart 
                        start/x: breakend/x + 1 
                        end: cellend
                    ] 
                    cellend/x: breakend/x 
                    set-cell table-state spancell/style []
                ] 
                if breakstart/y > cellstart/y [
                    make-span table-state context [
                        start: cellstart 
                        end: cellend 
                        end/y: breakstart/y - 1
                    ] 
                    cellstart/y: breakstart/y 
                    set-cell table-state spancell/style []
                ] 
                if breakend/y < cellend/y [
                    make-span table-state context [
                        start: cellstart 
                        start/y: breakend/y + 1 
                        end: cellend
                    ] 
                    cellend/y: breakend/y 
                    set-cell table-state spancell/style []
                ]
            ]
        ] 
        make-reference: func [table-state pos cell /local row old save] [
            row: make-row table-state pos none 
            if pos/x > length? row/contents [
                insert/dup tail row/contents none pos/x - length? row/contents
            ] 
            if all [old: pick row/contents pos/x old/type = 'span old/reference/position] [
                save: reduce bind [curcell curpos currow] in table-state 'self 
                break-span table-state old/reference cell/position cell/position + cell/spansize 
                set bind [curcell curpos currow] in table-state 'self save
            ] 
            poke row/contents pos/x local: context [
                type: 'span 
                reference: cell
            ] 
            local
        ] 
        add-cell: func [table-state args contents /local pos] [
            if object? args [pos: args/position] 
            if not pos [
                pos: any [table-state/curpos 1x0] 
                pos: pos + table-state/dir
            ] 
            args: merge-style/copy default-cell args 
            make-cell table-state pos args contents 
            table-state/size: max table-state/size pos
        ] 
        set-cell: func [table-state args contents] [
            either all [args args/position] [
                add-cell table-state args contents
            ] [
                table-state/curcell/style: merge-style table-state/curcell/style args 
                table-state/curcell/out: contents
            ]
        ] 
        make-span: func [table-state args /local cell pos] [
            if not all [
                object? args pair? args/start pair? args/end 
                set bind [start end] in args 'self reduce [min args/start args/end max args/start args/end]
            ] [exit] 
            if args/start = args/end [
                make-cell table-state args/start none [] 
                exit
            ] 
            if cell: make-cell/span table-state args/start none [] 1x1 + args/end - args/start [
                pos: args/start + 1x0 
                while [pos/y <= args/end/y] [
                    while [pos/x <= args/end/x] [
                        make-reference table-state pos cell 
                        pos: pos + 1x0
                    ] 
                    pos/x: args/start/x 
                    pos: pos + 0x1
                ] 
                table-state/size: max table-state/size args/end
            ]
        ] 
        common: [
            default: (emit [reduce ['command cmd opts]]) 
            "." rewind? initial
        ] 
        in-block: initial: inherit common [
            "" "link" "anchor" "image" "b" "i" "s" "f" "data" text: (open-block 'para none) continue in-para (close-block) 
            after-para: () 
            whitespace: () 
            "^/" (emit [[para]]) 
            "-" (emit [[hrule]]) 
            "1" (open-block 'header1 none) in-para (close-block) 
            "2" (open-block 'header2 none) in-para (close-block) 
            "3" (open-block 'header3 none) in-para (close-block) 
            "4" (open-block 'header4 none) in-para (close-block) 
            "5" (open-block 'header5 none) in-para (close-block) 
            "6" (open-block 'header6 none) in-para (close-block) 
            "1'" "1&#146;" (open-block 'header1* none) in-para (close-block) 
            "2'" "2&#146;" (open-block 'header2* none) in-para (close-block) 
            "3'" "3&#146;" (open-block 'header3* none) in-para (close-block) 
            "*" "**" (open-block 'bullets none) continue in-ulist (close-block) 
            "#" "##" (open-block 'enum none) continue in-olist (close-block) 
            "o" "x" (open-block 'checks none) continue in-checklist (close-block) 
            ">" (open-block 'para compose [indent: (opts)]) in-para (close-block) 
            "::" (open-block 'para [indent: 3]) in-para (close-block) 
            ":" (open-block 'definitions none) continue in-dlist (close-block) 
            "box" (open-block 'box merge-style/copy default-box opts) in-box (close-block) 
            "toc" (open-block 'section opts open-block 'toc none) in-toc (close-block) 
            "table" (open-table opts) in-table (close-block) 
            "c" (open-block 'para [text-halign: center]) in-para (close-block) 
            "center" (open-block 'center none) in-center (close-block) 
            "l" (open-block 'para [text-halign: left]) in-para (close-block) 
            "left" (open-block 'left none) in-left (close-block) 
            "r" (open-block 'para [text-halign: right]) in-para (close-block) 
            "right" (open-block 'right none) in-right (close-block) 
            "j" (open-block 'para [text-halign: justify]) in-para (close-block) 
            "justify" (open-block 'justify none) in-just (close-block) 
            "example" "html" "rebol" "makedoc" (emit [reduce ['escape cmd opts]]) 
            "csv" (handle-csv opts) 
            "repeat" (open-block 'repeat any [opts default-repeat]) in-repeat (close-block) 
            "center." continue rewind? in-center 
            "left." continue rewind? in-left 
            "right." continue rewind? in-right 
            "justify." continue rewind? in-just 
            "box." continue rewind? in-box 
            "table." continue rewind? in-table
        ] 
        in-center: inherit in-block [
            "center." override after-para return
        ] 
        in-left: inherit in-block [
            "left." override after-para return
        ] 
        in-right: inherit in-block [
            "right." override after-para return
        ] 
        in-just: inherit in-block [
            "justify." override after-para return
        ] 
        in-repeat: inherit in-block [
            "repeat." override after-para return
        ] 
        in-para: inherit common [
            text: whitespace: (emit opts) 
            "^/" override after-para return 
            "b" (open-block 'bold none) in-bold (close-block) 
            "i" (open-block 'italic none) in-italic (close-block) 
            "s" (open-block 'strike none) in-strike (close-block) 
            "" (emit [reduce ['qlink opts]]) 
            "link" (open-block 'link-proto opts) in-link (close-block) 
            "f" (open-block 'font opts) in-font (close-block) 
            "image" (
                if opts [
                    opts: merge-style/copy default-image opts 
                    if opts/src [opts/src: process-image-url opts/src] 
                    emit [reduce ['image 'opts make-style opts]]
                ]
            ) 
            "anchor" (open-block 'anchor opts if opts [insert/only insert tail anchors opts out]) in-anchor (close-block) 
            "data" (emit [reduce ['data make-style merge-style/copy default-data opts]]) 
            "repeat" (open-block 'repeat any [opts default-repeat]) in-repeat-inline (close-block)
        ] 
        in-repeat-inline: inherit in-para [
            "repeat." return
        ] 
        in-link: inherit in-para [
            "link." return
        ] 
        in-anchor: inherit in-para [
            "anchor." return
        ] 
        in-font: inherit in-para [
            "f." return
        ] 
        in-bold: inherit in-para [
            "b" in-bold 
            "b." return
        ] 
        in-italic: inherit in-para [
            "i" in-italic 
            "i." return
        ] 
        in-strike: inherit in-para [
            "s" in-strike 
            "s." return
        ] 
        in-underline: inherit in-para [
            "u" in-underline 
            "u." return
        ] 
        in-dlist: [
            ":" (open-block 'term none) in-para (close-block) 
            "::" (open-block 'desc none) in-para (close-block) 
            after-para: () 
            default: continue return
        ] 
        in-checklist: [
            "o" (open-block 'check compose [checked: (no)]) in-para (close-block) 
            "x" (open-block 'check compose [checked: (yes)]) in-para (close-block) 
            after-para: () 
            default: continue return
        ] 
        in-ulist: [
            "*" (open-block 'item if all [opts opts: attempt [to integer! opts]] [compose [type: (opts)]]) in-para (close-block) 
            "**" (open-block 'bullets none) continue in-ulist2 (close-block) 
            "##" (open-block 'enum none) continue in-olist2 (close-block) 
            after-para: () 
            default: continue return
        ] 
        in-olist: [
            "#" (open-block 'item if all [opts opts: attempt [to integer! opts]] [compose [force: (opts)]]) in-para (close-block) 
            "##" (open-block 'enum none) continue in-olist2 (close-block) 
            "**" (open-block 'bullets none) continue in-ulist2 (close-block) 
            after-para: () 
            default: continue return
        ] 
        in-ulist2: [
            "**" (open-block 'item if all [opts opts: attempt [to integer! opts]] [compose [type: (opts)]]) in-para (close-block) 
            after-para: () 
            default: continue return
        ] 
        in-olist2: [
            "##" (open-block 'item if all [opts opts: attempt [to integer! opts]] [compose [force: (opts)]]) in-para (close-block) 
            after-para: () 
            default: continue return
        ] 
        in-box: [
            "^/" after-para: box-contents 
            "" "link" "b" "i" "f" "s" "anchor" "data" "image" text: (open-block 'title none) continue in-para (close-block) 
            "box." override after-para return 
            default: continue box-contents
        ] 
        box-contents: inherit in-block [
            "box." continue return
        ] 
        in-toc: [
            "^/" (
                if default-toc-title [
                    open-block 'title none 
                    emit default-toc-title 
                    close-block
                ] 
                close-block
            ) in-toc2 
            after-para: (close-block) in-toc2 
            "" "link" "b" "i" "f" "s" "anchor" "data" "image" text: (open-block 'title none) continue in-para (close-block) 
            "toc." (close-block) override after-para return 
            default: (close-block) continue in-toc2
        ] 
        in-toc2: inherit in-block [
            "toc." override after-para 2 return
        ] 
        in-table: inherit common [
            "row" (emit ['row opts]) 
            "column" (emit ['column opts]) 
            "row." "column." (emit 'return) 
            "cell" (open-block/only 'cell opts) in-cell-block (close-block) 
            "table." return 
            "span" (emit ['span opts]) 
            default: (open-block 'cell none) continue in-cell (close-block) 
            "repeat" (open-block 'repeat any [opts default-repeat]) in-table-repeat (close-block)
        ] 
        in-cell-block: inherit in-block [
            "cell." return
        ] 
        in-cell: inherit in-block [
            "*" (
                open-block 'bullets none 
                open-block 'item if all [opts opts: attempt [to integer! opts]] [compose [type: (opts)]]
            ) in-para (close-block close-block) 
            "**" (
                open-block 'bullets none 
                open-block 'bullets none 
                open-block 'item if all [opts opts: attempt [to integer! opts]] [compose [type: (opts)]]
            ) in-para (close-block close-block close-block) 
            "#" (
                open-block 'enum none 
                open-block 'item if all [opts opts: attempt [to integer! opts]] [compose [force: (opts)]]
            ) in-para (close-block close-block) 
            "##" (
                open-block 'enum none 
                open-block 'enum none 
                open-block 'item if all [opts opts: attempt [to integer! opts]] [compose [force: (opts)]]
            ) in-para (close-block close-block close-block) 
            "::" (open-block 'para [indent: 2]) in-para (close-block) 
            ":" (open-block 'definitions none) override define in-cell-dlist (close-block) 
            "o" (open-block 'checks none open-block 'check no) in-para (close-block close-block) 
            "x" (open-block 'checks none open-block 'check yes) in-para (close-block close-block) 
            after-para: "^/" return
        ] 
        in-table-repeat: inherit in-table [
            "repeat." return
        ] 
        in-cell-dlist: [
            define: (open-block 'term none) in-para (close-block) 
            "::" (open-block 'desc none) in-para (close-block) 
            after-para: () 
            default: continue 2 return
        ] 
        eval-qlink: func [target /local a] [
            either a: select anchors target [
                compose/deep [alink opts [target: (target)] (skip a 3)]
            ] [
                compose/deep [link opts [(a: process-link target)] (select a [text:])]
            ]
        ] 
        eval-link: func [target] [
            either find anchors target [
                compose/deep [alink opts [target: (target)]]
            ] [
                compose/deep [link opts [(process-link target)]]
            ]
        ] 
        eval-data: func [opts /local val p] [
            opts: construct/with opts context [name: none index: none] 
            val: eval-var opts/name 
            if not val [return []] 
            either object? val [
                p: in pickers val/type 
                if p [
                    do get in get p type?/word opts/index val opts/index
                ]
            ] [
                reduce [val]
            ]
        ] 
        pickers: context [
            csv: context [
                none!: func [val index] [
                    "Not yet."
                ] 
                integer!: func [val index] [
                    csv-row/none! context [content: pick val/contents index] none
                ] 
                pair!: func [val index] [
                    pick pick val/contents index/y index/x
                ]
            ] 
            table: context [
                none!: func [val index] [
                    "Not yet."
                ] 
                integer!: func [val index] [
                    "Not yet."
                ] 
                pair!: func [val index] [
                    val: pick get in pick val/table index/y 'contents index/x 
                    if val/type = 'span [val: val/reference] 
                    cell/none! val none
                ]
            ] 
            table-proto: context [
                none!: integer!: pair!: func [val index] [
                    rewrite val/contents rewrite-rules 
                    eval-data compose [name: (val/name) index: (index)]
                ]
            ] 
            alias: context [
                none!: integer!: pair!: func [val index] [
                    eval-data compose [name: (val/dest) index: (index)]
                ]
            ] 
            cell: context [
                none!: integer!: pair!: func [val index] [
                    compose/deep [[
                            cell-if (either val/style ['opts] [[]]) (either val/style [reduce [make-style/ignore val/style [position]]] [[]]) (either val/spansize ['span] [[]]) (any [val/spansize []]) (val/out)
                        ]]
                ]
            ] 
            csv-row: context [
                none!: func [val index] [
                    either empty? val/content [[]] [
                        index: make block! 3 * length? val/content 
                        insert index first val/content 
                        foreach cell next val/content [
                            insert insert tail index " " cell
                        ] 
                        index
                    ]
                ] 
                integer!: func [val index] [
                    pick val/content index
                ] 
                pair!: func [val index] [
                    pick val/content index/x
                ]
            ] 
            table-row: none
        ] 
        eval-var: func [var] [
            if var: any [select/skip last local-vars var 2 select/skip vars var 2] [first var]
        ] 
        local-vars: [[]] 
        eval-repeat: func [spec body /local result var1 var2 val val2 val3 iter] [
            result: make block! 16 
            parse spec [
                integer! end (loop spec/1 [insert tail result copy/deep body]) 
                | 
                set var1 [word! | string! | into [some [word! | string!]]] opt 'in set var2 [word! | string!] end (
                    if val: eval-var form var2 [
                        insert/only tail local-vars local: copy last local-vars 
                        local: tail local 
                        if object? val [
                            iter: in iterators val/type 
                            if iter [iter: get iter iter/iterate val local var1 result body]
                        ] 
                        remove back tail local-vars
                    ]
                ) 
                | 
                set var1 [word! | string!] 
                opt 'from set val skip 
                opt 'to set val2 skip [['by | 'skip | 'step | none] set val3 skip | (val3: none)] end (
                    attempt [
                        insert/only tail local-vars local: copy last local-vars 
                        local: tail local 
                        for i val val2 any [val3 either val > val2 [-1] [1]] [
                            clear local 
                            insert insert tail local form var1 form i 
                            insert tail result rewrite copy/deep body rewrite-rules
                        ] 
                        remove back tail local-vars
                    ]
                )
            ] 
            result
        ] 
        iterators: context [
            csv: context [
                iterate: func [val locals var result body /local bind-var] [
                    bind-var: get in binders either block? var ['multi] ['single] 
                    foreach row val/contents [
                        clear locals 
                        bind-var locals var row 
                        insert tail result rewrite copy/deep body rewrite-rules
                    ]
                ] 
                binders: context [
                    single: func [local var row] [
                        insert insert tail local form var context [type: 'csv-row content: row]
                    ] 
                    multi: func [local vars row] [
                        foreach var vars [
                            insert insert tail local form var row/1 
                            row: next row
                        ]
                    ]
                ]
            ] 
            table: context [
                iterate: func [table locals var result body /local bind-var rows] [
                    bind-var: get in binders either block? var ['multi] ['single] 
                    rows: table/table 
                    if not all [table/style any [table/style/headerless table/style/vertical]] [rows: next rows] 
                    foreach row rows [
                        clear locals 
                        bind-var locals var row 
                        insert tail result rewrite copy/deep body rewrite-rules
                    ]
                ] 
                binders: context [
                    single: func [local var row] [
                        insert insert tail local form var make row [type: 'table-row]
                    ] 
                    multi: func [locals vars row /local i cell] [
                        i: 1 
                        foreach var vars [
                            cell: pick row/contents i 
                            if cell/type = 'span [cell: cell/reference] 
                            insert insert tail locals form var cell 
                            i: i + 1
                        ]
                    ]
                ]
            ] 
            table-proto: context [
                iterate: func [tablep local var result body] [
                    rewrite tablep/contents rewrite-rules 
                    table/iterate eval-var tablep/name local var result body
                ]
            ] 
            alias: context [
                iterate: func [alias locals var result body /local iter] [
                    alias: eval-var alias/dest 
                    iter: in iterators alias/type 
                    if iter [
                        iter/iterate alias locals var result body
                    ]
                ]
            ]
        ]
    ] 
    out: [] 
    init-stage3: does [
        clear out 
        clear stage3-ctx/blocks 
        clear stage3-ctx/vars 
        clear stage3-ctx/anchors 
        stage3-ctx/local-vars: copy [[]] 
        stage3-ctx/csvid: stage3-ctx/tabid: 1 
        insert out 'qml 
        stage3-fsm/init stage3-ctx/initial
    ] 
    end-stage3: does [
        stage3-fsm/end 
        rewrite out rewrite-rules 
        make-toc out 
        set-enum-counts out 
        out
    ] 
    merge-style: func [old new /copy /local val] [
        if object? new [
            either object? old [
                if copy [old: make old []] 
                foreach word next first new [
                    if val: get in new word [
                        set in old word val
                    ]
                ]
            ] [
                old: new
            ]
        ] 
        old
    ] 
    rewrite-rules: use [x y z] [[['table-proto ['opts set x skip | (x: none)] y: to end] [(stage3-ctx/generate-table x y)] [into ['hidden-table]] [] [into ['repeat 'opts set x block! into ['enum y: to end]]] [[enum [repeat opts [(x)] (y)]]] [into ['repeat 'opts set x block! into ['bullets y: to end]]] [[bullets [repeat opts [(x)] (y)]]] [into ['repeat 'opts set x block! y: to end]] [(stage3-ctx/eval-repeat x y)] [into ['data none!]] [] [into ['data set x block!]] [(stage3-ctx/eval-data x)] [into ['qlink none!]] [] ['qlink set x string!] [(stage3-ctx/eval-qlink x)] ['link-proto 'opts set x url!] [link opts [target: (x)]] ['link-proto 'opts set x string!] [(stage3-ctx/eval-link x)] ['anchor 'opts set x string!] [anchor opts [name: (x)]] [y: into ['cell-if opt ['opts skip] opt ['span skip] opt ['header] x: to end]] [(either 'row = first head y [y/1/1: 'cell copy/part y 1] [x])] [into [x: 'para 'opts set z block! any [y: into [block-level to end] :y break | skip] into [block-level to end] to end]] [[(copy/part x y)] (copy/part y 1) [para opts [(z)] (next y)]] [into [x: 'para any [y: into [block-level to end] :y break | skip] into [block-level to end] to end]] [[(copy/part x y)] (copy/part y 1) [para (next y)]] [y: ['para | 'item] opt ['opts skip] any [z: into ['para to end] :z break | skip] into ['para to end] to end] [(
                    rewrite copy y [[into ['para 'opts set x block! y: to end]] [[font opts [(x)] (y)]] [into ['para opt ['opts skip] y: to end]] [(y)]]
                )] ['box ['opts set x block! | (x: [])] into ['title y: to end] end] [box opts [(x)] [para (y)]] [into ['bold]] [] [into ['italic]] [] [into ['strike]] [] [into ['font opt ['opts skip]]] [] [into ['font x: [block! | string!] to end]] [(x)] ['font 'opts set x block! into ['bold y: to end] end] [font opts [(x) bold: (true)] (y)] ['font 'opts set x block! into ['italic y: to end] end] [font opts [(x) italic: (true)] (y)] ['bold into ['font 'opts set x block! y: to end] end] [font opts [(x) bold: (true)] (y)] ['italic into ['font 'opts set x block! y: to end] end] [font opts [(x) italic: (true)] (y)] ['link 'opts set x block! into ['font 'opts set y block! z: to end] end] [link opts [(x) (y)] (z)] ['alink 'opts set x block! into ['font 'opts set y block! z: to end] end] [alink opts [(x) (y)] (z)] ['anchor 'opts set x block! into ['font 'opts set y block! z: to end] end] [anchor opts [(x) (y)] (z)] ['para ['opts set x block! | (x: [])] into ['font 'opts set y block! z: to end] end] [para opts [(x) (y)] (z)] ['header1 ['opts set x block! | (x: [])] into ['font 'opts set y block! z: to end] end] [header1 opts [(x) (y)] (z)] ['header1* ['opts set x block! | (x: [])] into ['font 'opts set y block! z: to end] end] [header1* opts [(x) (y)] (z)] ['header2 ['opts set x block! | (x: [])] into ['font 'opts set y block! z: to end] end] [header2 opts [(x) (y)] (z)] ['header2* ['opts set x block! | (x: [])] into ['font 'opts set y block! z: to end] end] [header2* opts [(x) (y)] (z)] ['header3 ['opts set x block! | (x: [])] into ['font 'opts set y block! z: to end] end] [header3 opts [(x) (y)] (z)] ['header3* ['opts set x block! | (x: [])] into ['font 'opts set y block! z: to end] end] [header3* opts [(x) (y)] (z)] ['header4 ['opts set x block! | (x: [])] into ['font 'opts set y block! z: to end] end] [header4 opts [(x) (y)] (z)] ['header5 ['opts set x block! | (x: [])] into ['font 'opts set y block! z: to end] end] [header5 opts [(x) (y)] (z)] ['header6 ['opts set x block! | (x: [])] into ['font 'opts set y block! z: to end] end] [header6 opts [(x) (y)] (z)] ['item ['opts set x block! | (x: [])] into ['font 'opts set y block! z: to end] end] [item opts [(x) (y)] (z)] ['check ['opts set x block! | (x: [])] into ['font 'opts set y block! z: to end] end] [check opts [(x) (y)] (z)] ['term ['opts set x block! | (x: [])] into ['font 'opts set y block! z: to end] end] [term opts [(x) (y)] (z)] ['desc ['opts set x block! | (x: [])] into ['font 'opts set y block! z: to end] end] [desc opts [(x) (y)] (z)] ['title ['opts set x block! | (x: [])] into ['font 'opts set y block! z: to end] end] [title opts [(x) (y)] (z)]]] 
    block-level: [
        'hrule | 'header1 | 'header2 | 'header3 | 'header4 | 'header5 | 
        'header6 | 'bullets | 'enum | 'checks | 'definitions | 'box | 
        'table | 'center | 'left | 'right | 'justify | 'escape | 'header1* | 
        'header2* | 'header3*
    ] 
    numbering: context [
        toc-counters: [0 0 0 0 0 0] 
        toc-style: ["1. " "1[.1] "] 
        chars: complement charset "1AaIi[]0" 
        make-number: func [level /local style i res mk1 mk2 rpt term cont] [
            if not toc-style [return ""] 
            i: 1 
            style: any [pick toc-style level last toc-style] 
            res: make string! 16 
            poke toc-counters level 1 + pick toc-counters level 
            change/dup skip toc-counters level 0 subtract length? toc-counters level 
            term: [
                mk1: any chars mk2: (insert/part tail res mk1 mk2) [
                    "1" (insert tail res pick toc-counters i) 
                    | 
                    "A" (insert tail res pick "ABCDEFGHIJKLMNOPQRSTUVWXYZ" min 26 pick toc-counters i) 
                    | 
                    "a" (insert tail res pick "abcdefghijklmnopqrstuvwxyz" min 26 pick toc-counters i) 
                    | 
                    "I" (insert tail res uppercase to-roman pick toc-counters i) 
                    | 
                    "i" (insert tail res to-roman pick toc-counters i) 
                    | 
                    "0"
                ] 
                mk1: any chars mk2: (insert/part tail res mk1 mk2) (i: i + 1 cont: either i > level ['break] [[]]) cont
            ] 
            parse/all/case style [
                some [rpt: "[" some term "]" (cont: either i > level ['break] [[:rpt]]) cont | term] 
                rpt: (insert tail res rpt)
            ] 
            res
        ] 
        romans: [["" "i" "ii" "iii" "iv" "v" "vi" "vii" "viii" "ix"] ["" "x" "xx" "xxx" "xl" "l" "lx" "lxx" "lxxx" "xc"] ["" "c" "cc" "ccc" "cd" "d" "dc" "dcc" "dccc" "cm"]] 
        to-roman: func [int /local res] [
            int: form int 
            res: make string! 16 
            forall int [
                insert tail res pick pick romans length? int int/1 - #"/"
            ] 
            res
        ] 
        set-style: func [style] [
            style: any [style default-number-style] 
            if none? style [toc-style: none exit] 
            if not toc-style: select/case [
                "1" ["1. " "1[.1] "] 
                "A" ["A. " "A[.1] "] 
                "a" ["a) " "a1) " "a1[.1]) "] 
                "I" ["I. " "I[.1] "] 
                "i" ["i) " "i[.1]) "]
            ] style [
                toc-style: normalize parse/all style "|"
            ]
        ] 
        reset: does [change/dup toc-counters 0 6] 
        normalize: func [style /local count] [
            insert/dup tail style last style 6 - length? style 
            style: copy/deep style 
            repeat level 6 [
                if not empty? style/:level [
                    count: 0 
                    parse/all/case style/:level [
                        some [
                            any chars [["1" | "A" | "a" | "I" | "i" | "0"] (count: count + 1) 
                                | ["[" | "]"] (count: 6)
                            ] any chars
                        ]
                    ] 
                    insert/dup style/:level #"0" level - count
                ]
            ] 
            style
        ]
    ] 
    collect: func [output doc rule /local node] [
        match doc [set node into rule (append/only output copy/deep node)] 
        output
    ] 
    mkopts: func [level id] [compose [number: (numbering/make-number level) id: (id)]] 
    make-toc: func [doc /local style toc here l headid] [
        headid: 1 
        match doc [
            'section [here: 'opts set style string! (remove/part here 2) :here | (style: none)] (numbering/set-style style) 
            into ['toc toc: to end] here: to end (
                numbering/reset 
                collect toc here [['header1 (l: 1) | 'header2 (l: 2) | 'header3 (l: 3)] [
                        'opts set here block! (append here mkopts l headid headid: headid + 1) 
                        | 
                        here: (here: insert/only insert here 'opts mkopts l headid headid: headid + 1) :here
                    ] 
                    to end 
                    | ['header4 (l: 4) | 'header5 (l: 5) | 'header6 (l: 6)] [
                        'opts set here block! (insert insert tail here [number:] numbering/make-number l) 
                        | 
                        here: (here: insert/only insert here 'opts compose [number: (numbering/make-number l)]) :here
                    ] 
                    end skip
                ] 
                rewrite toc [[into ['anchor opt ['opts skip] here: to end]] [(here)]]
            )
        ]
    ] 
    count: func [counter options] [
        if block? options [
            options: construct options 
            if all [in options 'force integer? options: attempt [to integer! options/force]] [set counter options]
        ] 
        options: get counter 
        set counter 1 + options 
        options
    ] 
    set-enum-counts: func [doc /local count1 count2 opts] [
        count1: count2: 1 
        match doc [
            'enum some [
                into [
                    'item [
                        'opts set opts block! (insert insert tail opts [number:] count 'count1 opts) 
                        | 
                        opts: (opts: insert/only insert opts 'opts compose [number: (count 'count1 opts)]) :opts
                    ] (count2: 1) to end 
                    | 
                    'enum some [
                        into [
                            'item [
                                'opts set opts block! (insert insert tail opts [number:] count 'count2 opts) 
                                | 
                                opts: (opts: insert/only insert opts 'opts compose [number: (count 'count2 opts)]) :opts
                            ] to end
                        ] 
                        | 
                        skip
                    ]
                ] 
                | 
                skip
            ]
        ]
    ] 
    process-link: func [target] [
        either parse/all target [["http://" | "mailto:" | "ftp://" | "www."] to end] [
            compose [target: (target) class: "external" text: (target)]
        ] [
            compose [target: (join http://www.qtask.com/qwiki.cgi?goto= target) class: "internal" text: (target)]
        ]
    ] 
    process-image-url: func [url] [
        url
    ] 
    build-search-index: func [doc [block!] /local rule result val anchor] [
        result: copy/deep [toa [] doc-start ""] 
        rule: [
            into [[
                    'para | 'header4 | 'header5 | 'header6 | 'bullets | 'enum | 'checks | 
                    'definitions | 'box | 'section | 'center | 'left | 'right | 'justify | 
                    'item | 'check | 'term | 'desc | 'header1* | 'header2* | 'header3*
                ] opt ['opts skip] any rule (insert tail last result newline) 
                | 
                val: ['header1 | 'header2 | 'header3] opt ['opts skip] (insert insert/only tail result val make string! 256) 
                any rule (insert tail last result newline) 
                | 
                'escape string! set val string! (insert insert tail last result val newline) 
                | 
                'table opt ['opts skip] opt [into ['columns to end]] any [
                    into [
                        'row opt ['opts skip] opt 'header any [
                            into ['cell opt ['opts skip] opt ['span skip] opt 'header any rule (insert tail last result " ")]
                        ] (insert tail last result newline)
                    ]
                ] 
                | ['bold | 'italic | 'strike | 'link | 'alink | 'font] opt ['opts skip] any rule 
                | 
                anchor: 'anchor opt [
                    'opts set val block! (
                        if val: select val [name:] [
                            insert/only insert/only insert tail result/2 val anchor pick tail result -2
                        ]
                    )
                ] any rule
            ] 
            | 
            set val string! (insert tail last result val) 
            | 
            skip
        ] 
        parse doc ['qml any rule] 
        result
    ] 
    search: func [
        "Search a QML document tree for a substring" 
        doc [block!] "The QML document tree (as returned by SCAN-DOC)" 
        text [string!] "The substring to search for" 
        /local 
        res anchor
    ] [
        res: make block! 16 
        doc: build-search-index doc 
        if anchor: find doc/2 text [
            insert/only insert/only res anchor/3 anchor/2
        ] 
        foreach [header string] skip doc 2 [
            while [string: find/tail string text] [
                insert insert/only tail res header copy/part skip string -50 120
            ]
        ] 
        res
    ] 
    scan-doc: func [
        {Parse a QML text string and return a QML document tree} 
        text [string!] 
        /with defaults [block!] "Default options for commands" 
        /keep {Keep default options from previous session (ignores /with)}
    ] [
        init-stage2 
        init-stage3 
        if not keep [set-defaults defaults] 
        parse-qml text if defaults [select defaults "alias"] 
        end-stage2 
        end-stage3
    ]
]