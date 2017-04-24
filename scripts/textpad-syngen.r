REBOL [
    Title:   "Textpad syntax generator"
    Date:    7-Sep-2010
    File:    %textpad-syngen.r
    Author:  "John Kenyon"
    Version: "0.5"
    Purpose: {
        Textpad syntax generator for Textpad 4.4 (and above)
        Highlighter gets lost with {{}}
    }
    History: {
        0.5 7-Sep-2010 "Updates to a few fields after reading Paul Tretter's rebol.syn"
        0.4 25-Aug-2003 "Removed StringEsc and CharEsc"
        0.3 16-Aug-2001 "Now displays file req only in view and asks in core"
        0.2 20-Apr-2001 "Fixed a few issues"
        0.1 04-Dec-2000 "First attempt"
    }
    library: [
        level: 'intermediate
        platform: 'windows
        type: [tool]
        domain: [markup text]
        tested-under: [
        	view 2.7.7.3.1 WinXP
        ]
        support: johnkenyon.au@gmail.com
        license: 'PD
        see-also: none
    ]
]

basic-syntax-header: [
{; TextPad syntax definitions for Rebol (http://www.rebol.com)
; JKenyon generated } now/date
{

C=1

[Syntax]
Namespace1 = 6
IgnoreCase = Yes
InitKeyWordChars = A-Za-z_$
KeyWordChars = A-Za-z0-9_$
BracketChars = []()
OperatorChars =
PreprocStart =
SyntaxStart =
SyntaxEnd =
CommentStart = comment {
CommentEnd = }
CommentStartAlt =
CommentEndAlt =
SingleComment = ;
SingleCommentEsc =
StringStart = {
StringEnd = }
StringsSpanLines = Yes
StringAlt = "
StringEsc =
CharStart = &
CharEnd = ;
CharEsc =

} ;" -> to close StringAlt =
]

mapping: [
    "Keywords 1" 'op!
    "Keywords 2" 'action!
    "Keywords 3" 'datatype!
    "Keywords 4" 'native!
    "Keywords 5" 'string!
    "Keywords 6" 'function!
]

find-by-type: func [ search-type ] [
    list-words: copy ""
    word: search-type
    types: copy []
    attrs: second system/words
    if all [word? :word not value? :word] [word: mold :word]
    if any [string? :word all [word? :word datatype? get :word]] [
        foreach item first system/words [
            value: copy "              "
            change value :item
            if all [not unset? first attrs
                any [
                    all [string? :word find value word]
                    all [not string? :word datatype? get :word (get :word) = type? first attrs]
                ]
            ] [
                append types value
            ]
            attrs: next attrs
        ]
        sort types
        if not empty? types [
            foreach item types [append list-words join item newline ]
        ]
    ]
    return list-words
]

outstr: make string! 10000

emit: func [ val ] [
    either block? val [
        val: reduce val
        foreach item val [
            outstr: append outstr form item
        ]
    ] [
        outstr: append outstr form val
    ]
]

; Now generate the file
emit rejoin basic-syntax-header
foreach [ keyword word-type ] mapping [
    emit [ newline "[" keyword "]" newline ]
    emit [ find-by-type word-type ]
]

;... and none
emit [ "none" newline ]

;Add vid words on the end if view? is true and prompt for a filename
either error? try [ view? ] [
    write to-file ask "Save as ... eg /c/Program Files/TextPad 4/Samples/rebol.syn > " outstr
] [
    foreach word system/view/vid/vid-words [
        emit [ word newline ]
    ]
    out-file: request-file/title/file/filter "Location to save Rebol Textpad syntax file" "Save" "/c/Program Files/TextPad 5/System/rebol.syn" "*.syn"
    if  not none? out-file [ write first out-file outstr ]
]