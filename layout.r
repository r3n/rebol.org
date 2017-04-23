REBOL [
    Title: "REBOL/Layout"
    Date: 29-Jan-2001
    Version: 0.1.7
    File: %layout.r
    Author: "Carl Sassenrath"
    Purpose: "Visual Layout Editor"
    Email: carl@rebol.com
    Copyright: "REBOL Technologies 2000 - All rights reserved."
    library: [
        level: 'advanced 
        platform: none 
        type: none 
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

instructions:
{
- Click on NEW. Provide a project name. Click Ok.
- Provide a page name.  New page appears on screen.
- Open the Styles menu on the left.
- Click backdrops to pick an image from local directory. Limit: 12
- Click on other styles as needed: text, images, gadgets (more to come)
- Drag or resize faces as needed.
- Set other facet attributes.
- Arrow keys can be used to nudge.
- Check Prefs for other features like grid-snap.
- To edit face text: pick an item, type chars, or press Text (ctrl-T)
- Save file OFTEN! Still some bugs.

To delete to items, select them, then press delete key.
}

;--- Globals:

prefs-file: %layout-prefs.r

base-color: 210.190.170
menu-bar-color: 80.0.0
menu-arrow-color: 80.0.0
menu-button-color: 30.50.110

this-face: none
nub-size: 6x6
nub-color: 250.120.40
dup-space: 0x10
grid-snap: 5x5
nudge-size: 1x1
stickyness: 5x5
face-hold: none
layout-window: none
text-mode: off
auto-expand: on
icon-size: 96x96
exclude-styles: [window backdrop backtile]
face-file: %untitled.r
this-script: none
dirty: false
page-name: none

if exists? prefs-file [do prefs-file]

nub-size2: 2 * nub-size

as-x: func [pair] [pair * 1x0]
as-y: func [pair] [pair * 0x1]

t: get-style 'toggle

main-styles: stylize [
    sbt: txt 120x24 bold middle black base-color font [colors: [0.0.0 80.80.200]] ; !!! prevents odd bar from appearing in stlyes!
    lab: sbt 80x24 right
    fld: field 120x24
    nfld: fld with [color: 240.240.240 feel: none]
    cat: txt 200x20 bold white menu-bar-color
    btn: button 50 menu-button-color
    tgl: toggle 24x24 menu-button-color 240.128.24
    awu: tgl effect [fit arrow 240.240.240]
    awr: tgl effect [fit arrow 240.240.240 rotate 90]
    awd: tgl effect [fit arrow 240.240.240 rotate 180]
    awl: tgl effect [fit arrow 240.240.240 rotate 270]
    rty: rotary 120x24 menu-button-color
    sens: txt 120x24 black 240.240.240 edge [size: 2x2 effect: 'ibevel color: 110.120.130]
    xx: check
    cls: box 120x24 white font [size: 12 style: none align: 'left shadow: none color: black] ibevel
;   cls: txt 240.240.240 ibevel  ;!!! bug: ibevel does not work, because no edge!
;   cls: box 120x24 white ibevel font [size: 12 shadow: none color: black] ; bug!!! does not pick up font change!
;   !!!need PLAIN style
]


;--- Main Menuing System:

clone-facet: func [facet /local fac][
    fac: this-face
    if not block? fac/flags [fac/flags: copy []]
    if not find fac/flags facet [ ;print 'cloned
        set in fac facet make any [fac/:facet face/:facet] []
        append fac/flags facet
    ]
    fac/:facet
]

if-try: func [conv fix good] [if error? try conv fix  do good]

set-in: func [facet var val /local f][
    f: this-face
    if all [var var <> 'none] [
        f: clone-facet facet
        facet: var
    ]
    this-face/line-list: none
    set in f facet val
    update-face
]

set-pair: func [fld 'facet 'var][
    if-try [fld: to-pair load fld/text][fld: 1x1][set-in facet var fld]
]

put-pair: func [fld 'facet][
    if-try [fld: to-pair load fld/text][fld: 1x1][set facet fld]
]

set-int: func [fld 'facet 'var][
    if-try [fld: to-integer load fld/text][fld: 10][set-in facet var fld]
]

blockify: func [obj fld /local tmp][
    if not block? tmp: get in obj fld [
        tmp: either tmp [reduce [tmp]][copy []]
        set in obj fld tmp
    ]
]

set-font-var: func ['var val] [
    clone-facet 'font
    set in this-face/font var val
    this-face/line-list: none
    update-face
]

set-font-style: func [fld 'word /local tmp][
    if none? this-face [exit]
    clone-facet 'font
    tmp: this-face/font/style
    blockify this-face/font 'style
    either fld/data [if not find tmp word [append tmp word]][
        if tmp: find tmp word [remove tmp]]
    this-face/line-list: none
    update-face
]

set-color: func [face facet /local clr tmp][
    if not this-face [exit]
    clr: face/color
    if facet [
        clone-facet facet
        clr: this-face/:facet/color
    ]
    clr: request-color/color/offset any [clr black] menu-window/offset + 50x100
    face/text: face/color: clr
    show face
    either facet [set in this-face/:facet 'color clr][this-face/color: clr]
    update-face
]

set-var: func [facet] [
    if this-face [
        if not empty? facet/text [this-face/var: to-word facet/text]
    ]
]

set-image: func [facet /local f] [
    show-images change
]

set-effect: func [fld] [
    if not error? try [fld: load fld/text][this-face/effect: fld]
    update-face
]

try-page: [
    either error? try [
        nb-var: to-word trim np-name/text
    ][
        np-err/text: copy "Not a valid page name. Try again." show np-err
    ][
        hide-popup
    ]
]

np-lay: layout [
    h2 "New Page Name:"
    np-name: field try-page
    button "Ok" try-page
    np-err: txt 200 red bold
]

new-page: func [/local name lo] [
    clear np-name/text
    inform np-lay
    unfocus
    append layouts name: copy either empty? np-name/text ["A-Page"][np-name/text]
    repend this-script [to-set-word name 'layout]
    append/only layouts tail this-script
    append/only this-script lo: compose [size 640x480 vh1 (name)]
    append layout-names name
    show pl
    load-layout back tail this-script
]

del-page: func [name /local here h] [
    if here: find layouts name [
;       h: next next here
;       forall h [if block? first h [change h skip first h -3]]
        remove/part next second here -3
        remove/part here 2
        remove any [find layout-names name ""]
        show pl
    ]
]

menus: [
    "Prefs" [
        lab "Grid Snap"  p-snap: fld form grid-snap [put-pair p-snap grid-snap] return
        lab "Dup Space"  p-dups: fld form dup-space [put-pair p-dups dup-space] return
        lab "Stickyness" p-stick: fld form stickyness [put-pair p-stick stickyness] return
        lab "Nudge Size" p-nudge: fld form nudge-size [put-pair p-nudge nudge-size] return
        lab "Auto-expand" p-expand: tgl 120 "Enable" "Disable" [auto-expand: not p-expand/data] return
        lab "Preferences" btn 120 "Save Now" [save-prefs]
    ]

    "Pages" [
        btn "New Page" 100 [new-page]
        btn "Delete Page" 100 [close-layout del-page page-name] return
        pl: text-list 200x100 data layout-names [load-layout select layouts page-name: value]
    ]

    "Styles" [
        sbt "Backdrops" [show-images backdrop] return
        sbt "Text" [view-style style-text] return
        sbt "Images" [show-images image] return
        sbt "Gadgets" [view-style style-buttons] return
;       sbt "Custom" [] return
    ]

    "Face" [
        lab "Style"  f-style: nfld return
        lab "Offset" f-offs: fld [set-pair f-offs offset none] return
        lab "Size"   f-size: fld [set-pair f-size size none] return
        lab "Name"   f-var: fld [set-var f-var] return
        lab "Color"  f-color: cls [set-color f-color none] return
        lab "Image"  f-image: sens [set-image f-image] return ;!!! should pop file requestor
        lab "Effect" f-effect: fld [set-effect f-effect] return
        lab "Action" f-action: fld [] return
        lab "New Style" f-newstyle: fld return
    ]

    "Font" [
        lab "Type"   ff-name: rty "Sans-Serif" "Serif" "Fixed Space"
            [clone-facet 'font this-face/font/name:
                pick reduce [font-sans-serif font-serif font-fixed] index? ff-name/data update-face] return
        lab "Style"  ff-bold: tgl "B" [set-font-style ff-bold bold ]
            ff-italic: tgl "I" italic [set-font-style ff-italic italic]
            ff-under: tgl "U" underline [set-font-style ff-under underline] return
        lab "Align"  ff-left: awl of 'algn [set-font-var align 'left]
            ff-center: tgl of 'algn [set-font-var align 'center]
            ff-right: awr of 'algn [set-font-var align 'right] return
        lab "Vert Align" ff-top: awu of 'valgn [set-font-var valign 'top]
            ff-middle: tgl of 'valgn [set-font-var valign 'middle]
            ff-bottom: awd of 'valgn  [set-font-var valign 'bottom] return
        lab "Size"   ff-size: fld [set-int ff-size font size] return
        lab "Color"  ff-color: cls [set-color ff-color 'font] return
        lab "Shadow" ff-shadow: fld [set-pair ff-shadow font shadow] return
        lab "Space"  ff-space: fld [set-pair ff-space font space] return
    ]

    "Paragraph" [
        lab "Origin" fp-origin: fld [set-pair fp-origin para origin] return
        lab "Margin" fp-margin: fld [set-pair fp-margin para margin] return
        lab "Indent" fp-indent: fld [set-pair fp-indent para indent] return
        lab "Scroll" fp-scroll: fld [set-pair fp-scroll para scroll] return
        lab "Tabs"   fp-tabs: fld [set-int fp-tabs para tabs] return
        lab "Wrap" pad 0x4 fp-wrap: check [clone-facet 'para this-face/para/wrap?: fp-wrap/data update-face] return
    ]

    "Edge" [
        lab "Size"  fe-size: fld [set-pair fe-size edge size] return
        lab "Color" fe-color: cls [set-color fe-color 'edge] return
        lab "Image" fe-image: fld return
        lab "Effect" fe-effect: rty "none" "bevel" "ibevel" "bezel" "ibezel"
            [clone-facet 'edge this-face/edge/effect: load first fe-effect/data update-face] return
    ]
]

show-face-info: func [face /local f][
    f: face
    f-offs/text: f/offset
    f-size/text:  f/size
    f-style/text: f/style
    f-color/text: f-color/color: f/color
    f-var/text:   f/var
    f-image/text: f/file
    f-effect/text: mold f/effect
;   f-action/text: mold f/action
    if f: face/font [
        blockify f 'style
        ;!!! bug? : should be /data not /state?
        ff-bold/state: found? find f/style 'bold
        ff-italic/state: found? find f/style 'italic
        ff-under/state: found? find f/style 'underline
        ff-name/data: at head ff-name/data index? find reduce [font-sans-serif font-serif font-fixed] f/name
        ff-size/text: f/size
        ff-color/text: ff-color/color: f/color
        ff-shadow/text: f/shadow
        ff-space/text: f/space
    ]
    if f: face/para [
        fp-origin/text: f/origin
        fp-margin/text: f/margin
        fp-indent/text: f/indent
        fp-scroll/text: f/scroll
        fp-tabs/text: f/tabs
        fp-wrap/data: f/wrap?
    ]
    if f: face/edge [
        fe-size/text: f/size
        fe-color/text: fe-color/color: f/color
        fe-image/text: f/image
        fe-effect/data: find head fe-effect/data form f/effect
    ]
    if auto-expand [open-menus face]
]

op-menu: func [face state][
    either state [
        if 4 >= length? face/pane/effect [
            append face/pane/effect [rotate 90]
            face/data/size: face/data/data
        ]
    ][
        if 4 < length? face/pane/effect [
            remove/part tail face/pane/effect -2
            face/data/size/y: 0
        ]
    ]
]

make-facet-bar: func [name /local out bx tx] [
    ; Creates a facet banner bar with arrow that opens and closes
    ; the facet detail panel. Layout just makes the basic faces.
    out: layout [ origin 0 styles main-styles
        at 3x3 bx: box menu-arrow-color 14x14
        at 0x0 tx: cat para [origin: 18x2] [] 
    ]
    bx/effect: copy [arrow 255.255.255 rotate 90]
    tx/pane: bx
    tx/size: 200x20
    tx/action:
    bx/action: bind/copy [op-menu self 4 >= length? self/pane/effect size-menu] in tx 'self ;>
    tx/text: name
    tx
]

size-menu: function [][y face pane][
    ; Resizes the menu according to current panels open.
    pane: menu-window/pane
    until [
        face: first pane
        y: second face/offset + face/size
        pane: next pane 
        pane/1/style = 'cat
    ]
    y: y + 2
    foreach f pane [
        f/offset/y: y
        y: y + f/size/y + 1
    ]
    menu-window/size/y: y
    show menu-window
]

make-menus: function [][a b][
    ; For each menu above, create the necessary faces.
    forskip menus 2 [
        set [a b] menus
        insert b [styles main-styles origin 0x0 space 0 across]
        b: layout/offset b 0x0
        b/data: b/size
        b/size/y: 0
        b/color: base-color
        a: make-facet-bar a
        a/data: b
        change skip menus 1 a
        repend menu-window/pane [a b]
    ]
    menus: head menus
    size-menu
]

open-menu: func [name state] [
    if name: select menus name [op-menu name state size-menu]
]

open-menus: func [face][
    foreach [c n] [font "font" edge "edge"][
        op-menu select menus n not none? get in face c
    ]
    op-menu select menus "Face" on
    size-menu
]

at-bottom: func [wind x][
    wind/offset: x * 1x0 + as-y system/view/screen-face/size - wind/size - 30
]


;--- Predefined Styles:

style-text: layout [
    across
    panel 150x250 white [
        origin 8x8 space 4x4
        title "Title"
        h1 "Heading 1"
        h2 "Heading 2"
        h3 "Heading 3"
        h4 "Heading 4"
        h5 "Heading 5"
        txt "Document Text"
        tt  "Teletype Text"
        code "Code Text"
    ]
    panel 220x250 0.0.100 [
        origin 8x8 space 4x4
        banner "Banner"
        vh1 "Video Heading 1"
        vh2 "Video Heading 2"
        vh3 "Video Heading 3"
        text "Normal Text"
        label "Label"
    ]
]
at-bottom style-text 400

style-buttons: layout [  ; more needed!
    across
    button "Button" return
    toggle "Toggle" return
    rotary "Rotary" return
    choice "Choice" return
    arrow left
    arrow right
    arrow up 
    arrow down
    return
    check
    radio
    led
    return below
    at 140x20 guide 
    field "Field"
    area 200x100 "Area"
    slider 200x16
    progress .3 200x16 with [data: .3]  ; !!!bug: should be directly set
    return 
    slider 16x160 return 
    progress 16x160 with [data: .3]
    return
    box 50x50 leaf
    box 50x50 effect [gradient 200.0.0 0.0.200]
    box 50x50 effect [gradient 0x1 200.0.0 0.0.200]
    return
    box 50x50 40.128.243 frame
    box 50x50 40.128.243 bevel
    box 50x50 40.128.243 ibevel
    ;scroller
    ;panel
    ;list
    ;list-text
    ;edit-text
]
at-bottom style-buttons 400

view-style: func [out] [
    ; Display the style sheet on the screen. Remember location.
    if find system/view/screen-face/pane out [exit]
    if out/color <> base-color [out/color: base-color]
    view/new out
]

paste-face: func [face /head][
    if none? layout-window [exit]
    do pick [insert append] head = true layout-window/pane face
    face/feel: make face/feel [engage: :engage']
    center-face/with face layout-window
    show layout-window
]

engage-style: func [face act event][
    ; Puts a style from a style sheet into the edit window.
    if act = 'down [paste-face make-face/clone face]
]

set-style-feel: func [face][
    foreach f face/pane [
        either f/style = 'panel [set-style-feel f][
            f/feel: make f/feel [engage: :engage-style]
        ]
    ]
]

foreach s [style-text style-buttons] [set-style-feel get s]


;--- Temporary Image Selector:

image-file-types: [%.bmp %.jpg %.jpeg %.gif]
image-file?: func [file] [find image-file-types find/last file "."]
image-layout: []

load-images: func [path [file!] /local files cnt] [
    files: load path
    while [not tail? files][either image-file? first files [files: next files][remove files]]
    clear at files: head files 12  ; don't go overboard in loading
    view/new lo: layout [text bold "Loading Image Icons" pli: progress]
    cnt: 1
    foreach fil files [
        if not error? try [
            repend image-layout ['icon icon-size path/:fil
                to-image make face [
                    size: icon-size
                    color: 40.40.80
                    image: load path/:fil
                    effect: [aspect]
                ]
            ]
        ][
            pli/data: cnt / length? files  show pli
            cnt: cnt + 1
        ]
    ]
    unview/only lo 
]

order-images: function [][xy][
    xy: 10x10
    foreach icon image-window/pane [
        if (first xy + icon/size) > image-window/size/x [xy: xy * 0x1 + 10x0 + (icon/size + 0x10 * 0x1)]
        icon/offset: xy
        xy: icon/size * 1x0 + xy + 14x0
    ]
]

engage-image: func [face act event][
    ; Puts a style from a style sheet into the edit window.
    if act = 'down [
        switch i-mode [
            backdrop [
                act: layout-window/pane
                forall act [if find exclude-styles get in first act 'style [remove act break]]
                act: layout [backdrop to-file face/text]
                act: act/pane/1
                act/size: layout-window/size
                paste-face/head act
            ]
            image [
                act: layout [image to-file face/text]
                paste-face act/pane/1
            ]
            change [
                f-image/text: this-face/file: to-file face/text
                this-face/image: load this-face/file
                show [this-face f-image]
            ]
        ]
    ]
]

image-window: none

show-images: func ['mode-word] [
    i-mode: mode-word
    either image-window [view/new/options image-window [resize]][
        load-images %.
        image-window: layout image-layout
        image-window/size: 110x110 * 4x3
        order-images
        foreach image image-window/pane [
            image/feel/engage: :engage-image
        ]
        image-window/color: 40.40.40
        old-ilay-size: 0x0
        image-window/feel: make image-window/feel [
            detect: func [face event] [
                if all [event/type = 'resize face/size <> old-ilay-size] [
                    old-ilay-size: face/size
                    order-images
                    show image-window
                ]
                event
            ]
        ]
        at-bottom image-window 200
        view/new/options image-window [resize]
    ]
]


;--- Face Editing:

show-props: func [face xy] [
    hide-nubs ;!!! prevents a strange bug in engage
    choose/window/offset ["To Top" "To Bottom" "Up 1" "Down 1"] func [f p][
            push-face face select ["To Top" top "To Bottom" bottom "Up 1" up "Down 1" down] f/text
        ]
        layout-window xy - 50x0
]

nub-face: make get-style 'face [
    edge: make edge [color: nub-color effect: 'nubs size: nub-size]
    color: font: para: text: none
    start: 0x0 ; starting point - where the down happened
    code: [] ; code to do based on where the down happened
    xy: none ; current offset
    stuck: on
    feel: make feel [
        engage: func [face act event][
            ; face is set to NONE when the event started out on real face
            if any [none? this-face find exclude-styles this-face/style][exit]
            xy: event/offset
            if act = 'alt-down [show-props this-face xy + either face [face/offset][this-face/offset] exit]
            ;print [xy event/type act]
            if not face [xy: xy + nub-size] ; started out on real face
            if find [over away] act [
                if all [
                    stuck
                    stickyness/x > abs xy/x - start/x
                    stickyness/y > abs xy/y - start/y
                ][exit]
                stuck: off
                do code
                size: max size nub-size * 2 + 1x1  ; allow only to get this small
                f-offs/text: this-face/offset: offset + nub-size
                f-size/text: this-face/size: size - nub-size2
                this-face/line-list: none
                show [this-face nub-face]
                show [f-offs f-size] ;!!! this does not work in above line!
            ]
            if act = 'down [
                ;-- Show nubs and setup for an over or away event:
                clear code  ; remove previous code
                start: xy   ; starting point
                stuck: on
                ;-- Compose code to handle resizing drag on corners:
                foreach [cond op] [
                    [start/x < edge/size/x] 
                    [offset/x: offset/x + xy/x size/x: size/x - xy/x]
                    [start/y < edge/size/y]
                    [offset/y: offset/y + xy/y size/y: size/y - xy/y]
                    [size/x - edge/size/x < start/x]
                    [size/x: xy/x]
                    [size/y - edge/size/y < start/y]
                    [size/y: xy/y]  ;>
                ][if do cond [append code op]]
                ;-- If none, then must be a face drag condition:
                if empty? code [insert code [offset: offset + nub-size + xy - start / grid-snap * grid-snap - nub-size]]
                ; If the face has text, prepare for editing.
                if string? this-face/text [
                    system/view/focal-face: this-face
                    system/view/caret: tail this-face/text
                    show this-face
                ]
            ]
        ]
    ]
]

place-nubs: func [face][
    nub-face/offset: face/offset - nub-size
    nub-face/size: face/size + nub-size2
]

show-nubs: func [face] [
    ; set face values, update the pane, show the nubs
    dirty: true
    place-nubs face
    show-face-info this-face: face
    if not find layout-window/pane nub-face [
        append layout-window/pane nub-face
    ]
    show layout-window
;   show [f-offs f-size f-style f-color] ; f-fvar f-acts]
    set-text-mode off
]

hide-nubs: does [
    if this-face [
        hide-edit
        remove any [find layout-window/pane nub-face ""]
        show layout-window
        this-face: none
    ]
]

update-nubs: does [
    if not find exclude-styles this-face/style [
        hold: this-face
        hide-nubs
        show-nubs hold
    ]
]

update-face: does [update-nubs show this-face]

hide-edit: func [/local temp] [
    if temp: system/view/focal-face [
        system/view/focal-face: none
        system/view/caret: none
        show temp
    ]
]

nudge: func [key] [
    if this-face [
        key: nudge-size * switch key [
            up    0x-1
            down  0x1
            left -1x0
            right 1x0
        ]
        this-face/offset: this-face/offset + key
        nub-face/offset: nub-face/offset + key
    ]
]

push-face: func [face dir] [
    switch dir [
        up      [insert next remove find layout-window/pane face face]
        down    [insert back remove find layout-window/pane face face]
        top     [append remove find layout-window/pane face face]
        bottom  [insert next head remove find layout-window/pane face face]
    ]
]

engage': func [face act evt][
    ; The engage function used by all faces
    if act = 'down [
        hide-edit
        if find exclude-styles face/style [ ; don't select background
            hide-nubs show-face-info this-face: face exit
        ]
        show-nubs face
    ]
    if act = 'alt-down [show-props face face/offset + evt/offset]
    if this-face [nub-face/feel/engage none act evt]
]


;--- Top level event handler:

edit-text: get in ctx-text 'edit-text

detect-key: func [face event /local tmp] [
    either text-mode [
        edit-text this-face event none
    ][
        switch/default event/key [
            #"^D" [
                if this-face [
                    new: make-face/clone this-face
                    new/offset: new/offset + (as-y new/size) + dup-space
                    append layout-window/pane new
                    hide-nubs
                    show-nubs new
                ]
            ]
            #"^(del)" [
                if this-face [
                    temp: this-face
                    hide-nubs
                    remove find layout-window/pane temp
                ]
            ]
            #"^C" [
                if this-face [face-hold: this-face]
            ]
            #"^X" [
                if this-face [
                    face-hold: this-face
                    hide-nubs
                    remove find layout-window/pane face-hold
                ]
            ]
            #"^V" [
                if face-hold [
                    hide-nubs
                    append layout-window/pane face-hold: make face-hold [
                        offset: layout-window/size - size / 2
                    ]
                    show-nubs face-hold
                ]
            ]
            #"^T" [
                set-text-mode not text-mode
            ]
        ][
            if find [up down left right] event/key [nudge event/key]
            all [
                char? event/key
                system/view/focal-face
                set-text-mode on
                edit-text this-face event none
            ]
        ]
        show layout-window
    ]
    return none
]


;--- Layouts:

old-size: none
layouts: []
layout-names: [none]  ; need to fix text-list

resize-window: func [size] [
    layout-window/size: size
    foreach face layout-window/pane [
        if find exclude-styles face/style [face/size: size show face]
    ]
]

nudge-all: func [n] [
    foreach face layout-window/pane [
        if not find exclude-styles face/style [face/offset: face/offset + 0x4]
    ]
    show layout-window
]
find-layouts: func [script [block!] /local val cnt] [
    ;Finds all the layouts in a file. Puts them in a block.
    ;Saves optional layout name if a set-word appears before it.
    layouts: copy [] ; name | num + block position
    cnt: 1
    forall script [
        val: first script
        if any [:val = 'layout all [path? :val 'layout = first :val]] [
            repend layouts [
                form either set-word? first back script [first back script][cnt]
                script: next script
            ]
            cnt: cnt + 1
        ]
    ]
    clear layout-names
    foreach [n a] layouts [append layout-names n]
    show pl
]

close-layout: does [
    hide-nubs
    if layout-window [unview/only layout-window]
]

load-layout: func [blk [block!]] [
    close-layout
    either object? first blk [layout-window: first blk][
        change blk layout-window: layout first blk
        foreach f layout-window/pane [
            f/feel: make f/feel [engage: :engage']
            if f/font [f/font: make f/font []]
            if f/para [f/para: make f/para []]
            if f/edge [f/edge: make f/edge []]
            ; !!! (can now remove clone-facet above)
        ]
    ]
    view/new/offset/title/options layout-window
        menu-window/offset + (menu-window/size + 10 * 1x0) "Edit Window" [resize]
    layout-window/style: 'window

;;; move detect feel here?
        layout-window/feel: make layout-window/feel [
            engage: :engage'
            detect: func [f e] [
                if all [e/type = 'resize f/size <> old-size] [
                    hide-nubs
                    old-size: f/size
                    resize-window f/size
                    show-face-info layout-window
                ]
                if e/type = 'key [
                    detect-key f e
                ]
                e
            ]
        ]

]

load-file: func [file] [
    face-file: file
    w-file/text: file
    show w-file
    if not error? try [file: load/all file] [
        this-script: file
        find-layouts file
        if not empty? layouts [load-layout second layouts]
    ]
]

mold-layouts: function [] [out emit here] [
    clear out: ""
    emit: func [val] [
        val: mold val
        remove val  ;!!! add to mold/only
        remove back tail val
        repend out [val " "]
    ]
    emit copy/part this-script 2
    append out newline
    here: skip this-script 2
    foreach [var lo] layouts [
        if object? first :lo [
            emit copy/part here lo
            append out out-lay first :lo
            append out newline
            here: next lo
        ]
    ]
    emit here
    append out newline
    if not find this-script 'view [
        emit reduce ['view to-word first layouts]
    ]
    append out newline
    out
]

save-layout: function [] [file] [
    if not dirty [return true]
    if none? file: req-file "Save file as:" "Save" [return none]
    if exists? file [
        if not request rejoin ["Do you want to overwrite " file "?"][return none]
    ]
    write file mold-layouts
    script-file: file
    dirty: false
    true
]

text-window: [
    size 640x480 origin 0 space 0 across
    tw1: area 624x480 font [name: font-fixed] para [tabs: 28 origin: 4x4]
        with [color: 240.240.240  feel: make feel [redraw: none]]
    sw1: slider 16x480 [scroll-para tw1 sw1]
]

view-layout: function [] [size] [
    if block? text-window [text-window: layout/offset text-window 0x0]
    tw1/para/scroll: 0x0 sw1/data: 0
    tw1/text: tw1/data: mold-layouts
    size: size-text tw1
    sw1/redrag 320 / size/y
    unview/only text-window
    view/new/offset text-window layout-window/offset + 20x20
]

eq?: func [a b /local vars] [
    if not all [object? a object? b] [return a = b]
    if not-equal? next first b next first a [return false]
    foreach word next first a [if a/:word <> b/:word [return false]]
    true
]

flag?: func [face 'flag] [all [face/flags find face/flags flag]]

out-lay: function [facel] [emit style val ss output out-font s] [
    hide-nubs
    output: make string! 2000
    emit: func [val] [repend output val]

    out-font: func [val ss /local full][
        foreach [word intro] [style "" align "" valign "" size "font-size "][
            if val/:word <> ss/:word [emit [" " intro val/:word]]
        ]
        foreach word [name offset space shadow][
            if val/:word <> ss/:word [
                if not full [emit " font [" full: true]
                emit [word ": " mold val/:word " "]
            ]
        ]
        if full [remove/part tail output -1 emit "]"]
    ]

;   emit [{REBOL [Title: "} w-file/text {" Date: } now {]^/^/}]
;   emit "view layout [^/^/"
    emit "[^/^/"
    emit [tab "size " facel/size newline newline]
    emit-face: func [item at?][
        if none? style: any [get-style item/style select facel/styles item/style][break]

        either at? [
            emit [ tab
                head change at copy "at         " 4 item/offset
                either all [in item 'var item/var] [join " " mold to-set-word item/var] [""]
                " " item/style
            ]
        ][
            emit item/style
        ]

        either find [rotary choice] item/style [
            if block? item/data [
                foreach str item/data [emit [" " mold str]]
            ]
        ][
            if all [item/text not empty? item/text] [emit [" " mold item/text]]
        ]

        foreach word [file size color keycode effect] [
            val: item/:word
            ;print [newline "---" style/style]
            if all [
                word = 'color
                flag? item text
                any [item/color <> style/color item/font/color <> style/font/color]
            ][emit [" " item/font/color]]
            if all [
                val <> style/:word
                not image? val
                not all [word = 'size item/style = 'backdrop]
            ][
                if find [effect] word [emit [" " word]]  ;!!! data can go here
                emit [" " mold val]
            ]
        ]

        if get in item 'action [
            emit [" " mold second get in item 'action]
        ]

        if get in item 'para [item/para/scroll: 0x0]

        foreach word [font para edge] [
            val: item/:word
            ss: style/:word
            if not eq? val ss [
                either word = 'font [out-font val ss][
                    emit [" " word]
                    either object? val [
                        emit " ["
                        foreach word next first ss [
                            if val/:word <> ss/:word [
                                emit [word ": " either word? val/:word ["'"][#] mold val/:word " "]
                            ]
                        ]
                        remove/part tail output -1
                        emit "]"
                    ][emit [" " mold val]]
                ]
            ]
        ]
        emit newline
    ]
    ws: copy facel/styles
    reverse ws
    foreach [a f] ws [
        if not all [s: get-style f s = a] [emit [tab "style " f " "] emit-face a off]
    ]

;   facel/pane: sort/compare facel/pane func [a b] [
;       if a/style = 'backdrop [return true]
;       if b/style = 'backdrop [return false]
;       either a/offset/y = b/offset/y [a/offset/x < b/offset/x][a/offset/y < b/offset/y]
;   ]

    foreach item facel/pane [
        if object? item [emit-face item on]
    ]
    emit "^/]"
    output
]


;-- Preferences

save-prefs: function [] [out] [
    out: copy {REBOL [Title: "Layout Preferences"]^/^/}
    foreach word [
        face-file
        nub-size
        nub-color
        dup-space
        grid-snap
        nudge-size
        stickyness
        auto-expand
        base-color
        menu-bar-color
        menu-arrow-color
        menu-button-color
    ][
        repend out [word ": " mold get word newline]
    ]
    write prefs-file out
]


;--- Menu Window:

set-text-mode: func [s] [
    if text-mode = s [exit]
    text-mode: s
    tmb/state: s
    show tmb
    true
]

req-file: func [ttl act] [
    act: request-file/title/keep ttl act
    if all [act act: act/1] [return act]
]

load-file-blk: [load-file to-file mwf/text hide-popup]

menu-window: layout [
    size 200x600 origin 0 space 0x0
    styles main-styles
    h3 bold center 200 reform [system/script/header/title system/script/header/version]
    across
    btn "Load" 50 [load-file req-file "Load a layout file:" "Load"]
    btn "Save" 50 [save-layout]
    btn "New"  50 [if save-layout [new-project]]
    btn "Quit" 50 [
        if save-layout [quit]
        if request/confirm "Do you want to quit without saving?" [quit]
    ]
    return
    pad 0x2
    w-file: field center to-string face-file 200 [load-file to-file w-file/text] return
    pad 0x2
    btn "Code" 50 [view-layout]
    btn "Run" 50 [save-layout unview/all do script-file quit]
    btn "Help" 50 [show-help]
    tmb: tgl "Text" 50 [set-text-mode tmb/data] return
]
menu-window/color: base-color

show-help: does [
    request layout [
            backdrop silver
            h2 "Instructions:"
            txt bold as-is instructions
            across
            button "Bug Report" [send-text/to carl@rebol.com]
            button "Cancel" [hide-popup]
    ]
]

;--- Startup:

make-menus
p-expand/data: p-expand/state: not auto-expand

view/new menu-window
insert-event-func [
    either all [event/type = 'close event/face = menu-window][quit][event]
]

nn-lay: layout [
    h2 "New Project Name:"
    nn-name: field "Example"
    h4 "Page size:"
    nn-size: field 100 "640x480"
    button "Ok" [script-name: copy nn-name/text hide-popup]
    nn-err: txt 200 red bold
]

new-project: does [
    script-name: none
    inform nn-lay
    unfocus ;!!! fix this
    if not script-name [exit]
    clear layouts
    this-script: compose/deep [REBOL [Title: (script-name) Date: (now)]]
    clear layout-names
    dirty: true
    new-page
]

if exists? face-file [load-file face-file]

do-events

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        