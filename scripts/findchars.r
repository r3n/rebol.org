REBOL [
    Title: "Find Invalid Chars"
    Date: 4-Jun-1998
    File: %findchars.r
    Author: "Carl Sassenrath"
    Purpose: "Finds odd unprintable ASCII characters in a file"
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [file-handling text-processing] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

bad-chars: complement charset ["^I^J^M" #" " - #"~"]

file: to-file ask "Filename? "

data: read/binary file

forall data [
    if find bad-chars first data [
        print ["Bad char at" index? data]
        print mold to-string copy/part data 10
    ]
]

