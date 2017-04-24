REBOL [
    Title: "Email a Text File"
    Date: 10-Sep-1999
    File: %mailfile.r
    Purpose: "Send a text file (as text of message)."
    Note: {
        Puts the name of the file in the subject line.
    }
    library: [
        level: 'beginner 
        platform: none 
        type: none 
        domain: [email file-handling other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

file: %mailfile.r  ;name of file to send

send luke@rebol.com reform [
    "File:" file newline newline read file
]

