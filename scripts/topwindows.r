REBOL [
    Title: "TOPWINDOW lister"
    Date: 10-Jun-2003
    Name: 'Age
    Version: 3.0.0
    File: %topwindows.r
    Author: "Paul Tretter"
    Purpose: "List the Window handles on the computer"
    eMail: ptretter@charter.net
    library: [
        level: 'advanced 
        platform: 'windows 
        type: 'tool 
        domain: 'user-interface 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]


viswindows:       []   ; container for Visible Titled windows
notviswindows:    []   ; container for Invisible Titled windows
viswindowsnt:     []   ; container for Visible NON-Titled windows
plainparents:     []   ; container for Non Visible Non Titled windows
hungwindows:      []   ; container for hung windows including child windows
childrenvt:       []   ; container for Visible Titled Child windows
childrennvt:      []   ; container for Not Visible Titled Child windows
childrenvnt:      []   ; container for Visible Not Titled Child windows
childrennvnt:     []   ; container for Not Visible NON-titled Child windows
childrenvt2:      []   ; container for Visible Titled Child windows non-direct
childrennvt2:     []   ; container for Not Visible Titled Child windows non-direct
childrenvnt2:     []   ; container for Visible Non Titled Child windows non-direct
childrennvnt2:    []   ; container for Not Visible Non-titled windows non-direct
viswindowsh:      []
notviswindowsh:   []
viswindowsnth:    []
plainparentsh:    []
childrenvth:      []
childrennvth:     []
childrenvnth:     []
childrennvnth:    []
childrenvt2h:     []
childrennvt2h:    []
childrenvnt2h:    []
childrennvnt2h:   []

fetch:                    0
WM_QUIT:                  to-integer #{0012}
WM_NULL:                  to-integer #{0000}
WM_DESTROY:               to-integer #{0002}
WM_CLOSE:                 to-integer #{0010}
GW_CHILD:                 5
GW_HWNDNEXT:              2
GW_OWNER:                 4
SMTO_ABORTIFHUNG:         to-integer #{0002}
SMTO_BLOCK:               to-integer #{0001}
SMTO_NORMAL:              to-integer #{0000}
SMTO_NOTIMEOUTIFNOTHUNG:  to-integer #{0008}

winlib: load/library %user32.dll

sendmessagetimeout: make routine! [
                           "Sends the specified message to one of more windows."
    hWnd        [integer!] "[in] Handle to the window whose window procedure will receive the message. "
    Msg         [integer!] "[in] Specifies the message to be sent."
    wParam      [integer!] "[in] Specifies additional message-specific information."
    lParam      [integer!] "[in] Specifies additional message-specific information."
    fuFlags     [integer!] "[in] Specifies how to send the message. "
    uTimeout    [integer!] "[in] Specifies the duration, in milliseconds, of the time-out period."
    lpdwResult  [integer!] "[in] Receives the result of the message processing. "
    return:     [integer!] "If the function succeeds, the return value is nonzero otherwise zero."
] winlib "SendMessageTimeoutA"

iswindowvisible: make routine! [
                         "The IsWindowVisible function retrieves the visibility state of the specified window."
    hwnd    [integer!]   "[in] Handle to the window to test"
    return: [integer!]   {return value will <> 0 if its parent window, its parent's parent windows, anad so forth have
                         the WS_VISIBLE sytle. Otherwise its 0}
] winlib "IsWindowVisible"

getlasterror: make routine! [return: [long]] winlib2: load/library %kernel32.dll "GetLastError"

getwindowtext: make routine! [
                           {The GetWindowText function copies the text of the specified window's title bar (if it has one) into a buffer.}
    hWnd      [integer!]   "[in] Handle to the window or control containing the text."
    lpString  [string!]    "[out] Pointer to the buffer that will receive the text."
    nMaxCount [integer!]   "[in] Specifies the maximum number of characters to copy to the buffer, including the NULL character."
    return:   [integer!]   {If the function succeeds, the return value is the length, in characters, of the copied string,
                            not including the terminating NULL character.}
] winlib "GetWindowTextA"

str: make string! ""        ; needed to hold windows title and passed to the getwindowtext routine.
loop 200 [append str "^@"]

iswindow: make routine! [
                         "The IsWindow function determines whether the specified window handle identifies an existing window."
    hWnd    [integer!]   "[in] Handle to the window to test."
    return: [integer!]   "If the window handle identifies an existing window, the return value is nonzero otherwise zero."
] winlib "IsWindow"

sendmessage: make routine! [
                          "The SendMessage function sends the specified message to a window or windows."
    hWnd      [integer!]  "[in] Handle to the window whose window procedure will receive the message."
    Msg       [integer!]  "[in] Specifies the message to be sent."
    wParam    [integer!]  "[in] Specifies additional message-specific information."
    lParam    [integer!]  "[in] Specifies additional message-specific information."
    return:   [integer!]  "The return value specifies the result of the message processing; it depends on the message sent."
] winlib "SendMessageA"

getparent: make routine! [
                           "The GetParent function retrieves a handle to the specified window's parent or owner."
    hWnd      [integer!]   "[in] Handle to the window whose parent window handle is to be retrieved."
    return:   [integer!]   {If the window is a child window, the return value is a handle to the parent window.
                           If the window is a top-level window, the return value is a handle to the owner window.
                           If the window is a top-level unowned window or if the function fails, the return value is NULL.}
] winlib "GetParent"

pid: make struct! [proccessid [integer!]] none ; struct needed for GetWindowThreadProcessId

getwindowthreadprocessid: make routine!  [
                                                    {The GetWindowThreadProcessId function retrieves the identifier of the thread
                                                    that created the specified window and, optionally, the identifier of the process
                                                    that created the window.}
    hWnd               [integer!]    "[in] Handle to the window."
    lPdwProcessId [struct! [processid [integer!]]]  "[out] Pointer to a variable that receives the process identifier."
    return:                           [integer!]    "The return value is the identifier of the thread that created the window."
] winlib "GetWindowThreadProcessId"

destroywindow: make routine! [
                             "The DestroyWindow function destroys the specified window."
    hWnd     [integer!]      "[in] Handle to the window to be destroyed."
    return:  [integer!]      "If the function succeeds, the return value is nonzero.otherwise its zero"
] winlib "DestroyWindow"

getdesktopwindow: make routine! [
                            "The GetDesktopWindow function returns a handle to the desktop window."
    return:  [integer!]     "The return value is a handle to the desktop window"
] winlib "GetDesktopWindow"

postmessage: make routine! [
                           {The PostMessage function places (posts) a message in the message queue associated with the thread
                           that created the specified window and returns without waiting for the thread to process the message.}
    hWnd     [integer!]    "in] Handle to the window whose window procedure is to receive the message."
    Msg      [integer!]    "[in] Specifies the message to be posted."
    wParam   [integer!]    "[in] Specifies additional message-specific information."
    lParam   [integer!]    "[in] Specifies additional message-specific information."
    return:  [integer!]    "If the function succeeds, the return value is nonzero"
] winlib "PostMessageA"

getwindow: make routine! [
                            {The GetWindow function retrieves a handle to a window that has the specified relationship
                            (Z-Order or owner) to the specified window.}

    hwnd     [integer!]     "[in] Handle to a window."
    typ      [integer!]     "[in] Specifies the relationship between the specified window and the window whose handle is to be retrieved."
    return:  [integer!]     {If the function succeeds, the return value is a window handle. If no window exists with the specified
                            relationship to the specified window, the return value is NULL.}
] winlib "GetWindow"

ret: getdesktopwindow ; Retrieves the handle to the top most window in the Z-Order which is the Desktop window

getwindow-ret: getwindow ret GW_CHILD ; returns the first child windows of the topmost window - the desktop.

morechilds: does [
    more-ret: getparent xtraparent
    if more-ret > 0 [
        iswindowvisible-ret2: iswindowvisible more-ret
        getwindowtext-ret2: getwindowtext more-ret str 200
        getwindowthreadprocessid more-ret pid
        if all [more-ret > 0 iswindowvisible-ret2 > 0 getwindowtext-ret2 > 0][append childrennvt2h xtraparent append childrenvt2 rejoin ["Window: " xtraparent " has parent: " more-ret " with Process-ID of: " pid/proccessid " with Title: " trim/with str "@" newline]]
        if all [more-ret > 0 iswindowvisible-ret2 = 0 getwindowtext-ret2 > 0][append childrennvt2h xtraparent append childrennvt2 rejoin ["Window: " xtraparent " has parent: " more-ret " with Process-ID of: " pid/proccessid " with Title: " trim/with str "@" newline]]
        if all [more-ret > 0 iswindowvisible-ret2 > 0 getwindowtext-ret2 = 0][append childrenvnt2h xtraparent append childrenvnt2 rejoin ["Window: " xtraparent " has parent: " more-ret " with Process-ID of: " pid/proccessid newline]]
        if all [more-ret > 0 iswindowvisible-ret2 = 0 getwindowtext-ret2 = 0][append childrennvnt2h xtraparent append childrennvnt2 rejoin ["Window: " xtraparent " has parent: " more-ret " with Process-ID of: " pid/proccessid newline]]
        str: make string! ""
        loop 200 [append str "^@"]
    ]
    xtraparent: more-ret
    if more-ret > 0 [morechilds]

]

loop 1000 [
    getwindow-next-ret: getwindow getwindow-ret gw_hwndnext
    getparent-ret: getparent getwindow-next-ret
    getlasterror-ret: getlasterror
    getwindow-ret: getwindow-next-ret
    getwindowthreadprocessid getwindow-next-ret pid
    iswindowvisible-ret: iswindowvisible getwindow-next-ret
    getwindowtext-ret: getwindowtext getwindow-next-ret str 200
    if all [getparent-ret = 0 getlasterror-ret = 2 iswindowvisible-ret > 0 getwindowtext-ret > 0][append viswindowsh getwindow-next-ret append viswindows rejoin ["Window: " getwindow-next-ret  " with Proccess-ID of: " pid/proccessid " with Title: " trim/with str "@" newline ]]
    if all [getparent-ret = 0 getlasterror-ret = 2 iswindowvisible-ret > 0 getwindowtext-ret = 0][append viswindowsnth getwindow-next-ret append viswindowsnt rejoin ["Window: " getwindow-next-ret " with Process-ID of: " pid/proccessid newline]]
    if all [getparent-ret = 0 getlasterror-ret = 2 iswindowvisible-ret = 0 getwindowtext-ret > 0][append notviswindowsh getwindow-next-ret append notviswindows rejoin ["Window: " getwindow-next-ret " with Process-ID of: " pid/proccessid " with Title: " trim/with str "@" newline ]]
    if all [getparent-ret = 0 getlasterror-ret = 2 iswindowvisible-ret = 0 getwindowtext-ret = 0][append plainparentsh getwindow-next-ret append plainparents rejoin ["Window: " getwindow-next-ret " with Process-ID of: " pid/proccessid newline]]
    if all [getparent-ret > 0 iswindowvisible-ret > 0 getwindowtext-ret > 0][append childrenvth getwindow-next-ret append childrenvt rejoin ["Window: " getwindow-next-ret " has parent: " getparent-ret " with Process-ID of: " pid/proccessid " with Title: " trim/with str "@" newline]]
    if all [getparent-ret > 0 iswindowvisible-ret = 0 getwindowtext-ret > 0][append childrennvth getwindow-next-ret append childrennvt rejoin ["Window: " getwindow-next-ret " has parent: " getparent-ret " with Process-ID of: " pid/proccessid " with Title: " trim/with str "@" newline]]
    if all [getparent-ret > 0 iswindowvisible-ret > 0 getwindowtext-ret = 0][append childrenvnth getwindow-next-ret append childrenvnt rejoin ["Window: " getwindow-next-ret " has parent: " getparent-ret " with Process-ID of: " pid/proccessid newline]]
    if all [getparent-ret > 0 iswindowvisible-ret = 0 getwindowtext-ret = 0][append childrennvnth getwindow-next-ret append childrennvnt rejoin ["Window: " getwindow-next-ret " has parent: " getparent-ret " with Process-ID of: " pid/proccessid newline]]
    if getparent-ret > 0 [xtraparent: getparent-ret morechilds]
    str: make string! ""
    loop 200 [append str "^@"]
    getlasterror-ret: 0
    ;if getwindow-next-ret = 0 [break]

]

getwindow-ret: getwindow ret GW_CHILD

all-handles: to-block form reduce [viswindowsh notviswindowsh viswindowsnth plainparentsh childrenvth childrennvth childrenvnth childrennvnth
    childrenvt2h childrennvt2h childrenvnt2h childrenvnt2h
]

wincount: 0

foreach item all-handles [
    sendmessagetimeout-ret: sendmessageTimeout item WM_NULL 0 0 SMTO_ABORTIFHUNG and SMTO_BLOCK 1000 fetch
    getwindowthreadprocessid item pid
    if all [sendmessagetimeout-ret = 0][append hungwindows rejoin ["Window: " item " is hung! with Process-ID of: " pid/proccessid newline]]
    wincount: wincount + 1
]



print "*************************************************"
print "********** TOPWINDOWS BY PAUL TRETTER ***********"
print "*************************************************"
print newline

print ["DESKTOP WINDOW HANDLE = " ret newline]
print [" ******* TOPLEVEL WINDOWS *******" newline]

if not empty? viswindows [
    print ["VISIBLE TITLED WINDOWS:" newline viswindows]
]

if not empty? viswindowsnt[
    print ["VISBILE UNTITLED WINDOWS:" newline viswindowsnt]
]

if not empty? notviswindows [
    print ["NOT VISIBLE TITLED WINDOWS:" newline notviswindows]
]

if not empty? plainparents [
    print ["NOT VISIBLE UNTITLED WINDOWS:" newline plainparents]
]

print [" ********** CHILD WINDOWS *********" newline]

if not empty? childrenvt [
    print ["CHILD WINDOWS (VISIBLE AND TITLED):" newline childrenvt]
]

if not empty? childrenvnt [
    print ["CHILD WINDOWS (VISIBLE AND UNTITLED):" newline childrenvnt]
]

if not empty? childrennvt [
    print ["CHILD WINDOWS (NOT VISIBLE AND TITLED):" newline childrennvt]
]

if not empty? childrennvnt [
    print ["CHILD WINDOWS (NOT VISIBLE AND UNTITLED):" newline childrennvnt]
]

if not empty? childrenvt2 [
    print ["CHILD WINDOWS (VISIBLE AND TITLED - non direct):" newline childrenvt2]
]

if not empty? childrenvnt2 [
    print ["CHILD WINDOWS (VISIBLE AND UNTITLED - non direct):" newline childrenvnt2]
]

if not empty? childrennvt2 [
    print ["CHILD WINDOWS (NOT VISIBLE AND TITLED - non direct):" newline childrennvt2]
]

if not empty? childrennvnt2 [
    print ["CHILD WINDOWS (NOT VISIBLE AND UNTITLED - non direct):" newline childrennvnt2]
]

print [" ********** HUNG WINDOWS **********" newline]

either not empty? hungwindows [
    print ["HUNG WINDOWS: " newline hungwindows]
][
    print ["HUNG WINDOWS: " newline "NO HUNG WINDOWS DETECTED!" newline]
]

print [" ********** MISC INFO *************" newline]

print ["Total Window Count = " wincount]

free winlib
free winlib2

halt