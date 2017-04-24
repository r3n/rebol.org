REBOL [
    Title: "brother to text"
    Date: 8-Feb-2002/17:31:18-8:00
    Version: 1.1.0
    File: %bro2text.r
    Author: "Ryan S. Cole"
    Purpose: {Converts some brother word processing files (.wpt) to text.}
    Email: ryan@practicalproductivity.com
    Comments: {This script runs with REBOL/view, download from www.rebol.com}
    library: [
        level: 'intermediate 
        platform: 'all
        type: 'Tool 
        domain: [file-handling parse text-processing] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]


;;; PARSE RULES ;;;

format-chars: charset [#"^B"]
txt-chars: charset [#" " - #"~" #"^B"]

end-of-text: [
    any [
        #"^]" (add-text line " ") |
        #"^M" (add-text line "^/") |
        #"^K" (add-text line "^/^/^/^/") |
        #"^[" (add-text line " ") |
        #"^B" (add-text line " ") |
        #"^R" (add-text line " ") |
        #"û" (add-text line " ") |
        #"ü" (add-text line " ")
    ]
]

some-text: [thru "^F^Y^F^Y" copy line any txt-chars]

wpt-to-doc-rule: [
    some [ some-text end-of-text ]
]


add-text: func [line ender] [
    either none? line [
        line: copy ""
    ] [
        replace line "^B" ""
    ]
    append doc join line ender
]

;;;;;;;;;;;;;;

convert: func [files] [
    if none? files [quit]
    foreach fn files [
        wpt: to-string read/binary fn
        doc: copy ""

        parse/all wpt wpt-to-doc-rule
        replace fn ".wpt" ext/text
        if not all [
            exists? fn 
            not confirm rejoin ["Overwrite the file " fn "?"]
        ] [
            write fn doc
        ]
    ]
    quit
]

get-names: function [path-blk] [name-blk] [
    name-blk: copy []
    foreach f path-blk [
        append name-blk second split-path f
    ]
    return name-blk
]

;;;;;;;;;;;;;;;

selected-files: []

view layout [
    backdrop effect [gradient 1x1 128.128.128 90.90.90]
    txt "This program converts brother WPT files to plain text."
    txt "Converted files will be placed in same directory (folder)."
    guide
    file-list: text-list
    return
    
    button "Browse" [
        file-list/lines: get-names selected-files: request-file/filter/title ["*.wpt"] "Select one or more files." "Select"
        show file-list
    ]
    pad 0x40
    ext: rotary ".txt" ".doc"
    pad 0x40
    button red "Cancel" [quit]
    button forest "Convert" [convert selected-files]
]
    



                                                                                                      