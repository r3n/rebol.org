REBOL [
    Title: "Text Editor"
    Date: 4-Jun-2000
    File: %text-edit.r
    Author: "Carl Sassenrath"
    Purpose: {A basic text editor with: cut, copy, paste, horizontal and vertical scrolling, URLs as file names (for FTP remote editing), shortcut keys and a dialog box for file save confirmation.}
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'Tool 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
]

size: 0x0
file: none

view layout [
    h2 "Simple REBOL Text Editor..."
    box  656x4 effect [gradient 1x0 200.0.0]
    across space 6
    text bold "File:" f1: field 400x24 [
        file: either find f1/text ":" [to-url f1/text][to-file f1/text]
        if error? try [t1/text: read file][t1/text: copy ""]
        t1/line-list: none  show t1  size: size-text t1
    ]
    button "Save" 60x24 #"^S" [if file [write file t1/text]]
    button "Do" 60x24 [do t1/text]
    button "Quit" 60x24 #"^Q" [
        either all [none? file t1/text not empty? t1/text]
            [file: %temp-edit.txt][quit]
        inform layout [
            backdrop 200.50.50
            text rejoin ["Do you want to save " file "?"]
            button "Yes" [write file t1/text hide-popup]
            button "No" [hide-popup quit]
        ]
    ]
    return h1: space 0
    t1: area 640x480 with [
        color: 240.240.240 
        font: [name: font-fixed]
        feel: make feel [redraw: none]
    ] para [origin: 4x4]
    s1: slider 16x480 [
        probe s1/data
        t1/para/origin/y: s1/data - 1 * (negate size/y) - size/y + 2 show t1
    ]
    at (h1 + 0x480) s2: slider 640x16 [
        t1/para/origin/x: s2/data - 1 * (negate size/x) - size/x + 2
        t1/line-list: none show t1
    ]
]

