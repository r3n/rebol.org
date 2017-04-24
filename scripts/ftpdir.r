REBOL [
    Title: "Read File Directories"
    Date: 26-May-1999
    File: %ftpdir.r
    Purpose: "Read and print directories from an FTP server."
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

print read ftp://ftp.rebol.com/

print read ftp://ftp.rebol.com/pub/downloads/

print read ftp://user:pass@ftp.site.com/scripts/
