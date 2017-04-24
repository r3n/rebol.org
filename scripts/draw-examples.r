REBOL  [
    File: %draw-examples.r
    Date: 13-11-2011 
    Title: "One Hundred Draw Examples"
    Purpose: { - to illustrate draw examples.}
    License: "None"
    Author: "10Mile"
    Notes: {A text-list issue. "Basic Triangle" works, but "Triangle" alone
            causes multiple hilights (when only one is picked). Use than one word.
            Same in other groups.
      
            Similar strings may cause same problem.

            The examples are from www.rebol.com/docs/draw-ref.html}
]


;=================================================== draws text-list picked, shows script

draw-this: func [spec] [
    draw-box/effect:  [draw spec]
    draw-script/text: form mold select drawings copy draw-list/picked  ;copy not required
    if not find draw-script/text newline [replace draw-script/text "]" "^/ ]"]
    replace draw-script/text "["  "draw [ ^/    "  ;spaces work with form mold but not mold
    show [draw-box draw-script]
]

;=================================================== create a short list for text-list

gather: func [search-for] [
    clear draw-list/data
    reset-face draw-script
    reset-face draw-list
    draw-box/effect: none
    show draw-box
    forall selections [
        if find selections/1 search-for [
            append draw-list/data selections/1
        ]
    ]
    draw-list/picked: copy first draw-list/data  ;don't try this without copy
    show draw-list
    draw-this select drawings draw-list/picked
]

;=================================================== set fonts for draw

font-A: make face/font [style: 'bold size: 16]
font-B: make face/font [style: [bold italic] size: 20]
font-C: make face/font [style: [bold italic underline] size: 24]
bold20: make face/font [style: 'bold size: 20]
bold32: make face/font [style: 'bold size: 32]


;=================================================== series with example data

drawings: [
    "Radial Filled Box"
    [fill-pen radial 0x0 0 400 0 1 1 blue green red red box]

    "Pen Colors And Alpha Channel"
    [pen navy fill-pen yellow
     box 20x20 80x80
     fill-pen 0.200.0.150
     pen maroon
     box 30x30 90x90]

    "Image With Colored Transparencies"
    [image logo.gif 50x50 200x150 pen none line-width 0
    fill-pen 200.0.0.128 box 50x50  100x150
    fill-pen 0.200.0.128 box 100x50 150x150
    fill-pen 0.0.200.128 box 150x50 200x150]

    "Circle With Anti-Alias Off"
    [anti-alias off  line-width 10  circle 200x200 100]

    "Circle With Anti-Alias On"
    [anti-alias on  line-width 10  circle 200x200 100]

    "Simple Arcs Beginning With 0"
    [arc 200x25  100x100 0  90
    arc 200x125 100x100 0 135
    arc 200x250 100x100 0 180]

    "A Closed Arc"
    [arc 100x100 100x100 0 90  closed]

    "Closed Arcs"
    [fill-pen red    arc 100x100 90x90 135 180
    fill-pen green  arc 300x100 90x90 225 180
    fill-pen blue   arc 100x300 90x90 45  180
    fill-pen yellow arc 300x300 90x90 315 180]

    "More Arcs"                        ;comment {highlite issue if closed used in string}
    [fill-pen red    arc 150x250 90x90 0   180
    fill-pen green  arc 150x150 90x90 90  180
    fill-pen blue   arc 250x150 90x90 180 180
    fill-pen yellow arc 250x250 90x90 270 180]

    "Pie-Chart Arcs"
    [fill-pen red    arc 200x200 90x90 0   90 closed
    fill-pen green  arc 200x200 90x90 90  90 closed
    fill-pen blue   arc 200x200 90x90 180 90 closed
    fill-pen yellow arc 200x200 90x90 270 90 closed]

    "Exploded Pie-Charts, Change Centre Point"
    [pen white line-width 2
    fill-pen red    arc 204x204 150x150   0  90 closed
    fill-pen green  arc 196x204 150x150  90  30 closed
    fill-pen blue   arc 180x190 150x150 120 150 closed
    fill-pen yellow arc 204x196 150x150 270  90 closed]
    
    "Simple Arrow"
    [arrow 1x2  line 20x20 100x100]

    "Curved Arrow"
    [arrow 1x2  curve 50x50 300x50 50x300 300x300]

    "Open Spline Arrow"
    [arrow 1x2  spline 3
    20x20 200x70 150x200 50x300 80x300 200x200]

    "Closed Spline Arrow"
    [arrow 1x2  spline closed 3
    20x20 200x70 150x200 50x300 80x300 200x200]

    "Arrow With Polygon"
    [arrow 1x2  polygon 20x20 200x70 150x200 50x300]

    "Arrow Box"
    [arrow 1x2  box 20x20 150x200]

    "Blue Fill-Pen Box"
    [fill-pen blue box 20x20 200x200]

    "Background With Repeatede Fill-Pen Image"
    [fill-pen logo.gif  box 20x20 200x200]

    "Round Corner Boxes"
    [fill-pen blue box 20x20 380x380 30]

    "Rounded Imaged Filled Box"
    [fill-pen logo.gif  box 50x50 350x350 15]

    "Line Widths, Patterns, Joins, & Rounded Corners"
    [pen red yellow
    line-pattern 50 30
    line-width 30
    line-join round
    box 50x50 350x350 
    box 150x150 250x250 50]

    "A Simple Circle"
    [pen yellow line-width 5 circle 200x200 150]

    "Circle With An Image Pen"
    [pen logo.gif circle 200x200 150]

    "Circle With An Image Fill-Pen"
    [line-width 2 pen yellow fill-pen logo.gif
    circle 200x200 150]

    "Line Patterns"
    [pen red yellow
    line-pattern 50 30
    line-width 30
    circle 200x200 150]

   "Line Pattern 2"
    [pen blue green
    line-pattern 25 15
    line-width 15
    circle 200x200 125]

    "Clipped Box"
    [line-width 2 pen yellow 
    fill-pen blue
    clip 10x10 70x90
    box 20x20 200x200]

    "Clipping Other Shapes For Interesting Effects"
    [pen yellow 
    fill-pen red
    clip 50x50 125x200
    circle 50x50 100]

    "Use None To Turn clipping Off"
    [pen yellow
    fill-pen red
    clip 50x50 125x200
    circle 50x50 100
    pen green   fill-pen blue  
    clip none
    circle 125x75 50]


    "Single Control Point Curve"
    [curve 20x150 60x250 200x50]

    "Two Control Point Curve"
    [curve 20x20 80x300 140x20 200x300]

    "Thick Curve With Patterened Line"
    [pen yellow red
    line-pattern 5 5
    line-width 4
    curve 20x150 60x250 200x50]

    "Thick Curve With Two Control Points, A Patterened Line, & A Fill pen"
    [pen yellow red 
    line-pattern 5 5
    line-width 4 
    fill-pen blue
    curve 20x20 80x300 140x20 200x300]

    "Three Overlapping Ellipses"
    [fill-pen red   ellipse 100x125 50x100
    fill-pen white  ellipse 200x200 100x100
    fill-pen blue   ellipse 275x300 100x50]
 
    "Fill-Pen Gradiant 1"
    [fill-pen radial 200x200 0 100 0 1 1 
    blue green red yellow  
    box 100x100 300x300]

    "Fill-Pen Gradiant 2"
    [fill-pen radial 200x200 0 200 0 1 1 
    blue green red yellow  
    box 100x100 300x300]

    "Fill-Pen Gradiant 3"
    [fill-pen radial 200x200 0 300 0 1 1 
    blue green red yellow  
    box 100x100 300x300]

    "Fill-Pen Gradiant 4"
    [fill-pen radial 200x200 0 400 0 1 1 
    blue green red yellow  
    box 100x100 300x300]

    "Fill-Pen Gradiant 5"
    [fill-pen linear 0x0 0 300 25 1 1 
    red yellow green cyan blue magenta
    box 100x100 300x300]

    "Use None To Clear Fill-Pen"
    [fill-pen blue  box 100x100 200x200
    fill-pen none  box 200x200 350x350]

    "Fill-Pen Gradiant 6"
    [fill-pen radial 200x200 0 50 0 1 1 
    0.32.200 0.92.250 0.128.255 0.64.225 
    box 0x0 400x400]

    "Default Font"
    [text "Default font" 50x75]

    "Font 1"
    [font font-A text "16 pt, bold" 50x125]

    "Font 2"
    [font font-B text "20 pt, bold italic" 50x175]

    "Font 3"
    [font font-C text "24 pt, bold italic underline" 50x225]

    "Font 4"
    [font face/font text "face/font" 50x275]

    "A Normal Image"
    [image logo.gif]

    "Image At Specific Location"
    [image logo.gif 100x100]

    "Scaled Image At Location"  ;"Scaled Image At Specific Location"  issue too close duplicate hilite
    [image logo.gif 100x100 300x200]

    "Image With Border Using Line Attributes"
    [pen yellow red line-width 5 line-pattern 5 5
    image logo.gif 100x100 border]

    "Image With Patterened Border And A Key color"
    [pen yellow red line-width 5 line-pattern 5 5
    image logo.gif 100x100 254.254.254 border]

     "Perspective Images Or Simple Distortions"
    [image logo.gif 50x100 400x00 400x400 50x200
    image logo.gif 10x10 350x200 250x300 50x300]

    "A Line"
    [line 10x10 100x50]

    "Multiple Connected Lines"
    [line 10x10 20x50 30x0 4x40]

    "Pens & Line Attributes"
    [pen yellow red line-width 8 line-pattern 5 5
    line 10x10 20x50 30x0 4x40
    pen yellow  line-width 5  line-cap round
    line 100x100 100x200 200X100 200X200]

    "Butt End Line"
    [line-width 15
    line-cap butt
    pen red     line 20x20 150x20
    pen yellow  line 150x20 150x150
    pen red     line 150x150 20x150
    pen yellow  line 20x150 20x20]

    "Square End Line"
    [line-width 15
    line-cap square
    pen red     line 20x20 150x20
    pen yellow  line 150x20 150x150
    pen red     line 150x150 20x150
    pen yellow  line 20x150 20x20]

    "Round End Line"
    [line-width 15
    line-cap round
    pen red     line 20x20 150x20
    pen yellow  line 150x20 150x150
    pen red     line 150x150 20x150
    pen yellow  line 20x150 20x20]



    "Line Join Styles"
    [line-pattern 130 130
    pen red yellow
    line-width 15
    line-join miter         box 20x20 150x150
    line-join miter-bevel   box 220x20 350x150
    line-join round         box 22x220 150x350
    line-join bevel         box 220x220 350x350]



    "Alternating Red & Yellow"
    [line-pattern 10 10
     pen yellow red line 150x150 20x150
    ]

    "A Dashed Line, A Transparent Pen"
    [line-pattern 7 2
    pen none yellow line 150x150 20x150] ; comment {the NONE pen color must come first}
    


    "Repeating Stroke & Dash Sizes For Complex Patterns"
    [pen blue red
    line-pattern 7 2 4 4 3 6
    line 150x150 20x150]

    "Complex Pattern 2"
    [line-width 3
    pen red yellow
    line-pattern 1 5
    line 10x10 390x10
    ;line-pattern none ;To clear the current line pattern, set it to none.
    line 10x20 390x20
    line 10x30 390x30
    line-pattern 1 4 4 4
    box 10x40 390x80]

    "Complex Pattern 3"
    [line-width 3  pen red yellow
    line-pattern 1 5  line 10x10 390x10
    line-pattern 4 4  line 10x20 390x20]

    "Overlapped Squares"
    [pen yellow  
    line-width 5
    box 20x20 200x200
    pen yellow red
    line-width 5
    line-pattern 20 10
    box 50x50 250x250]

    "Polygon Line-Join Round"
    [pen yellow fill-pen orange
    line-width 5
    line-join round
    polygon 100x100 100x200 200X100 200X200]



    "Push Example"
    [line-width 3
    pen red
    transform 200x200 30 1 1 0x0
    box 100x100 300x300
    push [
        reset-matrix
        pen green
        box 100x100 300x300
        transform 200x200 60 1 1 0x0
        pen blue
        box 100x100 300x300
    ]
    pen white
    box 150x150 250x250]

    "Rotation"
    [fill-pen blue
    box 100x100 300x300
    rotate  30 fill-pen red
    box 100x100 300x300
    rotate -60 fill-pen yellow
    box 100x100 300x300]

    "Scale With Reset Matrix"
    [fill-pen blue
    box 100x100 200x200
    scale 2  .5
    fill-pen red
    box 100x100 200x200
    reset-matrix
    scale .5 1.5
    fill-pen yellow
    box 100x100 200x200]

    "Scale & Push Reset"
    [fill-pen blue
    box 100x100 200x200
    push [
        scale 2  .5 
        fill-pen red
        box 100x100 200x200
    ]
    scale .5 1.5 
    fill-pen yellow
    box 100x100 200x200]


    "Shape 1"
    [line-width 4
    pen red
    shape [move 100x100 hline 50]
    pen yellow
    shape [move 2x2 vline 50]]

    "Shape 2"
    [line-width 4
    pen red
    shape [move 100x100 hline 50 vline 50]]

    "Shape 3"
    [pen yellow
    line-width 4
    fill-pen red
    shape [
        move 100x100
        arc 200x100
        line 100x100
    ]]


    "Shape 4"
    [pen yellow
    line-width 4
    fill-pen red
    shape [
        move 100x100
        arc  100 200x100 false true
        line 100x100
        move 100x200
        arc 100 200x200 true true
        line 100x200
    ]]


    "Shape 5"
    [pen yellow
    line-width 4
    fill-pen red
    shape [
        move 100x10
        'line 100x0
        'arc 0x100
        'line -100x0
        'arc 0x-100 true
    ]]


    "Shape 6"
    [pen yellow
    fill-pen red
    line-width 4
    shape [
        move 100x100
        line 200x100
        curve 200x150 250x100 250x150
        curve 250x200 200x250 200x300
        line 100x300
    ]]


    "Shape 7"
    [pen yellow
    fill-pen red
    line-width 4
    shape [
        move 100x100
        hline 200
        vline 200
        hline 100
        vline 100
    ]]


    "Spline 1"
    [spline 20x20 200x70 150x200 
    50x230 50x300 80x300 200x200]

    "Spline 2"
    [spline 3 20x20 200x70 150x200
    50x230 50x300 80x300 200x200]

    "Spline 3"
    [spline 10 closed 20x20 200x70 150x200
    50x230 50x300 80x300 200x200]

    "Text 1"
    [text "This is a string of text  - Default size (12)" 50x25]

    "Text 2"
    [text vectorial "This is a string of text 1" 50x75]

    "Text 3"
    [text aliased "This is a string of text 2" 50x125]

    "Text 4"
    [font bold20 text anti-aliased "Font Size 20" 50x175]

    "Text 5"
    [font bold20 text vectorial "Font Size 20, type 1" 50x225]

    "Text 6"
    [font bold20 text aliased "Font Size 20, type 2" 50x275]


    "Patterned Vectorial Text"
    [font bold32
    pen yellow red
    line-pattern 5 5
    line-width 2
    text vectorial "Patterned Text" 50x150]

    "Vectorial Text With Spline"
    [font bold32
    line-width 2
    pen snow
    fill-pen linear 10x10 0 400 0 1 1 0.0.255
              0.0.255 0.255.0 255.0.0 255.0.0
    text vectorial 20x300 150x30 250x300 420x140
            "Curved text rendered by DRAW!" 500]


    "Closed Path Vectorial Spline Text"
    [font bold32
    line-width 2
    pen snow
    fill-pen 3 10x10
    radial 400 0 1 1 0.0.255 0.0.255
             0.255.0 255.0.0 255.0.0
    text vectorial 60x60 240x110 190x240 90x270
    "Curved text rendered by DRAW!" 500 closed]

    "Translate Cumulative Effect Translate" 
    [fill-pen
    blue box 50x50 150x150
    translate 50x50
    fill-pen red
    box 50x50 150x150
    translate 50x50
    fill-pen yellow
    box 50x50 150x150]

    "Non Cumulative Translate With Reset-Matrix"
    [fill-pen
    blue box 50x50 150x150
    translate 50x50
    fill-pen red
    box 50x50 150x150
    reset-matrix
    translate 50x50
    fill-pen yellow
    box 100x100 300x300]


    "Translate Reset Skew With Push"
    [fill-pen blue
    box 50x50 150x150
    push [
        translate 50x50
        fill-pen red
        box 50x50 150x150
    ]
    translate 50x50
    fill-pen yellow
    box 100x100 300x300]

    "Basic Triangle"
    [pen none
    triangle 50x150  150x50  150x150 red    green  blue
    triangle 150x50  250x150 150x150 green  yellow blue
    triangle 250x150 150x350 150x150 yellow orange blue
    triangle 150x350 50x150  150x150 orange red    blue]

    "Blended Triangle"
    [pen none
    triangle 50x150  150x50  150x150 red    green  gray
    triangle 150x50  250x150 150x150 green  yellow gray
    triangle 250x150 150x350 150x150 yellow orange gray
    triangle 150x350 50x150  150x150 orange red    gray]

    "Shaded Triangle"
    [pen none
    triangle 50x150  150x50  150x150 water sky   sky
    triangle 150x50  250x150 150x150 water coal  sky
    triangle 250x150 150x350 150x150 coal  coal  sky
    triangle 150x350 50x150  150x150 coal  water sky]

    "Mirror Arcs Less Than 180"
    [pen yellow line-width 4 shape [
        move 100x200
        arc  75 200x200 false false
    ]
    pen red shape [
        move 100x205
        arc 75 200x205 true false
    ]]


    "Mirror Arcs Greater Than 180"
    [pen yellow line-width 4 shape [
        move 100x200
        arc  75 200x200 false true
    ]
    pen red shape [
        move 100x205
        arc 75 200x205 true true
    ]]

    "Pen Lift & Move Absolute"
    [line-width 4
    pen red
    shape [
        move 100x100
        line 20x20 150x50
        move 0x0
    ]
    pen blue
    shape [
        move 100x200
        line 20x120 150x150
    ]]

    "Pen Lift & Move Relative"
    [line-width 4
    pen red
    shape [
        move 100x100
        line 20x20 150x50
        move 0x0
    ]
    pen blue
    shape [
        move 100x100
        'move 0x100
        'line -80x-80 130x30
        'move 0x0
     ]]


]

;=================================================== get example titles

selections: []

forskip drawings 2 [append selections drawings/1]

;=================================================== main layout

draw-examples: layout [
    size as-pair (5 + 500 + 2 + 400 + 5) (5 +5 400 + 2 + 345 + 5) 
    space 2
    origin 5x5
    draw-box: box 500x400 black left
    draw-script: info 500x345 water water font-color white font-size 18
    return 

    draw-list: text-list 400x650 ivory coal data copy selections [
        draw-this select drawings  :face/picked
    ]

    guide
    box 22x2
    across
    pad 12
    btn "All" 60 [
        clear draw-list/data
        draw-list/data: copy selections
        reset-face draw-list
        draw-list/picked: copy first draw-list/data
        show draw-list
        draw-this select drawings :draw-list/picked
    ]

    style short-list btn 60 [gather face/text]
    short-list "Font"
    short-list "Triangle"
    short-list "Shape"
    short-list "Anti-Alias"
    short-list "Gradiant" 
    return pad 12
    short-list "Line"
    short-list "Arrow"
    short-list "Arc"
    short-list "Image"
    short-list "Circle"
    short-list "Pie-Chart"
    return pad 12
    short-list "Pen Lift"
    short-list "Shape"
    short-list "Text"
    short-list "Box"
    short-list "Rotation"
    short-list "Push"
]


;=================================================== opening effect

draw-box/effect: [
    draw [
    line-width 3 
    pen red 
    transform 200x200 30 1 1 0x0 
    box 100x100 300x300 
    push [
        reset-matrix 
        pen green 
        box 100x100 300x300 
        transform 200x200 60 1 1 0x0 
        pen blue 
        box 100x100 300x300
    ] 
    pen white 
    box 150x150 250x250
        font font-B text "100 Draw Examples" 50x175
    ]
]

;=================================================== set the text-list highlight color

pick-color: 0.0.0
draw-list/iter/feel: make draw-list/iter/feel [
    redraw: func [f a e] bind [
        f/color: either find picked f/text [pick-color] [slf/color]
        ]
    in draw-list 'self 
]
    

view draw-examples