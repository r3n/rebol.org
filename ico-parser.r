REBOL [
    Title: "ico-parser"
    Date: 31-Jul-2001/0:25:23+2:00
    Version: 0.0.1
    File: %ico-parser.r
    Author: "Oldes"
    Usage: {
^-^-ico-parser/file http://sweb.cz/desold/icons/Icon21.ico
^-^-ico-parser/file %Icon21.ico
^-^-;--->see script %ico-view.r how to use it}
    Purpose: "To get data from the windows *.ico files"
    Comment: {Not finnished yet, I need a help with the rest:
^-^-1. how to create transparent parts from the mask image
^-^-2. how to flip the mask image (in binary format)
^-^-... and some time to sleep as well:)
^-^-(this is probably working only for icons in 24bits color depth!)}
    Email: oldes@bigfoot.com
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: [GUI file-handling] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

ico-parser: make object! [
    
    reversed: func[w][copy head reverse w]
    
    ico: none
    icon: none
    
    specs: make object! [
        icon: [
        ;name           bytes   comment
            'Reserved       2       ;Reserved (always 0)
            'ResourceType   2       ;Resource ID (always 1)
            'IconCount      2       ;Number of icon bitmaps in file
        ]
        iconDir: [
            'Width      1       ;Width of icon in pixels
            'Height     1       ;Height of icon in pixels
            'NumColors  1       ;Maximum number of colors - If the bitmap contains 256 or more colors the value of NumColors will be 0. 
            'Reserved   1       ;Not used (always 0)
            'NumPlanes  2       ;Not used (always 0)
            'BitsPerPixel   2   ;Not used (always 0)
            'DataSize   4       ;Length of icon bitmap in bytes 
            'DataOffset 4       ;Offset position of icon bitmap in file
        ]
        BITMAPINFOHEADER: [
            'biSize     4       ;specifies the size of the BITMAPINFOHEADER structure, in bytes. 
            'biWidth    4       ;specifies the width of the image, in pixels. 
            'biHeight   4       ;specifies the height of the image, in pixels. 
            'biPlanes   2       ;specifies the number of planes of the target device, must be set to zero. 
            'biBitCount 2       ;specifies the number of bits per pixel. 
            'biCompression  4   ;Specifies the type of compression, usually set to zero (no compression). 
            'biSizeImage    4   ;specifies the size of the image data, in bytes. If there is no compression, it is valid to set this member to zero. 
            'biXPelsPerMeter    4   ;specifies the the horizontal pixels per meter on the designated targer device, usually set to zero. 
            'biYPelsPerMeter    4   ;specifies the the vertical pixels per meter on the designated targer device, usually set to zero. 
            'biClrUsed      4       ;specifies the number of colors used in the bitmap, if set to zero the number of colors is calculated using the biBitCount member. 
            'biClrImportant 4
        ]
    ]

    get-data-by-spec: func[
        "Returns block of word and values and rest of the data file"
        data    [binary!]   "Binary data for examination"
        spec    [block!]    "Specification block of words and length in bytes"
    ][
        values: make block! []
        foreach [name bytes] spec [
            repend values [name to-integer b: reversed copy/part data bytes]
            data: skip data bytes
        ]
        reduce [values data]
    ]

    file: func[
        "Main converting function"
        source-file [file! url!]
        /local tmp tmp2
        width height image-data-length
        icXor flipedicXor dataOffset i
        icAnd maskBits
    ][
        icon: either url? source-file [
            read-thru   source-file
        ][  read/binary source-file ]
        
        ico: make object! [
            icons:  0
            dirs: make block! []
            bitmapinfoheaders: make block! []
            imgs: make block! []
            masks: make block! []
        ]
    
        tmp: get-data-by-spec icon specs/icon
        ico/icons: select tmp/1 'IconCount

        loop ico/icons [
            tmp: get-data-by-spec copy tmp/2 specs/iconDir
            append/only ico/dirs tmp/1
            tmp2: get-data-by-spec skip icon select tmp/1 'DataOffset specs/BITMAPINFOHEADER
            append/only ico/bitmapinfoheaders tmp2/1
            width:  select tmp/1 'Width
            height: select tmp/1 'Height
            image-data-length: 3 * (width * height)
            dataOffset: (select tmp2/1 'biSize) + (select tmp/1 'DataOffset)
            icXor:  copy/part ( skip icon dataOffset ) image-data-length
            flipedicXor: make binary! length? icXor
            while [not tail? icXor][
                insert head flipedicXor copy/part icXor (width * 3)
                icXor: skip icXor (width * 3)
            ]
            img: make image! reduce [to-pair reduce [width height] flipedicXor]
            append ico/imgs img
            icAnd: copy/part ( skip icon dataOffset + image-data-length)
                ((select tmp/1 'DataSize) - image-data-length)
            img: make image! to-pair reduce [width height]
            maskBits: (enbase/base icAnd 2)
            for i 1 (width * height) 1 [
                if #"1" = maskBits/:i [poke img i 255.255.255]
            ]
            append ico/masks head img
        ]
        ico
    ]
]
                                                                                                                            