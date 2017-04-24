REBOL [
	Title: "Method to set some Rebol console parameters."
	Author: "Maxime Tremblay, idea comes from %no-rebol-in-title-bar.r script by Nick Antonaccio"
	Version: 1.0.0
	Date: 19/03/2010
	file: %window-util.r
	purpose: {
        Used to set the Rebol console's window title and icon.
        Include a method to get the current windows handle.
        Work only in windows.
    }
]

window-util: context [
    
    user32.dll: load/library %user32.dll
    msvcrt.dll: load/library %msvcrt.dll
    
    GetDesktopWindow: make routine! [return: [integer!]] user32.dll "GetDesktopWindow"
    GetWindow: make routine! [hWnd [integer!] uCmd [integer!] return: [integer!]] user32.dll "GetWindow"
    GetWindowThreadProcessId: make routine! [hWnd [integer!] pid [struct! [id [integer!]]] return: [integer!]] user32.dll "GetWindowThreadProcessId"
    SetWindowText: make routine! [hwnd [int] text [string!] return: [int]] user32.dll "SetWindowTextA"
    SendMessage: make routine! [hWnd [integer!] msg [integer!] wparam [integer!] lparam [integer!] return: [integer!]] user32.dll "SendMessageA"
    LoadImage: make routine! [ hinst [integer!] lpszName [string!] uType [integer!] cxDesired [integer!] cyDesired [integer!] fuLoad [integer!] return: [integer!]] user32.dll "LoadImageA"
    
    getpid: make routine! [return: [long]] msvcrt.dll "_getpid"
    
    LR_LOADFROMFILE: to-integer #{0010}
    WM_SETICON: to-integer #{0080}
    IMAGE_ICON: 1
    ICON_SMALL: 0
    ICON_BIG: 1
    
    get-current-window: func [/local cw curpid wpid curwin] [
        wpid: make struct! [wpid [integer!]] none
        
        ; get current process
        curpid: getpid
        
        ; get desktop window (uppermost window)
        cw: getwindow getdesktopwindow 5
        
        ; find the first window for the current process 
        ; an infitine loop prevention may be useful here
        while [not equal? cw 0] [
            cw: getwindow cw 2
            getwindowthreadprocessid cw wpid
            if equal? wpid/wpid curpid [
                ; now we must find the top level window
                while [not equal? cw 0] [
                    curwin: cw
                    cw: getwindow cw 4
                ]
                break
             ]
        ]
        curwin
    ]
    
    set-title: func[title-text /local curwin] [
        ; this probe is there to ensure that the window is displayed when setting the title
        probe title-text
        if curwin: get-current-window [
            SetWindowText curwin title-text
        ]
    ]
    
    set-icon: func[icon-file [string!] "Must be a string to the full path of the .ico file." /local curwin imagehdl] [
        
        if curwin: get-current-window [
            imagehdl: LoadImage 0 icon-file 1 0 0 LR_LOADFROMFILE
            SendMessage curwin WM_SETICON ICON_SMALL imagehdl
        ]
        
    ]
]
