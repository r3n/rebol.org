REBOL [
    Title: "Image Sorter"
    Date: 30-May-2001
    Version: 1.1.0
    File: %image-sort.r
    Author: "Carl Sassenrath"
    Purpose: {A handy tool for sorting images into separate directories
or deleting images.  Includes scrolling list of image
files with highlight and scrolling list of target directories.
Also uses cursor keys, space, and backspace for navigation.
}
    Email: carl@rebol.com
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: [GUI file-handling] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

howto: {
    Click on a file in the upper list to view the image.
    You can use the arrow, space, or backspace keys to change images.

    Click the Scale button to scale all images to fit the window.
    
    To move an image, select a directory name from the lower list.
    The file will be moved to that directory.
    
    Click on the delete button or key to immediately delete an image.
}

files: []
dirs: []
a-file: none
dirn: num: 0 ; scroll offsets
date-of?: func [f] [all [f: modified? f  f/date]]

show-img: does [
    if a-file [
        img/text: none
        img/image: load root/:a-file
        name/text: reform [
            a-file "-" img/image/size "-" size? root/:a-file "bytes -" date-of? root/:a-file]
        show [name img]
    ]
    show l1
]

move-file: func [/move dir] [
    if a-file [
        if move [write/binary root/:dir/:a-file read/binary root/:a-file]
        remove dir: find files a-file
        delete root/:a-file
        if tail? dir [dir: back dir]
        a-file: pick dir 1 ; could be none
    ]
    show-img
]

next-file: func [/reverse /local file] [
    either none? a-file [
        a-file: files/1
        show l1
    ][
        if a-file: all [
            file: find files a-file
            file: either reverse [back file] [
                either tail? next file [file] [file: next file]
            ]
            pick file 1  ; could be none
        ][
            if (index? file) <= num [num: max 0 num - 1]
            if (index? file) > (num + max-files) [num: num + 1]
            show l1
        ]
    ]
    show-img
]

until [
    root: request-file/title "Pick a directory by picking any file in it." "View"
    if not root [quit]
    if empty? root [alert "You must select a file in the directory."]
    not empty? root
]

root: first split-path first root

files: read root
while [not tail? files] [  ; find dirs and images
    file: files/1
    any [
        all [dir? root/:file  append dirs file  remove files]
        all [find [%.bmp %.jpg %.gif %.png] find/last file "."
            files: next files
        ]
        remove files
    ]
]
files: head files

out: center-face layout [
    style bx text white 40.40.40 bold center middle 120x20
    backcolor pewter

    across at 20x20
    h2 "Image Sorter" center 120
    pad 10
    name: info 450x24 ivory center
    sensor 1x1 keycode [right down #" "] [next-file]
    sensor 1x1 keycode [left up #"^(back)"] [next-file/reverse]
    button "Delete File" 160.0.0 #"^(del)" [move-file]
    tog: toggle "Scale" [
        img/effect: either tog/state [[aspect]][none] show img
    ]
    button "Close" #"^(ESC)" [quit]

    return  space 0  pad 0x10
    t0: bx "Image Files" return
    l1: list 120x400 [
        t1: text 116x14 font [size: 10 color: black shadow: none] [
            a-file: t1/text  t1/font/color: black  show-img
        ]
    ] supply [
        count: count + num
        t1/color: either all [t1/text: files/:count  t1/text = a-file][
            yellow] [l1/color]
    ]
    do [max-files: to-integer 400 / 14]
    s1: slider l1/size * 0x1 + 16x0 length? files [num: s1/data * length? files show l1]

    return pad 0x10
    bx "Move Image To" return
    l2: list 120x150 [
        t2: txt 116x14 font-size 10 [move-file/move t2/text]
    ] supply [count: count + dirn t2/text: dirs/:count] 
    s2: slider l2/size * 0x1 + 16x0 length? dirs [dirn: s2/data * length? dirs show l2]

    return
    at t0/offset + 140x0
    img: box howto 800x600 40.40.40 effect none frame 100.100.100
    ;do [a-file: files/1 show-img]
]

if empty? files [name/text: "No image files found."]
view out
