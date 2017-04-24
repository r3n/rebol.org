REBOL [
    Title: "Multiple View Pages"
    Date: 20-May-2000
    File: %pages.r
    Purpose: {
        Shows how to switch between pages using
        a navigation menu.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

bay: load-thru/binary http://www.rebol.com/view/bay.jpg
rice: load-thru/binary http://www.rebol.com/view/rice.jpg

btn-styles: stylize [btn: button with [color: 20.20.160 edge: [XCLOR: 20.20.160]]]

menu: [  ; A pane that is common to all pages
    styles btn-styles
    backdrop effect [contrast 10 gradmul 0x1 0.0.0 128.128.128]
    origin 10x10
    text "Navigation" bold center 100x20
    btn "Page 1" [view page1]
    btn "Page 2" [view page2]
    btn "Page 3" [view page3]
    btn "Quit" [quit]
]

page1: layout [
    styles btn-styles
    size 500x300
    backtile rice 160.100.50
    at 0x0 panel 120x300 menu
    origin 130x20
    title "Page One"
    indent 30
    text {
        This is page one.  Click on any of the buttons
        to switch to other pages.
    }
    frame bay
]

page2: layout [
    styles btn-styles
    size 500x300
    backtile rice 50.160.100
    at 0x0 panel 120x300 menu
    origin 130x20
    title "Page Two"
    indent 30
    text {
        This is page two.  Click on any of the buttons
        to switch to other pages.
    }
    frame bay effect compose [gradmul 1x1]
]

page3: layout [
    styles btn-styles
    size 500x300
    backtile rice 100.50.160
    at 0x0 panel 120x300 menu
    origin 130x20
    title "Page Three"
    indent 30
    text {
        This is page three.  Click on any of the buttons
        to switch to other pages.
    }
    frame bay effect compose [multiply (rice)]
]

view page1
