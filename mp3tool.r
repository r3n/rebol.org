REBOL [
    Title: "mp3tool"
    Date: 15-May-2002/4:18:41-4:00
    Version: 1.0.0
    File: %mp3tool.r
    Author: "Vache"
    Purpose: {I have seen an ID3 reader in every language (C, Perl, Python, PHP), and decided I might as well write one for REBOL. It is very simplistic at the moment}
    Email: vache@bluejellybean.com
    library: [
        level: [intermediate advanced] 
        platform: none 
        type: 'tool 
        domain: 'file-handling 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

file: read to-file ask "file: "

id3: remove/part file (length? file) - 128  ; ID3 v1.x tags use the last 128 bytes of an MP3.

either found? find id3 "TAG" [
    remove/part id3 3
    tag: make object! [
        title:   copy/part id3 30 (id3: skip id3 30)
        artist:  copy/part id3 30 (id3: skip id3 30)
        album:   copy/part id3 30 (id3: skip id3 30)
        year:    copy/part id3 4  (id3: skip id3 4)
        comment: copy/part id3 28 (id3: skip id3 28)
        genre:   copy/part id3 2

        ; About the Genre tag--This isn't working. For some reason I can't get it to read correctly. I'd love some help on this.
        ; There are 79 ISO genres, and 80 thru 125 are "Winamp" extensions. www.id3.org/id3v2.3.0.html
    ]
][
    print "This file does not have a valid ID3 v1.x tag."
    exit
]

halt                                 