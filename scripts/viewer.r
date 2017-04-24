REBOL [
    Title: "Image Viewer"
    Date: 20-May-2000
    File: %viewer.r
    Author: "Carl Sassenrath"
    Purpose: {
        A useful image viewer that shows all the jpeg, gif, bmp, png
        images found in the current directory.
    }
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

page-size: 800x600

image-file?: func ["Returns true if file is an image" file] [
    find [%.bmp %.jpg %.jpeg %.gif %.png] find/last file "."
]

files: read %.  ;-- Read local file list, but want just image files...
while [not tail? files] [
    either image-file? first files [files: next files][remove files]
]
files: head files
if empty? files [
    inform layout [backdrop 140.0.0 text bold "No images found"]
    do-events quit
]

view layout [
    size page-size
    origin 10x10
    img: image page-size - 20x50 first files effect none
    across at page-size * 0x1 + 10x-30
    arrow left 24x24 keycode 'left [
        files: back files
        name/text: first files  show name
        img/image: load first files
        show img
    ]
    arrow right 24x24 keycode 'right [
        if tail? files: next files [files: back files]
        name/text: first files  show name
        img/image: load first files  show img
    ]
    tgl: toggle "Scale" [
        img/effect: either tgl/state ['aspect][none] show img
    ]
    button "Quit" #"^(ESC)" [quit]
    name: field 300x24 form first files
]
