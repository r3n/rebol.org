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
    Date: 18-Jan-2007
    Version: 2.19.1
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
        18-Mar-2006 1.14.0 "Added =&#146; as comment, changed =1* to =1' etc." 
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
        23-Nov-2006 2.17.1 "Merged changes from Qtask" 
        22-Dec-2006 2.18.1 "Reduced size of indent for =>" 
        18-Jan-2007 2.19.1 {Changed HTML escaping: now assumes UTF-8 source text, and emits HTML-encoded ASCII}
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
                    'toc (emit {<table border="0" cellpadding="0" cellspacing="0" class="toc"><tr><td>}) 
                    opt [into ['title opts (emit ["<h1" options ">"]) any inline-level (emit </h1>)]] (emit <ul>) 
                    any toc-headers (emit "</ul></td></tr></table>")
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
            'escape "HTML" set val string! (
                emit [
                    <div class="html-escape"> 
                    filter-html val 
                    </div>
                ]
            ) to end 
            | 
            'escape "MakeDoc" set val string! (
                emit [
                    <div class="makedoc"> 
                    filter-html second gen-html/options scan-doc val [no-toc no-template no-title no-indent no-nums] 
                    </div>
                ]
            ) to end 
            | 
            'escape (emit {<div class="pre"><pre>
}) string! set val string! (emit-encoded val emit "</pre></div>") to end 
            | 
            'command copy val [string! skip] (
                emit "<p>=" 
                emit-encoded val/1 
                if val/2 [
                    emit "[" 
                    emit-encoded mold/only val/2 
                    emit "]"
                ] 
                emit </p>
            )
        ] 
        | 
        error
    ] 
    emit: func [value] [
        repend out value
    ] 
    emit-encoded: func [string] [
        encode-entities out string
    ] 
    val: none 
    emit-header: func [level style opts] [
        emit ["<h" level style] 
        if in opts 'id [emit [{ id="header-} opts/id {"}]] 
        emit ">" 
        if in opts 'number [emit-encoded opts/number]
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
        image ["background-image: url('" escape-html replace/all copy image "'" "" "');"] 
        image-halign ["background-position: " image-valign " " image-halign ";"] 
        image-tiling [
            "background-repeat: " select [
                both "repeat" vertical "repeat-y" horizontal "repeat-x" neither "no-repeat"
            ] image-tiling ";"
        ] 
        indent ["margin-left: " 20 * indent "pt;"] 
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
            escape-html replace/all copy val ";" ""
        ]
    ] 
    box-rule: [
        opt [into ['title opts (emit ["<h2" options ">"]) any inline-level (emit </h2>)]] 
        any block-level
    ] 
    emit-rounded-box: func [box] [
        emit [
            <div class="boxouter"> 
            {<table class="} either box/shadow? ["roundshadow"] ["rounded"] {"} box/outerstyle ">" 
            <tr> 
            <td class="topleft"> </td> 
            <td class="top"> </td> 
            <td class="topright"> </td> 
            </tr> <tr> 
            <td class="left"> </td> 
            {<td class="box"} box/innerstyle ">"
        ] 
        parse box/contents box-rule 
        emit [
            </td> 
            <td class="right"> </td> 
            </tr> <tr> 
            <td class="bottomleft"> </td> 
            <td class="bottom"> </td> 
            <td class="bottomright"> </td> 
            </tr> 
            </table> 
            </div>
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
            {<div class="boxouter"><table class="shadow"} box/outerstyle ">" 
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
        emit [{<div class="boxouter"><div class="box"} box/style ">"] 
        parse box/contents box-rule 
        emit "</div></div>"
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
        set val string! (emit-encoded val) 
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
                    emit {<a href="} 
                    emit-encoded options*/target 
                    emit [{"} options] 
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
                    emit {<a href="#} 
                    emit-encoded options*/target 
                    emit [{"} options { class="internal">}]
                ]
            ) any inline-level (emit </a>) 
            | 
            'font opts (emit ["<span" options ">"]) any inline-level (emit </span>) 
            | 
            'image opts (if in options* 'src [emit {<img src="} emit-encoded options*/src emit [{"} options ">"]]) 
            | 
            'anchor opts (
                if in options* 'name [
                    emit {<a name="} 
                    emit-encoded options*/name 
                    emit [{"} options ">"]
                ]
            ) any inline-level (emit </a>) 
            | 
            'command copy val [string! skip] (emit "=" emit-encoded val/1 if val/2 [emit "[" emit-encoded mold/only val/2 emit "]"])
        ] 
        | 
        error
    ] 
    error: [here: skip] 
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
        if in opts 'number [emit-encoded opts/number]
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
    entity-map: [
        #{22} "quot" 
        #{26} "amp" 
        #{3C} "lt" 
        #{3E} "gt" 
        #{C2A0} "nbsp" 
        #{C2A1} "iexcl" 
        #{C2A2} "cent" 
        #{C2A3} "pound" 
        #{C2A4} "curren" 
        #{C2A5} "yen" 
        #{C2A6} "brvbar" 
        #{C2A7} "sect" 
        #{C2A8} "uml" 
        #{C2A9} "copy" 
        #{C2AA} "ordf" 
        #{C2AB} "laquo" 
        #{C2AC} "not" 
        #{C2AD} "shy" 
        #{C2AE} "reg" 
        #{C2AF} "macr" 
        #{C2B0} "deg" 
        #{C2B1} "plusmn" 
        #{C2B2} "sup2" 
        #{C2B3} "sup3" 
        #{C2B4} "acute" 
        #{C2B5} "micro" 
        #{C2B6} "para" 
        #{C2B7} "middot" 
        #{C2B8} "cedil" 
        #{C2B9} "sup1" 
        #{C2BA} "ordm" 
        #{C2BB} "raquo" 
        #{C2BC} "frac14" 
        #{C2BD} "frac12" 
        #{C2BE} "frac34" 
        #{C2BF} "iquest" 
        #{C380} "Agrave" 
        #{C381} "Aacute" 
        #{C382} "Acirc" 
        #{C383} "Atilde" 
        #{C384} "Auml" 
        #{C385} "Aring" 
        #{C386} "AElig" 
        #{C387} "Ccedil" 
        #{C388} "Egrave" 
        #{C389} "Eacute" 
        #{C38A} "Ecirc" 
        #{C38B} "Euml" 
        #{C38C} "Igrave" 
        #{C38D} "Iacute" 
        #{C38E} "Icirc" 
        #{C38F} "Iuml" 
        #{C390} "ETH" 
        #{C391} "Ntilde" 
        #{C392} "Ograve" 
        #{C393} "Oacute" 
        #{C394} "Ocirc" 
        #{C395} "Otilde" 
        #{C396} "Ouml" 
        #{C397} "times" 
        #{C398} "Oslash" 
        #{C399} "Ugrave" 
        #{C39A} "Uacute" 
        #{C39B} "Ucirc" 
        #{C39C} "Uuml" 
        #{C39D} "Yacute" 
        #{C39E} "THORN" 
        #{C39F} "szlig" 
        #{C3A0} "agrave" 
        #{C3A1} "aacute" 
        #{C3A2} "acirc" 
        #{C3A3} "atilde" 
        #{C3A4} "auml" 
        #{C3A5} "aring" 
        #{C3A6} "aelig" 
        #{C3A7} "ccedil" 
        #{C3A8} "egrave" 
        #{C3A9} "eacute" 
        #{C3AA} "ecirc" 
        #{C3AB} "euml" 
        #{C3AC} "igrave" 
        #{C3AD} "iacute" 
        #{C3AE} "icirc" 
        #{C3AF} "iuml" 
        #{C3B0} "eth" 
        #{C3B1} "ntilde" 
        #{C3B2} "ograve" 
        #{C3B3} "oacute" 
        #{C3B4} "ocirc" 
        #{C3B5} "otilde" 
        #{C3B6} "ouml" 
        #{C3B7} "divide" 
        #{C3B8} "oslash" 
        #{C3B9} "ugrave" 
        #{C3BA} "uacute" 
        #{C3BB} "ucirc" 
        #{C3BC} "uuml" 
        #{C3BD} "yacute" 
        #{C3BE} "thorn" 
        #{C3BF} "yuml" 
        #{C592} "OElig" 
        #{C593} "oelig" 
        #{C5A0} "Scaron" 
        #{C5A1} "scaron" 
        #{C5B8} "Yuml" 
        #{C692} "fnof" 
        #{CB86} "circ" 
        #{CB9C} "tilde" 
        #{CE91} "Alpha" 
        #{CE92} "Beta" 
        #{CE93} "Gamma" 
        #{CE94} "Delta" 
        #{CE95} "Epsilon" 
        #{CE96} "Zeta" 
        #{CE97} "Eta" 
        #{CE98} "Theta" 
        #{CE99} "Iota" 
        #{CE9A} "Kappa" 
        #{CE9B} "Lambda" 
        #{CE9C} "Mu" 
        #{CE9D} "Nu" 
        #{CE9E} "Xi" 
        #{CE9F} "Omicron" 
        #{CEA0} "Pi" 
        #{CEA1} "Rho" 
        #{CEA3} "Sigma" 
        #{CEA4} "Tau" 
        #{CEA5} "Upsilon" 
        #{CEA6} "Phi" 
        #{CEA7} "Chi" 
        #{CEA8} "Psi" 
        #{CEA9} "Omega" 
        #{CEB1} "alpha" 
        #{CEB2} "beta" 
        #{CEB3} "gamma" 
        #{CEB4} "delta" 
        #{CEB5} "epsilon" 
        #{CEB6} "zeta" 
        #{CEB7} "eta" 
        #{CEB8} "theta" 
        #{CEB9} "iota" 
        #{CEBA} "kappa" 
        #{CEBB} "lambda" 
        #{CEBC} "mu" 
        #{CEBD} "nu" 
        #{CEBE} "xi" 
        #{CEBF} "omicron" 
        #{CF80} "pi" 
        #{CF81} "rho" 
        #{CF82} "sigmaf" 
        #{CF83} "sigma" 
        #{CF84} "tau" 
        #{CF85} "upsilon" 
        #{CF86} "phi" 
        #{CF87} "chi" 
        #{CF88} "psi" 
        #{CF89} "omega" 
        #{CF91} "thetasym" 
        #{CF92} "upsih" 
        #{CF96} "piv" 
        #{E28082} "ensp" 
        #{E28083} "emsp" 
        #{E28089} "thinsp" 
        #{E2808C} "zwnj" 
        #{E2808D} "zwj" 
        #{E2808E} "lrm" 
        #{E2808F} "rlm" 
        #{E28093} "ndash" 
        #{E28094} "mdash" 
        #{E28098} "lsquo" 
        #{E28099} "rsquo" 
        #{E2809A} "sbquo" 
        #{E2809C} "ldquo" 
        #{E2809D} "rdquo" 
        #{E2809E} "bdquo" 
        #{E280A0} "dagger" 
        #{E280A1} "Dagger" 
        #{E280A2} "bull" 
        #{E280A6} "hellip" 
        #{E280B0} "permil" 
        #{E280B2} "prime" 
        #{E280B3} "Prime" 
        #{E280B9} "lsaquo" 
        #{E280BA} "rsaquo" 
        #{E280BE} "oline" 
        #{E28184} "frasl" 
        #{E282AC} "euro" 
        #{E28491} "image" 
        #{E28498} "weierp" 
        #{E2849C} "real" 
        #{E284A2} "trade" 
        #{E284B5} "alefsym" 
        #{E28690} "larr" 
        #{E28691} "uarr" 
        #{E28692} "rarr" 
        #{E28693} "darr" 
        #{E28694} "harr" 
        #{E286B5} "crarr" 
        #{E28790} "lArr" 
        #{E28791} "uArr" 
        #{E28792} "rArr" 
        #{E28793} "dArr" 
        #{E28794} "hArr" 
        #{E28880} "forall" 
        #{E28882} "part" 
        #{E28883} "exist" 
        #{E28885} "empty" 
        #{E28887} "nabla" 
        #{E28888} "isin" 
        #{E28889} "notin" 
        #{E2888B} "ni" 
        #{E2888F} "prod" 
        #{E28891} "sum" 
        #{E28892} "minus" 
        #{E28897} "lowast" 
        #{E2889A} "radic" 
        #{E2889D} "prop" 
        #{E2889E} "infin" 
        #{E288A0} "ang" 
        #{E288A7} "and" 
        #{E288A8} "or" 
        #{E288A9} "cap" 
        #{E288AA} "cup" 
        #{E288AB} "int" 
        #{E288B4} "there4" 
        #{E288BC} "sim" 
        #{E28985} "cong" 
        #{E28988} "asymp" 
        #{E289A0} "ne" 
        #{E289A1} "equiv" 
        #{E289A4} "le" 
        #{E289A5} "ge" 
        #{E28A82} "sub" 
        #{E28A83} "sup" 
        #{E28A84} "nsub" 
        #{E28A86} "sube" 
        #{E28A87} "supe" 
        #{E28A95} "oplus" 
        #{E28A97} "otimes" 
        #{E28AA5} "perp" 
        #{E28B85} "sdot" 
        #{E28C88} "lceil" 
        #{E28C89} "rceil" 
        #{E28C8A} "lfloor" 
        #{E28C8B} "rfloor" 
        #{E28CA9} "lang" 
        #{E28CAA} "rang" 
        #{E2978A} "loz" 
        #{E299A0} "spades" 
        #{E299A3} "clubs" 
        #{E299A5} "hearts" 
        #{E299A6} "diams"
    ] 
    ascii: exclude charset [#"^@" - #"^~"] special: charset {"&<>} 
    seq2: charset [#"À" - #"ß"] 
    seq3: charset [#"à" - #"ï"] 
    seq4: charset [#"ð" - #"÷"] 
    seq: charset [#"^(80)" - #"¿"] 
    encode-entities: func [output text /local mk1 mk2] [
        parse/all text [
            some [
                mk1: some ascii mk2: (insert/part tail output mk1 mk2) 
                | 
                copy mk1 [special | seq2 seq | seq3 2 seq | seq4 3 seq] (encode-entity output to binary! mk1) 
                | 
                skip
            ]
        ]
    ] 
    encode-entity: func [output char [binary!] /local nm] [
        if nm: select entity-map char [
            insert insert insert tail output "&" nm ";" 
            exit
        ] 
        do pick [
            none [
                char: char/1 and 31 * 64 + (char/2 and 63)
            ] [
                char: char/1 and 15 * 4096 + (char/2 and 63 * 64) + (char/3 and 63)
            ] [
                char: char/1 and 7 * 262144 + (char/2 and 63 * 4096) + (char/3 and 63 * 64) + (char/4 and 63)
            ]
        ] length? char 
        insert insert insert tail output "&#" char ";"
    ] 
    escape-html: func [text /local result] [
        result: make string! length? text 
        encode-entities result text 
        result
    ] 
    generate: func [qml-doc [block!]] [
        out: make string! 1024 
        parse qml-doc qml-rule 
        out
    ]
]