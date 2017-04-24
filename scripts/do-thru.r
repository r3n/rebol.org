REBOL [
    Title: "Do-Thru"
    Date: 4-Jun-2000
    File: %do-thru.r
    Author: "Allen Kamp"
    Purpose: "To 'do cache scripts with args"
    Note: {Script is obsolete since View 1.3 - 16-06-2005 - Allen K }
    Email: allenk@powerup.com.au
    library: [
        level: 'beginner 
        platform: []
        type: []
        domain: []
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

do-thru: func [
    "Do a file from the net thru the public cache."
    url [url!]
    /args arg
    /update "Force update from source site"
    /local path file
][
    path: parse url "/"
    file: trim/with last path {\:*?"<>|}
    path: rejoin [system/options/home %public/ path/3 "/"]
    if not exists? path [make-dir path]
    if any [update not exists? path/:file] [
       data: read/binary url write/binary path/:file :data
    ]
    either args [do/args path/:file :arg][do path/:file]
]

;example: do-thru http://www.rebol.com/library/scripts/viewer.r
