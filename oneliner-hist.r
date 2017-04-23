Rebol [
    Title: "Print console history"
    Date: 20-Jul-2003
    File: %oneliner-hist.r
    Purpose: "Print the console history."
    One-liner-length: 60
    Version: 1.0.0
    Author: "Romano Paolo Tenca"
    Library: [
        level: 'beginner
        platform: none
        type: [How-to FAQ one-liner function]
        domain: []
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
hist: does [repeat k system/console/history [print [";" k]]]
