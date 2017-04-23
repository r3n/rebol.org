REBOL [
    Title: "Graph functions"
    Date: 21-Aug-2001/12:22:03+2:00
    Version: 0.1.0
    File: %graph-fx.r
    Author: "Oldes"
    Purpose: "Some functions for making graphs with 3D columns"
    Comment: {This is not final version at all, there is still a lot of things to do!}
    Email: oldes@bigfoot.com
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

data: [
    ["1. row" 12 32 23]
    ["2. row" 3 12 11]
]

graph-size: 640x480
col-size:  10x10
col-color: 255.110.30
col-colors: [
    255.210.30
    255.110.30
    200.210.30
    200.110.30
    180.110.50
    80.255.100
    200.210.100
    255.190.50
    100.210.100
    50.255.150
]

zero-point: depth: rows: cols: 0

up-to: func[num limit][((to-integer num / limit) + 1) * limit ]

GetLimits: func[
    "Returns minumum and maximum value from the table"
    data "Block of rows with columns"
    /local max min
][
    if not block? data/1 [data: repend/only copy [] data]
    max: min: either integer? data/1/1 [data/1/1][0]
    foreach row data [
        foreach col next row [
            if number? col [
                either col > max [max: col][if col < min [min: col]]
            ]
        ]
    ]
    reduce [min max]
]
CountBlock: func[data [block!] /local counted][
    counted: 0
    foreach val next data [if number? val [counted: counted + val]]
    counted
]

CountColumns: func[
    "Counts all the columns values in rows"
    data "Block of rows with columns"
    /local counted
][
    if not block? data/1 [data: append/only copy [] data]
    counted: make block! length? data/1
    foreach row data [
        append counted CountBlock next row
    ]
    counted
]

get-scale: func[
    "Counts columns scale koeficient"
    data    "table data"
    height  "available height of the graph"
    /counted-columns    "If the columns will be counted"
    /local max-value
][
    probe max-value: last (GetLimits either counted-columns [CountColumns data][data])
    probe up-to max-value 25
    either max-value = 0 [1][height / up-to max-value 25]
]


MultiplyColumns: func[
    "Multiplies all values in the table"
    data "Block of rows with columns"
    m
    /local new-data new-row onerow?
][
    onerow? false
    if not block? data/1 [data: repend/only copy [] data onerow?: true]
    new-data: make block! length? data
    foreach row data [
        new-row: make block! length? row
        foreach col row [
            insert tail new-row either number? col [to-integer (col * m)][ col ]
        ]
        insert/only tail new-data new-row
    ]
    either onerow? [new-data/1][new-data]
]

GetColumn: func[
    "Returns draw parameters for 2d/3d column"
    position "bottom (back if 3D) column position"
    height width
    /D3 "3-Dimensional"
    /noedge
    /local urb ulf drf drb urf ulb "Corner positions" b w2
][
    w2: width / 2
    urb: to-pair reduce [position/x + width position/y - height]
    ulf: to-pair reduce [position/x - w2 position/y - height + w2]
    drf: to-pair reduce [position/x + w2 position/y + w2]
    drb: to-pair reduce [position/x + width position/y]
    urf: to-pair reduce [drf/x ulf/y]
    ulb: to-pair reduce [position/x urb/y]
    compose either d3 [
        [
            pen (col-color - 100)
            fill-pen (col-color) box (ulf) (drf)
            fill-pen (col-color - 20) polygon (drf) (drb) (urb) (urf)
            fill-pen (col-color + 20) polygon (ulf) (ulb) (urb) (urf)
            line (ulf) (ulb) (urb) (urf)
            line (drf) (drb) (urb)
        ]
    ][
        either noedge [
            [fill-pen (col-color) polygon (position)(drb)(urb)(ulb)]
        ][
            [pen (col-color - 100) fill-pen (col-color) box (position) (urb)]
        ]
    ]
]



GetColumns: func[data /spacing sp /reversed-cols /local  col-id c w pos columns][
    columns: make block! []
    position: make pair! zero-point

    if not spacing [sp: 0]
    if not block? data/1 [data: repend/only copy [] data]
    w: col-size/x
    depth: col-size/y
    pos: make pair! position
    r: 0
    col-id: 1
    foreach row data [
        c: 0
        col-color: col-colors/:col-id
        col-id: either col-id = (length? col-colors) [1][col-id + 1]
        if reversed-cols [row: head reverse row]
        foreach col next row [
            position/x: pos/x + (c * (sp + w))
            position/y: pos/y + (r * (sp +( depth / 2)))
            if number? col [
                insert tail columns GetColumn/d3 position col w
            ]
            c: c + 1
        ]
        r: r + 1
        pos/x: pos/x - (sp + w / 2)
    ]
    columns
]

GetColumnsCounted: func[data /d3 /spacing sp /local col-id c y r w pos columns][
    columns: make block! [draw]
    position: make pair! zero-point
    append/only columns copy []
    corner: position
    if not spacing [sp: 2]
    if not block? data/1 [data: repend/only copy [] data]
    w: col-size/x
    pos: position
    c: 0
    while [c < (length? data/1 )][
        c: c + 1
        y: 0
        r: 0
        col-id: 1
        foreach row data [
            r: r + 1
            col-color: col-colors/:col-id
            col-id: either col-id = (length? col-colors) [1][col-id + 1]
            position/y: pos/y - y - (r * sp)
            insert tail columns/2 either d3 [
                GetColumn/d3 position data/:r/:c w
            ][  GetColumn position data/:r/:c w ]
            y: y + data/:r/:c
        ]
        position/x: pos/x + (c * (sp + w))
    ]
    insert head columns/2  (Get3Dgrid corner )
    make face [
        color: 242.242.242
        size: graph-size
        edge: make object! [color: 230.230.230 size: 0x0]
        effect: columns
    ]
]

draw3Daxes: func[/local depth][
    depth: (graph-size/y - zero-point/y)
    c1: to-pair reduce [zero-point/x 0]
    c2: to-pair reduce [cols * col-size/x + c1/x  0]
    c3: to-pair reduce [c2/x zero-point/y]
    c4: to-pair reduce [zero-point/x - depth zero-point/y + depth]
    c5: to-pair reduce [c2/x - depth zero-point/y + depth]
    make block! compose[
        line (zero-point) (c1 ) ;y axis
        line (zero-point) (c3 ) 
        line (zero-point) (c4)
        line (c1) (c2) (c3) (c5) (c4)
    ]
]

draw3Dguide: func[
    /local draw-data i p1 p2 d2 d4 col-id
][
    draw-data: copy []
    i: 0
    p1: zero-point
    d2: col-size/y / 2
    d4: d2 / 2
    p1/x: p1/x - d4 + 2
    p1/y: min graph-size/y p1/y + d4 + 1
    p2: to-pair reduce [graph-size/x + 15 p1/y]
    p3: to-pair reduce [p2/x size/y - (rows * 12) ]
    p4: to-pair reduce [p2/x + (rows * 2) p3/y ]
    col-id: 1
    insert tail draw-data [font guideText]
    foreach row data [
        i: i + 1
        col-color: col-colors/:col-id - 100
        insert tail draw-data compose [
            pen (col-color) line (p1) (p2) (p3) (p4)
            line (p4 - 0x1) (p4 - 2x1)
            fill-pen (col-colors/:col-id + 20)
            box (p4 + 0x3) (p4 + 10x-7)
            pen: 0.0.0
            text (row/1) (p4 + 12x-8)
        ]
        p1/x: max 0 zero-point/x - (i * d2) - d4 + 2
        p1/y: min graph-size/y zero-point/y + (i * d2) + d4 + 1
        p2/x: p2/x + 2
        p2/y: p1/y
        p3: p3 + 2x12
        p4/y: p3/y
        
        col-id: either col-id = (length? col-colors) [1][col-id + 1]
    ] 
    draw-data
]

draw3DhorizontalGrid: func[
    /local draw-data p1
][
    draw-data: copy []
    p1: make pair! zero-point
    for y 0 60 10 [
        p1/y: p1/y - 20
        p2: to-pair reduce [p1/x - depth p1/y + depth] 
        p3: to-pair reduce [p1/x + (cols * col-size/x) p1/y]
        insert tail draw-data compose [
            line (p2) (p1) (p3)
        ]
    ]
    draw-data
]

draw3DBottomGrid: func[
    data
    /local colors column draw-data draw-position col-id
][
    ;column: [depth 60 width 10]
    colors: [175.190.195 170.185.205]
    col-id: 1
    draw-data: copy []
    draw-position: make pair! zero-point
    foreach column-width data [
        insert tail draw-data Get3DbottomColumn
            draw-position       ;position
            column-width                ;column width
            depth               ;column depth
            colors/:col-id  + 20    ;fill color
        draw-position/x: draw-position/x + column-width
        col-id: either col-id = (length? colors) [1][col-id + 1]
    ]
    draw-data
]

draw3DWallGrid: func[
    data
    /local colors
][
    colors: [175.190.195 170.185.205]
    col-id: 1
    draw-data: copy []
    draw-pos: make pair! zero-point
    foreach column-width data [
        col-color: colors/:col-id   
        insert tail draw-data GetColumn/noedge draw-pos zero-point/y column-width
        draw-pos/x: draw-pos/x + column-width
        col-id: either col-id = (length? colors) [1][col-id + 1]
    ]
    draw-data
]

Get3DbottomColumn: func[
    pos width depth color /edge
    /local d2 c1 c2 c3
][
    d2: depth / 2
    c1: to-pair reduce [(pos/x + width) pos/y]
    c2: to-pair reduce [(pos/x + width - d2) pos/y + d2]
    c3: to-pair reduce [(pos/x - d2) c2/y]
    compose either edge [
        [pen (color) line (pos) (c1) (c2) (c3)]
    ][  [fill-pen (color) polygon (pos) (c1) (c2) (c3)]]
]

graph: func[
    table
    facets [block!] ;[size 320x240 column 10x10]
    /local graph-face
][
    size:   facets/size if none? size [size: 320x240]
    graph-size: size
    column: facets/column if none? column [column: 5x10]
    col-size: column
    rows: length? table
    cols: -1 + length? table/1
    ;first i need to find the zero-point of the graph
    zero-point: 0x0
    zero-point/x: rows  * (col-size/y / 2 ) + 10
    zero-point/y: size/y - zero-point/x
    ;-----
    depth: 2 * zero-point/x
    
    guideText: make object! [
        name: "arial"
        style: none
        size: 11
        color: 0.0.0
        offset: 2x2
        space: 0x0
        align: 'center
        valign: 'center
        shadow: none
    ]
    
    probe sc: get-scale table (zero-point/y - 10)
    data: MultiplyColumns table sc
    data: sort/compare data func[a b][(CountBlock a) > (CountBlock b)]
    week-grid: multiplyColumns week-grid col-size/x
    eff: make block! [draw] append/only eff copy []
    append eff/draw draw3DBottomGrid week-grid
    append eff/draw draw3DWallGrid week-grid
    append eff/draw draw3Daxes
    append eff/draw draw3DhorizontalGrid 
    append eff/draw draw3Dguide
    
    append eff/draw GetColumns data

    graph-face: make face compose [
        size: (size + 180x1)
        edge: none
        color: white
    ]
    graph-face/effect: eff
    graph-face
]                                                                                                                                                                                                                                                                                                                                                                                       