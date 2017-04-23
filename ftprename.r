REBOL [
    Title: "Rename a File"
    Date: 26-May-1999
    File: %ftprename.r
    Purpose: "Rename a file on a server using FTP."
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

rename ftp://user:pass@ftp.site.com/foo.r %bar.r
