REBOL [
    Title: "Convert Line Terminators"
    Date: 4-Jun-1998
    File: %reline.r
    Author: "Carl Sassenrath"
    Purpose: {
        Convert all line terminators to those used by the
        local computer.  Works for PC, Mac, Unix, Amiga, and
        all others
    }
    library: [
        level: 'beginner 
        platform: none 
        type: none 
        domain: 'file-handling 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

file: to-file ask "Filename? "

write file read file


