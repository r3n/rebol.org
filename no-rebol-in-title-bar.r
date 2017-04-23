REBOL [
    title: "No 'REBOL -' in title bar"
    date: 12-Mar-2010
    file: %no-rebol-in-title-bar.r
    author:  Nick Antonaccio
    purpose: {
        Remove the deault "REBOL -" text from _all_ GUI title bars, including alerts
        and requestors.
    }
]

; AFTER THE FOLLOWING CODE IS DONE, ALL WINDOWS, INCLUDING ALERTS AND
; REQUESTORS, WILL HAVE THE TITLE BAR SET TO THE TEXT BELOW (currently,
; this works only on Windows OS):

title-text: {No default 'REBOL - ' in title bar!}

if system/version/4 = 3 [
    user32.dll: load/library %user32.dll
    get-tb-focus: make routine! [return: [int]] user32.dll "GetFocus"
    set-caption: make routine! [
        hwnd [int] 
        a [string!]  
        return: [int]
    ] user32.dll "SetWindowTextA"
    show-old: :show
    show: func [face] [
        show-old [face]
        hwnd: get-tb-focus
        set-caption hwnd title-text
    ]
]


; THE FOLLOWING CODE SETS THE DEFAULT WINDOW BACKDROP COLOR TO WHITE:

svv/vid-face/color: white


; HERE'S AN EXAMPLE WINDOW:

view center-face layout [
    size 600x400
    btn "Click Me" [
        alert {
            Now all windows, including alerts and requestors, 
            also have the "REBOL - " removed.
        }
    ]
]
