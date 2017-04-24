REBOL [
    Title: "Make a directory"
    Date: 26-May-1999
    File: %ftpmakedir.r
    Purpose: "Make a file directory on an FTP server."
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

make-dir ftp://user:pass@ftp.site.com/newdir/
