REBOL [
    Title: "XPM parser"
    Date: 26-Mar-2002
    Version: 0.1.0
    File: %xpm.r
    Author: "oldes"
    Purpose: "Convert XPM image file to rebol image! datatype"
    Email: oliva.david@seznam.cz
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'tool 
        domain: [GUI graphics file-handling] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

xpm-to-img: func[
    "Converts XPM image file to rebol image! datatype. Returns block with image and transparent color."
    xpm-f [file! url!] "XPM file"
    /local
    xpm size colors chars-on-color pallete none-col img i tmp row col-to-bin c b bin-incr
][
    xpm-f: read xpm-f
    replace/all xpm-f "^^" "\"
    xpm: make block! 100
    parse xpm-f [
        thru "static char *" thru "= {"
        some [
            thru {"} copy tmp to {"} 1 skip
            (append xpm tmp)
        ]
        to end
    ]
    xpm/1: load xpm/1
    size: to-pair reduce [xpm/1/1 xpm/1/2]
    colors: xpm/1/3
    chars-on-color: xpm/1/4

    pallete: make hash! colors * 2
    xpm: next xpm
    
    col-to-bin: func [hex [string!] ][
        if all [hex/1 = #"#" 7 = length? hex][
            head reverse load rejoin ["#{" next hex "}"]
        ]
    ]
    
    loop colors [
        parse/all (first xpm) [
            copy c chars-on-color skip
            thru "c "
            copy b to end
            (
                repend pallete [c col-to-bin b]
            )
        ]
        xpm: next xpm   
    ]
    bin-incr: func[b][
        load rejoin ["#{" skip to-hex (1 + to-integer b) 2 "}"]
    ]
    none-col: #{000000}
    while [found? find pallete none-col][none-col: bin-incr none-col]

    for i 2 (length? pallete) 2 [
        if none? pallete/:i [poke pallete i none-col]]

    img: make binary! 3 * size/x * size/y
    while [ not tail? xpm][
        row: xpm/1
        while [not tail? row][
            c: copy/part row chars-on-color
            if none? select pallete c [probe c] ;error!
            append img select pallete c
            row: skip row chars-on-color
        ]
        xpm: next xpm
    ]
    reduce [make image! reduce [size img] none-col]
]                                                                          