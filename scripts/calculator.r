REBOL [
    Title: "Calculator"
    Date: 2-Apr-2001
    Version: 1.2.0
    File: %calculator.r
    Author: "Jeff Kreis"
    Purpose: "Simple numeric calculator."
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [GUI math] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

auto-clear: true

calculate: does [
    if error? try [text-box/text: form do text-box/text][
        text-box/text: "Error"
        text-box/color: red
    ]
    auto-clear: true
    show text-box
]

calculator: layout [   
    style btn button 40x24
    style kc btn brick [text-box/text: copy "0" auto-clear: true show text-box]
    style k= btn [calculate]
    style k  btn [
        if auto-clear [clear text-box/text text-box/color: snow auto-clear: false]
        append text-box/text face/text
        show text-box
    ]
    origin 10
    backcolor rebolor
    space 4
    text-box: field "0" 172x24 bold snow right feel none
    pad 4
    across
    kc "C" keycode [#"C" #"c" page-down]
    k "(" #"("  k ")" #")"  k " / " #"/" return 
    k "7" #"7"  k "8" #"8"  k "9" #"9"  k " * " #"*" return 
    k "4" #"4"  k "5" #"5"  k "6" #"6"  k " - " #"-" return 
    k "1" #"1"  k "2" #"2"  k "3" #"3"  k " + " #"+" return 
    k "0" #"0"  k "-"       k "." #"."
    k= "=" keycode [#"=" #"^m"] return
    key keycode [#"^(ESC)" #"^q"] [quit]
]

view center-face calculator