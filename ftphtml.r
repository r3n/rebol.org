REBOL [
    Title: "Upload all HTML Files"
    Date: 26-May-1999
    File: %ftphtml.r
    Purpose: "Upload a group of files to an FTP server."
    library: [
        level: 'beginner 
        platform: none 
        type: 'Tool 
        domain: [ftp other-net file-handling] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

site: ftp://user:pass@ftp.site.com/www/

pattern: "*.html"

foreach file read %. [
    if find/match/any file pattern [
        print ["Uploading:" site/:file]
        write/binary site/:file read/binary file
    ]
]
