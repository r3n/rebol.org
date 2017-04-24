Rebol [
    title: "Web Cam"
    date: 29-june-2008
    file: %web-cam.r
    author: Nick Antonaccio
    purpose: {
        An example demonstrating how to use the Windows API to access local web cam
        images.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

; First, open the Dlls that contain the Windows api functions we want
; to use (to view webcam video, and to change window titles):

avicap32.dll: load/library %avicap32.dll
user32.dll: load/library %user32.dll

; Create Rebol function prototypes required to change window titles:
; (These functions are found in user32.dll, built in to Windows.)

get-focus: make routine! [return: [int]] user32.dll "GetFocus"
set-caption: make routine! [
    hwnd [int] a [string!]  return: [int]
] user32.dll "SetWindowTextA"

; Create Rebol function prototypes required to view the webcam:
; (also built in to Windows)

find-window-by-class: make routine! [
    ClassName [string!] WindowName [integer!] return: [integer!]
] user32.dll "FindWindowA"
sendmessage: make routine! [
    hWnd [integer!] val1 [integer!] val2 [integer!] val3 [integer!]
    return: [integer!]
] user32.dll "SendMessageA"
sendmessage-file: make routine! [
    hWnd [integer!] val1 [integer!] val2 [integer!] val3 [string!]
    return: [integer!]
] user32.dll  "SendMessageA"
cap: make routine! [
    cap [string!] child-val1 [integer!] val2 [integer!] val3 [integer!]
    width [integer!] height [integer!] handle [integer!] 
    val4 [integer!] return: [integer!]
] avicap32.dll "capCreateCaptureWindowA"

; Create the Rebol GUI window:

view/new center-face layout/tight [
    image 320x240
    across
    btn "Take Snapshot" [
        ; Run the dll functions that take a snapshot:
        sendmessage cap-result 1085 0 0
        sendmessage-file cap-result 1049 0 "scrshot.bmp"
    ]
    btn "Exit" [
        ; Run the dll functions that stop the video:
        sendmessage cap-result 1205 0 0
        sendmessage cap-result 1035 0 0
        free user32.dll
        quit
    ]
]

; Run the Dll functions that reset our Rebol GUI window title:
; (eliminates "REBOL - " in the title bar)

hwnd-set-title: get-focus
set-caption hwnd-set-title "Web Camera"

; Run the Dll functions that show the video:

hwnd: find-window-by-class "REBOLWind" 0
cap-result: cap "cap" 1342177280 0 0 320 240 hwnd 0
sendmessage cap-result 1034 0 0
sendmessage cap-result 1077 1 0
sendmessage cap-result 1075 1 0
sendmessage cap-result 1074 1 0
sendmessage cap-result 1076 1 0

; start the GUI:

do-events