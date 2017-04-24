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
    Purpose: {
        A dialect to create PDF files from REBOL.
    }
    Author: "Gabriele Santilli"
    EMail: giesse@rebol.it
    Comments: {
        Thanks to Volker Nitsch <volker.nitsch@gmail.com> for the AFM parser.
    }
    File: %pdf-maker.r
    License: {
Copyright (c) 2001-2006, Gabriele Santilli
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer. 
  
* Redistributions in binary form must reproduce the above
  copyright notice, this list of conditions and the following
  disclaimer in the documentation and/or other materials provided
  with the distribution. 

* The name of Gabriele Santilli may not be used to endorse or
  promote products derived from this software without specific
  prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
    }
    Date: 3-Aug-2006
    Version: 1.27.1 ; majorv.minorv.status
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
            Added support for the Euro char (&#128;) in font metrics .
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
        11-Aug-2005 1.25.1 "Port to View 1.3; backported some changes from version 2"
         2-Jun-2006 1.26.1 "Fixed a bug with images"
         3-Aug-2006 1.27.1 "Fixed a bug (make-images returning none if there where no images)"
    ]
]

context [
    ; font metrics information for the 14 standard fonts (THANKS VOLKER!)
    ; now handles &#128; (it was somehow left out, don't ask me why :)
    metrics: load decompress 64#{
        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
        u1/3qzdXfje0nfK774zvkBcX/x+JkUJfi50BAA==
    }
    ; guess what are these?
    ; note: we will actually emit a 1.4 version PDF file, tough
    ; we'll use the key in the root catalog to state the real version;
    ; this way we should stay compatible with 1.3 (i.e. Acrobat 4)
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
        ; now has full support for the alpha channel (PDF 1.4)
        ; you are required to supply the ID for the SoftMask
        image: func [
            id "Object id for the image (generation will always be 0)"
            aid "Object id for the SoftMask (generation will always be 0)"
            img [image!] "Image data"
            /local rgb alpha
        ] [
            insert tail xref compose/deep [(id) [(-1 + index? tail contents)]]
            ; requires View 1.3
            rgb: img/rgb
            alpha: img/alpha
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
                        /SMask (aid) 0 R
                        /Length (length? rgb)
                    #>>
                ]
                "^/stream^/"
                rgb
                "^/endstream^/endobj^/"
            ]
            insert tail xref compose/deep [(aid) [(-1 + index? tail contents)]]
            ; NOTE: I'm not using the Matte key, i.e. I'm assuming that the image
            ; is not preblended. handling all that would go far beyond the scope of
            ; the PDF Maker. if you need to use preblended images you could apply the
            ; inverse formula on the image before passing it to the PDF Maker, or you could
            ; hack it here adding /Matte for your own purpose... :)
            insert tail contents reduce [
                aid " 0 obj^/"
                pdf-form compose [
                    #<< /Type /XObject
                        /Subtype /Image
                        /Width (img/size/x)
                        /Height (img/size/y)
                        /ColorSpace /DeviceGray
                        /BitsPerComponent 8
                        /Interpolate true
                        ; REBOL's alpha channel is inverted with respect to PDF's
                        /Decode [1 0]
                        /Length (length? alpha)
                    #>>
                ]
                "^/stream^/"
                alpha
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
        repeat i pick tail xref -2 [
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
    but: func [a [any-type!] b [any-type!]] [:a]
    pop: does [if not empty? stack [but last stack remove back tail stack]]
    ; this creates the document's root objects
    make-docroot: func [pages] [
        insert tail pdf-spec [
            obj 1 compose [
                #<< /Type /Catalog
                    /Version /1.4
                    /Outlines 2 0 R
                    /Pages (pages) 0 R
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
            ; approximates a circle
            gfx-emit [
                val1/1 + val1/3 val1/2 'm
                val1/1 + val1/3 val1/3 * 0.552 + val1/2
                val1/3 * 0.552 + val1/1 val1/2 + val1/3
                val1/1 val1/2 + val1/3 'c
                -0.552 * val1/3 + val1/1 val1/2 + val1/3
                val1/1 - val1/3 val1/3 * 0.552 + val1/2
                val1/1 - val1/3 val1/2 'c
                val1/1 - val1/3 -0.552 * val1/3 + val1/2
                -0.552 * val1/3 + val1/1 val1/2 - val1/3
                val1/1 val1/2 - val1/3 'c
                0.552 * val1/3 + val1/1 val1/2 - val1/3
                val1/1 + val1/3 -0.552 * val1/3 + val1/2
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
        i
    ]
    image-resources: []
    used-images: []
    ; this creates the Image XObjects in the PDF file
    make-images: func [i] [
        clear image-resources
        foreach [name image] used-images [
            insert tail image-resources reduce [to-refinement name i 0 'R]
            insert tail pdf-spec compose/deep [
                image (i) (i + 1) (image)
            ]
            i: i + 2
        ]
        i
    ]
    ; guess what's this? ;)
    mm2pt: func [mm] compose [mm * (72 / 25.4)]
    ; this creates the page objects
    make-pages: func [i /local kids mediabox stream pid] [
        kids: clear []
        pid: (2 * length? pages) + i
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
                        /Parent (pid) 0 R
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
            obj (i) [
                #<< /Type /Pages
                    /Kids [(kids)]
                    /Count (length? pages)
                #>>
            ]
        ]
        i + 1
    ]
    ; MAIN FUNCTION - takes a dialect block and returns a binary
    set 'layout-pdf func [
        "Layout a PDF file (based on the provided spec)"
        spec [block!] "PDF contents, see documentation for details"

        /local pgs
    ] [
        clear pages
        clear used-fonts
        clear used-images
        clear pdf-spec
        parse-spec spec
        pgs: make-pages make-images make-fonts
        make-docroot pgs - 1
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
        but (any [txtb/last-lh 0]) * 0.1818 + txtb/text-height txtb: none
    ]
]