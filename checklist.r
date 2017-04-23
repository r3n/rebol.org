REBOL [
    Title: "Checklister (HTML)"
    Date: 15-Sep-1999
    File: %checklist.r
    Usage: {
        Text indentation is used to determine the level of items
        in the list. Items that begin with a "+" are marked as
        done. Items that begin with a ";" are plain text
        comments.  An example text input file would be:

        item
            subitem 
            subitem
                subsubitem
        item
            subitem
            +subitem
            ;above subitem is done

        The first line of the file is used as the title.
    }
    Purpose: "Creates a checklist in HTML from a text file."
    library: [
        level: 'advanced 
        platform: none 
        type: none 
        domain: [cgi markup text-processing file-handling] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

html: make string! 10000
emit: func [data] [append html reduce data append html newline]
indent: func [level] [loop (level - 1) * 8 [append html "&nbsp;"]]

file: to-file ask "Filename? %"

outline: read file
file: head change clear find file "." ".html"

emit "<html><body>"
emit <FONT FACE="arial, helvetica">

parse/all outline [
    copy text to newline skip (emit [<H2>text</H2><P>now <P>])
    any [
        (level: 1  cmt: done: false) 
        any [[4 " " | tab] (level: level + 1)]
        (if level = 1 [emit <p>])
        [any " " [";" (cmt: true) | "+" (done: true)] | none]
        copy text to newline skip (
            if text [
                indent level
                emit either cmt [
                    [<font size="2"><i>text</i></font><br>]
                ][
                    [
                        {<FONT SIZE="} max 1 (5 - level) {">}
                        <B> "[" pick "x_" done "] " text </B>
                        </FONT><BR>
                    ]
                ]
            ]
        )
    ]
]
emit "</font></html></body>"
write file html
quit
