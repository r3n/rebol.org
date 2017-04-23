REBOL [
    Title: "Rebocalc"
    Date: 19-Jun-2001
    Version: 1.0.0
    File: %rebocalc.r
    Author: "Carl Sassenrath"
    Purpose: {The world's smallest spreadsheet program, but very powerful.}
    Email: carl@rebol.com
    library: [
        level: 'beginner 
        platform: [all plugin]
        plugin: [size: 900x550]
        type: 'tool 
        domain: [math GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

csize: 100x20
max-x: 8
max-y: 16
pane: []
xy: csize / 2 + 1 * 1x0
yx: csize + 1 * 0x1
layout [
    cell:  field csize edge none [enter face  compute  face/para/scroll: 0x0]
    label: text csize white black bold center
]

;--Headings:
char: #"A"
repeat x max-x [
    append pane make label [offset: xy text: char]
    set in last pane 'offset xy
    xy: csize + 1 * 1x0 + xy
    char: char + 1
]
repeat y max-y [
    append pane make label [offset: yx text: y size: csize * 1x2 / 2]
    yx: csize + 1 * 0x1 + yx
]
xy: csize * 1x2 / 2 + 1

;--Cells:
cells: tail pane
repeat y max-y [
    char: #"A"
    repeat x max-x [
        v: to-word join char y
        set v none
        char: char + 1
        append pane make cell [offset: xy text: none var: v formula: none]
        xy: csize + 1 * 1x0 + xy
    ]
    xy: csize * 1x2 / 2 + 1 + (xy * 0x1)
]

enter: func [face /local data] [
    if empty? face/text [exit]
    set face/var face/text
    data: either face/text/1 = #"=" [next face/text][face/text]
    if error? try [data: load data] [exit]
    if find [integer! decimal! money! time! date! tuple! pair!] type?/word :data [set face/var data exit]
    if face/text/1 = #"=" [face/formula: :data]  ; string case falls thru
]

compute: has [blk] [
    unfocus
    foreach cell cells [
        if cell/formula [ ;probe cell/var
            if error? cell/text: try [do cell/formula] [cell/text: "ERROR!"]
            set cell/var cell/text
            show cell
        ]
    ]
]

lo: layout [
    bx: box second span? pane
    pad 55x0
    text as-is trim/auto {
        Cells can be numbers, times, money, tuples, pairs, etc.
        If a cell is not a scalar value, then it is treated as a string.
        Start formulas with the = character.  Any REBOL expression is valid.
        Remember to put spaces between each item in a formula.  Use ( ) where needed.
        Refer to cells as A1 D8 E10.  Example: =A1 + B1 * length? B8
        Example: in A1 type REBOL, in B1 type =length? a1, in C1 type =reverse copy a1
        Then: in D1 =checksum A1.  Now, change A1 to "Amazing!"
        In A2 type 1 + 2 (no =), in B2 type =A2.  Now change A2 to 3 * 4.
        Try: =(now/time) or =request-date or =checksum read rejoin [http://www. A1 ".com"]
        Computation moves from top to bottom. It is non-iterative.
    }
]
bx/pane: pane
view lo


