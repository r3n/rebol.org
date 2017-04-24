REBOL [
    Title: "Download List of Files"
    Date: 26-May-1999
    File: %ftpdown.r
    Purpose: "Download a list of binary files using FTP."
    library: [
        level: 'beginner 
        platform: none 
        type: none 
        domain: [ftp other-net file-handling] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

site: ftp://user:pass@ftp.site.com/www/images

files: [icon.gif logo.gif photo.jpg]

foreach file files [
    write/binary file read/binary site/:file
]
