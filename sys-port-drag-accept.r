REBOL [
    Title:  "System Port - Drag Accept Demo"
    File:   %sys-port-drag-accept.r
    Author: "Gregg Irwin"
    EMail:  greggirwin@acm.org
    Version: 0.0.1
    Date:    25-sep-2003
    Purpose: {
        Demo using system port to catch WM_DROPFILE messages for drag-n-drop
        support.
    }
    library: [
        level:    'intermediate
        platform: 'windows
        type:     [demo how-to]
        domain:   [external-library win-api]
        tested-under: [view/pro 1.2.8.3.1 on W2K]
        support:  none
        license:  none
        see-also: none
    ]
]

; Stripped version of win-shell object for demo purposes.
win-shell: make object! [
    win-lib:  load/library %shell32.dll

    null-buff: func [
        {Returns a null-filled string buffer of the specified length.}
        len [integer!]
    ][
        head insert/dup make string! len #"^@" len
    ]

    drag-accept-files: make routine! [
        hWnd    [integer!]
        fAccept [integer!]
        return: [integer!]
    ] win-lib "DragAcceptFiles"

    drag-finish: make routine! [
        hDrop   [integer!]
        return: [integer!]
    ] win-lib "DragFinish"

    point: make struct! [
        x [integer!]
        y [integer!]
    ] none

    drag-query-point: make routine! compose/deep [
        {Returns nonzero if the drop occurred in the client area of the window,
        or zero if the drop did not occur in the client area of the window.}
        hDrop   [integer!]
        lpPoint [struct! [(first point)]]
        return: [integer!]
    ] win-lib "DragQueryPoint"

    drag-query-file: make routine! [
        hWnd    [integer!]
        iFile   [integer!]
        lpszFile[string!]
        cb      [integer!]
        return: [integer!]
    ] win-lib "DragQueryFile"

    drag-query-filename-size: make routine! [
        hWnd    [integer!]
        iFile   [integer!]
        lpszFile[integer!]
        cb      [integer!]
        return: [integer!]
    ] win-lib "DragQueryFile"

    num-files-dropped?: func [hdrop [integer!]] [
        drag-query-file hdrop -1 "" 0
    ]

    ; When they give us a filename index, we'll subtract one for them,
    ; because Windows has the list as zero based, but I'd much rather let
    ; everything be one based on the REBOL side.
    dropped-filename-size?: func [
        hdrop [integer!] index [integer!]
    ][
        drag-query-filename-size hdrop index - 1 0 0
    ]

    dropped-filename?: func [
        hdrop [integer!] index [integer!] /local result len
    ][
        result: null-buff add 1 dropped-filename-size? hdrop index
        len: drag-query-file hdrop index - 1 result length? result
        copy/part result len
    ]

]


my-hwnd?: does [second get-modes system/ports/system [window]]

WM_DESTROY:   2   ; &H2
WM_DROPFILES: 563 ; &H233

enable-system-trap: does [
     ; Trap OS interrupts
    if not system/ports/system [
        if none? attempt [system/ports/system: open [scheme: 'system]][
            print "NOTE: Missing System Port" exit
        ]
    ]
    if find get-modes system/ports/system 'system-modes 'winmsg [
        set-modes system/ports/system [winmsg: WM_DROPFILES]
    ]
    append system/ports/wait-list system/ports/system
]

check-system-trap: func [port /local msg pt] [
    if not port? port [return none]
    if any [port/scheme <> 'system  port <> system/ports/system][return port]
    if not system/ports/system [return none]
    while [msg: pick system/ports/system 1] [
        ;print ["msg:" mold msg]
        if msg/1 = 'winmsg [
            if msg/2  = WM_DROPFILES [
                print [
                    "You dropped " win-shell/num-files-dropped? msg/3 "files."
                ]
                pt: make struct! win-shell/point [0 0]
                win-shell/drag-query-point msg/3 pt
                print [" at coordinate " to pair! reduce [pt/x pt/y]]
                repeat i win-shell/num-files-dropped? msg/3 [
                    file: to-rebol-file win-shell/dropped-filename? msg/3 i
                    print [
                        tab join i "." tab either dir? file [dirize file][file]
                    ]
                ]
                print "Finishing drag operation"
                win-shell/drag-finish msg/3
                print "Unregistering window from DragAcceptFiles queue"
                win-shell/drag-accept-files my-hwnd? to integer! false
                ; (do something with files here)
                halt
            ]
        ]
    ]
    none
]

print "Drag some files and drop them on this window...^/"

win-shell/drag-accept-files my-hwnd? to integer! true

enable-system-trap

forever [
     wake-port: wait []
     if wake-port [check-system-trap wake-port]
]

