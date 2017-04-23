REBOL [
    Title: "ICO view 2"
    Date: 18-Aug-2001/23:40:32+2:00
    Version: 0.0.5
    File: %ico-view2.r
    Author: "oldes"
    Purpose: {To view the images from the ICO files (windows icons)}
    Comment: {This is just an example what to do with the %ico-parser2}
    Email: oldes@bigfoot.com
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
;first of all I include the %ico-parser.r
do %ico-parser2.r
do %slide.r
wm: make object! load %win-maker.r

get-icon: func[
    ico-file
    /local ico i icon i-size
][
    ico-parser/load-ico ico-file
    ico-parser/get-icon
    
    icon: make face [
        size:  ( ico-parser/size )
        image: ( ico-parser/img )
        edge: none
        name: ""
        state: off
        effect: []
        highlite: func[f][
            either f/state [
                    remove/part find f/effect 'invert 1
            ][  
                insert tail f/effect [invert]
            ]
            f/effect/3: 255.255.255 - f/effect/3
            f/state: not f/state
            show f
        ]
        feel: make feel [
            engage: func [f a e /local o pf dmax][
                pf: f/parent-face
                if a = 'down [
                    f/state: on
                    highlite f
                    remove find pf/pane f
                    append pf/pane f
                    mouse-pos: e/offset
                    print f/name
                    show f
                ]
                if a = 'up []
                if find [over away] a [
                    dmax: to-pair reduce [(pf/size/x - f/size/x) (pf/size/y - f/size/y)]
                    o: f/offset + (e/offset - mouse-pos)
                    o: max 0x0 min o dmax
                    f/offset: o
                    show f
                ]
            ]
            over: func [f a e][
                highlite f
            ]
        ]
    ]
    icon/effect: reduce ['fit 'key ico-parser/key-color]
    icon
]

save-to-png?: false
icons-dir: to-file ask "Path to dir with icons: %" ;%umac/ ;%Sputnik_ipack/  ;%FuturistYellow_IP/
if #"/" <> last icons-dir [insert tail icons-dir #"/"]

icons: read icons-dir
ic-offset: 0x0
prin "Loading...."
icon-field: make face [
    size: 320x240
    color: 170.185.165
    edge: none
    pane: make block! []
]
foreach ico-file icons [
    if found? find ico-file ".ico" [
        prin ico-file
        ic: get-icon icons-dir/:ico-file
        if (ic-offset/x + ic/size/x) > icon-field/size/x [
            ic-offset/x: 0
            ic-offset/y: ic-offset/y + ic/size/y
        ]
        ic/offset: ic-offset
        ic/name: ico-file
        append icon-field/pane ic
        ic-offset/x: ic-offset/x + ic/size/x
        ;if ic-offset/x > icon-field/size/x [
        ;   ic-offset/x: 0
        ;   ic-offset/y: ic-offset/y + ic/size/y
        ;]
        loop length? ico-file [prin "^(back) ^(back)"]
    ]
]
print "DONE"
if ic-offset/y > icon-field/size/y [icon-field/size/y: ic-offset/y + ic/size/y]
win: make face compose [
    size: 332x240
    edge: none ; make edge [size: 1x1 color: 0.0.0]
    pane: copy []
]
insert win/pane reduce ['content icon-field]
add-slider win reduce ['dragging win/pane/content]


view/options center-face f: wm/add-title win  "Icon viewer" [no-title]
                                                                                                                  