REBOL [
    Title:   "Get Windows Version"
    File:    %get-version-ex.r
    Author:  "Gregg Irwin"
    Version: 0.0.1
    Date:    23-sep-2003
    Purpose: {
        Shows how to call Windows GetVersonEx function.
    }
    library: [
        level:    'intermediate
        platform: 'windows
        type:     [function how-to]
        domain:   [external-library win-api]
        tested-under: [view/pro 1.2.8.3.1 on W2K]
        support:  none
        license:  none
        see-also: none
    ]
]


; The credit for this technique of dealing with fixed char arrays
; in structs belongs to Pekr and Cyphre. I just modded the idea a
; bit for my own uses.
make-elements: func [name count type /local result][
    if not word? type [type: type?/word type]
    result: copy "^/"
    repeat i count [
        append result join name [i " [" type "]" newline]
    ]
    to block! result
]

kernel.dll: load/library %kernel32.dll


OSVERSIONINFOEXA: make struct! OSVERSIONINFOEXA-def: compose/deep [
    dwOSVersionInfoSize [integer!]  ; DWORD
    dwMajorVersion      [integer!]  ; DWORD
    dwMinorVersion      [integer!]  ; DWORD
    dwBuildNumber       [integer!]  ; DWORD
    dwPlatformId        [integer!]  ; DWORD
    (make-elements 'szCSDVersion 128 #"@")  ; TCHAR
    wServicePackMajor   [short]     ; WORD
    wServicePackMinor   [short]     ; WORD
    wSuiteMask          [short]     ; WORD
    wProductType        [char!]     ; BYTE
    wReserved           [char!]     ; BYTE
] none
OSVERSIONINFOEXA/dwOSVersionInfoSize: length? third OSVERSIONINFOEXA

GetLastError: make routine! [return: [integer!]] kernel.dll "GetLastError"

GetVersionEx: make routine! compose/deep/only [
    lpVersionInformation    [struct! (OSVERSIONINFOEXA-def)] ;LPOSVERSIONINFO
    return:     [integer!]  ;BOOL
] kernel.dll "GetVersionExA"

get-version: has [res] [
    res: GetVersionEx OSVERSIONINFOEXA
    either 0 = res [none][OSVERSIONINFOEXA]
]

; test call
print either res: get-version [
    [
        "Major:" res/dwMajorVersion newline
        "Minor:" res/dwMinorVersion newline
        "Build:" res/dwBuildNumber  newline
        "SP.Major:" res/wServicePackMajor   newline
        "SP.Minor:" res/wServicePackMinor   newline
        "Suite"   mold res/wSuiteMask    newline
        "Product" mold res/wProductType  newline
        "Version:" to-string copy/part at third OSVERSIONINFOEXA 21 128
    ]
][
    ["Call failed: " GetLastError]
]

free kernel.dll
