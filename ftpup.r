REBOL [
    Title: "Upload a File"
    Date: 26-May-1999
    File: %ftpup.r
    Purpose: "Upload a binary file to an FTP server."
    library: [
        level: 'beginner 
        platform: 'all 
        type: 'one-liner 
        domain: [ftp other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

write/binary ftp://ftp.site.com/file read/binary %file

