REBOL [
    Library: [
        level: 'beginner
        platform: 'all
        type: 'tool
        domain: [compression extension math scientific text text-processing]
        tested-under: none
        support: none
        license: 'lgpl
        see-also: "ieee.r"
    ]
    Title: "bin-to-float"
    Description: "Binary series to IEEE-32 float series and back"
    Date: 2006-11-07
    Version: 0.0.3
    Author: "Glenn M. Lewis"
    File: %bin-to-float.r
    Purpose: {Convert a binary file to a series of floats and back}
    License: "GNU Lesser General Public License (Version 2.1)"
    Comment: {Relies on 'ieee.r' script found at www.REBOL.org}
]

do %ieee.r

bin-to-float: func [
    "Converts a binary series to a series of floats"
    dat [binary!] "Binary data to be converted to floats"
    /local result val
] [
    result: copy []
    for i ((length? dat) / 4) 1 -1 [
        val: from-ieee skip dat (4 * i - 4)
        insert result val
    ]
    result
]

float-to-bin: func [
    "Converts a series of floats to a binary series"
    dat [series!] "Float series to be converted to binary"
    /local result val
] [
    result: copy #{}
    for i (length? dat) 1 -1 [
        val: to-ieee pick dat i
        insert result val
    ]
    result
]

