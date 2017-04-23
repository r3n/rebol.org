REBOL [
    Title: "Email Text Files"
    Date: 10-Sep-1999
    File: %mailfiles.r
    Purpose: {
        This example sends a group of text files as
        separate messages.
    }
    Note: "Puts the name of the file in the subject line."
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [email file-handling other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

directory: %.      ; where to find the files
pattern: %mail*.r  ; a pattern to match particular files

foreach file read directory [
    if find/match/any file pattern [
        send luke@rebol.com reform [
            "File:" file newline newline read file
        ]
    ]
]

