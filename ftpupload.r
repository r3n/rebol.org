REBOL [
    Title: "Upload Several Files"
    Date: 26-May-1999
    File: %ftpupload.r
    Purpose: {Upload multiple files with FTP using login and password.}
    library: [
        level: 'beginner 
        platform: 'all 
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

site: ftp://user:pass@www.site.dom/web-files

files: [%index.html %home.html %info.html]

foreach file files [
    write site/:file read file
]
