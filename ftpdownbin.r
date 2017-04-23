REBOL [
    Title: "Download a Binary File"
    Date: 26-May-1999
    File: %ftpdownbin.r
    Purpose: "Download a binary file from an FTP server."
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

file: ftp://ftp.rebol.com/pub/downloads/rebol011.lha

write/binary %rebol011.lha read/binary file
