REBOL [
   title: "Always on Top"
    date: 23-Dec-2013
    file: %always-on-top.r
    author:  Nick Antonaccio
    purpose: {
        Demonstrates how to use the Windows API to make a Rebol
        application always stay on top of other windows (so that the
        Rebol window is always visible in front of any other programs
        that are opened).  Be sure to use the view/new option, then
        run the 2 Windows API functions, then do-events to show the
        GUI.
    }
]

user32.dll: load/library %user32.dll

FindWindowByClass: make routine! [
    ClassName [string!] WindowName [integer!] return: [integer!]
] user32.dll "FindWindowA"

SetWindowPos: make routine! [
    hWnd [integer!] hWndInsertAfter [integer!] X [integer!] Y [integer!]
    cx [integer!] cy [integer!] wFlags [integer!] return: [integer!]
] user32.dll "SetWindowPos"

view/new center-face layout [
    h4 "Try opening some other applications."
    h4 "This window always stays on top."
    area
    field 400
    btn "Quit" [quit]
]

hwnd: FindWindowByClass "REBOLWind" 0
SetWindowPos hwnd -1 0 0 0 0 3

do-events
