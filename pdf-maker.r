REBOL [
  Library: [
     level: 'advanced
     platform: 'all
     type: 'dialect
     domain: [dialects graphics printing]
     tested-under: none
     support: none
     license: none
     see-also: none
   ]

    Title: "PDF Maker"
    Author: "Gabriele Santilli"
    EMail: giesse@rebol.it
    Purpose: {
        A dialect to create PDF files from REBOL.
    }
    Comments: {
        Thanks to Volker Nitsch <agem@crosswinds.net> for the AFM parser.
    }
    File: %pdf-maker.r
    Date: 23-Jul-2003
    Version: 1.24.0 ; majorv.minorv.status
                    ; status: 0: unfinished; 1: testing; 2: stable
    History: [
        15-Jul-2001 1.1.0 "History start"
        15-Jul-2001 1.2.0 "Added some comments; this will hopefully be appreciated :)"
        15-Jul-2001 1.3.0 "Added graphics system and some primitives"
        15-Jul-2001 1.4.0 "Added coordinate transformations"
        16-Jul-2001 1.5.0 "Added circle (approx) and bezier"
        16-Jul-2001 1.6.0 "(Hopefully) fixed buggy XREF handling"
        17-Jul-2001 1.7.0 "Added paths; now graphics lacks only images"
        17-Jul-2001 1.8.0 "Better decimal handling in PDF-FORM"
        17-Jul-2001 1.9.0 "Added images (not efficient, but works!)"
        21-Jul-2001 1.10.0 "Added font metrics information (THANKS VOLKER!)"
        22-Jul-2001 1.11.0 "Text sizing experiments..."
        26-Jul-2001 1.12.0 "Added text typesetter (alpha version, only justification)"
        26-Jul-2001 1.13.0 "Fixed bugs in justification"
        26-Jul-2001 1.14.0 "Finished typesetting engine"
        27-Jul-2001 1.15.0 "Fixed various bugs"
        31-Jul-2001 1.16.0 "Fixed a nasty bug (layout-pdf wasn't clearing pdf-spec)"
         1-Aug-2001 1.17.0 "Added the ability to disable wrapping"
         9-Aug-2001 1.18.0 "Changed the behaviour of the newline command in textboxes"
         9-Aug-2001 1.19.0 "Changed path-rule a bit; now allows circles in a path too"
        25-Aug-2001 1.20.0 "traslation -> translation (fixed the spelling)"
        10-Jan-2002 1.21.0 {
            Fixed a bug: if a page ended with graphic commands, and the following page
            started with graphic commands, these were rendered in the previous page.
            Added support for the Euro char (€) in font metrics .
        }
        24-Feb-2003 1.22.0 {Uploaded new version with temporary PRECALC-TEXTBOX function.}
        20-Jun-2003 1.23.0 {
            Fixed a bug that caused an error when layouting a string starting with a space
            or a newline
        }
        23-Jul-2003 1.24.0 {
            Small change to PRECALC-TEXBOX, now should add enough space for letters that
            expand below the baseline (as pqg etc.); it is just an hack, and don't expect
            it to really be precise. (That is, the typesetter is too stupid right now
            to take this kind of things into account. Maybe I'll change it, or you'll just
            have to wait for version 2.)
        }
    ]
]

context [
    ; font metrics information for the 14 standard fonts (THANKS VOLKER!)
    ; now handles € (it was somehow left out, don't ask me why :)
    metrics: do decompress 64#{
        eJztnduS1UaWhu/nKfZUXw7YOyWlDnbMBeOO8MyV2zO2aaaDizKU6WoDZQMFTU/M
        QzTDFTd+FcDwAj6F7TARVFGEKTAQ5hScHD3KVH5LqX0q7ZKqqE2J2EJ/6ZDKXGvl
        aelfqX86Nv/pQm/p478sHDr1z70//VMv//fO0vKJxYUTb/X+9KfjS8cXejv4v7jf
        77ZXtIkCptJEbVVOTHXEvUPXb5zA1Jmvnfwu3Q7mTUa+db/ut0t/B3tx9Lv/2Wf+
        /eHNyr9P3uz/IVx6c1m9+WZYHk3/9X8P+p3u3n9bOnq463m7bdLW9byd/Q1sB7ue
        t/vt6l8rPe97Hx9d/Hx5oeuAu23S1nXAnf0NbAe7Drj77epf4w6463y7rcbWdb6d
        /Q1sB7vOt/vt6t+mO99/Xzh6euHU4qH5Weh2gyS1W6h1T+vYbmma9eI46alM9cIw
        LLb8mE6j4tr8b+7jno02uT5PQ7b8uOorbR9mtiQI7Gb/VqqX5DeYv+2Npl3Kj9sM
        5hmw1+bH7X3uOrnP4SyKJG1znEyYLYozm5YpjGQ0f4afYcEmD/lmzpt96t/jNpuO
        Oc99OU7cPWxhmAswLvZGAFYD5uJCFeZql5Lqe1mRA6Yc5o/x2nQZRWvyAHt7mbD7
        Y7DvzZO3wJeJJGEyTm6SMM9I4npOKYk9mp+NzCPyg2I7JJefx37sFuvixjSXB5vR
        k+hsYKtIxT+BUjEQDMkaxsBmcobBJE7kGIyRncnAOCs2NcM3kkHrrlUr0mj0M0h3
        ezrf3839fa63N9fp7+b+LwehAV/kIDPgGuAAYH8OIgM+yoE24AML6j3qXH5trrz8
        rvMF4kSPPIy5YqOEe2TCg0MX/YO8/wY4CzgDOA14hjBeAl4AngOWfYEVub4m6ICg
        /YjKyCwx4AeO/AT4EfChL1cVGPQ+j/kW8D3gK8B3gG8AXwPeA7wLeMcCK5M3cmgf
        sgfwg823y5sib4q8qfK+kPu8tBKOJdMYkr34S45cBVwEXAFcBlwC7LMAFZ8wf+le
        kRdl5fiYnD4FPAA8ATwCPAQsAW4B7gBuA9YBC74wiqfeQI03AdcBa4BVwApgHmBk
        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
        YBo7WqAu827Sljxlkb1XB6oXmbTyPIR5N2H2knfzdfOgvAdsrrH35ueNPE1eo4z9
        INMz2wHar/Gf4V/GeQcTRInNtDKKcsaS6LCyqX4U9LI0sZJgHznLMdJEYiYBK5G4
        X7EI+wDDSjU3FiDXUxoUMjR6NKlancfFcbBJcezG+dwuzJaaLQjFjq2u+qF76Kgi
        5Fk1RkACSVooOEyjkZstmrcVBNrA8IAjWxK2OgmYmw9uA/uz+3W/nfub0BWfMQd/
        Xz14XLri/57/7JPfLx4/8vH8qZMz0SHnnWSWNxNZrIp9ahqovO1JaX+KDi7Lm84s
        LJrMNJ8LZXnzmhkuv9nnnZ65N8mPp1HeVsWmo8yb33zmFieJ7VwNMT/ReZq6aGa0
        Dno6zNv4/Hycd6S2jUvTYrPPNQ1o1EtVXDS8eX7SvOM12AwY7PG8I83MOcu3N3vy
        nHfMeeOdmI7RNMYmffPsfp6Xft5Jp/nffZNWnkY+qLVlTYvzsWmDM9NcZi5PiWvM
        8wFBqu0+TUJbvqKcLu18S/PnpLYsphymY097KjQDkSTvjnQvzM+ZLTYDhXwr2uk8
        w3ZTid1MTIPZdD+zW5SPMM0WhJHdQrdtdT8c5vqxA6bcJlSxHrbVodlM9swgJ9dP
        HHh626FbauzI6KKfG02kzQguN/ogKvbK4CTfUruluWyNgtOguMZuuV6y0FSAfJSW
        G3OaGiOMiy0XjNms0eRbmjjdGGCklZkakdeENNbFPs9RZm4yOQsLa7IZSPo2M10H
        3P2636S5cPpm3gH/y4gO+OD/A+B97vKunAEA
    }
    ; guess what are these?
    pdf-start: "%PDF-1.3^/"
    pdf-end: "%%EOF"
    ; form a decimal value avoiding scientific format etc.
    form-decimal: func [
        "Form a decimal number"
        num [number!]
        /local str sign float ip fp
    ] [
        if zero? num [return copy "0"]
        sign: either negative? num [
            num: abs num
            "-"
        ] [""]
        str: make string! 20
        num: form multiply power 10 negate float: to-integer log-10 num to-decimal num
        ip: first num
        fp: copy skip num 2
        ; understanding this is left as an exercise to the reader. >:->
        insert/dup
            insert/part
                insert
                    insert/dup
                        insert
                            insert str sign
                            either float < 0 ["0."] [""]
                        #"0"
                        -1 - float
                    ip
                fp
                either float < 0 [tail fp] [float]
            #"0"
            float - length? fp
        if all [float >= 0 float < length? fp] [
            insert insert tail str #"." skip fp float
        ]
        str
    ]
    ; valid characters in strings
    pdf-string-valid: complement charset "()\"
    ; this converts REBOL values to PDF values; it's way from perfect but works.
    pdf-form: func ["REBOL to PDF" value /only /local result mrk1 mrk2] [
        result: make string! 256
        if block? :value [
            if empty? value [return copy "[]"]
            if only [insert result "["]
            foreach element value [
                insert insert tail result pdf-form/only element #" "
            ]
            either only [change back tail result "]"] [remove back tail result]
            return result
        ]
        if char? :value [
            return head insert result reduce [
                #"("
                either find pdf-string-valid value [""] [#"\"] value
                #")"
            ]
        ]
        if string? :value [
            insert result "("
            parse/all value [
                some [
                    mrk1: some pdf-string-valid mrk2: (
                        insert/part tail result mrk1 mrk2
                    )
                  | mrk1: skip (
                        insert insert tail result #"\" mrk1/1
                    )
                ]
            ]
            insert tail result ")"
            return result
        ]
        if decimal? :value [return form-decimal value]
        ; issues are used for tricks. ;-)
        if issue? :value [return form value]
        ; other values simply molded currently.
        mold :value
    ]
    ; this will hold the document's xref table
    xref: []
    ; this will hold the document itself
    contents: #{}

    ; LOWLEVEL PDF DIALECT
    ; (this is what people on the ml were looking for. :)
    pdf-words: context [
        ; creates an object
        obj: func [
            id "Object id (generation will always be 0)"
            data "A block of data (will use PDF-FORM above)"
        ] [
            insert tail xref compose/deep [(id) [(-1 + index? tail contents)]]
            insert tail contents reduce [
                id " 0 obj^/" pdf-form data "^/endobj^/"
            ]
        ]
        ; creates a stream
        stream: func [
            id "Object id (generation will always be 0)"
            data "Block (will use PDF-FORM) or any-string"
        ] [
            insert tail xref compose/deep [(id) [(-1 + index? tail contents)]]
            if block? data [data: pdf-form data]
            insert tail contents reduce [
                id " 0 obj^/"
                pdf-form compose [
                    #<< /Length (length? data) #>>
                ]
                "^/stream^/"
                data
                "^/endstream^/endobj^/"
            ]
        ]
        ; creates an Image XObject
        image: func [
            id "Object id (generation will always be 0)"
            img [image!] "Image data"
            /local data
        ] [
            insert tail xref compose/deep [(id) [(-1 + index? tail contents)]]
            data: make binary! length? img
            foreach [b g r a] img [
                insert insert insert tail data r g b
            ]
            insert tail contents reduce [
                id " 0 obj^/"
                pdf-form compose [
                    #<< /Type /XObject
                        /Subtype /Image
                        /Width (img/size/x)
                        /Height (img/size/y)
                        /ColorSpace /DeviceRGB
                        /BitsPerComponent 8
                        /Interpolate true
                        /Length (length? data)
                    #>>
                ]
                "^/stream^/"
                data
                "^/endstream^/endobj^/"
            ]
        ]
    ]

    ; guess what's this? :)
    zero-padded: func [val n] [
        val: form val
        head insert insert/dup make string! n #"0" n - length? val val
    ]
    ; makes the xref table for the document
    make-xref: has [pos xref' lastfree firstfree cur] [
        pos: tail contents
        sort/skip xref 2
        xref': clear []
        firstfree: lastfree: 0
        for i 1 pick tail xref -2 1 [
            either cur: select xref i [
                insert/only tail xref' reduce [cur/1 'n]
            ] [
                either firstfree = 0 [firstfree: i] [xref'/:lastfree/1: i]
                lastfree: i
                insert/only tail xref' copy [0 f]
            ]
        ]
        insert pos reduce [
            "xref^/0 " 1 + length? xref' "^/" zero-padded firstfree 10 " 65535 f ^/"
        ]
        foreach item xref' [
            insert tail pos reduce [
                zero-padded item/1 10 " 00000 " item/2 " ^/"
            ]
        ]
        insert tail pos reduce [
            "trailer^/"
            pdf-form compose [
                #<< /Size (1 + length? xref')
                    /Root 1 0 R ; this assumes root will always be 1
                #>>
            ]
            "^/startxref^/"
            -1 + index? pos newline
        ]
    ]
    ; THIS IS THE LOWLEVEL FUNCTION
    ; use this to make a PDF file using the three lowlevel commands defined above
    ; (OBJ, STREAM and IMAGE)
    set 'make-pdf func [spec [block!]] [
        clear xref
        clear contents
        insert contents pdf-start
        do bind spec in pdf-words 'self
        make-xref
        copy head insert tail contents pdf-end
    ]

    ; high level dialect begins here...
    ; this will hold the pages etc.
    pages: []
    used-fonts: []
    font-resources: []
    ; this will hold the spec then passed to MAKE-PDF
    pdf-spec: []
    ; default page object
    default-page: context [
        size: [211 297] ; mm. (ISO A4)
        offset: [0 0]
        rotation: 0
        contents: []
    ]
    ; default textbox object
    default-textbox: context [
        bbox: [10 17 191 263]
        ; default font is Helvetica 4.23 (12pt)
        font-name: 'Helvetica
        font-size: 4.23
        ; last used font (to avoid setting it each time)
        last-font: [none none]
        ; line height handling
        max-size: 0
        linefactor: 1.1
        lineheight: none
        ; last used line height (to avoid setting it each time)
        last-lh: none
        left: right: 0 ; margins
        last-offset: 0 ; current x text offset
        ; this is the amount of space a text line can consume
        ; before being wrapped
        fuel: bbox/3 - left - right ; text width
        wrappers: charset "+-\/"
        no-wrap?: no ; set to yes to disable wrapping
        in-para?: no
        mode: 'justify ; 'left 'right 'center 'as-is
        ; justify: word spacing vs char spacing factor
        word-spacing: 0.5
        ; buffer holding each rendered line
        linebuff: []
        ; buffer holding the entire text
        text: []
        ; text color (default is black)
        color: 0.0.0
        last-color: none
        ; current y position of text (actually, this is a sort of
        ; temporary text-height; text-height gets the maximum value
        ; reached by this word) (needed for automatic page breaks)
        current-y-pos: 0
        ; actual height of text (textbox autosizing, automatic page breaks)
        text-height: 0
        ; space between paragraphs
        para-skip: 5
        to-pdf: does [
            compose [
                q
                (bbox/1) (bbox/2)
                (bbox/3) (bbox/4) re W n
                BT (bbox/1) (bbox/2 + bbox/4) Td (text) ET
                Q
            ]
        ]
    ]
    ; default space object
    default-space: context [
        translate: none ; [x y]
        scale: none ; [sx sy]
        rotate: none ; angle
        skew: none ; [alpha beta]
        contents: []
        to-pdf: has [result] [
            result: make block! 256
            insert result 'q
            ; apply transformations...
            if translate [
                insert tail result reduce [1 0 0 1 translate/1 translate/2 'cm]
            ]
            if rotate [
                insert tail result reduce [
                    cosine rotate sine rotate
                    negate sine rotate cosine rotate 0 0 'cm
                ]
            ]
            if scale [
                insert tail result reduce [scale/1 0 0 scale/2 0 0 'cm]
            ]
            if skew [
                insert tail result reduce [1 tangent skew/1 tangent skew/2 1 0 0 'cm]
            ]
            ; handle contents
            foreach object contents [
                insert tail result object/to-pdf
            ]
            head insert tail result 'Q
        ]
    ]
    ; default graphics object
    default-gfx: context [
        contents: []
        to-pdf: does [
            contents
        ]
    ]
    ; this is a "context" stack; it is used to make spaces work
    stack: []
    push: func [thing] [insert tail stack thing]
    pop: does [if not empty? stack [first reduce [last stack remove back tail stack]]]
    ; this creates the document's root objects
    make-docroot: does [
        insert tail pdf-spec [
            obj 1 [
                #<< /Type /Catalog
                    /Outlines 2 0 R
                    /Pages 100 0 R
                #>>
            ]

            obj 2 [
                #<< /Type /Outlines
                    /Count 0
                #>>
            ]

            obj 3 [ ; ProcSet to use in pages
                [/PDF /Text /ImageC]
            ]
        ]
    ]
    new: val1: val2: txtb: gfx: none
    gfx-emit: func [data] [
        if not gfx [insert tail new/contents gfx: make default-gfx []]
        insert tail gfx/contents reduce data
    ]
    ; TEXT TYPESETTER
    typeset-text: none
    emit-line: none
    context [
        sum: chset: widths: kern: prev: char: buff: wbuff: wstr: invalid: wrappers: none
        ; emit first char in a line
        emit-veryfirst: func [char] [
            wbuff: reduce [wstr: to-string char]
            sum: pick widths prev: 1 + to-integer char
            emit-char: :emit-other
        ]
        ; emit first char in a word
        emit-first: func [char /local k] [
            clear wbuff
            either k: select/case pick kern prev char [
                sum: k
                insert insert tail wbuff negate k wstr: to-string char
            ] [
                sum: 0
                insert tail wbuff wstr: to-string char
            ]
            sum: sum + pick widths prev: 1 + to-integer char
            emit-char: :emit-other
        ]
        ; emit any other char
        emit-other: func [char /local k] [
            either k: select/case pick kern prev char [
                sum: sum + k
                insert insert tail wbuff negate k wstr: to-string char
            ] [
                insert tail wstr char
            ]
            sum: sum + pick widths prev: 1 + to-integer char
        ]
        emit-char: :emit-veryfirst
        ; handles spaces at the end of a word; they should not be
        ; rendered if we are at the end of the line
        old-spaces: [0 0 0 [""]]
        spaces: [0 0 0 []]
        emit-space: has [k] [
            if all [prev k: select/case pick kern prev #" "] [
                spaces/3: spaces/3 + k
                spaces/2: spaces/2 - k
            ]
            spaces/1: spaces/1 + 1
            spaces/3: spaces/3 + pick widths prev: 33
            spaces/4: buff
        ]
        ; this actually assumes #"?" is available in any font...
        char-rule: [char: chset (emit-char char/1 bc) | invalid (emit-char #"?" bc)]
        wrapper-rule: [char: wrappers (emit-char char/1 bc)]
        word-rule: [
            [some wrapper-rule any char-rule | some char-rule]
            opt wrapper-rule
            opt [#" " (emit-space) any [#" " (if txtb/mode = 'as-is [emit-space])]]
        ]
        ; needed for justification
        word-chars: word-spaces: 0
        line-chars: line-spaces: 0
        bc: does [word-chars: word-chars + 1]
        bs: does [word-spaces: word-spaces + 1]
        reset-margin: does [
            if txtb/left <> txtb/last-offset [
                insert tail txtb/text reduce [txtb/left - txtb/last-offset 0 'Td]
                txtb/last-offset: txtb/left
            ]
        ]
        set 'emit-line has [lh ofs] [
            if txtb/max-size = 0 [
                return empty-line
            ]
            lh: any [txtb/lineheight txtb/max-size * txtb/linefactor]
            if txtb-vskip lh [
                ;print "overflow"
                return false
            ]
            if lh <> txtb/last-lh [
                insert insert tail txtb/text lh 'TL
            ]
            txtb/last-lh: lh
            insert tail txtb/text 'T*
            switch txtb/mode [
                justify [
                    reset-margin
                    ; no space should be added after the last char!
                    line-chars: line-chars - 1
                    either line-spaces > 0 [
                        if line-chars > 0 [
                            insert tail txtb/text reduce [
                                txtb/fuel * txtb/word-spacing / line-spaces 'Tw
                                1 - txtb/word-spacing * txtb/fuel / line-chars 'Tc
                            ]
                        ]
                    ] [
                        if line-chars > 0 [
                            insert tail txtb/text reduce [
                                txtb/fuel / line-chars 'Tc
                            ]
                        ]
                    ]
                ]
                right [
                    ofs: txtb/left + txtb/fuel
                    insert tail txtb/text reduce [ofs - txtb/last-offset 0 'Td]
                    txtb/last-offset: ofs
                ]
                center [
                    ofs: txtb/left + txtb/fuel / 2
                    insert tail txtb/text reduce [ofs - txtb/last-offset 0 'Td]
                    txtb/last-offset: ofs
                ]
                left [
                    reset-margin
                ]
                as-is [
                    reset-margin
                ]
            ]
            insert tail txtb/text txtb/linebuff
            txtb/fuel: txtb/bbox/3 - txtb/left - txtb/right
            txtb/max-size: 0
            clear txtb/linebuff
            emit-char: :emit-veryfirst
            old-spaces: [0 0 0 [""]]
            line-spaces: line-chars: 0
            insert tail txtb/linebuff reduce [buff: copy/deep [""] 'TJ]
            true
        ]
        ; render an empty line
        empty-line: does [
            if txtb-vskip any [txtb/last-lh 0] [
                return false
            ]
            insert tail txtb/text 'T*
            true
        ]
        emit-word: does [
            sum: sum * txtb/font-size / 1000
            old-spaces/3: old-spaces/3 * txtb/font-size / 1000
            either any [txtb/no-wrap? sum + old-spaces/3 <= txtb/fuel line-chars = 0] [
                ; let's render spaces we did not render before
                if old-spaces/2 <> 0 [
                    insert insert tail old-spaces/4 old-spaces/2 copy ""
                ]
                insert/dup tail last old-spaces/4 #" " old-spaces/1
                line-spaces: line-spaces + old-spaces/1 + word-spaces
                line-chars: line-chars + old-spaces/1 + word-chars
                insert tail buff either integer? wbuff/1 [
                    wbuff
                ] [
                    insert tail last buff wbuff/1
                    next wbuff
                ]
                txtb/fuel: txtb/fuel - sum - old-spaces/3
            ] [
                emit-line
                spaces/4: buff
                if integer? wbuff/1 [wbuff: next wbuff]
                insert tail last buff wbuff/1
                insert tail buff next wbuff
                txtb/fuel: txtb/fuel - sum
                txtb/max-size: txtb/font-size
                line-spaces: word-spaces
                line-chars: word-chars
            ]
            emit-char: :emit-first
            old-spaces: spaces
            spaces: copy [0 0 0 [""]]
            word-spaces: word-chars: 0
        ]
        set 'typeset-text func [text /local wrp] [
            if empty? text [exit]
            replace/all text newline #" "
            txtb/max-size: max txtb/max-size txtb/font-size
            set [widths kern chset] get in metrics txtb/font-name
            if txtb/last-font <> reduce [txtb/font-name txtb/font-size] [
                used-fonts: union used-fonts reduce [txtb/font-name]
                insert tail txtb/linebuff reduce [to-refinement txtb/font-name txtb/font-size 'Tf]
                txtb/last-font/1: txtb/font-name
                txtb/last-font/2: txtb/font-size
            ]
            if txtb/last-color <> txtb/color [
                txtb/last-color: txtb/color
                insert tail txtb/linebuff reduce [
                    c2d txtb/color/1 c2d txtb/color/2 c2d txtb/color/3 'rg
                ]
            ]
            either all [not empty? txtb/linebuff 'TJ = last txtb/linebuff] [
                buff: pick tail txtb/linebuff -2
            ] [
                insert tail txtb/linebuff reduce [buff: copy/deep [""] 'TJ]
            ]
            chset: exclude make bitset! chset wrp: union wrappers: txtb/wrappers charset " ^/"
            invalid: exclude complement chset wrp
            emit-char: :emit-veryfirst
            spaces: copy [0 0 0 [""]]
            parse/all text [
                opt [
                    #" " (emit-space) any [#" " (if txtb/mode = 'as-is [emit-space])]
                    (old-spaces: spaces spaces: copy [0 0 0 [""]])
                ]
                some [word-rule (emit-word) | newline (empty-line)]
            ]
        ]
    ]
    ; sets the current font; notice that the line height is set to
    ; size * 1.1 as a reasonable default.
    use-font: func [name size] [
        txtb/font-name: name
        txtb/font-size: size
    ]
    txtb-vskip: func [amount] [
        txtb/current-y-pos: txtb/current-y-pos + amount
        txtb/text-height: max txtb/text-height txtb/current-y-pos
        txtb/text-height > txtb/bbox/4
    ]
    ; dialect rules
    endp: does [
        if txtb/in-para? [
            emit-last
            txtb-vskip txtb/para-skip
            append txtb/text compose [0 (negate txtb/para-skip) Td] 
            txtb/in-para?: no
        ]
    ]
    end-para: [opt 'end ['p | 'paragraph] (endp)]
    set-wrappers: [
        'wrap (txtb/no-wrap?: no) opt ['on set val1 string! (txtb/wrappers: charset val1)]
      | 'don't 'wrap (txtb/no-wrap?: yes)
    ]
    set-margins: [opt 'with [
        'left 'margin set val1 number! (txtb/left: val1)
      | 'right 'margin set val1 number! (txtb/right: val1)
    ]]
    set-para: [
        set val1 ['justify | 'left 'align | 'right 'align | 'center | 'as-is] (
            endp
            txtb/mode: val1
        )
        any [
            set-margins
          | opt ['with 'word] 'spacing opt 'factor set val1 number! (txtb/word-spacing: val1)
        ] (txtb/fuel: txtb/bbox/3 - txtb/left - txtb/right)
    ]
    font-def: ['font set val1 word! set val2 number! (use-font val1 val2)]
    set-lead: ['line [
        'height set val1 number! (txtb/lineheight: val1)
      | 'factor set val1 number! (txtb/lineheight: none txtb/linefactor: val1)
    ]]
    set-para-skip: [
        'space 'after opt 'paragraphs set val1 number! (txtb/para-skip: val1)
    ]
    draw-text: [set val1 string! (
        txtb/in-para?: yes
        either txtb/mode = 'as-is [
            val1: parse/all val1 "^/"
            if not empty? val1 [
                typeset-text val1/1
                foreach text next val1 [
                    emit-line
                    typeset-text text
                ]
            ]
        ] [typeset-text val1]
    )]
    ; 0-255 -> 0.0-1.0
    c2d: func [val] [divide any [val 0] 255]
    set-color: [set val1 tuple! (txtb/color: val1)]
    vspace: [opt ['vertical] 'space set val1 number! (txtb-vskip val1 append txtb/text reduce [0 negate val1 'Td])]
    emit-last: does [
        either txtb/mode = 'justify [
            txtb/mode: 'left
            append txtb/text [0 Tc 0 Tw]
            emit-line
            txtb/mode: 'justify
        ] [
            emit-line
        ]
    ]
    textbox-rule: [
        some [
            font-def
          | 'newline (emit-line)
          | vspace
          | end-para
          | set-para
          | set-lead
          | draw-text
          | set-color
          | set-wrappers
          | set-para-skip
        ] end (emit-last)
    ]
    gfxstate-words: context [
        butt: 0 round: 1 square: 2
        miter: 0 bevel: 2
    ]
    gfxstate-rule: [
        'width set val1 number! (gfx-emit [val1 'w])
      | 'cap set val1 ['butt | 'round | 'square] (
            gfx-emit [get in gfxstate-words val1 'J]
        )
      | 'join set val1 ['miter | 'round | 'bevel] (
            gfx-emit [get in gfxstate-words val1 'j]
        )
      | 'miter 'limit set val1 number! (gfx-emit [val1 'M])
      | 'dash [
            'solid (gfx-emit [[] 0 'd])
          | set val1 into [some number!] set val2 number! (gfx-emit [val1 val2 'd])
        ]
    ]
    color-rule: [opt ['color] set val1 tuple! (gfx-emit [c2d val1/1 c2d val1/2 c2d val1/3])]
    sc-rule: [color-rule (gfx-emit ['RG])]
    fc-rule: [color-rule (gfx-emit ['rg])]
    box-rule: [
        copy val1 4 number! (
            gfx-emit [val1/1 val1/2 val1/3 val1/4 're]
        )
    ]
    lineopt-rule: [any [gfxstate-rule | sc-rule]]
    boxopt-rule: [any ['line gfxstate-rule | sc-rule]]
    sboxopt-rule: [any ['edge gfxstate-rule | 'edge sc-rule | fc-rule]]
    circle-rule: [
        copy val1 3 number! (
            ; approximates a circle; error should be less than 1%
            gfx-emit [
                val1/1 + val1/3 val1/2 'm
                val1/1 + val1/3 val1/3 * 0.55 + val1/2
                val1/3 * 0.55 + val1/1 val1/2 + val1/3
                val1/1 val1/2 + val1/3 'c
                -0.55 * val1/3 + val1/1 val1/2 + val1/3
                val1/1 - val1/3 val1/3 * 0.55 + val1/2
                val1/1 - val1/3 val1/2 'c
                val1/1 - val1/3 -0.55 * val1/3 + val1/2
                -0.55 * val1/3 + val1/1 val1/2 - val1/3
                val1/1 val1/2 - val1/3 'c
                0.55 * val1/3 + val1/1 val1/2 - val1/3
                val1/1 + val1/3 -0.55 * val1/3 + val1/2
                val1/1 + val1/3 val1/2 'c 'h
            ]
        )
    ]
    move-to: ['move opt 'to]
    line-to: ['line opt 'to]
    boxpath-rule: ['box copy val1 4 number! (gfx-emit [val1/1 val1/2 val1/3 val1/4 're])]
    path-rule: [some [boxpath-rule | 'circle circle-rule | shape-rule]]
    shape-rule: [
        opt move-to copy val1 2 number! (gfx-emit [val1/1 val1/2 'm]) some [
            opt line-to copy val1 2 number! (gfx-emit [val1/1 val1/2 'l])
          | move-to copy val1 2 number! (gfx-emit [val1/1 val1/2 'm])
          | 'bezier copy val1 6 number! (gfx-emit [val1/1 val1/2 val1/3 val1/4 val1/5 val1/6 'c])
          | 'bezier 'to copy val1 4 number! (gfx-emit [val1/1 val1/2 val1/3 val1/4 'v])
          | 'bezier 'from copy val1 4 number! (gfx-emit [val1/1 val1/2 val1/3 val1/4 'y])
          | 'close (gfx-emit ['h])
        ]
    ]
    contents-rule: [
        any [
            'textbox (gfx: none insert tail new/contents txtb: make default-textbox [])
            opt [copy val1 4 number! (change txtb/bbox val1 txtb/fuel: val1/3 - txtb/left - txtb/right)]
            into textbox-rule
          | 'apply (
                push new
                gfx: none
                insert tail new/contents new: make default-space []
            ) any [
                'translation copy val1 2 number! (new/translate: val1)
              | 'rotation set val1 number! (new/rotate: val1)
              | 'scaling copy val1 2 number! (new/scale: val1)
              | 'skew copy val1 2 number! (new/skew: val1)
            ] into contents-rule (new: pop gfx: none)
          | 'line lineopt-rule opt [
                copy val1 4 number! (gfx-emit [val1/1 val1/2 'm val1/3 val1/4 'l 'S])
            ]
          | 'bezier lineopt-rule copy val1 8 number! (
                gfx-emit [
                    val1/1 val1/2 'm
                    val1/3 val1/4 val1/5 val1/6 val1/7 val1/8 'c 'S
                ]
            )
          | 'box boxopt-rule box-rule (gfx-emit ['S])
          | 'solid 'box sboxopt-rule box-rule (gfx-emit ['B])
          | 'circle boxopt-rule circle-rule (gfx-emit ['S])
          | 'solid 'circle sboxopt-rule circle-rule (gfx-emit ['B])
          | 'stroke boxopt-rule into path-rule (gfx-emit ['S])
          | 'fill (val2: 'f) any [fc-rule | 'even-odd (val2: 'f*)] opt [into path-rule (gfx-emit [val2])]
          | 'paint (val2: 'B) any [
                'edge gfxstate-rule | 'edge sc-rule | fc-rule | 'even-odd (val2: 'B*)
            ] into path-rule (gfx-emit [val2])
          | 'clip opt 'to (val2: 'W) opt ['even-odd (val2: 'W*)] into path-rule (gfx-emit [val2 'n])
          | 'image (
                push new
                gfx: none
                insert tail new/contents new: make default-space []
            ) opt 'at copy val1 2 number! (new/translate: val1)
            opt 'size copy val1 2 number! (new/scale: val1) any [
                'rotated set val1 number! (new/rotate: val1)
              | 'skew copy val1 2 number! (new/skew: val1)
            ]  set val1 [image! | file! | word!] (
                if word? val1 [val1: get val1]
                if file? val1 [val1: load val1]
                insert insert tail used-images val2: join "Img" length? used-images val1
                gfx-emit [to-refinement val2 'Do]
                new: pop gfx: none
            )
        ]
    ]
    page-rule: [
        (insert tail pages new: make default-page [] gfx: none)
        opt ['page any [
            'size set val1 number! set val2 number! (new/size: reduce [val1 val2])
          | 'rotation set val1 integer! (new/rotation: val1)
          | 'offset set val1 number! set val2 number! (new/offset: reduce [val1 val2])
        ]]
        contents-rule
    ]
    ; dialect parser
    parse-spec: func [spec] [
        parse spec [some [into page-rule]]
    ]
    ; this creates the font objects in the PDF file
    ; only the 14 standard PDF fonts supported currently
    make-fonts: has [i] [
        i: 4
        clear font-resources
        foreach font used-fonts [
            insert tail font-resources reduce [to-refinement font i 0 'R]
            insert tail pdf-spec compose/deep [
                obj (i) [
                    #<< /Type /Font
                        /Subtype /Type1
                        /BaseFont (to-refinement font)
                        /Encoding /WinAnsiEncoding
                    #>>
                ]
            ]
            i: i + 1
        ]
    ]
    image-resources: []
    used-images: []
    ; this creates the Image XObjects in the PDF file
    make-images: has [i] [
        i: 101 + (2 * length? pages)
        clear image-resources
        foreach [name image] used-images [
            insert tail image-resources reduce [to-refinement name i 0 'R]
            insert tail pdf-spec compose/deep [
                image (i) (image)
            ]
            i: i + 1
        ]
    ]
    ; guess what's this? ;)
    mm2pt: func [mm] compose [mm * (72 / 25.4)]
    ; this creates the page objects
    make-pages: has [i kids mediabox stream] [
        i: 101
        kids: clear []
        foreach page pages [
            insert tail kids reduce [i 0 'R]
            mediabox: reduce [0 0 mm2pt page/size/1 mm2pt page/size/2]
            stream: clear []
            insert tail stream compose [(mm2pt 1) 0 0 (mm2pt 1) (mm2pt page/offset/1) (mm2pt page/offset/2) cm]
            foreach object page/contents [
                insert tail stream object/to-pdf
            ]
            insert tail pdf-spec compose/deep [
                obj (i) [
                    #<< /Type /Page
                        /Parent 100 0 R
                        /MediaBox [(mediabox)]
                        /Rotate (page/rotation)
                        /Contents (i + 1) 0 R
                        /Resources #<<
                            /ProcSet 3 0 R
                            (either empty? font-resources [] [compose [/Font #<< (font-resources) #>>]])
                            (either empty? image-resources [] [compose [/XObject #<< (image-resources) #>>]])
                        #>>
                    #>>
                ]

                stream (i + 1) [
                    (stream)
                ]
            ]
            i: i + 2
        ]
        insert tail pdf-spec compose/deep [
            obj 100 [
                #<< /Type /Pages
                    /Kids [(kids)]
                    /Count (length? pages)
                #>>
            ]
        ]
    ]
    ; MAIN FUNCTION - takes a dialect block and returns a binary
    set 'layout-pdf func [
        "Layout a PDF file (based on the provided spec)"
        spec [block!] "PDF contents, see documentation for details"
    ] [
        clear pages
        clear used-fonts
        clear used-images
        clear pdf-spec
        make-docroot
        parse-spec spec
        make-images
        make-fonts
        make-pages
        make-pdf pdf-spec
    ]
    ; quick hack to allow the creation of tables and so that things like 
    ; MDP will be able to use the PDF Maker
    set 'precalc-textbox func [
        "Precalculate a textbox, to get its vertical space"
        width [number!] "Width of the textbox"
        spec [block!] "Textbox spec"
    ] [
        txtb: make default-textbox [
            bbox/3: width
            fuel: width - left - right
        ]
        parse spec textbox-rule
        first reduce [(any [txtb/last-lh 0]) * 0.1818 + txtb/text-height txtb: none]
    ]
]
