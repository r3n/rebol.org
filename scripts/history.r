REBOL [
    Title: "Library History"
    Date: 27-May-2001/11:20-7:00
    Version: 1.0.1
    File: %history.r
    Author: "Carl Sassenrath"
    Purpose: {Show file change dates for the REBOL public library.
Click on a file to view it.
}
    Email: carl@rebol.com
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: [ldc DB GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

site: http://www.reboltech.com/
file: %add-script-log.txt

cnt: 0
files: []

either data: request-download site/library/:file [
    data: to-string data
    write file data
][
    either exists? file [
        alert "Using local copy of library history."
    ][
        alert "History log could not be downloaded."
        quit
    ]
]

history: []
foreach line read/lines file [
    if not find/match line "%" [insert line "%"]
    if all [not error? try [line: load line] file? line/1 date? line/2] [
        if not tuple? last line [append line 0.0.0.0]
        insert history line
    ]
]

local-time: func [t] [
    if not date? t [return 1/1/1900-0:00]
    t - t/zone + now/zone
]

ed-file: func [file] [
    file: join %scripts/ file
    read-thru/update/to site/library/:file file
    editor file
]

out: center-face layout [
    origin 0x0 space 0x0 across
    backcolor silver
    return space 0
    txt snow black "File" 160 bold
    txt snow black "Date" 80 center bold
    txt snow black "Time" 80 center bold
    txt snow black 16
    return
    lst: list 320x400 [
        origin 0 space 0x0 across
        txt bold 160 [ed-file file]
        txt 80 center para [origin: margin: 0x2]
        txt 80 center para [origin: margin: 0x2]
    ] supply [
        count: count + cnt
        face/color: ivory
        face/text: none
        if even? count [face/color: ivory - 50.50.50]
        if count * 3 > (length? history) [exit]
        set [file dat] at history count * 3 - 2
        face/text: do pick [
            [file]
            [dat/date]
            [dat/time]
        ] index
    ]
    sld: slider 16x400 [
        c: to-integer value * (length? history) / 3
        if c <> cnt [cnt: c show lst]
    ] return
]

view out
