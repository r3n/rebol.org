REBOL [
    Title: "Diff compare"
    Date: 20-Jul-1999
    File: %diff.r
    Author: "Bohdan Lechnowsky"
    Purpose: {
        See the differences between two files.
        Only provides basic DIFF functionality.
        Shows lines which don't exist in other file.
    }
    Email: bo@rebol.com
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

diff: func [
    "Compares two files for differences" 
    file1 [file!] 
    file2 [file!] 
    /local f-1 f-2
][    
    foreach [f file][f-1 file1 f-2 file2][
    if not exists? get file [print [file "not found"] exit]
    set f read/lines get file
    ]
    foreach [block1 block2 name1] reduce [f-1 f-2 file2 f-2 f-1 file2][
        print ["*****" name1 "*****" newline
           "Lines which are not present in the other." newline
           "-------------------------------------"]
        forall block1 [
            if none? find block2 first block1 [
                print [index? block1 ":" first block1]
            ]
        ] 
    ]
]
