REBOL [
    Title: "Specs Document Converter (Text to HTML)"
    Date: 8-Jun-2000
    File: %makespec.r
    Author: "Carl Sassenrath"
    Purpose: {(See MakeDoc2 for the latest version.)
We use this script to save a lot of time when writing specification documents here at REBOL HQ. Very little notation is required to produce good looking HTML documents with titles, table of contents, section headers, indented fixed-spaced examples, "sidebars", and more. Does all the formatting so we can focus on writing the words (the hard part).}
    History: [
        10-Jun-2000 "Posted to library" 
        8-Mar-2000 "Merged features: TOC, HR, etc." 
        29-Feb-2000 "Fixed newline bug" 
        12-Oct-1999 orig
    ]
    Example: {  (This would be flush left in text editor)
        First line is The Title

        ===Section Title

        Section paragraph here.

        ---Subsection Title

        This is a subsection paragraph.

            Code examples are indented and monospaced

        #indent
            This is a specially indented paragraph.
        /indent

        #side This is the sidebar label
            And this is the text of the sidebar.
        /side
    }
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'tool
        domain: [text-processing markup] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
]

text-to-html: make object! [
    html: make string! 10000
    emit: func [data] [append html reduce data]
    code: text: none
    subnum: sectnum: toc-marker: 0
    sections: []
    space: charset " ^-"
    chars: complement charset " ^-^/"
    font: <font face="arial,helvetica">
    marg-in: <blockquote>
    marg-out: </blockquote>

    escape-html: func [
        "Format a code example" code
    ][
        replace/all code "&" "&amp;"
        replace/all code "<" "&lt;"
        replace/all code ">" "&gt;"
        insert code [<b><pre>]
        append code reduce [</pre></b> newline]
    ]

    ;--- Text Format Language:
    rules: [title some parts done]
    title: [text-line 
        (emit [<html><title>text</title><body>font<h2>text</h2></font><p>])]
    parts: [newline | "===" section | "---" subsect |
        "#indent" (emit marg-in) | "/indent" (emit marg-out) |
        "#side" side | "/side" (emit [</TD></TR></TABLE>]) |
         "###" to end (emit [marg-out "-End-"]) | example | paragraph]
    section: [
        text-line (
            if sectnum > 0 [emit marg-out]
            sectnum: sectnum + 1 subnum: 1
            if sectnum = 1 [toc-marker: length? html]
            emit [{<HR><P>} {<A NAME="section-} sectnum {"></A>}]
            emit [<p>font<h3>(head insert text reduce [sectnum ". "])</h3></font><p>]
            append sections rejoin [{<A HREF="#section-} sectnum {">} text </A>]
            emit marg-in
        ) newline
    ]
    subsect: [text-line
        (emit [<p>font<i><h4>head insert trim text reduce [sectnum "." subnum ". "]
            </h4></i></font><p>] subnum: subnum + 1) newline]
    example: [copy code some [indented | some newline indented]
        (emit escape-html code)]
    paragraph: [copy para some [chars thru newline] (emit [para<p>])]
    done: [(emit [</body></html>])]
    text-line: [copy text thru newline]
    indented: [some space thru newline]
    side: [text-line
        (emit [<TABLE BORDER="1" CELLPADDING="3" CELLSPACING="0" WIDTH="80%">
            <TR><TD WIDTH="100%" BGCOLOR="black"><B>
            <FONT COLOR="white" FACE="Arial, Helvetica"> text
            </FONT></B></TD></TR> <TR><TD WIDTH="100%">
        ])
    ]

    make-contents: func [] [
        html: skip html toc-marker
        html: insert html reduce [<P><HR><P>font<h3>"Contents:"</h3></font><p>marg-in<B>]
        foreach section sections [
            html: insert html reduce [section <BR>]
        ]
        insert html reduce [</B> marg-out <P>]
        html: head html
    ]
    convert: func [data] [
        clear html: head html
        subnum: sectnum: toc-marker: 0
        sections: clear []
        parse/all detab data rules
        make-contents
        html
    ]
]

file: to-file ask "Filename? "
if not empty? file [
    if not find file ".txt" [append file ".txt"]
    if not exists? file [print ["Error:" file "does not exist"] halt]
    data: text-to-html/convert read file
    write head change find file "." ".html" data
]
