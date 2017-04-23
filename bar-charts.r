REBOL [
    title: "Bar Charts"
    date: 9-feb-2013
    file: %bar-charts.r
    author:  "Nick Antonaccio"
    purpose: {

        Several examples demonstrating how to draw bar charts using
        simple REBOL GUI code.  From the tutorial at:

        http://re-bol.com/business_programming.html

    }
]

    ; Creating bar charts can be as simple as drawing box widgets,
    ; each sized to the numerical value of items in a list:

    REBOL [title: "Simplest Bar Chart Maker"]
    data: [12 3 9 38 1 23 18]
    gui: copy [backdrop white]
    foreach val data [append gui compose [box blue (as-pair (val * 10) 40)]]
    view layout gui

    ; The example below adds a number of features such as text labels,
    ; randomly colored bars, and a 3D look using buttons instead of box widgets:

    REBOL [title: "Simple Bar Chart Maker"]
    data: [12 3 9 38 1 23 18]
    labels: [Jan Feb Mar Apr May Jun Jul]
    gui: copy [backdrop white across]
    repeat i length? data [
        append gui compose [
            text bold 30 (form labels/:i)
            button random white (as-pair (data/:i * 12) 40) (mold data/:i) return
        ]
    ]
    view layout gui

    ; This example adds variables for auto scaling and sizing, a gradient and
    ; colored grid background pattern, and vertical bar layout:

    REBOL [title: "Simple Bar Chart Maker"]

    data: [12 3 9 38 1 23 18]
    labels: ["Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul"]
    height: 11
    width: 50

    gui: copy [
        backdrop effect [
            gradient 1x1 180.255.255 255.255.100 grid 10x10 220.220.189
        ]
        across
    ]
    foreach val reverse data [
        append gui compose [
            button random white (as-pair width (val * height))
        ]
    ]
    chart: to-image layout gui
    gui2: [
        backdrop white
        style txt text bold (width)
        tabs 20
        across image (chart) effect [rotate 180] return tab
    ] 
    foreach label labels [append gui2 compose [txt (label)]] 
    view center-face layout gui2
