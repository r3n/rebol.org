REBOL [
    Title: "Hash Table"
    Date: 12-Nov-2002/12:17:35+1:00
    Version: 1.0.2
    File: %hashtable.r
    Author: "Gregory Pecheret"
    Purpose: "Very simple Hashtable object, but usefull!"
    Email: gregory.pecheret@free.fr
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'tool 
        domain: 'database 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]


hashtable!: make object! [
data: copy []

addvalue: func [key value /local k] [
    inserted: false

    foreach k data [
        if key == first k [
            append second k value
            inserted: true
        ]
    ]

    if not inserted [
        append data compose/deep [[(key) [(value)]]]
    ]


]


getKeys: func [/local k ret] [
    ret: copy []
    foreach k data [
        append ret first k
    ]
    return ret
]

getValue: func [key /local k ret] [
    ret: none
    foreach k data [
        if key == first k [
            ret: second k
        ]
    ]
    return ret
]


getValues: func [] [
    ret: copy []
    foreach key getKeys [
        append ret getValue key
    ]
    unique ret
]
]


{
; sample
; values added with the same key are put in a list
addValue "ghg" "ofgfg"
addValue "ghg" "hjhkh"
addValue "aaaa" "popop"
probe getKeys
probe getValue "ghg"
probe getValue "aaaa"
probe getValues
}
                                                                     
                                                                          