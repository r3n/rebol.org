REBOL [
    Title: "Transfer REBOL Files to Server"
    Date: 18-Dec-1997
    File: %ftpallto.r
    Purpose: {FTP all .r files in the current directory to a server.}
    library: [
        level: 'beginner 
        platform: 'all 
        type: 'Tool 
        domain: [ftp other-net file-handling] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

ftp-to: ftp://user:pass@domain.com/examples

foreach file load %./ [
    if find/any file "*.r" [
        print ["uploading:" file]
        write ftp-to/:file read file
    ]
]
