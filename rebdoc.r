REBOL [
    Title: "REBOL Document Generator"
    Date: 18-May-2001
    Version: 1.0.1
    File: %rebdoc.r
    Author: "Carl Sassenrath"
    Purpose: {Generates an HTML formatted document of all REBOL
defined words (from the information found within the
REBOL program itself).  The output file is rebdoc.html.
}
    Email: carl@rebol.com
    Note: {
        With minor modifications you can use this script to create
        docs for your own scripts.
    }
    library: [
        level: 'advanced 
        platform: none 
        type: [tool] 
        domain: 'text-processing 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

show-all: false

;-- HTML Template for the Doc:
html: load {
<HTML>
<HEAD><TITLE>title</title></HEAD>
<BODY BGCOLOR="white">
<FONT SIZE=+2 FACE="Arial, Helvetica"><CENTER><B>title</B></CENTER></FONT><BR>
<FONT FACE="Arial, Helvetica"><CENTER><B>date</B><BR>count " words"</CENTER></FONT>
<P>
<FONT FACE="Arial, Helvetica">
<!--head-->

<TABLE WIDTH="100%" BORDER="0" CELLSPACING="3">
    <TR>
        <TD WIDTH="20%" BGCOLOR="#B5BB9F"><P ALIGN="CENTER"><B>name</B></TD>
        <TD WIDTH="80%" BGCOLOR="#E4DECB"><B><I>arg-list</FONT></I></B></TD>
    </TR>
    <TR>
        <TD>nbsp</TD>
        <TD><B>description<B></TD>
    </TR>
<!--word-->

    <TR>
        <TD BGCOLOR="#E0E0E0"><P ALIGN="CENTER"><B>argument</B></TD>
        <TD>description</TD>
    </TR>
<!--args-->

    <TR>
        <TD BGCOLOR="#C59060"><P ALIGN="CENTER"><B>argument</B></TD>
        <TD>description</TD>
    </TR>
<!--refs-->

</TABLE>
<!--next-->

</FONT>
</BODY>
</HTML>
<!--end-->
}

html: bind html 'html ; make it's words useful

sections: [ ; comment tags as placed in the html code
    head-html   <!--head-->
    word-html   <!--word-->
    args-html   <!--args-->
    refs-html   <!--refs-->
    next-html   <!--next-->
    end-html    <!--end-->
]

;-- Split off each html section:
foreach [word marker] sections [
    mark: find html marker
    set word copy/part html mark
    html: next mark
]

;-- Generate the word list:
word-list: make block! 200
words: first system/words
vals:  second system/words
while [not tail? words] [
    if any-function? first vals [
        append word-list first words
    ]
    words: next words
    vals: next vals
]
if not show-all [clear next find word-list 'what]
sort word-list
;if not show-all [remove/part word-list find word-list '?]
bind word-list 'system

;-- Generate the document:
output: make string! 120000
emit: func [html][append output reduce html]
get-next: func ['series][first back set series next get series]
title: reform ["REBOL Word Summary for" system/version]
count: length? word-list
nbsp: "&nbsp;"  ; keeps the ";" out of the html!
date: mold now
emit head-html
description: make string! 100
foreach word word-list [
    name: word  ; to get global binding
    args: first get name ; function's arg list
    arg-list: second parse/all mold args "[]"
    spec: third get name ; function's specification
    insert clear description either string? pick spec 1 [get-next spec]
        ["This is an undocumented function"]
    emit word-html
    while [not empty? spec] [
        arg: get-next spec ; each item in spec...
        if any [arg = /local number? arg] [break] ; bug: not /local
        argument: mold :arg  ; ":" needed to get-lit
        words: if block? pick spec 1 [get-next spec]
        clear description
        if string? pick spec 1 [insert description get-next spec]
        if not block? arg [
            either refinement? arg [emit refs-html][
                append description rejoin [" <i>(accepts: "
                    any [words "any value"] ")</i>"]
                emit args-html
            ]
        ]
    ]
    emit next-html
    emit [<P> newline]
]

emit end-html
write %rebdoc.html output

print {
    Rebdoc has completed compiling the online documentation.  View
    rebdoc.html with your web browser or HTML viewer to read this
    documentation file.
}
wait 2

if view? [browse %rebdoc.html]

