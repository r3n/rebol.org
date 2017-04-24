REBOL [
    Title: "ZIP explorer"
    Date: 3-Dec-2001/13:11:09+1:00
    Version: 0.1.0
    File: %zip.r
    Author: "Oldes"
    Usage: "zip/examine  %some-archive.zip ;will list the info"
    Purpose: "Shows content of some ZIP archive"
    Comment: {
^-This script does not explore all zip atributes, just search the "central directory block"
^-If you need something more you will have to look at ZIP spec. and enhance this script:
^-^-http://www.pkware.com/support/appnote.html
^-}
    Email: oliva.david@seznam.cz
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: [file-handling broken] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

zip: context [
;event handlers - modify it if you need some other functionality 
on-parse-file_head: does[show-info/file_head file_head]
on-parse-cde:       does[show-info/central_dir_end cde]
;----------------------------------------------------------------

file_HEAD: cde: none

;help functions:
get-int: func[i][to-integer head reverse copy i]

getpart: func[bytes /local tmp][
    tmp: copy/part bin bytes 
    bin: skip bin bytes
    tmp
]
;-----------------
structure: make object! [
    file_head: [
        2 ;version made by
        2 ;version needed to extract
        2 ;general purpose bit flag
        2 ;compression method
        4 ;last mod file date/time
        4 ;crc-32
        4 ;compressed size
        4 ;uncompressed size
        2 ;file name length
        2 ;extra field length
        2 ;file comment length
        2 ;disk number start
        2 ;internal file attributes
        4 ;external file attributes
        4 ;relative offset of local header
        ;file name (variable size)
        ;extra field (variable size)
        ;file comment (variable size)
    ]
    central_dir_end: [
        4 ;end of central dir signature 4 bytes (0x06054b50) 
        2 ;number of this disk
        2 ;number of the disk with the start of the central directory
        2 ;total number of entries in the central directory on this disk
        2 ;total number of entries in the central directory
        4 ;size of the central directory
        4 ;offset of start of central directory with respect to the starting disk number
        2 ;.ZIP file comment length
        ;.ZIP file comment (variable size) 
    ]
    version_made_by: [
        #{0000} "MS-DOS and OS/2 (FAT / VFAT / FAT32 file systems)"
        #{0100} "Amiga"
        #{0200} "OpenVMS"
        #{0300} "Unix"
        #{0400} "VM/CMS"
        #{0500} "Atari ST"
        #{0600} "OS/2 H.P.F.S."
        #{0700} "Macintosh"
        #{0800} "Z-System"
        #{0900} "CP/M"
        #{1000} "Windows NTFS"
        #{1100} "MVS"
        #{1200} "VSE"
        #{1300} "Acorn Risc"
        #{1400} "VFAT"
        #{1500} "Alternate MVS"
        #{1600} "BeOS"
        #{1700} "Tandem"
    ]
]
show-info: make object! [
    central_dir_end: func[cde /local n][
        if 0 < n: get-int cde/2 [   print ["Number of this disk:" n]]
        if not empty? n: last cde [ print ["ZIP comment:" mold n] ]
        print head insert/dup copy "" "-" 71
    ]
    file_head: func[fh][
        if 0 < get-int fH/8 [   ;don't show dirs
            print [
                pad/left (to-string fh/16) 25
                pad (get-int fH/7 ) 8 "/" pad/left (get-int fH/8) 8
                pad/left msdate-to-date fH/5 20 ;modified date
                select structure/version_made_by fH/1
                tab
            ]
        ]
    ]
]

examine: func[file][
    print ["ZIP file:" file]
    bin: read/binary file
    
    bin: find bin #{504b0506} ;end of central dir signature
    cde: slice-bin bin structure/central_dir_end
    
    insert tail cde to-string copy/part skip bin 22 get-int last cde
    
    on-parse-cde

    bin: skip head bin get-int cde/7 ;central directory structure

    while [#{504b0102} = getpart 4][
        file_HEAD: slice-bin getpart 42 structure/file_head
        set [L1 L2 L3] reduce [get-int file_HEAD/9 get-int file_HEAD/10 get-int file_HEAD/11]
        insert tail file_HEAD slice-bin getpart (L1 + L2 + L3) reduce [L1 L2 L3]
        on-parse-file_head
    ]
]
];end of context

;other used functions:
pad: func [arg count /left /with ch /local txt L][
    txt: make string! 10
    L: (length? form arg) - count
    either L > 0 [
        txt: join copy/part form arg (count - 3) "..."
    ][
        loop abs L [append txt either with [ch][" "]]
        either left [
            insert head txt arg
        ][
            append txt arg
        ]
    ]
    txt
]
msdate-to-date: func[
    "Converts standard MS DOS binary time to Rebol's"
    ms [binary! string!] /local to-int y m d h mi s
][
    ms: enbase/base head reverse ms 2
    to-int: func[v][
        insert/dup v "0" 8 - length? v
        to-integer debase/base head v 2
    ]
    parse ms [
        copy y 7 skip  (y: 1980 + to-int y)
        copy m 4 skip  (m: to-int m)
        copy d 5 skip  (d: to-int d)
        copy h 5 skip  (h: to-int h)
        copy mi 6 skip (mi: to-int mi)
        copy s 5 skip  (s: 2 * to-int s)
    ]
    to-date rejoin [d "-" m "-" y "/" h ":" mi ":" s]
]
slice-bin: func [bin bytes /integers /local tmp b][
    tmp: make block! length? bytes
    forall bytes [
        b: copy/part bin bytes/1
        append tmp either integers [get-int b][b]
        bin: skip bin bytes/1
    ]
    tmp
]                                                                                                                                                                           