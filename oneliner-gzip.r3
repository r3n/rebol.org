REBOL [
    Title: "Simple gzip archiver"
    Date: 9-Jan-2013
    File: %oneliner-gzip.r3
    Purpose: "Creates gzip archives, 1-line r3 version."
    One-liner-length: 157
    Version: 1.0.0
    Author: "Vincent Ecuyer"
    Usage: {
        my-data: #{........}
        write %test.gz gzip my-data
    }
    Comment: {
        Limitations:

        - REBOL 3 only
        - No filename in archive
        - No timestamp in archive
    }
    Library: [
        level: 'advanced
        platform: 'all
        type: [tool]
        domain: [compression file-handling files]
        tested-under: [ 
            core 2.100.111.2.5 on [Macintosh osx-x86]
            core 2.101.0.2.5 on [Macintosh osx-x86]
        ]
        support: none
        license: 'public-domain
        see-also: none
    ]
]
gzip: func [value [binary!]][head change at tail join #{1F8B08000000000002FF} skip compress value 2 -8 reverse skip to-binary checksum/method value 'crc32 4]

;Slighty shorter form (131 bytes):
; gz: func[v][head change at tail join #{1F8B08000000000002FF}skip compress v 2 -8 reverse skip to-binary checksum/method v 'crc32 4]
