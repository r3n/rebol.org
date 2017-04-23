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

    Title: "Qtask Markup Language - XHTML emitter"
    File: %xhtml-emitter.r
    Purpose: {
        This program implements a QML to XHTML converter. The input is a QML document tree
        (from the QML parser), and the output is XHTML text.
    }
    Author: "Gabriele Santilli"
    EMail: giesse@rebol.it
    License: {
        Copyright (c) 2006 Prolific Publishing, Inc.

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
    Date: 21-Aug-2006
    Version: 2.16.1
    History: [
        17-Feb-2006 1.1.0 "History start" 
        22-Feb-2006 1.2.0 {Fixed problem with closing block commands inside paragraphs} 
        13-Mar-2006 1.3.0 {Now assumes output from 2-pass scanner (simplified a lot of states)} 
        13-Mar-2006 1.4.0 "Added handling for default argument name" 
        14-Mar-2006 1.5.0 "Changed =TOC" 
        15-Mar-2006 1.6.0 "Minor change to =example" 
        15-Mar-2006 1.7.0 "Changed default handling for =image" 
        17-Mar-2006 1.8.0 "New handling of newlines" 
        18-Mar-2006 1.9.0 {Numbered items are now numbered sequentially regardless of where they happen} 
        18-Mar-2006 1.10.0 "Added TOC linking" 
        18-Mar-2006 1.11.0 {Cells are now replaced instead of appended to; row 1 defaults to header} 
        18-Mar-2006 1.12.0 "Added args handling for =row and =column" 
        18-Mar-2006 1.13.0 "Changed box options" 
        18-Mar-2006 1.14.0 "Added =’ as comment, changed =1* to =1' etc." 
        18-Mar-2006 1.15.0 "Now =link does internal (Qwiki) links too" 
        18-Mar-2006 1.16.0 "Fixed a bug in table nesting" 
        20-Mar-2006 1.17.0 "Changed lists inside tables" 
        21-Mar-2006 1.18.0 "Changed =box, image is now aligned instead of text" 
        23-Mar-2006 1.19.0 "Changed =cell handling" 
        24-Mar-2006 1.20.0 "All empty cells are now shown in tables" 
        27-Mar-2006 1.21.0 "Changed command arguments handling" 
        27-Mar-2006 1.22.0 "Removed comment handling" 
        29-Mar-2006 1.23.0 {Minor changes to options handling, also now =box[float boxleft] is possible} 
        29-Mar-2006 1.24.0 {=cell, =row and =column can overwrite a previous one and merge the style} 
        29-Mar-2006 1.25.0 "Split =c and =center into two separate commands" 
        29-Mar-2006 1.26.0 "Newline eating moved to scanner" 
        30-Mar-2006 1.27.1 "Added position to table" 
        30-Mar-2006 1.28.1 "Added =left, =right, =l, =r" 
        30-Mar-2006 1.29.1 "Added =span and support for it in table handling" 
        1-Apr-2006 1.30.1 "Added =justify and =j" 
        5-Apr-2006 1.31.1 "Now =span moves the cursor" 
        5-Apr-2006 1.32.1 "No more &nbsp; in tables by default" 
        5-Apr-2006 1.33.1 "Added rounded and shadow to table" 
        5-Apr-2006 1.34.1 "Fixed =span=cell case" 
        5-Apr-2006 1.35.1 "Now =span breaks up previous overlapping spans" 
        5-Apr-2006 1.36.1 "Another fix for =span=cell and fixed =span=span" 
        5-Apr-2006 1.37.1 {Allows any arg order for =span, also fixes breaking span to single cells} 
        6-Apr-2006 1.38.1 {Fixed a few table bugs, improved handling of overlapping spans style} 
        6-Apr-2006 1.39.1 "Implemented style inheritance in table" 
        6-Apr-2006 1.40.1 "Fixed =span=column and =span=row bug" 
        6-Apr-2006 1.41.1 "Fixed bug in end-table" 
        13-Apr-2006 1.42.1 "Fixed a bug with money! (width/height in percents)" 
        18-Apr-2006 1.43.1 "Added default options for commands" 
        18-Apr-2006 1.44.1 "Added section numbering" 
        18-Apr-2006 1.45.1 "Added checklists" 
        21-Apr-2006 1.46.1 "Added =s and =u" 
        21-Apr-2006 1.47.1 "Changed =toc output" 
        21-Apr-2006 1.48.1 "Added support for =toc font style" 
        21-Apr-2006 1.49.1 "Added support for header numbers font style" 
        21-Apr-2006 1.50.1 "Fixed a bug with =box in =table" 
        22-Apr-2006 1.51.1 {Fixed a bug with unintentionally altering the default-* objects (added /copy to merge-style)} 
        22-Apr-2006 1.52.1 "Added =font[space]" 
        22-Apr-2006 1.53.1 {Added many changes from Ammon for better Qtask integration} 
        22-Apr-2006 1.54.1 "Added non-css color names" 
        24-Apr-2006 1.55.1 "Added =column. and =row." 
        24-Apr-2006 1.56.1 "New =image (now inline)" 
        24-Apr-2006 1.57.1 {Added =4, =5 and =6, changed numbering to support them} 
        27-Apr-2006 1.58.1 "Added initial support for =anchor" 
        28-Apr-2006 1.59.1 "Finished =anchor support" 
        28-Apr-2006 1.60.1 "=: now emits a table" 
        28-Apr-2006 1.61.1 {If a =box has only the header, then it is not a header} 
        16-May-2006 2.1.0 "Rewriting from scratch, for the new parser" 
        17-May-2006 2.2.0 "Added emitting unknown commands as text" 
        18-May-2006 2.3.0 "Initial toc support" 
        19-May-2006 2.4.0 "Finished toc, added 'alink" 
        19-May-2006 2.5.0 "Options support for bullets and enums" 
        20-May-2006 2.6.0 "Added options rendering for all nodes" 
        24-May-2006 2.7.0 "Fixed header styling" 
        25-May-2006 2.8.0 "Support for =table[space]" 
        25-May-2006 2.9.1 "Fixed =>" 
        29-May-2006 2.10.1 "Added boxes" 
        7-Jun-2006 2.11.1 "Fixed make-style with empty opts" 
        16-Jun-2006 2.12.1 "Changed options for =image" 
        16-Jun-2006 2.13.1 "Links now emit a class too" 
        29-Jun-2006 2.14.1 "Fixed crash with options* being none in some cases" 
        21-Jul-2006 2.15.1 "Fixed bug with =table[borderless]" 
        21-Aug-2006 2.16.1 "First public release (with rel. 2.0i of QML)"
    ]
]

xhtml-emitter: context [
    out: none 
    qml-rule: ['qml some block-level] 
    block-level: [
        into [
            'para opts (emit ["<p" options ">"]) [some inline-level | (emit "&nbsp;")] (emit </p>) 
            | 
            'hrule to end (emit <hr />) 
            | ['header1 | 'header1*] opts (emit-header 1 options options*) any inline-level (emit </h1>) 
            | ['header2 | 'header2*] opts (emit-header 2 options options*) any inline-level (emit </h2>) 
            | ['header3 | 'header3*] opts (emit-header 3 options options*) any inline-level (emit </h3>) 
            | 
            'header4 opts (emit-header 4 options options*) any inline-level (emit </h4>) 
            | 
            'header5 opts (emit-header 5 options options*) any inline-level (emit </h5>) 
            | 
            'header6 opts (emit-header 6 options options*) any inline-level (emit </h6>) 
            | 
            'bullets (emit <ul>) any bullets (emit </ul>) 
            | 
            'enum (emit <ol>) any enum-items (emit </ol>) 
            | 
            'checks (emit <ul class="checks">) any checks (emit </ul>) 
            | 
            'definitions (emit {<table class="dlist"><tbody>}) any definitions (emit "</tbody></table>") 
            | 
            'box opts val: to end (emit-box options* options val) 
            | 
            'section opt [
                into [
                    'toc (emit <div class="toc">) 
                    opt [into ['title opts (emit ["<h1" options ">"]) any inline-level (emit </h1>)]] (emit <ul>) 
                    any toc-headers (emit "</ul></div>")
                ]
            ] any block-level 
            | 
            'table opts (emit ["<table" options ">"]) table-rule (emit </table>) 
            | 
            'center opts (emit [{<div style="text-align: center;"} options ">"]) any block-level (emit </div>) 
            | 
            'left opts (emit [{<div style="text-align: left;"} options ">"]) any block-level (emit </div>) 
            | 
            'right opts (emit [{<div style="text-align: right;"} options ">"]) any block-level (emit </div>) 
            | 
            'justify opts (emit [{<div style="text-align: justify;"} options ">"]) any block-level (emit </div>) 
            | 
            'escape (emit "<pre>^/") string! set val string! (emit [escape-html val </pre>]) to end 
            | 
            'command copy val [string! skip] (emit [<p> "=" escape-html val/1] if val/2 [emit ["[" escape-html mold/only val/2 "]"]] emit </p>)
        ] 
        | 
        error
    ] 
    emit: func [value] [
        repend out value
    ] 
    val: none 
    emit-header: func [level style opts] [
        emit ["<h" level style] 
        if in opts 'id [emit [{ id="header-} opts/id {"}]] 
        emit ">" 
        if in opts 'number [emit escape-html copy opts/number]
    ] 
    opts: [
        'opts set val block! (options: make-style val) | (options: "" options*: context [])
    ] 
    options: none 
    options*: none 
    make-style: func [opts /only /local res] [
        if empty? opts [options*: context [] return ""] 
        either only [
            opts: construct opts
        ] [
            opts: options*: make construct/with opts context [
                outline-color: outline-style: image-halign: image-valign: float: position: none
            ] [
                outline-color: any [outline-color if outline-style [/black]] 
                outline-style: any [outline-style if outline-color ['solid]] 
                if outline-style = 'rounded [outline-color: none] 
                image-halign: any [image-halign if image-valign ['left]] 
                image-valign: any [image-valign if image-halign ['top]] 
                if float [
                    float: either position = 'left ['left] ['right] 
                    position: none
                ]
            ]
        ] 
        res: append make string! 128 { style="} 
        bind opts-to-css in opts 'self 
        foreach [word css] opts-to-css [
            if all [word: in opts word word: get word] [
                append res switch type?/word :css [
                    block! [rejoin css] 
                    paren! [do css] 
                    string! [css]
                ]
            ]
        ] 
        append res {"} 
        either res = { style=""} [""] [res]
    ] 
    opts-to-css: [
        background ["background-color: " to-css-color background ";"] 
        bold "font-weight: bold;" 
        color ["color: " to-css-color color ";"] 
        float ["float: " float ";"] 
        fontsize ["font-size: " fontsize "pt;"] 
        height ["height: " either money? height [to integer! second height] [height] either money? height ["%"] ["px"] ";"] 
        image ["background-image: url('" escape-html replace/all image "'" "" "');"] 
        image-halign ["background-position: " image-valign " " image-halign ";"] 
        image-tiling [
            "background-repeat: " select [
                both "repeat" vertical "repeat-y" horizontal "repeat-x" neither "no-repeat"
            ] image-tiling ";"
        ] 
        indent ["margin-left: " 48 * indent "pt;"] 
        italic "font-style: italic;" 
        outline-color (
            either outline-style = 'borderless [
                "border: none;"
            ] [
                rejoin ["border: " outline-style " thin " to-css-color outline-color ";"]
            ]
        ) 
        position (select [
                center {margin-left: auto;margin-right: auto;display: table;} 
                left "margin-right: auto;display: table;" 
                right "margin-left: auto;display: table;"
            ] position) 
        space ["padding: 0 " either logic? space ["1ex;"] [rejoin [space "px;"]]] 
        text-halign ["text-align: " text-halign ";"] 
        text-valign ["vertical-align: " text-valign ";"] 
        typeface ["font-family: " to-fontface typeface ";"] 
        width ["width: " either money? width [to integer! second width] [width] either money? width ["%"] ["px"] ";"]
    ] 
    non-css-colors: [
        /AliceBlue "#F0F8FF" /AntiqueWhite "#FAEBD7" /Aquamarine "#7FFFD4" 
        /Azure "#F0FFFF" /Beige "#F5F5DC" /Bisque "#FFE4C4" 
        /BlanchedAlmond "#FFEBCD" /BlueViolet "#8A2BE2" /Brown "#A52A2A" 
        /BurlyWood "#DEB887" /CadetBlue "#5F9EA0" /Chartreuse "#7FFF00" 
        /Chocolate "#D2691E" /Coral "#FF7F50" /CornflowerBlue "#6495ED" 
        /Cornsilk "#FFF8DC" /Crimson "#DC143C" /Cyan "#00FFFF" 
        /DarkBlue "#00008B" /DarkCyan "#008B8B" /DarkGoldenRod "#B8860B" 
        /DarkGray "#A9A9A9" /DarkGreen "#006400" /DarkKhaki "#BDB76B" 
        /DarkMagenta "#8B008B" /DarkOliveGreen "#556B2F" /Darkorange "#FF8C00" 
        /DarkOrchid "#9932CC" /DarkRed "#8B0000" /DarkSalmon "#E9967A" 
        /DarkSeaGreen "#8FBC8F" /DarkSlateBlue "#483D8B" /DarkSlateGray "#2F4F4F" 
        /DarkTurquoise "#00CED1" /DarkViolet "#9400D3" /DeepPink "#FF1493" 
        /DeepSkyBlue "#00BFFF" /DimGray "#696969" /DodgerBlue "#1E90FF" 
        /Feldspar "#D19275" /FireBrick "#B22222" /FloralWhite "#FFFAF0" 
        /ForestGreen "#228B22" /Gainsboro "#DCDCDC" /GhostWhite "#F8F8FF" 
        /Gold "#FFD700" /GoldenRod "#DAA520" /GreenYellow "#ADFF2F" 
        /HoneyDew "#F0FFF0" /HotPink "#FF69B4" /IndianRed "#CD5C5C" 
        /Indigo "#4B0082" /Ivory "#FFFFF0" /Khaki "#F0E68C" 
        /Lavender "#E6E6FA" /LavenderBlush "#FFF0F5" /LawnGreen "#7CFC00" 
        /LemonChiffon "#FFFACD" /LightBlue "#ADD8E6" /LightCoral "#F08080" 
        /LightCyan "#E0FFFF" /LightGoldenRodYellow "#FAFAD2" /LightGrey "#D3D3D3" 
        /LightGreen "#90EE90" /LightPink "#FFB6C1" /LightSalmon "#FFA07A" 
        /LightSeaGreen "#20B2AA" /LightSkyBlue "#87CEFA" /LightSlateBlue "#8470FF" 
        /LightSlateGray "#778899" /LightSteelBlue "#B0C4DE" /LightYellow "#FFFFE0" 
        /LimeGreen "#32CD32" /Linen "#FAF0E6" /Magenta "#FF00FF" 
        /MediumAquaMarine "#66CDAA" /MediumBlue "#0000CD" /MediumOrchid "#BA55D3" 
        /MediumPurple "#9370D8" /MediumSeaGreen "#3CB371" /MediumSlateBlue "#7B68EE" 
        /MediumSpringGreen "#00FA9A" /MediumTurquoise "#48D1CC" /MediumVioletRed "#C71585" 
        /MidnightBlue "#191970" /MintCream "#F5FFFA" /MistyRose "#FFE4E1" 
        /Moccasin "#FFE4B5" /NavajoWhite "#FFDEAD" /OldLace "#FDF5E6" 
        /OliveDrab "#6B8E23" /OrangeRed "#FF4500" /Orchid "#DA70D6" 
        /PaleGoldenRod "#EEE8AA" /PaleGreen "#98FB98" /PaleTurquoise "#AFEEEE" 
        /PaleVioletRed "#D87093" /PapayaWhip "#FFEFD5" /PeachPuff "#FFDAB9" 
        /Peru "#CD853F" /Pink "#FFC0CB" /Plum "#DDA0DD" 
        /PowderBlue "#B0E0E6" /RosyBrown "#BC8F8F" /RoyalBlue "#4169E1" 
        /SaddleBrown "#8B4513" /Salmon "#FA8072" /SandyBrown "#F4A460" 
        /SeaGreen "#2E8B57" /SeaShell "#FFF5EE" /Sienna "#A0522D" 
        /SkyBlue "#87CEEB" /SlateBlue "#6A5ACD" /SlateGray "#708090" 
        /Snow "#FFFAFA" /SpringGreen "#00FF7F" /SteelBlue "#4682B4" 
        /Tan "#D2B48C" /Thistle "#D8BFD8" /Tomato "#FF6347" 
        /Turquoise "#40E0D0" /Violet "#EE82EE" /VioletRed "#D02090" 
        /Wheat "#F5DEB3" /WhiteSmoke "#F5F5F5" /YellowGreen "#9ACD32"
    ] 
    to-css-color: func [val] [
        switch type?/word val [
            issue! [mold val] 
            refinement! [any [select non-css-colors val form val]] 
            tuple! [rejoin ["#" enbase/base to binary! val 16]]
        ]
    ] 
    to-fontface: func [val] [
        switch/default val [
            times ["Times New Roman, serif"] 
            helvetica ["Arial, Helvetica, sans-serif"] 
            courier ["Courier New, Courier, fixed"]
        ] [
            escape-html replace/all val ";" ""
        ]
    ] 
    box-rule: [
        opt [into ['title opts (emit ["<h2" options ">"]) any inline-level (emit </h2>)]] 
        any block-level
    ] 
    emit-rounded-box: func [box] [
        emit [
            {<table class="} either box/shadow? ["roundshadow"] ["rounded"] {"} box/outerstyle ">" 
            <tr> 
            <td class="topleft"> "&nbsp;" </td> 
            <td class="topleftplus"> "&nbsp;" </td> 
            <td class="top"> "&nbsp;" </td> 
            <td class="toprightminus"> "&nbsp;" </td> 
            <td class="topright"> "&nbsp;" </td> 
            </tr> <tr> 
            <td class="topleftminus"> "&nbsp;" </td> 
            <td> </td> <td> </td> <td> </td> 
            <td class="toprightplus"> "&nbsp;" </td> 
            </tr> <tr> 
            <td class="left"> "&nbsp;" </td> 
            <td> </td> 
            {<td class="box"} box/innerstyle ">"
        ] 
        parse box/contents box-rule 
        emit [
            </td> 
            <td> </td> 
            <td class="right"> "&nbsp;" </td> 
            </tr> <tr> 
            <td class="bottomleftplus"> "&nbsp;" </td> 
            <td> </td> <td> </td> <td> </td> 
            <td class="bottomrightminus"> "&nbsp;" </td> 
            </tr> <tr> 
            <td class="bottomleft"> "&nbsp;" </td> 
            <td class="bottomleftminus"> "&nbsp;" </td> 
            <td class="bottom"> "&nbsp;" </td> 
            <td class="bottomrightplus"> "&nbsp;" </td> 
            <td class="bottomright"> "&nbsp;" </td> 
            </tr> 
            </table>
        ]
    ] 
    emit-fw-rounded-box: func [box] [
        emit [
            <div class="boxouter"> 
            {<table class="} either box/shadow? ["roundshadow"] ["rounded"] {"} box/outerstyle100 ">" 
            <tr> <td class="topleft"> </td> <td class="top"> </td> <td class="topright"> </td> </tr> 
            <tr> <td class="left"> </td> {<td class="box"} box/innerstyle ">"
        ] 
        parse box/contents box-rule 
        emit [
            </td> <td class="right"> </td> </tr> 
            <tr> <td class="bottomleft"> </td> <td class="bottom"> </td> <td class="bottomright"> </td> </tr> 
            </table> </div>
        ]
    ] 
    emit-shadow-box: func [box] [
        emit [
            {<table class="shadow"} box/outerstyle ">" 
            <tr> <td class="topleft"> </td> <td class="top"> </td> <td class="topright"> </td> </tr> 
            <tr> <td class="left"> </td> {<td class="box"} box/innerstyle ">"
        ] 
        parse box/contents box-rule 
        emit [
            </td> <td class="right"> </td> </tr> 
            <tr> <td class="bottomleft"> </td> <td class="bottom"> </td> 
            <td class="bottomright"> </td> </tr> 
            </table>
        ]
    ] 
    emit-fw-shadow-box: func [box] [
        emit [
            {<div class="boxouter"><table class="shadow"} box/outerstyle100 ">" 
            <tr> <td class="topleft"> </td> <td class="top"> </td> <td class="topright"> </td> </tr> 
            <tr> <td class="left"> </td> {<td class="box"} box/innerstyle ">"
        ] 
        parse box/contents box-rule 
        emit [
            </td> <td class="right"> </td> </tr> 
            <tr> <td class="bottomleft"> </td> <td class="bottom"> </td> 
            <td class="bottomright"> </td> </tr> 
            </table> </div>
        ]
    ] 
    emit-generic-box: func [box] [
        emit [{<div class="box"} box/style ">"] 
        parse box/contents box-rule 
        emit </div>
    ] 
    emit-box: func [args style' contents' /local box] [
        args: make context [
            shadow: outline-style: width: position: float: none
        ] args 
        box: context [
            contents: contents' 
            style: style' 
            shadow?: found? args/shadow 
            innerstyle: make-style/only extract-only args [
                background image image-halign image-tiling color outline-color typeface fontsize 
                bold italic text-halign text-valign
            ] 
            outerstyle: make-style/only extract-only args [width height float background position] 
            outerstyle100: make-style/only extract-only make args [width: $100.00] [width height float background position]
        ] 
        if all [args/outline-style = 'rounded any [args/width args/position args/float]] [
            emit-rounded-box box 
            exit
        ] 
        if args/outline-style = 'rounded [
            emit-fw-rounded-box box 
            exit
        ] 
        if all [args/shadow any [args/width args/position args/float]] [
            emit-shadow-box box 
            exit
        ] 
        if args/shadow [
            emit-fw-shadow-box box 
            exit
        ] 
        emit-generic-box box
    ] 
    extract-only: func [object words /local res] [
        object: third object 
        res: make block! length? object 
        foreach [word value] object [
            if all [find words to word! word not none? :value] [
                insert/only insert tail res word :value
            ]
        ] 
        res
    ] 
    inline-level: [
        set val string! (emit escape-html val) 
        | 
        into [
            'bold (emit <strong>) any inline-level (emit </strong>) 
            | 
            'italic (emit <em>) any inline-level (emit </em>) 
            | 
            'strike (emit <s>) any inline-level (emit </s>) 
            | 
            'link opts (
                if in options* 'target [
                    emit [{<a href="} escape-html options*/target {"} options] 
                    if in options* 'class [
                        emit [{ class="} options*/class {"}] 
                        if options*/class = "external" [
                            emit { target="_blank"}
                        ]
                    ] 
                    emit ">"
                ]
            ) any inline-level (emit </a>) 
            | 
            'alink opts (
                if in options* 'target [
                    emit [{<a href="#} escape-html options*/target {"} options { class="internal">}]
                ]
            ) any inline-level (emit </a>) 
            | 
            'font opts (emit ["<span" options ">"]) any inline-level (emit </span>) 
            | 
            'image opts (if in options* 'src [emit [{<img src="} escape-html options*/src {"} options ">"]]) 
            | 
            'anchor opts (if in options* 'name [emit [{<a name="} escape-html options*/name {"} options ">"]]) any inline-level (emit </a>) 
            | 
            'command copy val [string! skip] (emit ["=" escape-html val/1] if val/2 [emit ["[" escape-html mold/only val/2 "]"]])
        ] 
        | 
        error
    ] 
    error: [here: skip (print ["error" copy/part trim/lines mold here 80])] 
    liclass: "" 
    bullets: [
        into [
            'item opts (
                if in options* 'type [
                    options: join options [{ type="} pick ["disc" "circle" "square"] options*/type {"}]
                ] 
                emit ["<li" liclass options "><p>"]
            ) any inline-level (emit </p>)
        ] [into ['bullets (emit <ul>) any bullets (emit </ul>)] | into ['enum (emit <ol>) any enum-items (emit </ol>)] | none] (emit </li>) 
        | 
        into ['bullets (liclass: { class="indented"}) any bullets (liclass: "")] 
        | 
        into ['enum (liclass: { class="indented"}) any enum-items (liclass: "")] 
        | 
        error
    ] 
    enum-items: [
        into ['item opts (emit [{<li value="} options*/number {"} liclass options "><p>"]) any inline-level (emit </p>)] [into ['bullets (emit <ul>) any bullets (emit </ul>)] | into ['enum (emit <ol>) any enum-items (emit </ol>)] | none] (emit </li>) 
        | 
        into ['bullets (liclass: { class="indented"}) any bullets (liclass: "")] 
        | 
        into ['enum (liclass: { class="indented"}) any enum-items (liclass: "")] 
        | 
        error
    ] 
    checks: [
        into [
            'check opts (emit [
                    "<li" options {><p><input type="checkbox" disabled="yes"} 
                    either options*/checked [{ checked="yes"}] [""] 
                    " /> "
                ]) any inline-level (emit "</p></li>")
        ] 
        | 
        error
    ] 
    definitions: [
        into ['term opts (emit ["<tr><th" options ">"]) any inline-level (emit </th>)] 
        any [into ['term opts (emit ["</tr><tr><th" options ">"]) any inline-level (emit </th>)]] 
        into ['desc opts (emit ["<td" options ">"]) any inline-level (emit "</td></tr>")] 
        any [into ['desc opts (emit ["<tr><td></td><td" options ">"]) any inline-level (emit "</td></tr>")]] 
        | 
        error
    ] 
    toc-headers: [
        into ['header1 opts (emit-toclink options options*) any inline-level (emit "</a></p>")] [
            val: into ['header2 to end | 'header3 to end] :val (emit <ul>) any toc-headers2 (emit "</ul></li>") 
            | (emit </li>)
        ] 
        | 
        val: into ['header2 to end | 'header3 to end] :val (emit "<li><ul>") any toc-headers2 (emit "</ul></li>")
    ] 
    toc-headers2: [
        into ['header2 opts (emit-toclink options options*) any inline-level (emit "</a></p>")] [
            val: into ['header3 to end] :val (emit <ul>) any toc-headers3 (emit "</ul></li>") 
            | (emit </li>)
        ] 
        | 
        val: into ['header3 to end] :val (emit "<li><ul>") any toc-headers3 (emit "</ul></li>")
    ] 
    toc-headers3: [
        into ['header3 opts (emit-toclink options options*) any inline-level (emit "</a></p></li>")]
    ] 
    emit-toclink: func [style opts] [
        emit ["<li" style {><p><a href="#header-} opts/id {">}] 
        if in opts 'number [emit escape-html copy opts/number]
    ] 
    table-rule: [(space: all [in options* 'force-space options*/force-space]) 
        opt [into ['columns any [into ['column opts (emit ["<col" options ">"])]]]] (emit <tbody>) 
        any [
            into [
                'row opts opt 'header (emit ["<tr" options ">"]) 
                any [
                    into [
                        'cell (td: "td") 
                        opts ['span set val pair! (span: rejoin [{ rowspan="} val/y {" colspan="} val/x {"}]) | (span: "")] 
                        opt ['header (td: "th")] (emit ["<" td options span ">"]) [some block-level | end (if space [emit "&nbsp;"])] (emit </td>)
                    ] 
                    | 
                    error
                ] (emit </tr>)
            ] 
            | 
            error
        ] (emit </tbody>)
    ] 
    td: "td" span: "" space: none 
    escape-html: func [text [string! url!]] [
        foreach [from to] html-codes [replace/all text from to] 
        text
    ] 
    html-codes: ["&" "&amp;" "<" "&lt;" ">" "&gt;" {"} "&quot;"] 
    generate: func [qml-doc [block!]] [
        out: make string! 1024 
        parse qml-doc qml-rule 
        out
    ]
]
