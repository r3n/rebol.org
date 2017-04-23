REBOL [
    Title: "RAR parser"
    Date: 3-Dec-2001/13:40:57+1:00
    Version: 0.1.1
    File: %rar.r
    Author: "Oldes"
    Usage: "rar/examine  %some-archive.rar"
    Purpose: {Just if you need to search inside your RAR archives (for example)}
    Email: oliva.david@seznam.cz
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: 'file-handling 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

rar: context [
    ;---- variables -----
    HEAD_CRC: HEAD_FLAGS: HEAD_SIZE: RESERVED1: RESERVED2:
    COMM: DICT_SIZE: PACK:_SIZE UNP_SIZE: HOST_OS: FILE_CRC:
    FTIME: UNP_VER: METHOD: NAME_SIZE: ATTR: FILE_NAME:
    COMM_CRC: INFO: SUB_TYPE: DATA: none
    s: hs: 0
    
;event handlers - modify it if you need some other functionality 
on-parse-file_head: does [
    if integer? DICT_SIZE [
        print [
            pad/left File_Name 25
            pad PACK_SIZE 8 "/" pad/left UNP_SIZE 8
            pad/left msdate-to-date FTIME 20
            OS/:HOST_OS get-int UNP_VER METHOD
        ]
    ]
]
on-parse-MAIN_HEAD: does [
    if HEAD_FLAGS/6 = #"1" [print "Authenticity information present"]
]
on-parse-COMM_HEAD:  does [probe comm]
on-parse-EXTRA_INFO: does [probe info]
on-parse-SUBBLOCK: none
;----------------------------------------------------------------


    ;---- help functions -----
    get-int: func[i][to-integer head reverse to-binary i]
    ;-------------------------
    dict_sizes: [
        "000" 64
        "001" 128
        "010" 256
        "011" 512
        "100" 1024
        "111" ["dir"]
    ]
    OS: ["MS DOS" "OS/2" "Win32" "Unix"] 
    Packing_methods: [
        "0" "storing"
        "1" "fastest compression"
        "2" "fast compression"
        "3" "normal compression"
        "4" "good compression"
        "5" "best compression"
    ]

;-----PARSE RULES------

    ;Marker block
MARK_HEAD: to-string #{526172211A0700}

    ;Archive header 
MAIN_HEAD: [
    copy HEAD_CRC   2 skip
    #{73}   ;type
    copy HEAD_FLAGS 2 skip (HEAD_FLAGS: enbase/base head reverse HEAD_FLAGS 2)
    copy HEAD_SIZE  2 skip (HEAD_SIZE: get-int HEAD_SIZE hs: HEAD_SIZE - 13)
    copy RESERVED1  2 skip
    copy RESERVED2  4 skip
    copy COMM       hs skip (if not none? COMM [parse COMM [any [COMM_HEAD]]])
    ( on-parse-MAIN_HEAD )
]

    ;File header (File in archive)
FILE_HEAD: [
    copy HEAD_CRC   2 skip
    #{74}   ;type
    copy HEAD_FLAGS 2 skip (
        HEAD_FLAGS: enbase/base head reverse HEAD_FLAGS 2
        DICT_SIZE: switch copy/part at HEAD_FLAGS 9 3 dict_sizes
    )
    copy HEAD_SIZE  2 skip (HEAD_SIZE: get-int HEAD_SIZE)
    copy PACK_SIZE  4 skip (PACK_SIZE: get-int PACK_SIZE)
    copy UNP_SIZE   4 skip (UNP_SIZE:  get-int UNP_SIZE)
    copy HOST_OS    1 skip (HOST_OS: 1 + get-int HOST_OS)
    copy FILE_CRC   4 skip
    copy FTIME      4 skip
    copy UNP_VER    1 skip
    copy METHOD     1 skip
    copy NAME_SIZE  2 skip (s: get-int Name_size)
    copy ATTR       4 skip
    copy FILE_NAME  s skip
    ( hs: Head_size - 32 - s )
    copy COMM       hs skip (if not none? COMM [parse COMM [any [COMM_HEAD]]])
    PACK_SIZE skip
    ( on-parse-FILE_HEAD )
]
    ;Comment block
COMM_HEAD: [
    copy HEAD_CRC   2 skip
    #{75}   ;type
    copy HEAD_FLAGS 2 skip (HEAD_FLAGS: enbase/base head reverse HEAD_FLAGS 2)
    copy HEAD_SIZE  2 skip ( hs: (get-int HEAD_SIZE) - 13 )
    copy UNP_SIZE   2 skip
    copy UNP_VER    1 skip
    copy METHOD     1 skip
    copy COMM_CRC   2 skip
    copy COMM       hs skip
    (on-parse-COMM_HEAD)
]
    ;Extra info block
EXTRA_INFO: [
    copy HEAD_CRC   2 skip
    #{76}   ;type
    copy HEAD_FLAGS 2 skip (HEAD_FLAGS: enbase/base head reverse HEAD_FLAGS 2)
    copy HEAD_SIZE  2 skip ( hs: (get-int HEAD_SIZE) - 7 )
    copy INFO       hs skip
    (on-parse-EXTRA_INFO)
]
    ;Subblock
SUBBLOCK: [
    copy HEAD_CRC   2 skip
    #{77}   ;type
    copy HEAD_FLAGS 2 skip (HEAD_FLAGS: enbase/base head reverse HEAD_FLAGS 2)
    copy HEAD_SIZE  2 skip ( hs: (get-int HEAD_SIZE) - 7 )
    copy DATA_SIZE  4 skip (DATA_SIZE: get-int DATA_SIZE)
    copy SUB_TYPE   2 skip
    copy RESERVED1  1 skip
    copy DATA       DATA_SIZE skip
    (on-parse-SUBBLOCK)
]

;-----MAIN FUNCTION----
    examine: func[
        "Prints the content of the RAR archive"
        rar-file [file! url!]   "RAR file to parse"
        /local
    ][
        parse/all read/binary rar-file [
            thru MARK_HEAD
            any [MAIN_HEAD | FILE_HEAD | COMM_HEAD | EXTRA_INFO | SUBBLOCK]
        ]
        recycle
    ]
] ;end of context

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