REBOL [
    Title: "Write Text File"
    Date: 26-May-1999
    File: %ftpwrite.r
    Purpose: "Write a text file to an FTP server."
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

write ftp://ftp.site.com/file.r "Just a test file."
