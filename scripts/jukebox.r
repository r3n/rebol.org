REBOL [
    File: %jukebox.r
    Date: 10-Aug-2009
    Title: "Jukebox - Wav/Mp3 Player"
    Author:  Nick Antonaccio
    Purpose: {
        Play .wav and .mp3 files from a selection list.
        Taken from the tutorial at http://musiclessonz.com/rebol.html
    }
]

if not exists? %libwmp3.dll [
    write/binary %libwmp3.dll
    read/binary http://musiclessonz.com/rebol_tutorial/libwmp3.dll
]

lib: load/library %libwmp3.dll

Mp3_Initialize: make routine! [
    return: [integer!]
] lib "Mp3_Initialize"

Mp3_OpenFile: make routine! [
    return: [integer!] 
    class [integer!] 
    filename [string!]
    nWaveBufferLengthMs [integer!]
    nSeekFromStart [integer!] 
    nFileSize [integer!]
] lib "Mp3_OpenFile"

Mp3_Play: make routine! [
    return: [integer!] 
    initialized [integer!]
] lib "Mp3_Play"

Mp3_Stop: make routine! [
    return: [integer!] 
    initialized [integer!]
] lib "Mp3_Stop"

Mp3_Destroy: make routine! [
    return: [integer!] 
    initialized [integer!]
] lib "Mp3_Destroy"

Mp3_GetStatus: make routine! [
    return: [integer!] 
    initialized [integer!] 
    status [struct! []]
] lib "Mp3_GetStatus"

status: make struct! [
    fPlay [integer!] 
    fPause [integer!] 
    fStop [integer!] 
    fEcho [integer!] 
    nSfxMode [integer!] 
    fExternalEQ [integer!] 
    fInternalEQ [integer!] 
    fVocalCut [integer!] 
    fChannelMix [integer!] 
    fFadeIn [integer!] 
    fFadeOut [integer!] 
    fInternalVolume [integer!] 
    fLoop [integer!] 
    fReverse [integer!] 
] none

play-sound: func [sound-file] [
    wait 0
    wait-flag: true
    ring: load sound-file
    sound-port: open sound://
    insert sound-port ring
    wait sound-port
    close sound-port
    wait-flag: false
]

wait-flag: false
change-dir %/c/Windows/media
waves: []
foreach file read %. [
    if ((%.wav = suffix? file) or
        (%.mp3 = suffix? file)) [append waves file]
]

initialized: Mp3_Initialize

view center-face layout [
    vh2 "Click a File to Play:"
    file-list: text-list data waves [
        Mp3_GetStatus initialized status
        either %.mp3 = suffix? value [
            if (wait-flag <> true) and (status/fPlay = 0) [
                file: rejoin [to-local-file what-dir "\" value]
                Mp3_OpenFile initialized file 1000 0 0
                Mp3_Play initialized
            ]
        ] [
            if (wait-flag <> true) and (status/fPlay = 0) [
                if error? try [play-sound value] [
                    alert "malformed wave"
                    close sound-port
                    wait-flag: false
                ]
            ]
        ]
    ]
    across
    btn "Change Folder" [
        change-dir request-dir
        waves: copy []
        foreach file read %. [
            if ((%.wav = suffix? file) or
            (%.mp3 = suffix? file)) [append waves file]
        ]
        file-list/data: waves
        show file-list
    ]
    btn "Stop" [
         close sound-port
         wait-flag: false
         if (status/fPlay > 0) [Mp3_Stop initialized]
    ]
]

Mp3_Destroy initialized
free lib