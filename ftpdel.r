REBOL [
    Title: "Delete a File or Directory"
    Date: 26-May-1999
    File: %ftpdel.r
    Purpose: {Delete a file or directory from a server using FTP.}
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

delete ftp://user:pass@ftp.site.com/file.txt

delete ftp://user:pass@ftp.site.com/adir/

