REBOL [
    Title: "Interactive FTP Downloader"
    Date: 26-May-1999
    File: %ftpdownload.r
    Purpose: {
        Download a group of files from an FTP server, prompting
        for each file along the way.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [ftp other-net file-handling] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

site: ftp://ftp.rebol.com/pub/downloads/

pattern: "*.gz"

files: read site

foreach file files [
    if find/match/any file pattern [
        if find/match ask ["Get" file "now? "] "y" [
            write/binary file read/binary site/:file
        ]
    ]
]
