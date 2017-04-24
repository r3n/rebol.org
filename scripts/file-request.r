REBOL [
    Title: "Simple File Requestor"
    Date: 20-May-2000
    File: %file-request.r
    Author: "Carl Sassenrath"
    Purpose: "Example of a simple file requestor."
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

files: sort read %.
forall files [
    change/only files reduce [files/1 size? files/1 modified? files/1]
]
files: head files

date-of: func [file] [file: modified? file file/date]
time-of: func [file] [file: modified? file file/time]
num: count: 0

txt-style: stylize [txt: text with [font: [size: 10 color: black shadow: none]]]

view layout [
    backdrop effect [gradient 1x1 0.0.20 0.30.120]
    text white bold join "Path:  " what-dir
    w: at
    vx: list 320x400 240.240.240 [
        styles txt-style
        size 320x14  ; should not be required!!!
        across space 0x0
        file-name: txt bold 100x14 [print file-name/text]
        txt 80x14 180.0.0 right txt 75x14 right  txt 55x14 right 
    ] supply [
        count: count + num
        face/text: either count > (1 + length? files) [""][
            do pick [
                [files/:count/1]
                [files/:count/2]
                [files/:count/3/date]
                [files/:count/3/time]
            ] index
        ]
    ]
    at w + (vx/size * 1x0)
    vv: slider 16x400 to-integer vx/size/y / file-name/size/y
        [num: vv/data * ((1 + length? files) - (vv/size/y / file-name/size/y)) show vx]
]
