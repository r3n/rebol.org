Rebol [
    Title: "Upload  a file with FTP"
    Date: 20-Jul-2003
    File: %oneliner-ftp-upload-file.r
    Purpose: {Uploads a file using FTP (file transfer protocol). Username and password are
provided in the line (so be warned). Any file can be uploaded, text, images, webpages, etc.}
    One-liner-length: 62
    Version: 1.0.0
    Author: "RT"
    Library: [
        level: 'beginner
        platform: none
        type: [How-to FAQ one-liner]
        domain: [ftp]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
write/binary ftp://user:pass@ftp.example.com read/binary %file
