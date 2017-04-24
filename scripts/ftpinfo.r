REBOL [
    Title: "Get File Size and Date"
    Date: 26-May-1999
    File: %ftpinfo.r
    Purpose: "Get size and date information about an FTP file."
    library: [
        level: 'beginner 
        platform: none 
        type: none 
        domain: [ftp other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

print size? ftp://ftp.rebol.com/pub/downloads/rebol011.lha

print modified? ftp://ftp.rebol.com/pub/downloads/rebol011.lha
