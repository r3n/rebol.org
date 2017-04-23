Rebol [
    Title: "Upload all files in a directory with FTP"
    Date: 20-Jul-2003
    File: %oneliner-ftp-upload-dir.r
    Purpose: {Uploads all the files in a directory using FTP. Files can be text, images, web pages,
anything... but not directories.}
    One-liner-length: 111
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
foreach file load %./ [if not dir? file [write/binary join ftp://user:pass@example.com/ file read/binary file]]
