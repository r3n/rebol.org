REBOL [
    Title: "Check for Directory"
    Date: 26-May-1999
    File: %ftpdircheck.r
    Purpose: {Check if a filename belongs to a directory using FTP.}
    library: [
        level: 'beginner 
        platform: none 
        type: 'one-liner
        domain: [ftp other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

if dir? ftp://ftp.rebol.com/pub/downloads [print "It's a directory"]
