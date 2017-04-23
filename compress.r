REBOL [
    Title: "File Compress and Decompress"
    Date: 16-May-2001
    Version: 1.0.0
    File: %compress.r
    Author: "Carl Sassenrath"
    Purpose: "An example file compression utility."
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: 'file-handling 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

if none? op: request [{Select the action that you required.
    If you are compressing a file, it is recommended that you
    make a backup copy first before continuing.
    } "Comp." "Decomp." "Cancel"
] [quit]

if none? files: request-file [quit]

press: get pick [compress decompress] op

foreach file files [write/binary file press read/binary file]

alert "Done."
