REBOL [
    Title: "gunzip"
    Date: 30-Dec-2004
    Version: 1.0.0
    File: %gunzip.r
    Author: "Vincent Ecuyer"
    Purpose: "Decompresses gzip archives."
    Usage: {
        write/binary %my-file.txt gunzip %my-file.txt.gz

        or

        c-data: read/binary %my-file.txt.gz
        my-data: gunzip c-data
    }
    Comment: {
        It only works with rebol/view or rebol/face.

        PiNG file format uses "deflate" compression,
        like gzip and Rebol COMPRESS command.
        
        This hack builds a PiNG picture with the compressed data,
        loads it, then extracts the uncompressed data.
        
        Tested with .gz files from %gzip.r,
        gzip32 1.2.4 and 7-Zip 3.13.
    }
    Library: [
        level: 'advanced
        platform: 'all
        type: [module tool]
        domain: [compression file-handling files]
        tested-under: [
        	view 1.2.1.3.1  on [Win2K]
        	view 1.2.1.1.1  on [AmigaOS30]
        	face 1.2.48.3.1 on [Win2K]
        ]
        support: none
        license: 'public-domain
        see-also: %gzip.r
    ]
]

ctx-gunzip: context [
    to-bin: func [value][load join "#{" [to-hex value "}"]]
    set?: func [value bit][not zero? value and to-integer 2 ** bit]
    os-codes: [
        'FAT 'Amiga 'VMS 'Unix 'VM/CMS 'Atari-TOS 'HPFS 'Macintosh
        'Z-System 'CP/M 'TOPS-20 'NTFS 'QDOS 'Acorn-RISCOS
    ]

    set 'gunzip func [
        "Decompresses a gzip encoding - returns a binary."
        data [any-string! file!] "Data to decompress"
        /info "Returns a block with [data filename date comment OS]"
        /local flags os filename filecomment time size r
    ][
        if not all [value? 'view? view?][make error! "/View needed"]
    
        if string? data [data: to-binary data]
        if file? data [data: read/binary data]

        if data/1 <> 31 [make error! "Bad ID"]
        if data/2 <> 139 [make error! "Bad ID"]
        if data/3 <> 8 [make error! "Unknown Method"]

        flags: data/4

        time: to-integer head reverse copy/part skip data 4 4
        time: either zero? time [none][
            01-01-1970/0:0:0 + now/zone + to-time time
        ]

        os: pick os-codes data/10 + 1

        filename: filecomment: none

        data: skip data 10
        if set? flags 2 [ ; extra?
            data: skip data 2
            data: skip data data/2 * 256 + data/1 + 2
        ]
        if set? flags 3 [ ; name?
            filename: data
            data: find/tail data #"^@"
            filename: copy/part filename back data
        ]
        if set? flags 4 [ ; comment?
            filecomment: data
            filecomment: find/tail data #"^@"
            filecomment: copy/part filecomment back data
        ]
        if set? flags 1 [ ; crc-16?
            data: skip data 2
        ]

        size: to-integer head reverse copy skip tail data -4

        data: copy/part data skip tail data -8

        data: to-binary rejoin [
            #{89504E47} #{0D0A1A0A} ; signature
            #{0000000D} ; IHDR length
            "IHDR" ; type: header
            to-bin size ; width = uncompressed size
            #{00000001} ; height = 1 line
            #{08} ; bit depth
            #{00} ; color type = grayscale
            #{00} ; compression method
            #{00} ; filter method = none
            #{00} ; interlace method = no interlace
            #{00000000} ; no checksum
            to-bin 2 + 6 + length? data ; length
            "IDAT" ; type: data
            #{789C} ; zlib header
            #{00 0100 FEFF 00} ; 0 = no filter for scanline
            data
            #{00000000} ; no checksum
            #{00000000} ; length
            "IEND" ; type: end
            #{00000000} ; no checksum
        ]

        if error? try [data: load data][
            make error! "Unable to decompress"
        ]
        
        r: make binary! size
        repeat i size [insert tail r to-char pick pick data i 1]

        either info [
            reduce [
                r
                either filename [to-file filename][none]
                time
                either filecomment [to-string comment][none]
                either os [os]['Unknown]
            ]
        ][r]
    ]
]
