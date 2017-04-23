REBOL [
    Title: "REBOL Standard Document Formatter"
    Date: 25-May-2001
    Version: 0.9.0
    File: %make-doc.r
    Author: "Carl Sassenrath"
    Purpose: {(See MakeDoc2 for the latest version.)
Converts very simple text file format into other
document formats (such as HTML) with good titles, table
of contents, section headers, indented fixed-spaced
examples, bullets and definitons.  Does the formatting
so you can focus on the hard part: the words.
}
    Email: carl@rebol.com
    Note: {
^-^-The input file scanner and the output format generator
^-^-are now independent.  The input file is scanned into
^-^-an internal block that can be used to generate different
^-^-target output formats such as HTML, text, PDF, helpfile,
^-^-etc. Only HTML generator is provided at this time.
^-}
    library: [
        level: 'advanced 
        platform: 'all
        type: 'tool 
        domain: [file-handling markup text-processing] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

;-- Scan document into the internal format -----------------------------------
scan-ctx: context [

    out: []

    emit: func ['word d1] [
        if string? d1 [trim/tail d1]
        repend out [word d1]
    ]

    emit-section: func [num] [emit (to-word join "sect" num) text title: true]

    as-file: func [str] [to-file trim str]

    insert-file: func [str file /local text] [
        if file/1 = "%" [remove file]
        if not exists? file [alert reform ["Missing include file:" file] exit]
        text: read file
        insert/part str text any [find text "^/###" tail text] 
    ]

    space: charset " ^-"
    chars: complement nochar: charset " ^-^/"
    text: none
    para: none
    title: none

    ;--- Text Format Language:
    rules: [some parts]

    parts: [ ;here: (print here)

        newline |

        ;--Document sections:
        "***" text-line (if title [alert reform ["Duplicate title:" text]] emit title text) |
        ["===" | "-1-"] TEXT-LINE (EMIT-SECTION 1) |
        ["---" | "-2-"] text-line (emit-section 2) |
        ["+++" | "-3-"] text-line (emit-section 3) |
        ["..." | "-4-"] text-line (emit-section 4) |
        "###" to end (emit end none) |

        ;--Special common notations:
        ":" define opt newline (emit define reduce [text para]) |
        "*" paragraph opt newline (emit bullet para) |
        "#" paragraph opt newline (emit enum para) |
        ";" paragraph |  ; comment

        ;--Commands:
        "=image" image |
        "=url" some-chars copy para to newline newline (emit url reduce [text para]) |
        "=view" left? [some space copy text some chars | none] (emit view text) |
        "=include" some-chars here: (insert-file here as-file text) |
        "=file" some-chars (emit file as-file text) |
        "=options" some [
            spaces "no-indent" (emit option 'no-indent) |
            spaces "modern" (emit option 'modern)
        ] thru newline |
        "=toc" thru newline (emit toc none) |

        ;--Special sections:
        "\in" (emit indent-in none) |
        "/in" (emit indent-out none) |
        "\note" text-line (emit note-in text) |
        "/note" text-line (emit note-out none)|

        ;--Defaults:
        example (emit code trim/auto code) |
        paragraph (either title [emit para para][emit title title: para]) |
        skip
    ]

    spaces: [any space]
    some-chars: [some space copy text some chars]
    text-line: [copy text thru newline]
    paragraph: [copy para some [chars thru newline]]
    example:   [copy code some [indented | some newline indented]]
    indented:  [some space chars thru newline ]
    define:    [copy text to " -" 2 skip any space paragraph]

    left?: [some space "left" (left-flag: on) | none (left-flag: off)]

    image: [
        left? any space copy text some chars (
            text: as-file text
            either left-flag [emit image reduce [text 'left]][emit image text]
        ) 
    ]

    set 'scan-doc func [str] [
        clear out
        parse/all detab str rules
        copy out
    ]
]

;-- Generate HTML output ----------------------------------------------------
html-ctx: context [

    out: make string! 10000
    emit: func [data] [append out reduce data append out newline]

    sects: [0 0 0 0]

    fonts: context [
        title: <font face="arial,helvetica" size="5">
        h1: <font face="arial,helvetica" size="4">
        h2: <font face="arial,helvetica" size="3">
        h3: <font face="arial,helvetica" size="2">
        h4: <font face="arial,helvetica" size="2" color="#404040">
        toc: <font face="arial,helvetica" size="2">
        normal: <font face="arial,helvetica" size="2">
        list: normal
        define: normal
        note: <font face="arial,helvetica" size="2" color="yellow">
        url: <font face="arial,helvetica" size="2" color="maroon">
    ]
    ef: </FONT>
    hfonts: [h1 h2 h3 h4]

    sect-num?: func [num /local n sn] [
        change at sects num n: sects/:num + 1
        change/dup at sects num + 1 0 4 - num
        sn: copy ""
        repeat n num [append sn join sects/:n "."]
        sn
    ]

    clear-sects: does [change/dup sects 0 4]

    emit-sect: func [num str /local sn] [
        if num <= 2 [
            if sects/1 > 0 [emit </BLOCKQUOTE>]
            if num = 1 [emit <HR>]
        ]
        sn: sect-num? num
        emit [{<A NAME="sect} sn {"></A>}]
        emit ["<H" num + 1 ">" get in fonts hfonts/:num 
            sn " " str ef "</H" num + 1 ">"]
        if num <= 2 [emit <BLOCKQUOTE>]
    ]

    emit-toc: func [doc /local w] [
        emit [<HR> fonts/h1 "Contents" ef <BLOCKQUOTE>]
        foreach [word text] doc [
            if w: find [sect1 sect2 sect3 sect4] word [
                sn: sect-num? w: index? w
                loop w - 1 * 8 [append out "&nbsp;"]
                emit [
                    {<A HREF="#sect} sn {">}
                    either w = 1 [fonts/h2][fonts/normal]
                    pick [<B> ""] w <= 2
                    sn " " text
                    pick [</B> ""] w <= 2 ef
                    </A><BR>
                ]
            ]
        ]
        emit </BLOCKQUOTE>
        clear-sects
    ]

    emit-item: func [doc 'item tag] [
        if doc/-2 <> item [emit tag]
        emit [<LI> fonts/list doc/2 ef]
        if doc/3 <> item [emit head insert copy tag #"/"]
    ]

    emit-def: func [doc] [
        if doc/-2 <> 'define [
            emit {<TABLE cellspacing="6" border="0" width="95%">}
        ]
        emit [
            <TR><TD width="20"> "&nbsp;" </TD>
            <TD valign="top" width="80">
            <B> fonts/define any [doc/2/1 "&nbsp;"] ef </B></TD>
            <TD valign="top"> fonts/normal any [doc/2/2 " "] ef </TD>
            </TR>
        ]
        if doc/3 <> 'define [emit {</TABLE><P>}]
    ]

    emit-note: func [text] [
        emit [
            {<TABLE BORDER="1" CELLPADDING="5" CELLSPACING="0" WIDTH="80%">
            <TR><TD WIDTH="100%" BGCOLOR="black"><B>}
            fonts/note text ef
            {</B></TD></TR><TR><TD WIDTH="100%">}
        ]
    ]

    emit-end: does [  ; change this for your own docs
        emit [
            <P></BLOCKQUOTE><HR><FONT face="arial,helvetica" size="1">
            "Copyright REBOL Technologies. All Rights Reserved." <BR>
            "REBOL and the REBOL logo are trademarks of REBOL Technologies." <BR> 
            "Formatted with Make-Doc " system/script/header/version " on " now/date " at " now/time
            </FONT><P>
        ]
    ]

    html-codes: ["&" "&amp;"  "<" "&lt;"  ">" "&gt;"]
    escape-html: func [text][
        foreach [from to] html-codes [replace/all text from to]
        text
    ]

    emit-code: func [text] [
        emit [<BLOCKQUOTE><PRE><B> escape-html text </B></PRE></BLOCKQUOTE>]
    ]

    set 'gen-html func [doc] [

        ;foreach [w t] doc [print w] halt

        emit <HTML>
        if doc/1 = 'title [emit [<TITLE> doc/2 </TITLE>]]
        emit <BODY bgcolor="white">
        if doc/1 = 'title [
            emit [<H1> fonts/title doc/2 ef </H1>]
            doc: skip doc 2
        ]

        if doc/1 = 'code [
            emit [<BLOCKQUOTE><PRE> fonts/normal <B> doc/2 </B> ef </PRE></BLOCKQUOTE>]
            doc: skip doc 2
        ]

        if not find head doc 'toc [emit-toc doc]

        forskip doc 2 [
            switch/default doc/1 [
                para [emit [fonts/normal doc/2 ef <P>]]
                code [emit-code doc/2]
                enum [emit-item doc enum <OL>]
                bullet [emit-item doc bullet <UL>]
                define [emit-def doc]
                sect1 [emit-sect 1 doc/2]
                sect2 [emit-sect 2 doc/2]
                sect3 [emit-sect 3 doc/2]
                sect4 [emit-sect 4 doc/2]
                indent-in [emit <BLOCKQUOTE>]
                indent-out [emit </BLOCKQUOTE>]
                note-in [emit-note doc/2]
                note-out [emit {</TD></TR></TABLE><P>}]
                image []
                view []
                end [emit-end]
                toc []
            ][print doc/1 halt]
        ]

        emit {</BODY></HTML>}
        write %test-out.html out
        browse %test-out.html

    ]

]

;-- Read file...
;system/script/args: %makespec.txt
if not file: system/script/args [
    file: request-file
    if any [not file not file: file/1] [quit]
]
if empty? file [quit]

if not exists? file [alert reform ["Error:" file "does not exist"] quit]

gen-html scan-doc read file

