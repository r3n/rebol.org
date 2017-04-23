REBOL [
    Title: "PNG Examiner"
    Date: 25-Nov-2001
    Version: 0.0.2
    File: %png.r
    Home: http://oldes.multimedia.cz/rur/download/
    Author: "oldes"
    Purpose: {Basic PNG (Portable Network Graphics) parser which can show all informations from standard chunks in the file. 
 }
    History: [
    0.0.2 [25-Nov-2001 "Fixed small bug in parsing textual data." "oldes"] 
    0.0.1 [31-Aug-2000 "Initial version" "oldes"]
]
    Email: oliva.david@seznam.cz
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: 'file-handling 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

if empty? png-file: to-file ask "PNG file: " [png-file: %/d/test.png]
png-bin: read/binary png-file

png: make object! [
    header: none
    Color-type: none
    Color-types: [
        0 "grayscale, without alpha"
        2 "truecolor, without alpha"
        3 "indexed color"
        4 "grayscale, with alpha"
        6 "truecolor, with alpha"
    ]
    chunks: make block! 6
    chunk: make object! [
        length: none
        type:   none
        data:   none
        CRC:    none
    ]
    chunk-bytes: [
        "IHDR" [4 4 1 1 1 1 1]
        "PLTE" []
        "IDAT" []
        "IEND" []
        
        "cHRM" [4 4 4 4 4 4 4 4]
        "gAMA" [4]
        "sBIT" []
        "bKGD" []
        "hIST" []
        "tRNS" []
        "pHYs" [4 4 1]
        "tIME" [2 1 1 1 1 1]
        "tEXt" []
        "zTXt" []
    ]
    
]

print ["PNG size:" length? png-bin "bytes"]

png/header: copy/part png-bin 8
png-bin: skip png-bin 8
if png/header <> #{89504E470D0A1A0A} [print "Illegal PNG header!" halt]

;help functions:
getpart: func[bytes /local tmp][
    tmp: copy/part png-bin bytes 
    png-bin: skip png-bin bytes
    tmp
]

slice-bin: func [bin bytes /integers /local tmp b][
    tmp: make block! length? bytes
    forall bytes [
        b: copy/part bin bytes/1
        append tmp either integers [to-integer b][b]
        bin: skip bin bytes/1
    ]
    tmp
]
extract-data: func[type][
    png/chunk/data: slice-bin/integers png/chunk/data select png/chunk-bytes type
]
;end of help functions

prin "Searching for chunks... "


while [not tail? png-bin][
    png/chunk/length:   to-integer getpart 4    ;length
    png/chunk/type:     to-string getpart 4     ;type
    png/chunk/data:     getpart png/chunk/length    ;data
    png/chunk/CRC:      getpart 4   ;CRC

    repend png/chunks [png/chunk/length png/chunk/CRC png/chunk/type]
    switch png/chunk/type [
        "IHDR" [extract-data "IHDR"]    ;Image header
        "sBIT" []                       ;Significant bits
        "pHYs" [extract-data "pHYs"]    ;Physical pixel dimensions
        "cHRM" [extract-data "cHRM"]    ;Primary chromaticities and white point
        "gAMA" [extract-data "gAMA"]    ;Image gamma
        "hIST" []                       ;Image histogram
        "tEXt" [;Textual data
            parse/all png/chunk/data [copy k to #"^@" 1 skip copy d to end]
            png/chunk/data: reduce [k d]
        ]
        "tIME" [;Image last-modification time
            extract-data "tIME"
            png/chunk/data: to-date rejoin [png/chunk/data/3 "-" png/chunk/data/2 "-" png/chunk/data/1 "/" png/chunk/data/4 ":" png/chunk/data/5 ":" png/chunk/data/6] 
        ]
        "tRNS" [];Transparency
        "zTXt" [;Compressed textual data
            parse png/chunk/data [copy k to #"^@" 1 skip copy cm 1 skip copy d to end]
            png/chunk/data: reduce [k cm d]
        ]
    ]
    repend/only png/chunks png/chunk/data
]

print ["found" (length? png/chunks) / 4 "chunks."]
;show results:
print "-------------------------------------------"
foreach [length crc type data] png/chunks [
    switch/default type [
        "IHDR" [;Image header
            print ["Width_______________" data/1 "pixels"]
            print ["Height______________" data/2 "pixels"]
            print ["Bit depth___________" data/3]
            print ["Color type__________" data/4 "(" select png/color-types data/4 ")"]
            print ["Compression method__" data/5]
            print ["Filter method_______" data/6]
            print ["Interlace method____" data/7]
        ]
        "PLTE" [print ["Palette:   " mold data]]
        "IDAT" [print ["Image data:" length? data "B"]  ]
        "IEND" [print "Image trailer - EOF"]
        ;Ancillary chunks
        "bKGD" [print ["Background color:" mold data]]
        "cHRM" [
            print "Primary chromaticities and white point:"
            print ["  White Point x__" data/1]
            print ["  White Point y__" data/2]
            print ["  Red x__________" data/3]
            print ["  Red y__________" data/4]
            print ["  Green x________" data/5]
            print ["  Green y________" data/6]
            print ["  Blue x_________" data/7]
            print ["  Blue y_________" data/8]

        ]
        "gAMA" [print ["Image gamma:__" data]]
        "hIST" [print ["Image histogram:" data]]
        "pHYs" [;Physical pixel dimensions
            Print ["Pixels per unit, X axis: " data/1]
            Print ["Pixels per unit, Y axis: " data/2]
            Print ["Unit specifier: " data/3 "(" pick ["unknown" "meter"] (data/3 + 1)
")"]
        ]
        "sBIT" [print ["Significant bits:" data]]
        "tEXt" [print [data/1 ":" data/2]]
        "tRNS" [print ["Transparency:____" data]]
        "zTXt" [
            print "Compressed textual data:"
            print [" " data/1 data/2 data/3]
        ]
          
    ][
        either find png/chunk-bytes type [
            prin [type " "] probe data
        ][  print ["Nonstandard" either (to-integer type/2) > 88 ["private"]["public"] "chunk:" type]
        ]
    ] 
]


                                                                                                                                                                              