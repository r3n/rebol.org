REBOL [
    Title: "Check for a File or Directory"
    Date: 26-May-1999
    File: %ftpcheck.r
    Purpose: {Check for the existence of an FTP file or directory.}
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

if exists? ftp://ftp.rebol.com/pub/downloads/ [
    print "Download directory is there"
]

if exists? ftp://ftp.rebol.com/pub/downloads/rebol011.lha [
    print "Archive file is there"
]
