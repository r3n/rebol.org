REBOL [
    Title: "REBOL Memory Stats"
    Date: 21-Jun-2000
    File: %mem-stats.r
    Author: "Carl Sassenrath"
    Purpose: {
        Print out statistics for memory usage. (Command only.)
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]


stats: get in system 'stats

fmt: func [n /local str] [
    str: form n
    head insert/dup str " " (8 - length? str)
]

peach: func [title vals strings] [
    print [newline "--------" title]
    foreach val vals [
        print [fmt val first strings]
        strings: next strings
    ]
]

mem-stats: does [
    print "REBOL MEMORY STATISTICS"

    peach "RECYCLE STATS:" stats/recycle [
        "recycles since boot"
        "series recycled since boot"
        "series last recycled"
        "frames recycled since boot"
        "frames last recycled"
        "ballast remaining"
    ]

    peach "SERIES STATS:" stats/series [
        "total series"
        "block series"
        "string series"
        "other series"
        "unused series"
        "free series (should be same as above)"
        "expansions performed"
    ]

    peach "FRAME STATS:" stats/frames [
        "total frames"
        "frames in use"
        "frames not in use"
        "free frames (should be same as above)"
        "values held in frames"
    ]

    print "^/-------- MEMORY POOLS:"
    foreach a stats/pools [
        print [
            fmt a/1 "wide"
            fmt a/2 "units"
            fmt a/3 "free"
            fmt a/5 "segs"
            fmt a/4 "per"
            fmt a/6 "bytes"
        ]
    ]

    print [fmt stats "bytes total memory allocated by REBOL kernel"]

    print "^/-------- TOTAL DATATYPES:"
    foreach [type cnt] stats/types [print [fmt cnt type]]
]

mem-stats
halt
