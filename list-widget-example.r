REBOL [
    title: "List Widget Example"
    file: %list-widget-example.r
    date: 8-jul-2010
    author:  Nick Antonaccio
    purpose: {
        This examples demonstrates how to use REBOL's native GUI list
        widget to manage a grid of data values.  Columns can be sorted
        by clicking the headers.  Individual values at any column/row
        position can be edited by the user (just click the current value).
        Entire rows can be added, removed, or moved to/from user-selected
        positions.  The data block can be saved or loaded to/from file(s).
        Scrolling can be done with the mouse, arrow keys, or page-up/
        page-down keys.  Several resizing concepts are also demonstrated.
    }
]
x: copy []   random/seed now/time   ; generate 5000 rows of random data:
repeat i 5000 [
    append/only x reduce [random "asdfqwertyiop" form random 1000 form i]
]  y: copy x
Alert {Be sure to try the following features:  1) Resize the GUI window
    to see the list automatically adjust to fit  2) Click column headers
    to sort by field  3) Use the arrow keys and page-up/page-down keys to
    scroll  4) Use the Insert, Delete and "M" keys to add, remove and move
    rows (at the currently highlighted row)  5) Click the small "r" header
    button in the top right corner to reset the list back to its original
    values  6) Click any individual data cell to edit the selected value.}
sort-column: func [field] [
    either sort-order: not sort-order [
        sort/compare x func [a b] [(at a field) > (at b field)]
    ] [
        sort/compare x func [a b] [(at a field) < (at b field)]
    ]  
    show li
]
key-scroll: func [scroll-amount] [
    s-pos: s-pos + scroll-amount
    if s-pos > (length? x) [s-pos: length? x]
    if s-pos < 0 [s-pos: 0]
    sl/data: s-pos / (length? x)  
    show li  show sl
]
resize-grid: func [percentage] [
    gui-size: system/view/screen-face/pane/1/size ; - 10x0
    list-size/1: list-size/1 * percentage
    list-size/2: gui-size/2 - 95
    t-size: round (list-size/1 / 3)
    sl-size: as-pair 16 list-size/2
    unview/only gui view/options center-face layout gui-block [resize]
]
resize-fit: does [
    gui-size: system/view/screen-face/pane/1/size
    resize-grid (gui-size/1 / list-size/1 - .1)
]
insert-event-func [either event/type = 'resize [resize-fit none] [event]]
gui-size: system/view/screen-face/size - 0x50
list-size: gui-size - 60x95
sl-size: as-pair 16 list-size/2
t-size: round (list-size/1 / 3)
s-pos: 0  sort-order: true  ovr-cnt: none  svv/vid-face/color: white
view/options center-face gui: layout gui-block: [
    size gui-size  across
    btn "Smaller" [resize-grid .75]
    btn "Bigger" [resize-grid 1.3333]
    btn "Fit" [resize-fit]
    btn #"^~" "Remove" [attempt [
        indx: to-integer request-text/title/default "Row to remove:" 
            form ovr-cnt
        if indx = 0 [return]
        if true <> request rejoin ["Remove: " pick x indx "?"] [return]
        remove (at x indx)  show li
    ]]
    insert-btn: btn "Add" [attempt [
        indx: to-integer request-text/title/default "Add values at row #:"
            form ovr-cnt
        if indx = 0 [return]
        new-values: reduce [
            request-text request-text (form ((length? x) + 1))
        ]
        insert/only (at x indx) new-values  show li
    ]]
    btn #"m" "Move" [
        old-indx: to-integer request-text/title/default "Move from row #:"
            form ovr-cnt
        new-indx: to-integer request-text/title "Move to row #:"
        if ((new-indx = 0) or (old-indx = 0)) [return]
        if true <> request rejoin ["Move: " pick x old-indx "?"] [return]
        move/to (at x old-indx) new-indx  show li
    ]
    btn "Save" [save to-file request-file/save x]
    btn "Load" [y: copy x: copy load request-file/only  show li]
    btn "View Data" [editor x]
    return  space 0x0
    style header button as-pair t-size 20 black white bold
    header "Random Text" [sort-column 1]
    header "Random Number" [sort-column 2] 
    header "Unique Key" [sort-column 3]
    button black "r" 17x20 [if true = request "Reset?"[x: copy y show li]]
    return
    li: list list-size [
        style cell text t-size feel [
            over: func [f o] [
                if all [o ovr-cnt <> f/data] [ovr-cnt: f/data show li]
            ]
            engage: func [f a e] [
                if a = 'up [
                    f/text: request-text/default f/text show li
                ]
            ]
        ]             
        across  space 0x0
        col1: cell blue
        col2: cell
        col3: cell red
    ] supply [
        either even? count [face/color: white] [face/color: 240.240.255]
        count: count + s-pos
        if none? q: pick x count [face/text: copy "" exit]
        if ovr-cnt = count [face/color: 200.200.255]
        face/data: count
        face/text: pick q index
    ]
    sl: scroller sl-size [s-pos: (length? x) * value  show li]
    key keycode [up] [key-scroll -1]
    key keycode [down] [key-scroll 1]
    key keycode [page-up] [key-scroll -20]
    key keycode [page-down] [key-scroll 20]
    key keycode [insert] [do-face insert-btn 1]
] [resize]
