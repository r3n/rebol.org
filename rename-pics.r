Rebol [
    Title: "Rename & Renumber Pictures"
    file: %rename-pics.r
    purpose: "Renumber & Rename pictures in a folder"
    date: 11/05/2008
    version: 1.0.2

    library: [
        level: 'advanced
        platform: [all]
        type: [tool]
        domain: 'email
        tested-under: ["view 1.3.2.3.1"]
        support: none
        license: none
        see-also: none
    ]

    License: {Copyright (c) <2007>, <Phil Bevan>
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.}


]

gv-folder: %./
gv-files: []
gv-ofiles: []
gv-start: 10
gv-inc: 10
gv-pic-max: 200x150

fn-aspect: func [ip-size [pair!] /local x1 y1][
    ; Check x/y size
    x1: gv-pic-max/x
    y1: x1 * ip-size/y / ip-size/x
    either y1 <= gv-pic-max/y [
        return to pair! reduce [x1 y1]
    ][
        y1: gv-pic-max/y
        x1: ip-size/x * y1 / ip-size/y
        return to pair! reduce [x1 y1]
    ]
]

fn-save-flr: func [][write %rename-pics.ini to string! gv-folder]

fn-init-flr: func [][
    either exists? %rename-pics.ini
    [gv-folder: to file! read %rename-pics.ini]
    [gv-folder: %./]
    if not exists? gv-folder [gv-folder: %./]
]

fn-fetch-files: func [/new-fldr /local lv-fldr][
        if new-fldr [
            lv-fldr: request-dir/dir gv-folder
            if lv-fldr <> none [gv-folder: lv-fldr]
        ]
        if gv-folder = none [return]
        either gv-folder = %./ [f-folder/text: to string! gv-folder]
        [f-folder/text: to string! second split-path gv-folder]
        fn-read-files
        fix-slider f-list
        clear f-list/picked
        f-data/text: ""
        fn-high-first
        show [f-list f-data f-folder]
        fn-save-flr
]

fn-read-files: func [/local lv-files sfx lv-file name sh-name][
    clear gv-files
    clear gv-ofiles
    lv-files: sort read gv-folder
    foreach lv-file lv-files [
        sfx: suffix? lv-file
        if any[sfx = %.jpg sfx = %.gif sfx = %.bmp sfx = %.png sfx = %.jpeg] [
            name: copy to-string lv-file
            append gv-files name
            append gv-ofiles lv-file
        ]
    ]
]


; fix slider when text list is updated
fix-slider: func [faces [object! block!] /noreset]
[
    foreach lv-list to-block faces
    [
        if not noreset
        [
            lv-list/sld/data: 0
            lv-list/sn: 0
            lv-list/sld/redrag lv-list/lc / max 1 length? head lv-list/lines
        ]
        show lv-list
    ]
]

fn-up: func [/local curr lv-file][
    if (length? f-list/picked) > 0 [
        curr: find gv-files f-list/picked
        if (index? curr) = 1 [return]
        idx: index? curr
        remove curr
        curr: back curr
        insert curr first f-list/picked
        curr: skip gv-ofiles (idx - 1)
        lv-file: copy first curr
        remove curr
        curr: back curr
        insert curr lv-file
        show f-list
    ]
]

fn-down: func [][
    if (length? f-list/picked) > 0 [
        curr: find gv-files f-list/picked
        if (index? curr) = length? gv-files [return]
        idx: index? curr
        remove curr
        curr: next curr
        insert curr first f-list/picked
        curr: skip gv-ofiles (idx - 1)
        lv-file: copy first curr
        remove curr
        curr: next curr
        insert curr lv-file
        show f-list
    ]
]

fn-refocus: func [][
    focus f-data
    system/view/caret: f-data/text
    system/view/highlight-start: tail f-data/text
    system/view/highlight-end: tail f-data/text
]

fn-update: func [/local ind sfx osfx][
    ind: index? find gv-files first f-list/picked
    sfx: skip f-data/text ((length? f-data/text) - 4)
    osfx: to string! suffix? pick gv-ofiles ind
    if sfx <> osfx [f-data/text: rejoin[f-data/text osfx]]
    poke gv-files ind f-data/text
    clear f-list/picked
    append f-list/picked f-data/text
    fn-refocus
    show [f-list f-data]
]

fn-rename: func [/ok /prt /local count from-file new-file dups new-file-p][
    dups: copy []
    count: gv-start
;rename with qzwx-
    for i 1 length? gv-files 1 [

        to-file: fn-strip to string! gv-files/:i
        from-file: rejoin[gv-folder gv-ofiles/:i]
        new-file: to file! rejoin [fn-pad count " " to-file] ; new file name
        new-file-p: to file! rejoin ["qzwx-" new-file]
        append/only dups reduce[ rejoin[gv-folder new-file-p] new-file]
        if prt [print [from-file " ---> " new-file exists? new-file]]
        if ok [rename from-file new-file-p]
        count: count + gv-inc
    ]

    ; rename without qzwx-
    if any[ok][
    	foreach dup dups [
            if ok [rename dup/1 dup/2]
    	]
    ]
    ; refresh list
    fn-fetch-files
]

fn-pad: func [ip-int [integer!]][
    outstr: to-string ip-int
    while [4 > length? outstr] [
        outstr: rejoin ["0" outstr]
    ]
    return outstr
]

fn-strip: func [ip-str [string!] /local i][
    i: 0
    for j 1 length? ip-str 1 [
        if ip-str/:j = #" " [i: j + 1 break]
        if none = find "1234567890" ip-str/:j [i: j break]
    ]
    ip-str: skip ip-str (i - 1)
]

fn-high-up: func [/local lv-file][
    if 0 = length? f-list/picked [return]
    lv-file: first f-list/picked
    curr: find f-list/data lv-file
    if 1 = index? curr [return]
    fn-update
    clear f-list/picked
    append f-list/picked first back curr
    f-data/text: first f-list/picked
    fn-refocus
    show [f-list f-data]
    fn-fit-image
]

fn-high-down: func [/local lv-file][
    if 0 = length? f-list/picked [return]
    lv-file: first f-list/picked
    curr: find f-list/data lv-file
    if (length? gv-files) = index? curr [return]
    fn-update
    clear f-list/picked
    append f-list/picked first next curr
    f-data/text: first f-list/picked
    fn-refocus
    show [f-list f-data]
    fn-fit-image
]

fn-high-first: func [][
    if 0 < length? gv-files [
        append f-list/picked first gv-files
        f-data/text: first gv-files
        focus f-data
    ]
    fn-fit-image
]

fn-fit-image: func [/local lv-file idx][
    if 0 = length? f-list/picked [return]
    idx: index? find gv-files first f-list/picked
    lv-file: gv-ofiles/:idx
    lv-file: rejoin [gv-folder lv-file]
    lv-image: load/all lv-file
    f-image/size: fn-aspect lv-image/size
    f-image/image: lv-image
    show f-image
]

; initial folder
fn-init-flr

; Read the initial files
fn-read-files

;create the layout
lv-lay: layout [
    style btnf btn 200
    backdrop 0.200.0
    origin 4x4
    space 4x0

;    sensor keycode [page-down page-up home end #"^D" #"^A"]
    sensor keycode [up down F1 F2 F5]
    [
        switch value
        [
            F1 [fn-up]
            F2 [fn-down]
            F5 [fn-rename/ok]
            up [fn-high-up]
            down [fn-high-down]
        ]
    ] 0x0

    across
    f-folder: info white to string! gv-folder 604
    return
    panel [
        across
        space 0x0
        f-list: text-list 400x400 data gv-files [f-data/text: value focus f-data show f-data fn-fit-image]
        return
        f-data: field [fn-update] 350
        arrow down 25x25 [fn-down]
        arrow up 25x25 [fn-up]
    ] 400x430

    panel [
        btnf "Renumber (F5)" [fn-rename/ok] 200x40
        f-image: image help.gif gv-pic-max
        space 0x0
        btnf "Change Folder" [fn-fetch-files/new-fldr]
        space 0x20
        btnf "Print" [fn-rename/prt]
        space 0x0
        vtext "F1=Up"
        vtext "F2=Down"
    ] 200x430
]

either gv-folder = %./
[f-folder/text: to string! gv-folder]
[f-folder/text: to string! second split-path gv-folder]

fn-high-first

; display the layout
view/title lv-lay "Rename pictures in a folder"