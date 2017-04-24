REBOL [
    Title: "Scroll Pictures"
    Date: 16-Jun-2000
    File: %scrollpic.r
    Author: "P. Bevan"
    Purpose: "Scroll through some pictures"
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

pics: []

find-param: function [t-param] [p-text]
[
    p-text: find str t-param
    either p-text = none
        [return ""]
        [return second p-text]
]

; setup parameters
either exists? %title.txt
    [str: parse (read %title.txt) "="]
    [str: ""]

; title text
title-text: find-param "Title"

;size
pic-size: find-param "size"
either pic-size = ""
    [pic-size: 640x400]
    [pic-size: to-pair pic-size]

num-pics: 0
foreach files read %.
[
    p-files: (parse files ".")
    if (length? p-files) = 2
    [
        is-jpg-gif: second p-files
        if any[is-jpg-gif = "gif" is-jpg-gif = "jpg"]
        [
            num-pics: num-pics + 1
            pics: append pics to-string files
        ]
    ]
]

pic-text: find-param (first pics)

count: 0

view/title layout 
[
    size pic-size ; 720x540
    backface: backdrop (to-file (first pics)) effect [fit] 
    at 5x5
    p-text: text pic-text 400x24
    with 
    [
        rate: 1
        feel: make feel 
        [
            engage: func [face action event i] 
            [
                count: count + 1
                if (count // 10) = 0
                [
                    elem: 1 + (to-integer (count / 10))
                    if elem > num-pics
                        [elem: 1 count: 0]
                    filename: pick pics elem
                    imag: load to-file filename
                    backface/image: imag
                    show backface
                    p-text/text: find-param filename
                    show p-text
                ]
            ]
        ]
    ]
] title-text

