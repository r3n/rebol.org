REBOL [
    Title:   "Rectangle Module"
    File:    %rect-lib.r
    Author:  "Gregg Irwin"
    EMail:   greggirwin@acm.org
    Version: 0.0.1
    Date:    11-Oct-2003
    Purpose: {
        Code from a REBOLForces article
        (http://www.rebolforces.com/articles/pairs/2/) that provides
        support for rectangle-related operations. It was also used to
        explore the concept of function spec templates. You could
        refactor that concept out though if you want.
    }
    library: [
        level:    'advanced
        platform: 'all
        type:     [function module]
        domain:   [UI math]
        tested-under: [view/pro 1.2.8.3.1 on W2K]
        support:  none
        license:  'public-domain
        see-also: none
    ]
]

rect: make object! [
    ; make a rectangle object
    _rect: make object! [offset: size: 0x0]

    _make-rect: func [offset [pair!] size [pair!]] [
        make _rect compose [offset: (offset) size: (size)]
    ]

    ; These are function interface templates.
    _fn-spec-1: compose [(copy "") r [block! object!] "The rectangle"]
    _fn-spec-2: append copy _fn-spec-1 [r2 [block! object!] "The other rectangle"]
    _fn-spec-3: append copy _fn-spec-1 [value [pair!]]

    mod-fn-spec: func [spec [block!] desc [string!]] [
        head change copy spec desc
    ]


    top?:    func _fn-spec-1 [r/offset/y]
    left?:   func _fn-spec-1 [r/offset/x]
    height?: func _fn-spec-1 [r/size/y]
    width?:  func _fn-spec-1 [r/size/x]
    right?:  func _fn-spec-1 [add left? r width? r]
    bottom?: func _fn-spec-1 [add top? r height? r]
    ; upper-left and lower-right shortcuts
    ul?:     func _fn-spec-1 [r/offset]
    lr?:     func _fn-spec-1 [add r/offset r/size]

    empty?: func mod-fn-spec _fn-spec-1
        "An empty rectangle is one with no area"
    [
        any [(0 >= height? r) (0 >= width? r)]
    ]

    equal?: func mod-fn-spec _fn-spec-2
        "Equal rectangles have the same coordinates"
    [
        all [(r/offset = r2/offset) (r/size = r2/size)]
    ]


    inflate: func mod-fn-spec _fn-spec-3
        {Inflates a rectangle by the specified amounts. The change occurs
     in all directions. I.e. the offset will change as well as the size.
     Negative values deflate the rectangle.}
    [
        r/offset: subtract r/offset value
        r/size: add r/size (value * 2)
        r
    ]

    deflate: func mod-fn-spec _fn-spec-3
        {Deflates a rectangle by the specified amounts. The change occurs
     in all directions. I.e. the offset will change as well as the size.
     Negative values inflate the rectangle.}
    [
        inflate r negate value
    ]

    grow: func mod-fn-spec _fn-spec-3
        {Grows a rectangle by the specified amounts. Negative values shrink it.}
    [
        r/size: add r/size value
        r
    ]

    shrink: func mod-fn-spec _fn-spec-3
        {Shrinks a rectangle by the specified amounts. Negative values grow it.}
    [
        grow r negate value
    ]

    move: func mod-fn-spec _fn-spec-3
        {Moves a rectangle by the specified amounts. Negative values are allowed.}
    [
        r/offset: add r/offset value
        r
    ]

    contains?: func mod-fn-spec _fn-spec-3
        {Returns true if the specified point lies within the rectangle.}
    [
        within? value r/offset r/size
    ]

    intersects?: func mod-fn-spec _fn-spec-2
        "Returns true if the rectangles intersect."
    [
        to-logic any [
            (contains? r2 ul? r)
            (contains? r2 lr? r)
            (contains? r  ul? r2)
            (contains? r  lr? r2)
            all [
                (left? r)  < (right?  r2)
                (left? r2) < (right?  r)
                (top?  r)  < (bottom? r2)
                (top?  r2) < (bottom? r)
            ]
        ]
    ]

    intersection: func mod-fn-spec _fn-spec-2
        {Returns the intersection of the two rectangles as an object
        containing offset and size values.}
    [
        either intersects? r r2 [
            _make-rect
                maximum ul? r2 ul? r
                ; Have to subtract the intersection offset to get the size
                subtract minimum lr? r2 lr? r (maximum ul? r2 ul? r)
        ][
            _make-rect 0x0 0x0
        ]
    ]

    union: func mod-fn-spec _fn-spec-2
        {Returns the union of the two rectangles as an object
        containing offset and size values.}
    [
        _make-rect
            minimum ul? r2 ul? r
            ; Have to subtract the union offset to get the size
            subtract maximum lr? r2 lr? r (minimum ul? r2 ul? r)
    ]

]

; r0: [offset 0x0 size 0x0]
; r1: [offset 20x20 size 80x80]
; r2: [offset 40x10 size 40x100]
; 
; print rect/top? r1
; print rect/left? r1
; print rect/right? r1
; print rect/bottom? r1
; print rect/height? r1
; print rect/width? r1
; print mold rect/inflate r1 2x2
; print mold rect/deflate r1 2x2
; print mold rect/grow r1 2x2
; print mold rect/shrink r1 2x2
; print mold rect/move r1 2x2
; 
; print [rect/contains? r1 0x0 tab "should be false"]
; print [rect/contains? r1 40x40 tab "should be true"]
; print [rect/contains? r1 79x79 tab "should be true"]
; print [rect/contains? r1 183x183 tab "should be false"]
; 
; print rect/intersects? r1 r2
; print rect/intersects? r2 r1
; print rect/intersects? r0 r1
; print rect/intersects? r0 r2
; 
; print mold rect/intersection r0 r1
; print mold rect/intersection r1 r2
; print mold rect/intersection r2 r1
; print mold rect/intersection r0 r2
; 
; print mold rect/union r0 r1
; print mold rect/union r1 r2
; print mold rect/union r2 r1
; print mold rect/union r0 r2
; 
; halt


; get-coordinates: func [r [block! object!]] [
;     compose [(r/offset) (r/size)]
; ]
; 
; coordinates-to-paren: func [r [block! object!]] [
;     to-paren compose [(r/offset) (r/size)]
; ]
; 
; coordinates-to-paren: func [r [block! object!]] [
;     to-paren compose [(r/offset) (r/offset + r/size)]
; ]
; 
; rect-lib-test: func [face-1 face-2 draw-face /local r] [
;     draw-face/effect: compose/deep [
;         draw [
;             ; Show where the faces are now
;             pen blue
;             box (rect/ul? face-1) (rect/lr? face-1)
;             pen orange
;             box (rect/ul? face-2) (rect/lr? face-2)
;             ; Resize the faces. This is a bit odd, being inside
;             ; the draw commands we're building, but it works.
;             (rect/inflate face-1 5x5)
;             (rect/deflate face-2 5x5)
;             ; Back to draw commands
;             pen black
;             box (rect/ul? r: rect/intersection face-1 face-2) (rect/lr? r)
;             pen red
;             box (rect/ul? r: rect/union face-1 face-2) (rect/lr? r)
;         ]
;     ]
;     show [face-1 face-2 draw-face]
; ]
; 
; lay: layout [
;     b1: box yellow 100x100
;     at 50x50
;     b2: box green 100x100
;     at 175x20
;     button "Test" [rect-lib-test b1 b2 b3]
;     button "Quit" [quit]
;     ; This is our drawing surface
;     at 0x0
;     b3: box 175x175 effect [draw copy []]
; ]
; 
; view lay
