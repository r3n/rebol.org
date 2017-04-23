REBOL 
[
    Title: "Graph a function"
    File: %graph.r
    Author: "Phil Bevan"
    Date: 21-Oct-2001/12:00:00
    Version: 1.1.0
    Email: philb@upnaway.com
    Category: [math]
    Purpose: {
        Graph a function 
        rounding function by Ladislav Mecir

        Usage .... 
            Type in your function of x into the input field        
        
        Some pretty functions to get you started .....
        3 * sin (0.5 * pi * x)
        3 * sin (x * x)
        exp(0.1 * x) * (sin(4 * pi * x))
        4 * sin (4 * pi / x)
        0.2 * exp(- x) * sin (0.5 * pi * x)
        10 / ((3 * x * x) + (4 * x) - 3)

    }

    History: [
        1.0.1   ["Initial version" "Phil Bevan"]
        1.0.2   ["Initial Version submitted to library" "Phil Bevan"]
        1.0.3   ["Tidy up GUI Settings" "Phil Bevan"] 
        1.0.4   ["Change line type Button choice to rotary" "Phil Bevan"]
        1.0.5   ["Add Navigation Panel" "Phil Bevan"]
        1.0.6   ["Add Grid Markings & Finish Nav Panel" "Phil Bevan"] 
        1.0.7   ["Add help function,flash Drawing Graph" "Phil Bevan" ] 
        1.1.0   ["Use draw dialect to draw graph" "Phil Bevan"]
        ]
    Email: philb@upnaway.com
    library: [
        level: 'advanced
        platform: [all]
        type: [tool]
        domain: 'math 
        tested-under: ["view 1.2.8.3.1" "view 1.2.46.3.1"]
        support: none 
        license: none 
        see-also: none
    ]
]

; functions
paper: make object! 
[
    size: 0x0
    x-min: -1 
    x-max: 1
    y-min: -1 
    y-max: 1
    grid: yes
    x-grid: 0.5
    y-grid: 0.5
    zoom-in: 0.5
    zoom-out: 2
    grid-color: sky
    axes: yes
    axes-color: black
    paper-color: white
    pen-color: black
    axes-color: black
    image: none
    draw: copy []
    crt: func 
    [
        size [pair!] 
        xmin [decimal!] 
        xmax [decimal!] 
        ymin [decimal!] 
        ymax [decimal!] 
    ]
    [
        self/size: size
        self/x-min: xmin
        self/x-max: xmax
        self/y-min: ymin
        self/y-max: ymax
    ]
]

; plot a point
fn-plot: func [paper [object!] p [pair!] col [tuple!] /local i xs ys]
[
    xs: paper/size/x 
    ys: paper/size/y
    if any[p/x < 1 p/x > xs p/y < 1 p/y > ys]
        [return]
    
    append paper/draw 'pen
    append paper/draw col
    append paper/draw 'line
    append paper/draw p
    append paper/draw p
]

fn-draw-line: func [
    {draw line from point a to b using Bresenham's algorithm}
    paper [object!] 
    a [pair!]
    b [pair!]
    color [tuple!]
    /local d inc dpr dpru p set-pixel xs ys
][
    append paper/draw 'pen
    append paper/draw color
    append paper/draw 'line
    append paper/draw a
    append paper/draw b
]

; Convert Degrees to Radians & Radians to Degrees 
rad: function [x] [] [ x * pi / 180 ]
deg: function [x] [] [ x * 180 / pi ] 

; trig functions
sin: function [x] [] [return sine/radians x]
cos: function [x] [] [return cosine/radians x]
tan: function [x] [] [return tangent/radians x]

; square-root
sqrt: function [x] [] [return square-root x]

; hyperbolic trig functions
sinh: function [x] [] [return ((exp(x)) - (exp(- x))) / 2]
cosh: function [x] [] [return ((exp(x)) + (exp(- x))) / 2]
tanh: function [x] [] [return ((exp(2 * x)) - 1) / ((exp(2 * x)) + 1)]

fac: func [x [integer!] /local fa i]
[
    if x < 0 [return none]
    fa: 1.0
    i: 1
    while [i <= x]
    [
        fa: fa * i
        i: i + 1
    ]
    return fa
]

; create a function
create-function: function [t-func [string!]] [f] 
[
    ; return a newly created function
    if error? try [f: to-block load t-func]
        [return none]
    function [x [any-type!]] [] f
]

mod: func 
[
    {compute a non-negative remainder}
    a [number!]
    b [number!]
    /local r
]
[
    either negative? r: a // b [
        r + abs b
    ] [r]
]

round: func 
[
    "Round a number"
    n [number!]
    /places
    p [integer!] {Decimal places - can be negative}
    /local factor r
]
[
    factor: either places [10 ** (- p)] [1]
    n: 0.5 * factor + n
    n - mod n factor
]

floor: func [
    n [number!]
    /places
    p [integer!] {Decimal places - can be negative}
    /local factor r
] [
    factor: either places [10 ** (- p)] [1]
    n - mod n factor
]

ceiling: func [
    n [number!]
    /places
    p [integer!] {Decimal places - can be negative}
    /local factor r
] [
    factor: either places [10 ** (- p)] [1]
    n + mod (- n) factor
]

truncate: func [
    n [number!]
    /places
    p [integer!] {Decimal places - can be negative}
    /local factor r
] [
    factor: either places [10 ** (- p)] [1]
    n - (n // factor)
]

; initialise the graph
init-graph: func [paper [object!]]
[
    gr-paper-f/color: paper/paper-color
    show gr-paper-f
    clear paper/draw
    fn-draw-axes paper
]

fn-draw-axes: func [paper /local pt]
[
    fn-draw-grid paper
    pt: coordinates paper 0 0
    if all [pt/y >= 0 pt/y < paper/size/y]
        [fn-draw-line paper to-pair reduce [1 pt/y] to-pair reduce [(paper/size/x - 1) pt/y] paper/axes-color] ; x-axis
    if all [pt/x >= 0 pt/x < paper/size/x]
        [fn-draw-line paper to pair! reduce [pt/x 1] to pair! reduce [pt/x paper/size/y] paper/axes-color]; y-axis
]

; draw grid
fn-draw-grid: func [paper [object!] /local gs pt-from pt-to]
[
    if all [paper/x-grid <> 0 paper/x-max - paper/x-min > paper/x-grid]
    [
        ; draw x-gridlines
        either paper/x-min < 0
            [gs: (to-integer (paper/x-min / paper/x-grid) - 1) * paper/x-grid]
            [gs: (to-integer (paper/x-min / paper/x-grid) + 1) * paper/x-grid]
        while [gs <= paper/x-max]
        [
            gs: gs + paper/x-grid
            pt-from: coordinates paper gs 0
            pt-to: coordinates paper gs 0
            pt-from/y: 1
            pt-to/y: paper/size/y - 1
            ; print [pt-from pt-to]
            fn-draw-line paper pt-from pt-to paper/grid-color
        ]
    ]   

    if all [paper/x-grid <> 0 paper/y-max - paper/y-min > paper/y-grid]
    [
        ; draw y-gridlines
        gs: (to-integer (paper/y-min / paper/y-grid)) * paper/y-grid
        while [gs <= paper/y-max]
        [
            gs: gs + paper/y-grid
            pt-from: coordinates paper 0 gs
            pt-to: coordinates paper 0 gs
            pt-from/x: 1
            pt-to/x: paper/size/x - 1
            fn-draw-line paper pt-from pt-to paper/grid-color
        ]
    ]
    font-obj: make face/font [
        name: font-fixed
        size: 12
        ; style: [italic]
    ]

    lv-coords: rejoin ["(" paper/x-min "," paper/y-min ") - (" paper/x-max "," paper/y-max ")"]
    lv-text-pos: make pair! reduce [0 (paper/size/y - 14)]
    append paper/draw 'font 
    append paper/draw font-obj
    append paper/draw 'pen
    append paper/draw paper/axes-color
    append paper/draw 'text
    append paper/draw lv-text-pos
    append paper/draw lv-coords

]

; convert to co-ordinates
coordinates: func [paper [object!] x [number!] y [number!] /local xc yc]
[
    xd: x - paper/x-min
    xp: (paper/x-max - paper/x-min) / paper/size/x
    xc: xd / xp
    if any [xc < 0 xc > paper/size/x] [-1]
    if error? try[xc: to-integer round xc]
        [return none]
    
    yd: y - paper/y-min
    yp: (paper/y-max - paper/y-min) / paper/size/y
    yc: paper/size/y - (yd / yp)
    if any [yc < 0 yc > paper/size/y] [-1]
    if error? try[yc: to-integer round yc]
        [return none]

    return make pair! reduce [xc yc]
]

new-styles: stylize
[
    fix-area: area font [name: "courier new" size: 12] wrap
    fix-field: field font [name: "courier new" size: 12]
    fix-text: text font [name: "courier new" size: 12]
] 


; Draw the graph
draw-graph: func 
[
    paper [object!] t-fx [string!] trace [string!] 
    /local x x-step fx pt last-pt lv-flash
]
[
    if t-fx = ""
        [request/ok "No function entered" return]

    f-fx: create-function t-fx

    if not function? :f-fx
        [request/ok "Improper function entered" return]    

    lv-flash: flash "Drawing graph"
    last-pt: none
    x-step: (paper/x-max - paper/x-min) / paper/size/x
    for x paper/x-min paper/x-max x-step
    [
        either not error? try [fx: f-fx x]
        [
            pt: coordinates paper x fx
            if pt <> none
                [
                    switch trace
                    [
                        "Point" 
                            [fn-plot paper pt paper/pen-color]
                        "Line" 
                            [
                                either last-pt <> none
                                    [fn-draw-line paper last-pt pt paper/pen-color]
                                    [fn-plot paper pt paper/pen-color]
                            ]
                    ]
                ]
            last-pt: pt
        ]
        [last-pt: none]
    ]
    unview lv-flash
]

; Graph Paper settings
gr-settings: func 
[
    paper [object!] 
    gr-face [object!]
    /local f-xmin f-xmax f-ymin f-ymax f-paper-color f-pen-color lv-valid lv-col
        lv-x-min lv-x-max
        lv-y-min lv-y-max
        lv-x-grid lv-y-grid
]
[
    view/new layout
    [
        backdrop 0.150.0
        styles new-styles
        origin 5x5
        space 5
        across
        at 5x5
        label "Min X" right 80x24
        f-xmin: fix-field to-string(paper/x-min) 100x24
        return
        label "Max X" right 80x24
        f-xmax: fix-field to-string(paper/x-max) 100x24
        return
        label "Min Y" right 80x24
        f-ymin: fix-field to-string(paper/y-min) 100x24
        return
        label "Max Y" right 80x24
        f-ymax: fix-field to-string(paper/y-max) 100x24
        return
        label "X Grid size" right 80x24
        f-xgrid: fix-field to-string(paper/x-grid) 100x24
        return
        label "Y Grid size" right 80x24
        f-ygrid: fix-field to-string(paper/y-grid) 100x24
        return
        label "Zoom+" right 80x24
        f-zoom-in: fix-field to-string(paper/zoom-in) 100x24
        return
        label "Zoom-" right 80x24
        f-zoom-out: fix-field to-string(paper/zoom-out) 100x24
        return
        pad 0x-3
        label "Clear" right 80x24
        pad 0x3
        cb-clear: check with [state: false]
        return
        pad 0x-5
        button "Paper Color" 80x24
        [
            lv-col: request-color/color paper/paper-color
            if lv-col <> none 
            [
                f-paper-color/color: lv-col
                show f-paper-color
            ]
        ]
        f-paper-color: box paper/paper-color 100x24 edge [size: 2x2 color: gray effect: 'bevel]
        return
        button "Pen Color" 80x24
        [
            lv-col: request-color/color paper/paper-color
            if lv-col <> none 
            [
                f-pen-color/color: lv-col
                show f-pen-color
            ]
        ]
        f-pen-color: box paper/pen-color 100x24 edge [size: 2x2 color: gray effect: 'bevel]  
        return
        button "Grid Color" 80x24
        [
            lv-col: request-color/color paper/paper-color
            if lv-col <> none 
            [
                f-grid-color/color: lv-col
                show f-grid-color
            ]
        ]
        f-grid-color: box paper/grid-color 100x24 edge [size: 2x2 color: gray effect: 'bevel]  
        return
        button "Apply" 185x24
        [
            lv-valid: true
            if error? try [lv-x-min: to-decimal f-xmin/text] [alert "Invalid Min X value entered" lv-valid: false focus f-xmin]
            if lv-valid [if error? try [lv-x-max: to-decimal f-xmax/text] [alert "Invalid Max X value entered" lv-valid: false focus f-xmax]]
            if lv-valid [if lv-x-min >= lv-x-max [alert "Min X value must be less than Max X value" lv-valid: no focus f-xmin]]
            if lv-valid [if error? try [lv-y-min: to-decimal f-ymin/text] [request/ok "Invalid Min Y value entered" lv-valid: false focus f-ymin]]
            if lv-valid [if error? try [lv-y-max: to-decimal f-ymax/text] [request/ok "Invalid Max Y value entered" lv-valid: false focus f-ymax]]
            if lv-valid [if lv-y-min >= lv-y-max [alert "Min Y value must be less than Max Y value" lv-valid: false focus f-ymin]]
            if lv-valid [if error? try [lv-x-grid: to-decimal f-xgrid/text] [request/ok "Invalid X grid value entered" lv-valid: false focus f-xgrid]]
            if lv-valid [if lv-x-grid < 0 [alert "X Grid value cannot be < 0" lv-valid: no focus f-xgrid]]
            if lv-valid [if error? try [lv-y-grid: to-decimal f-ygrid/text] [request/ok "Invalid Y grid value entered" lv-valid: false focus f-ygrid]]
            if lv-valid [if lv-y-grid < 0 [alert "Y Grid value cannot be < 0" lv-valid: no focus f-ygrid]]
            if lv-valid [if error? try [lv-zoom-in: to-decimal f-zoom-in/text] [request/ok "Invalid Zoom in factor entered" lv-valid: false focus f-zoom-in]]
            if lv-valid [if any [lv-zoom-in < 0 lv-zoom-in > 1] [alert "Zoom in factor must be between 0 & 1" lv-valid: no focus f-zoom-in]]
            if lv-valid [if error? try [lv-zoom-out: to-decimal f-zoom-out/text] [request/ok "Invalid Zoom out factor entered" lv-valid: false focus f-zoom-out]]
            if lv-valid [if lv-zoom-out < 1 [alert "Zoom out factor must be > 1" lv-valid: no focus f-zoom-out]]

            if lv-valid = yes
            [
                paper/x-min: lv-x-min
                paper/x-max: lv-x-max
                paper/y-min: lv-y-min
                paper/y-max: lv-y-max
                paper/x-grid: lv-x-grid
                paper/y-grid: to-decimal f-ygrid/text
                paper/zoom-in: lv-zoom-in
                paper/zoom-out: lv-zoom-out
                paper/paper-color: f-paper-color/color
                paper/pen-color: f-pen-color/color
                paper/grid-color: f-grid-color/color
                unview
                if cb-clear/data = true
                [
                    init-graph paper
                    show gr-face
                ]
            ]
        ]

    ]
]


fn-left: func [paper [object!] /local dx]
[
    dx: (paper/x-max - paper/x-min) / 10
    paper/x-min: paper/x-min - dx
    paper/x-max: paper/x-max - dx
    init-graph paper
    draw-graph paper t-func1/text first r-trace/data
    show gr-paper-f    
]

fn-right: func [paper [object!] /local dx]
[
    dx: (paper/x-max - paper/x-min) / 10
    paper/x-min: paper/x-min + dx
    paper/x-max: paper/x-max + dx
    init-graph paper
    draw-graph paper t-func1/text first r-trace/data
    show gr-paper-f    
]

fn-up: func [paper [object!] /local dy]
[
    dy: (paper/y-max - paper/y-min) / 10
    paper/y-min: paper/y-min + dy
    paper/y-max: paper/y-max + dy
    init-graph paper
    draw-graph paper t-func1/text first r-trace/data
    show gr-paper-f    
]

fn-down: func [paper [object!] /local dy]
[
    dy: (paper/y-max - paper/y-min) / 10
    paper/y-min: paper/y-min - dy
    paper/y-max: paper/y-max - dy
    init-graph paper
    draw-graph paper t-func1/text first r-trace/data
    show gr-paper-f    
]

fn-zoom-in: func [paper [object!] /local mid]
[
    mid: paper/x-min + ((paper/x-max - paper/x-min) / 2)
    nsize: (paper/x-max - paper/x-min) * paper/zoom-in / 2
    paper/x-min: mid - nsize
    paper/x-max: mid + nsize
    mid: paper/y-min + ((paper/y-max - paper/y-min) / 2)
    nsize: (paper/y-max - paper/y-min) * paper/zoom-in / 2
    paper/y-min: mid - nsize
    paper/y-max: mid + nsize
    init-graph paper
    draw-graph paper t-func1/text first r-trace/data
    show gr-paper-f    
]

fn-zoom-out: func [paper [object!] /local mid]
[
    mid: paper/x-min + ((paper/x-max - paper/x-min) / 2)
    nsize: (paper/x-max - paper/x-min) * paper/zoom-out / 2
    paper/x-min: mid - nsize
    paper/x-max: mid + nsize
    mid: paper/y-min + ((paper/y-max - paper/y-min) / 2)
    nsize: (paper/y-max - paper/y-min) * paper/zoom-out / 2
    paper/y-min: mid - nsize
    paper/y-max: mid + nsize
    init-graph paper
    draw-graph paper t-func1/text first r-trace/data
    show gr-paper-f    
]

;
; Main Line
;
gr-size: 500x500
gr-paper: make paper []
gr-paper/crt gr-size -5.0 5.0 -5.0 5.0
gr-paper/pen-color: 0.0.255

; colors
panel-back: 80.150.80

fn-draw-axes gr-paper
lv-init-eqn: "(sine (x * 256)) / x"

;
; view the window
;
lv-layout: layout [
    backdrop panel-back
    origin 0x0
    styles new-styles
    at 0x0
    space 0x0
    across
    panel teal
    [
        origin 0x0
        space 0
        across   
        vtext "Save" bold white teal 40x24
        [
            t-save-name: request-file/title/filter/keep/file "Save Graph as png" "Save" "*.png" "graph.png"
            if t-save-name <> none
            [
                if error? try [save/png to-file t-save-name to-image gr-paper-f] ; gr-paper/image]
                     [request/OK "Unable to Save graph"]
            ]
        ]
        vtext "Settings" bold white teal [gr-settings gr-paper gr-paper-f] 60x24
        vtext "Help" bold white teal 40x24
        [
            either exists? %graph.html 
            [browse %graph.html]
            [browse http://www.upnaway.com/~philb/philip/utils/graph.html]
        ] 
    ] edge [size: 1x1 color: gray effect: 'bevel] 495x24
    image logo.gif
    return

    panel 
    [
        across
        origin 5x5
        space 5x5
        at 5x5
        gr-paper-f: box gr-paper/size gr-paper/paper-color
            effect reduce ['draw gr-paper/draw]
        return
        t-func1: fix-field lv-init-eqn (gr-size * 1x0 + 0x24)
        space 0
        return

        r-trace: rotary 120.20.120 100x24 data ["Line" "Point"]
        button "Graph Color" 
        [
            gr-col: request-color/color gr-paper/pen-color 
            if gr-col <> none [gr-paper/pen-color: gr-col]
        ]
        space 0x5
        button "Draw f(x)" 100x24
        [
           draw-graph gr-paper t-func1/text first r-trace/data
           show gr-paper-f
        ]
        button "Save Equation" 
        [
            either t-func1/text = ""
            [request/ok "No equation to Save"]
            [
                filnm: request-file/title/filter/file/keep "Save Equation" "Save" "*.eqn" "graph.eqn"
                if filnm <> none
                [
                    if error? try [write to-file filnm t-func1/text]
                    [request/OK "Unable to Save Equation"]
                ]
            ]
        ]
        button "Load Equation"
        [
            filnm: request-file/title/filter/file/keep "Load Equation" "Load" "*.eqn" "graph.eqn"
            if filnm <> none
            [
                t-func1/text: read to-file filnm
                show t-func1
            ]
        ]
    
    ] 510x510 + (2 * 0x25) + 0x5

    panel
    [
        backdrop panel-back
        at 5x5
        panel
        [
            backdrop brick
            
            origin 5x5
            space 5
            at 5x5
            panel
            [
                at 0x20
                arrow left 20x20 [fn-left gr-paper]
                at 40x20
                arrow right 20x20 [fn-right gr-paper]
                at 20x0 
                arrow up 20x20 [fn-up gr-paper]
                at 20x40
                arrow down 20x20 [fn-down gr-paper]
            ] 70x70
            button "Zoom +" [fn-zoom-in gr-paper] 60x24
            button "Zoom -" [fn-zoom-out gr-paper] 60x24
            button "Clear" [init-graph gr-paper show gr-paper-f] 60x24
        ] edge [size: 2x2 color: gray effect: 'bevel] 90x510 + (2 * 0x24) 0x3
    ] 80x510 + (2 * 0x25) + 0x10
]

lv-layout/offset: system/view/screen-face/size - lv-layout/size / 2

view/title lv-layout
    reform [system/script/header/title system/script/header/version] 
