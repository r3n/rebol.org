REBOL [
    Title: "Text File Viewer"
    Date: 31-May-2001
    Version: 1.0.2
    File: %text-view.r
    Author: "Carl Sassenrath"
    Purpose: {A simple scrolling text file viewer. (Updated from 20-May-2000 version.)}
    Email: carl@pacific.net
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [GUI text-processing file-handling] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

size: 0x0

view layout [
    backcolor silver
    h2 "Text File Viewer..."
    box 656x4 effect [gradient 1x0 200.0.0 0.0.0]
    across space 2x6
    txt bold "File:" f1: info 300x24 "Click here to select a file." feel [
        engage: func [f a e] [
            if a = 'down [
                file: request-file
                if any [none? file empty? file] [exit]
                f1/text: file: file/1
                t1/text: sz: size? file  show t1
                t2/text: modified? file  show t2
                t3/para/scroll: 0x0
                t3/text: either sz [detab read file][none]
                t3/line-list: none
                s1/data: 0
                show [f1 t1 t2 t3 s1]
                size: size-text t3
                ]
        ]
    ]
    text bold "Size:"  t1: text 60
    text bold "Date:"  t2: text 160
    return space 0
    t3: vtext 640x480 white 0.0.80
    s1: slider 16x480 [
        t3/para/scroll/y: s1/data - 1 * (negate size/y) - size/y + 2 show t3
    ]
]

