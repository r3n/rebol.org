REBOL [
    Title: "Dictionary Lookup"
    Date: 12-Jun-2001
    Version: 1.0.0
    File: %dict.r
    Author: "Jos Yule"
    Needs: "View"
    Purpose: {Uses the Merriam-Webster website for dictionary and thesaurus lookups, without using their form. Just a small utility really.}
    Email: jos@theorganization.net
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

view layout [ 
    origin 1x1
    size 121x50
    space 3x3
    across
    word_to_lookup: field 120 [
        browse/only join "" [http://www.m-w.com/cgi-bin/dictionary "?book=dictionary&va=" word_to_lookup/text]
    ] return
    button "Thesaurus" 120 [
        browse/only join "" [http://www.m-w.com/cgi-bin/thesaurus "?book=thesaurus&va=" word_to_lookup/text]
    ]
]