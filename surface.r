rebol [
    Title:   "3D-Surface Plot"
    Date:    06-August-2007
    File:    %surface.r
    Version: 1.0.0
    Email: phil.bevan@gmail.com
    Category: [demo]
    Purpose:
    {
        Draw a surface with 3-D Perspective and allow roation
    }

    License: {Copyright (c) <2007>, <Phil Bevan>
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.}

    History: [
        0.0.1 - Initial Version - test purposes only
    ]
    Email: phil.bevan@gmail.com
    library: [
        level: 'advanced
        platform: [all]
        type: [tool]
        domain: 'math
        tested-under: ["view 1.3.2.3.1"]
        support: none
        license: mit
        see-also: none
    ]
]

objs: []


;
; reb-3d.r
;

screen: 0x0
sox: 500
soy: 300
screen/x: sox * 2
screen/y: soy * 2
pen-color: black
anti-alias: true

camera: [0 0 6 0 0 800 800] ; x y z a1 a2 xsc ysc

; draw order for all faces
draw-o: []

; draw block
draw-bl: []

fn-rot: func [obj [block!]][
    context [
; print "Rot"
; r1: now/time/precise
        c1: cosine obj/1/4
        c2: cosine obj/1/5
        c3: cosine obj/1/6
        s1: sine obj/1/4
        s2: sine obj/1/5
        s3: sine obj/1/6
; r2: now/time/precise

        clear obj/3
        clear obj/4

        obj/3: copy/deep obj/2

        ; calculate the perspective of the points after the roation & translation
        foreach point obj/3 [
            ; Roation about z axis
            x1: (point/1 * c1) - (point/2 * s1)
            y1: (point/1 * s1) + (point/2 * c1)
            z1: point/3

            ; Roation about y axis
            x2: (x1 * c2) + (point/3 * s2)
            y2: y1
            z2: - (x1 * s2) + (point/3 * c2)

            x3: x2 + obj/1/1
            y3: (y2 * c3) - (z2 * s3) + obj/1/2
            z3: (y2 * s3) + (z2 * c3) + obj/1/3

            poke point 1 (x3 + camera/1)
            poke point 2 (y3 + camera/2)
            poke point 3 (z3 + camera/3)

            x: point/1 / point/3 * camera/6
            y: point/2 / point/3 * camera/7
            append obj/4 to pair! reduce[(x + sox) (soy - y)]
        ]
; c: 0
; r3: now/time/precise

        foreach f obj/5 [
; c: c + 1
            p1: f/1/1
            p2: f/1/2
            p3: f/1/3
            d1: reduce [(obj/3/:p2/1 - obj/3/:p1/1) (obj/3/:p2/2 - obj/3/:p1/2) (obj/3/:p2/3 - obj/3/:p1/3)] ; dist^2 between p2 & p1
            d2: reduce [(obj/3/:p3/1 - obj/3/:p1/1) (obj/3/:p3/2 - obj/3/:p1/2) (obj/3/:p3/3 - obj/3/:p1/3)] ; dist^2 between p3 & p1
            poke f 4 (-2 * obj/3/:p1/3 - d1/3 - d2/3) ; 2 * z-dist from camera
            n1: (d1/2 * d2/3) - (d1/3 * d2/2) ; normal x
            n2: - (d1/1 * d2/3) + (d1/3 * d2/1) ; normal y
            n3: (d1/1 * d2/2) - (d1/2 * d2/1) ; normal z
            v: 0 > ((obj/3/:p1/1 * n1) + (obj/3/:p1/2 * n2) + (obj/3/:p1/3 * n3))
            poke f 2 v
        ]

; r4: now/time/precise

;print ["Rotation times" r2 - r1 r3 - r2 r4 - r3]

    ]
]
; if c = 1255 [probe f probe obj/3/:p1 probe obj/3/:p2 probe obj/3/:p3 print ["^/Distance^/" d1 "^/" d2 "^/Normal^/" n1 n2 n3 "^/" ((obj/3/:p1/1 * n1) + (obj/3/:p1/2 * n2) + (obj/3/:p1/3 * n3))]]

fn-show: func [][
    context [
    ; setup the faces to be shown
    pts: []
    clear draw-o
    foreach o objs [
        foreach f o/5 [
            if any [f/2 = true f/3/1 = 3 f/3/1 = 4 f/3/1 = 5][
                append draw-o f/4
                switch f/3/1 [
                    1 [append/only draw-o reduce ['image (pick bmps f/3/2) pick o/4 f/1/1 pick o/4 f/1/2 pick o/4 f/1/3 pick o/4 f/1/4]]
                    2 [
                        pts: copy reduce ['fill-pen (pick clrs f/3/2) 'polygon]
                        foreach coord f/1 [append pts pick o/4 coord]
                        append/only draw-o pts
                    ]
                    3 [
                        either f/2 [cl: pick clrs f/3/2][cl: pick clrs f/3/3]
                        pts: copy reduce ['fill-pen cl 'polygon]
                        foreach coord f/1 [append pts pick o/4 coord]
                        append/only draw-o pts
                    ]
                    4 [
                        pts: copy reduce ['pen 0.0.0 'line]
                        foreach coord f/1 [append pts pick o/4 coord]
                        append pts pick o/4 f/1/1
                        append/only draw-o pts
                    ]
                    5 [append/only draw-o reduce ['image (pick bmps f/3/2) pick o/4 f/1/1 pick o/4 f/1/2 pick o/4 f/1/3 pick o/4 f/1/4]]
                ]
            ]
        ]
    ]
    ; sort the faces
    sort/skip draw-o 2

    ; reset the draw-block
    clear draw-bl
    append draw-bl reduce ['pen pen-color]
    either anti-alias [append draw-bl reduce ['anti-alias 'on]][append draw-bl reduce ['anti-alias 'off]]
    ; create the draw block
    forskip draw-o 2 [append draw-bl draw-o/2]

    ; show the face
    show f-box
    ]
]


;
; surface-obj.r
;

fn-append-pt: func [x [number!] y [number!] z [number!] pts [block!] ][
    append/only pts reduce [x y z]
]

fn-append-fc: func [p1 [integer!] p2 [integer!] p3 [integer!] p4 [integer!] ip-col [integer!] /local fc col][
    either p4 = 0
        [fc: reduce [p1 p2 p3]]
        [fc: reduce [p1 p2 p3 p4]]
    col: reduce [2 ip-col]
    facet: reduce [fc false col 0]
    append/only facets facet
]

fn-gen-plane: func [ip-col-1 [tuple!] ip-col-2 [tuple!] x1 [number!] y1 [number!] x2 [number!] y2 [number!] nsx [integer!] nsy [integer!]][
    context [

        pts: []
        facets: []
        obj: []
        obj-col: []

        npx: nsx + 1
        npy: nsy + 1
        cols: reduce[ip-col-1 ip-col-2]

        ; points & face
        clear pts
        for i y1 y2 (y2 - y1) / nsy [
            for j x1 x2 (x2 - x1) / nsx [
                ; points
                fn-append-pt i j 0 pts
            ]
        ]

        for i (y1 + ((y2 - y1) / nsy / 2)) (y2) (y2 - y1) / nsy [
            for j (x1 + ((x2 - x1) / nsx / 2))  (x2) (x2 - x1) / nsx [
                ; points
                fn-append-pt i j 0 pts
            ]
        ]

        ; faces
; print ["AAA" npx npy]
        clear facets
        for i 1 npy - 1 1 [
            for j 1 npx - 1 1 [
                ; top facets
                fc: reduce [
                    (npx * npy) + ((i - 1) * (npx - 1)) + j
                    (i - 1) * npx + j + 1
                    (i - 1) * npx + j
                ]
                facet: reduce [fc false copy [3 1 4] 0]
                append/only facets facet

                fc: reduce [
                    (npx * npy) + ((i - 1) * (npx - 1)) + j
                    (i - 1) * npx + j
                    i * npx + j
                ]
                facet: reduce [fc false copy [3 2 3] 0]
                append/only facets facet

                fc: reduce [
                    (npx * npy) + ((i - 1) * (npx - 1)) + j
                    i * npx + j
                    i * npx + j + 1
                ]
                facet: reduce [fc false copy [3 1 4] 0]
                append/only facets facet

                fc: reduce [
                    (npx * npy) + ((i - 1) * (npx - 1)) + j
                    i * npx + j + 1
                    (i - 1) * npx + j + 1
                ]
                facet: reduce [fc false copy [3 2 3] 0]
                append/only facets facet
            ]
        ]
        ; print length? facets

        ; create the object
        append obj reduce [
            ; angles & co-ordinates
            [0 0 0 0 0 0] ;obj/1
            pts
            []
            []
            facets
            cols
        ]
        append/only objs obj
    ]
]



;
; Main line
;

clrs: reduce [white orange red white 255.255.200 50.50.200 100.100.150 255.25.10 blue green yellow]

; foreach o objs [fn-rot o]

fn-show-cam: func [][
    f-cx/text: to string! camera/1
    f-cy/text: to string! camera/2
    f-cz/text: to string! camera/3
    if f-panel/show? [show [f-cx f-cy f-cz]]
]

fn-show-angles: func [][
    f-cx/text: to string! camera/1
    f-cy/text: to string! camera/2
    f-cz/text: to string! camera/3
]


help-text: {
Welcome to Surface.r.

To Rotate the surface use the following keys:
"[" & "]" - rotate left/right
"{" & "}" - rotate forard/back
"<" & ">" - roll left/right

To move the surface use the following function keys:
F1: move the surface left
F2: move the surface right
F3: move the surface up
F4: move the surface down
F5: move the surface back
F6: move the surface forward

}

fn-surface-help: func [][
    lv-lay: layout [
        backdrop 0.0.0 effect [gradient 0x1 130.255.230 0.150.0]
        vh1 "3D Surface Help"
        vtext help-text 400x600 as-is
    ]
    view/new lv-lay
]



fn-prefs: func [/hide-panel /local lv-err xl-new yl-new xh-new yh-new][

    if error? lv-err: try [xl-new: to decimal! f-xl/text][
        focus f-xl
        show f-xl
        alert "Invalid low x value"
        return
    ]
    if error? lv-err: try [yl-new: to decimal! f-yl/text][
        focus f-yl
        show f-yl
        alert "Invalid low y value"
        return
    ]
    if error? lv-err: try [xh-new: to decimal! f-xh/text][
        focus f-xh
        show f-xh
        alert "Invalid high x value"
        return
    ]
    if error? lv-err: try [yh-new: to decimal! f-yh/text][
        focus f-yh
        show f-yh
        alert "Invalid high y value"
        return
    ]
    if xh-new <= xl-new [
        focus f-xh
        show f-xh
        alert "The high x value must be greater than the low x value"
        return
    ]
    if yh-new <= yl-new [
        focus f-yh
        show f-yh
        alert "The high y value must be greater than the low y value"
        return
    ]
    xl: xl-new
    yl: yl-new
    xh: xh-new
    yh: yh-new
    if error? lv-err: try [squares-x-new: to integer! f-xsq/text][
        focus f-xsq
        show f-xsq
        alert "Invalid no of x squares"
        return
    ]
    if error? lv-err: try [squares-y-new: to integer! f-ysq/text][
        focus f-ysq
        show f-ysq
        alert "Invalid no of y squares"
        return
    ]
    if squares-x-new < 4 [
        focus f-xsq
        show f-xsq
        alert "No of squares must be >= 4"
        return
    ]
    if squares-x-new > 64 [
        focus f-xsq
        show f-xsq
        alert "No of squares must be <= 64"
        return
    ]
    if squares-y-new < 4 [
        focus f-ysq
        show f-ysq
        alert "No of squares must be >= 4"
        return
    ]
    if squares-y-new > 64 [
        focus f-ysq
        show f-ysq
        alert "No of squares must be <= 64"
        return
    ]
    squares-x: squares-x-new
    squares-y: squares-y-new

    fn-str: f-fun-str/text
    if error? lv-err: try [camera/1: to decimal! f-cx/text][
        focus f-cx
        show f-cx
        alert "The x Camera value is invalid"
        return
    ]
    if error? lv-err: try [camera/2: to decimal! f-cy/text][
        focus f-cy
        show f-cy
        alert "The y Camera value is invalid"
        return
    ]
    if error? lv-err: try [camera/3: to decimal! f-cz/text][
        focus f-cz
        show f-cz
        alert "The z Camera value is invalid"
        return
    ]
    anti-alias: f-anti-alias/data
    either f-pen/data [pen-color: f-pen-col/color][pen-color: none]
    poke clrs 2 f-top-c1/color
    poke clrs 1 f-top-c2/color
    poke clrs 3 f-btm-c1/color
    poke clrs 4 f-btm-c2/color

    clear objs
    fn-gen-plane white red xl yl xh yh squares-x squares-y
    fn-height fn-str xl xh yl yh squares-x squares-y
    foreach o objs [fn-rot o]
    fn-show
    if hide-panel [hide f-panel]
]

fn-high-chg: func [dx [integer!] dy [integer!]] [
    context [
        if error? lv-err: try [x: to integer! f-x-high/text][return]
        if error? lv-err: try [y: to integer! f-y-high/text][return]
        if all [dx = -1 x > 1][f-x-high/text: to string! (x - 1) x: x - 1]
        if all [dy = -1 y > 1][f-y-high/text: to string! (y - 1) y: y - 1]
        if all [dx = 1 x < squares-x][f-x-high/text: to string! (x + 1) x: x + 1]
        if all [dy = 1 y < squares-y][f-y-high/text: to string! (y + 1) y: y + 1]
        show [f-x-high f-y-high]
        poke clrs 6 f-htop-c1/color
        poke clrs 5 f-htop-c2/color
        poke clrs 8 f-hbtm-c1/color
        poke clrs 7 f-hbtm-c2/color
        fn-highlight x y 5 6 7 8
    ]
]

fn-highlight: func [x [integer!] y [integer!] col1 [integer!] col2 [integer!] col3 [integer!] col4 [integer!]][
    context [
        ; restore original colours
        if (high-sq-cols/1) > 0 [
            high-sq: high-sq-cols/1
            poke objs/1/5/:high-sq/3 2 high-sq-cols/2
            poke objs/1/5/:high-sq/3 3 high-sq-cols/3
            high-sq: high-sq + 1
            poke objs/1/5/:high-sq/3 2 high-sq-cols/4
            poke objs/1/5/:high-sq/3 3 high-sq-cols/5
            high-sq: high-sq + 1
            poke objs/1/5/:high-sq/3 2 high-sq-cols/6
            poke objs/1/5/:high-sq/3 3 high-sq-cols/7
            high-sq: high-sq + 1
            poke objs/1/5/:high-sq/3 2 high-sq-cols/8
            poke objs/1/5/:high-sq/3 3 high-sq-cols/9
        ]

        h-sq: (squares-x * squares-y) + ((x - 1) + ((y - 1) * squares-x)) + 1
        f-xh-val/text: to string! objs/1/2/:h-sq/1
        f-yh-val/text: to string! objs/1/2/:h-sq/2
        f-high-val/text: to string! objs/1/2/:h-sq/3
        show [f-xh-val f-yh-val f-high-val]

        ; set hightlight
        high-sq: 4 * ((x - 1) + ((y - 1) * squares-x)) + 1
        poke high-sq-cols 1 high-sq

        poke high-sq-cols 2 objs/1/5/:high-sq/3/2
        poke high-sq-cols 3 objs/1/5/:high-sq/3/3
        poke objs/1/5/:high-sq/3 2 col1
        poke objs/1/5/:high-sq/3 3 col3

        high-sq: high-sq + 1
        poke high-sq-cols 4 objs/1/5/:high-sq/3/2
        poke high-sq-cols 5 objs/1/5/:high-sq/3/3
        poke objs/1/5/:high-sq/3 2 col2
        poke objs/1/5/:high-sq/3 3 col4

        high-sq: high-sq + 1
        poke high-sq-cols 6 objs/1/5/:high-sq/3/2
        poke high-sq-cols 7 objs/1/5/:high-sq/3/3
        poke objs/1/5/:high-sq/3 2 col1
        poke objs/1/5/:high-sq/3 3 col3

        high-sq: high-sq + 1
        poke high-sq-cols 8 objs/1/5/:high-sq/3/2
        poke high-sq-cols 9 objs/1/5/:high-sq/3/3
        poke objs/1/5/:high-sq/3 2 col2
        poke objs/1/5/:high-sq/3 3 col4

        fn-show
    ]
]

fn-high-prefs: func [/hide-panel][
    if error? lv-err: try [x: to integer! f-x-high/text][
        focus f-x-high
        show f-x-high
        alert "Invalid x value"
        return
    ]
    if x < 1 [
        focus f-x-high
        show f-x-high
        alert "x value cannot be less than 1"
        return
    ]
    if x > squares-x [
        focus f-x-high
        show f-x-high
        alert "x value grater than the number of squres in the x direction"
        return
    ]
    if error? lv-err: try [y: to integer! f-y-high/text][
        focus f-y-high
        show f-y-high
        alert "Invalid y value"
        return
    ]
    if y < 1 [
        focus f-y-high
        show f-y-high
        alert "y value cannot be less than 1"
        return
    ]
    if y > squares-y [
        focus f-y-high
        show f-y-high
        alert "y value grater than the number of squres in the y direction"
        return
    ]

    poke clrs 6 f-htop-c1/color
    poke clrs 5 f-htop-c2/color
    poke clrs 8 f-hbtm-c1/color
    poke clrs 7 f-hbtm-c2/color
    fn-highlight x y 5 6 7 8
    if hide-panel [hide f-panel-h]
]

lv-lay: layout [
    backdrop 0.0.0 effect [gradient 0x1 130.255.230 0.150.0]
    origin 0x0
    at 0x0
    space 0x0
    across
    f-box: box screen effect [draw draw-bl] rate 60 edge [size: 1x1 color: gray effect: 'bevel]
    feel [
        engage: func [face action event][
            if all[action = 'time  rot][
                st: now/time/precise
                theta1: theta1 + 5
                theta2: theta2 + 7
                if theta1 > 360 [theta1: theta1 - 360]
                if theta2 > 360 [theta2: theta2 - 360]

                objs/1/1/4: objs/1/1/4 + 5
                objs/1/1/5: objs/1/1/5 + 7
                if objs/1/1/4 > 360 [objs/1/1/4: objs/1/1/4 - 360]
                if objs/1/1/5 > 360 [objs/1/1/5: objs/1/1/5 - 360]

                rots: now/time/precise
                foreach o objs [fn-rot o]
                rote: now/time/precise
                fn-show
                shoe: now/time/precise
                print [now/time/precise - st rote - rots shoe - rote]
            ]
        ]
    ]
    return

    sensor 0x0 keycode [F1 F2 F3 F4 F5 F6 F7 #">" #"<" #"{" #"}" #"[" #"]"] [
        switch value [
            #"[" [objs/1/1/4: objs/1/1/4 + 5 fn-rot objs/1 if objs/1/1/4 > 360 [objs/1/1/4: objs/1/1/4 - 360] fn-show-angles]
            #"]" [objs/1/1/4: objs/1/1/4 - 5 fn-rot objs/1 if objs/1/1/4 < 0 [objs/1/1/4: objs/1/1/4 + 360] fn-show-angles]
            #"<" [objs/1/1/5: objs/1/1/5 + 5 fn-rot objs/1 if objs/1/1/5 > 360 [objs/1/1/5: objs/1/1/5 - 360] fn-show-angles]
            #">" [objs/1/1/5: objs/1/1/5 - 5 fn-rot objs/1 if objs/1/1/5 < 0 [objs/1/1/5: objs/1/1/5 + 360] fn-show-angles]
            #"{" [objs/1/1/6: objs/1/1/6 - 5 fn-rot objs/1 if objs/1/1/6 < 0 [objs/1/1/6: objs/1/1/6 + 360] fn-show-angles]
            #"}" [objs/1/1/6: objs/1/1/6 + 5 fn-rot objs/1 if objs/1/1/6 > 360 [objs/1/1/6: objs/1/1/6 - 360] fn-show-angles]
            F1 [camera/1: camera/1 - 0.1 fn-show-cam]
            F2 [camera/1: camera/1 + 0.1 fn-show-cam]
            F3 [camera/2: camera/2 + 0.1 fn-show-cam]
            F4 [camera/2: camera/2 - 0.1 fn-show-cam]
            F5 [camera/3: camera/3 + 0.1 fn-show-cam]
            F6 [camera/3: camera/3 - 0.1 fn-show-cam]
        ]
        foreach o objs [fn-rot o]
        fn-show
    ]
    btn "Details" [show f-panel]
    btn "Help" [fn-surface-help]
    at 4x4
    f-panel: panel [
        across
        origin 4x4
        at 4x4
        space 4x4
        vtext "X" right 20
        f-xl: field 100
        f-xh: field 100
        return
        vtext "Y" right 20
        f-yl: field 100
        f-yh: field 100
        return
        vtext "Camera"
        return
        vtext "x" 20
        f-cx: field 204
        return
        vtext "y" 20
        f-cy: field 204
        return
        vtext "z" 20
        f-cz: field 204
        return
        f-fun-str: area 228x200 font-name "Courier" wrap
        return
        vtext "No of X-Squares" 100
        f-xsq: field 124
        return
        vtext "No of Y-Squares" 100
        f-ysq: field 124
        return
        f-anti-alias: check-line "Anti-Alias" true
        return
        f-pen: check-line "Pen"
        f-pen-col: box black 20x20 edge [size: 1x1] [
            lv-val: request-color/color f-pen-col/color
            either lv-val = none [f-pen/data: false]
            [f-pen/data: true f-pen-col/color: lv-val]
            show [f-pen f-pen-col]
        ]
        return
        vtext "Colors (Top)" 100
        f-top-c1: box 20x20 orange edge [size: 1x1] [
            lv-val: request-color/color f-top-c1/color
            if lv-val <> none [f-top-c1/color: lv-val]
            show [f-top-c1]
        ]
        f-top-c2: box 20x20 white edge [size: 1x1][
            lv-val: request-color/color f-top-c2/color
            if lv-val <> none [f-top-c2/color: lv-val]
            show [f-top-c2]
        ]
        return
        vtext "Colors (Bottom)" 100
        f-btm-c1: box 20x20 red edge [size: 1x1] [
            lv-val: request-color/color f-btm-c1/color
            if lv-val <> none [f-btm-c1/color: lv-val]
            show [f-btm-c1]
        ]
        f-btm-c2: box 20x20 white edge [size: 1x1][
            lv-val: request-color/color f-btm-c2/color
            if lv-val <> none [f-btm-c2/color: lv-val]
            show [f-btm-c1]
        ]
        return
        btn "Hightlight Square" [show f-panel-h] 112
        return
        btn "Hide" 112 [
            fn-prefs/hide-panel
        ]
        btn "Apply" 112 [fn-prefs]
    ] edge [size: 2x2 effect: 'ibevel]

    f-panel-h: panel [
        across
        origin 4x4
        at 4x4
        space 4x4
        vtext "Highlight square"
        return
        vtext "x:"
        f-x-high: field "1" 100
        space 0x0
        arrow left [fn-high-chg -1 0]
        space 4x4
        arrow right [fn-high-chg 1 0]
        return
        vtext "y:"
        f-y-high: field "1" 100
        space 0x0
        arrow left [fn-high-chg 0 -1]
        space 4x4
        arrow right [fn-high-chg 0 1]
        return
        vtext "Colors (Top)" 100
        f-htop-c1: box 20x20 0.0.150 edge [size: 1x1] [
            lv-val: request-color/color f-htop-c1/color
            if lv-val <> none [f-htop-c1/color: lv-val]
            show [f-htop-c1]
        ]
        f-htop-c2: box 20x20 0.0.200 edge [size: 1x1][
            lv-val: request-color/color f-htop-c2/color
            if lv-val <> none [f-htop-c2/color: lv-val]
            show [f-htop-c2]
        ]
        return
        vtext "Colors (Bottom)" 100
        f-hbtm-c1: box 20x20 200.200.200 edge [size: 1x1] [
            lv-val: request-color/color f-hbtm-c1/color
            if lv-val <> none [f-hbtm-c1/color: lv-val]
            show [f-hbtm-c1]
        ]
        f-hbtm-c2: box 20x20 255.200.200 edge [size: 1x1][
            lv-val: request-color/color f-hbtm-c2/color
            if lv-val <> none [f-hbtm-c2/color: lv-val]
            show [f-hbtm-c1]
        ]
        return
        vtext "x:" 50
        f-xh-val: info "0.0" 174 silver
        return
        vtext "y:" 50
        f-yh-val: info "0.0" 174 silver
        return
        vtext "f(x,y)" 50
        f-high-val: info "0.0" 174 silver
        return
        btn "Hide" 112 [
            fn-high-prefs/hide-panel
        ]
        btn "Apply" 112 [
            fn-high-prefs
        ]
    ] edge [size: 2x2 effect: 'ibevel] with [show?: false]
]

; create a function
create-function: function [t-func [string!]] [f]
[
    ; return a newly created function
    if error? try [f: to-block load t-func]
        [return none]
    function [x [any-type!] y [any-type!]] [] f
]


rot: false
dist: 0.0
theta1: 0.0
theta2: 0.0

fn-height: func [fn [string!] x1 [decimal! integer!] x2 [decimal! integer!] y1 [decimal! integer!] y2 [decimal! integer!] xs [decimal! integer!] ys [decimal! integer!] /local c h][
    f-fx: create-function fn
    c: 0
    ; corners
    for i y1 (y2 + (((y2 - y1) / ys / 10))) (y2 - y1) / ys [
        for j x1 (x2 + ((x2 - x1) / xs / 10)) (x2 - x1) / xs [
            ; evaluate function

            if error? lv-err: try [h: f-fx i j][
                focus f-x-high
                show f-x-high
                alert rejoin ["Unable to evaluate function at " i " , " j]
                h: 0
            ]
            c: c + 1
            objs/1/2/:c/3: h
        ]
    ]
    ; centers
    c: (xs + 1) * (ys + 1)
    for i y1 + ((y2 - y1) / ys / 2) y2 - ((y2 - y1) / ys / 2) + ((y2 - y1) / ys / 10) (y2 - y1) / ys [
        for j x1 + ((x2 - x1) / xs / 2) x2 - ((x2 - x1) / xs / 2) + ((x2 - x1) / xs / 10) (x2 - x1) / xs [
            ; function goes here
            h: f-fx i j
            c: c + 1
            objs/1/2/:c/3: h
        ]
    ]
]

fn-str: "(2 * exp - ( ((0.5  * x) * (0.5 * x)) + ((0.5 * (y + -3.0)) * (0.5 * (y + -3.0)) ) )) + (4 * exp - ( ((0.5 * (x + 3.0)) * (0.5 * (x + 3.0))) + ((0.5 * (y + 3.0)) * (0.5 * (y + 3.0))) ) )"
; fn-str: "((i) * (i)) + ((j) * (j)) / 20"
f-fun-str/text: fn-str

xl: -8
yl: -8
xh: 8
yh: 8
f-xl/text: to string! xl
f-yl/text: to string! yl
f-xh/text: to string! xh
f-yh/text: to string! yh
squares-x: 16
squares-y: 16
f-xsq/text: to string! squares-x
f-ysq/text: to string! squares-y
high-sq-cols: [0 0 0 0 0 0 0 0 0]

f-fun-str/text: fn-str
f-cx/text: "0"
f-cy/text: "0"
f-cz/text: "20"
fn-prefs

; initial camera
objs/1/1/6: 250
objs/1/1/4: 60
pen-color: none
anti-alias: true

foreach o objs [fn-rot o]

fn-show

view lv-lay
quit