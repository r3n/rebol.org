REBOL [
    Title: "XML Generator"
    Date: 4-Jun-1999
    File: %xmlgen.r
    Author: "Scrip Rebo"
    Purpose: {Simple functions to generate XML output. Creates example XML as published in Scientific American, May 1999.}
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [DB markup xml] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
]

;-- Scientific American example using REBOL blocks:
example: [
    movie [
        title "Star Trek: Insurrection"
        star  "Patrick Stewart" "Brent Spiner"
        theater [
            theater-name "MonoPlex 2000"
            showtime 14:15 16:30 18:45 21:00
            price [
                adult $8.50
                child $5.00
            ]
        ]
        theater [
            theater-name "Bigscreen 1"
            showtime 19:30
            price $6.00
        ]
    ]
]

;-- XML conversion functions:
emit-xml: function [data] [action tag-word][
    foreach item data [
        action: select [
            word!  [tag-word: form item]
            block! [emit-tag tag-word [emit-xml item]]
        ] type?/word item
        either action [do action] [emit-tag tag-word item]
    ]
]

emit-tag: func [tag value] [
    either block? value [
        emit [indent to-tag tag newline]
        insert/dup indent " " 4
        do value
        remove/part indent 4
        emit [indent to-tag join "/" tag newline]
    ][
        emit [
            indent to-tag tag
            value
            to-tag join "/" tag
            newline
        ]
    ]
]

emit: func [data] [append output reduce data]
output: make string! 8000
indent: make string! 40

;-- Convert example to XML and print it:
emit-xml example
print output

