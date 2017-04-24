REBOL [
    Title:      "Representing And Relating Data In A Text-list"
    Date:     11-Oct-2007
    Name:    "Representing And Relating Data In A Text-list"
    Version: 1.0.1
    File:       %representation-in-text-lists.r
    Author:  "R. v.d.Zee"
    Rights:   "Copyright (C) R. v.d.Zee"
    Tabs:     4
    History: [
        "11-Oct-2007  Version: 1.0.0 Upload To Library"
     ]
    
    Library: [
       level:              'beginner
       platform:         'all
       type:                [how-to reference demo]
       domain:           [gui text-processing] 
       tested-under: 'WXP
       support:          none
       License:          none
    ]

    Purpose: {- to illustrate a method to format columns in text-lists
                     - to illustrate a method of relating the representation 
                       of data in a text-list with the data
                     - to illustrate how non unique data may be presented in text-lists }
 
    Note:    {To represent data in text-lists in orderly columns, use font/name: font-fixed.
                   Font-fixed characters have the same width.
           
                   Append or insert spaces to the data as illustrated in the 
                   make-columns function.

                   A single hi-lite of duplicated data can be achieved.  When representing
                   the data, a unique number may be appended to the row string.  This number
                   does not need to be shown in the text-list.  The number does not
                   become part of the data. Adding unique numbers would not be needed if
                   the data were unique.
 
                  The selected or picked row is related to the data with 
                  "skip-point: index? find example-list/data   to-block mold face/picked"
 
                  Unlike left aligned fields, the text insertion bar of right aligned fields
                  may remain to the right of the right aligned field!}
]


make-columns: [
        unique-counter: 1
        forall example-data [
            row: copy []
                row-string: copy {}
                append row-string   example-data/1/1
                loop (30 - (length? example-data/1/1))      [append row-string " "]
                append row-string   example-data/1/2
                loop (30 - (length? example-data/1/2))      [append row-string " "]
                loop (10 - (length? form example-data/1/3)) [append row-string " "]  ;form - non string data
                append row-string   form pick first example-data 3

                loop 15 [append row-string " "]
                append row-string  unique-counter  
                unique-counter: unique-counter + 1
                append row row-string
                print row-string                            ;print to show the hidden number
                append/only example-list/data row
                show example-list
        ]
    ]


clear-up: [
    clear example-list/data
    example-data: head example-data
    edit-ready?: false
    title-field/text: author-field/text: num-field/text: ""
    show  [title-field author-field num-field]
    reset-face example-list   ;removes hi-lite
    focus none                     ;removes field hi-lite
]

edit-ready?: false                         ;used to control the "Change" button


list-&-data: layout [
    size 900x600
    backdrop navy
    style inputs field 140
    origin 60x30

    example-list: text-list 600x300  teal orange with [font/name: font-fixed] [
        skip-point: index? find example-list/data   to-block mold face/picked
        example-data: head example-data
        example-data: skip example-data skip-point - 1
        title-field/text:   example-data/1/1
        author-field/text:  example-data/1/2
        num-field/text:     example-data/1/3
        edit-ready?: true
        show [title-field author-field num-field]
    ]

    across

    title-field:  inputs 160
    author-field: inputs
    num-field:    inputs 100 right

    btn  "Change" [
        if edit-ready? [
            example-data/1/1:  title-field/text
            example-data/1/2:  author-field/text
            example-data/1/3:  to-integer num-field/text  ;to-integer, maintaining the data structure
            example-data: head example-data
            data-view/text: mold example-data
            show data-view
            do clear-up
            do make-columns
        ]
    ]

    btn "Represent Data" [
        do clear-up
        do make-columns
    ]

    return
    below

    data-view: info 400x100  silver

]



example-data: [
    ["Sometimes A Great Notion" "Ken Kesey" 4539485]
    ["For Whom The Bell Tolls" "Earnest Hemingway" 23453]
    ["Cannery Row" "John Steinbeck" 342244]
    ["Cannery Row" "John Steinbeck" 342244]
]

data-view/text: mold example-data
print now

view list-&-data
