REBOL [
    Title:  "md5sum in REBOL"
    Date:   2010-04-08
    Author: "Andreas Bolka"
    Needs:  [2] ;; Written for REBOL 2
    Rights: {
        Copyright 2010 Andreas Bolka
        Licensed under the Apache License, Version 2.0
    }
    Purpose: {
        Demonstrate streaming checksums combined with seek mode. Prints the
        MD5 checksum for each file given as command-line argument in a format
        that is compatible with the commong md5sum(1) utility.
    }
    File: %md5sum.r
]

md5sum: func [
    "Returns an MD5 checksum for the contents of the file given."
    fname [file!] /local fport sport chunk-size
] [
    chunk-size: 4096 ;; 4K chunks, just like in md5sum (matches page size)
    fport: open/seek/binary/read fname
    sport: open [scheme: 'checksum algorithm: 'md5]
    while [not tail? fport] [
        insert sport copy/part fport chunk-size
        fport: skip fport chunk-size
    ]
    close fport
    update sport
    sum: copy sport
    close sport
    sum
]

main: func [args [block!]] [
    foreach fname args [
        print [lowercase enbase/base md5sum to-file fname 16 "" fname]
    ]
]

main system/options/args