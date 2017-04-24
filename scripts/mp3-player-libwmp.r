REBOL [
    File: %mp3-player-libwmp.r
    Date: 9-Aug-2009
    Title: "mp3-player-demo-using-libwmp3.dll"
    Author:  Nick Antonaccio
    Purpose: {
        Demo of how to play mp3 files in REBOL using libwmp3.dll
        ( http://www.inet.hr/~zcindori/libwmp3/index.html )
        Taken from the tutorial at http://musiclessonz.com/rebol.html
    }
]

if not exists? %libwmp3.dll [
    print "Downloading libwmp3.dll..."
    write/binary %libwmp3.dll
    read/binary http://musiclessonz.com/rebol_tutorial/libwmp3.dll
]
lib: load/library %libwmp3.dll


; ---------------------------------------------------------
; Required functions in libwmp3.dll:
; ---------------------------------------------------------

Mp3_Initialize: make routine! [
    return: [integer!]
] lib "Mp3_Initialize"

Mp3_Destroy: make routine! [
    return: [integer!] 
    initialized [integer!]
] lib "Mp3_Destroy"

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


; ---------------------------------------------------------
; Some more useful values and functions:
; ---------------------------------------------------------

status: make struct! [
    fPlay [integer!]           
    ; if song is playing this value is nonzero 
    fPause [integer!]          
    ; if song is paused this value is nonzero 
    fStop [integer!]           
    ; if song is stoped this value is nonzero 
    fEcho [integer!]           
    ; if echo is enabled this value is nonzero 
    nSfxMode [integer!]        
    ; return current echo mode
    fExternalEQ [integer!]     
    ; if external equalizer is enabled this value is nonzero 
    fInternalEQ [integer!]     
    ; if internal equalizer is enabled this value is nonzero	
    fVocalCut [integer!]       
    ; if vocal cut is enabled this value is nonzero
    fChannelMix [integer!]     
    ; if channel mixing is enabled this value is nonzero
    fFadeIn [integer!]         
    ; if song is in "fade in" interval this value is nonzero
    fFadeOut [integer!]        
    ; if song is in "fade out" interval this value is nonzero
    fInternalVolume [integer!] 
    ; if internal volume is enabled this value is nonzero
    fLoop [integer!]           
    ; if song is in loop this value is nonzero
    fReverse [integer!]        
    ; if song is in reverse mode this value is nonzero
] none

Mp3_GetStatus: make routine! [
    return: [integer!] 
    initialized [integer!] 
    status [struct! []]
] lib "Mp3_GetStatus"

Mp3_Time: make struct! [
    ms [integer!] 
    sec [integer!]
    bytes [integer!] 
    frames [integer!] 
    hms_hour [integer!] 
    hms_minute [integer!] 
    hms_second [integer!] 
    hms_millisecond [integer!] 
] none

TIME_FORMAT_MS: 1
TIME_FORMAT_SEC: 2
TIME_FORMAT_HMS: 4
TIME_FORMAT_BYTES: 8
SONG_BEGIN: 1
SONG_END: 2
SONG_CURRENT_FORWARD: 4
SONG_CURRENT_BACKWARD: 8

Mp3_Seek: make routine! [
    return: [integer!] 
    initialized [integer!]
    fFormat [integer!]
    pTime [struct! []]
    nMoveMethod [integer!]
] lib "Mp3_Seek"

; Mp3_Seek stops play.  ALWAYS CALL Mp3_Play AFTER USING IT.

Mp3_PlayLoop: make routine! [
    return: [integer!] 
    initialized [integer!]
    fFormatStartTime [integer!]
    pStartTime [struct! []]
    fFormatEndTime [integer!] 
    pEndTime [struct! []]
    nNumOfRepeat [integer!] 
] lib "Mp3_PlayLoop"

Mp3_GetPosition: make routine! [
    return: [integer!] 
    initialized [integer!]
    pTime [struct! []]
] lib "Mp3_GetPosition"

Mp3_Pause: make routine! [
    return: [integer!] 
    initialized [integer!]
] lib "Mp3_Pause"

Mp3_Resume: make routine! [
    return: [integer!] 
    initialized [integer!]
] lib "Mp3_Resume"

Mp3_SetVolume: make routine! [
    return: [integer!] 
    initialized [integer!]
    nLeftVolume [integer!]
    nRightVolume [integer!]
] lib "Mp3_SetVolume"

; volume range is 0 to 100

Mp3_SetMasterVolume: make routine! [
    return: [integer!] 
    initialized [integer!]
    nLeftVolume [integer!]
    nRightVolume [integer!]
] lib "Mp3_SetMasterVolume"

; SetMasterVolume sets output volume of wave out device driver
; (the master volue of all sounds on the computer):

Mp3_VocalCut: make routine! [
    return: [integer!] 
    initialized [integer!]
    fEnable [integer!]
] lib "Mp3_VocalCut"

; 1 enables vocal cut, 0 disables vocal cut

Mp3_ReverseMode: make routine! [
    return: [integer!] 
    initialized [integer!]
    fEnable [integer!]
] lib "Mp3_ReverseMode"

; 1 enables playing mp3 in reverse, 0 plays normal (forward)

Mp3_Stop: make routine! [
    return: [integer!] 
    initialized [integer!]
] lib "Mp3_Stop"

Mp3_Close: make routine! [
    return: [integer!] 
    initialized [integer!]
] lib "Mp3_Close"


; There are MANY more powerful functions in libmp3.dll.  
; The functions above will get mp3s playing, and enable
; some basic capabilities such as pause/resume, volume
; control, seeking (fast forward and rewind), looping, as 
; well as some interesting tools such as reverse play and
; vocal removal (for stereo tracks only).
; The prototypes above should provide clear enough examples
; to demonstrate how to use all the other functions in the 
; library:  equalizer settings, stream playing, retrieval
; of ID field and recorded data info, effect application
; (echo, etc.), and more.  I drew these function prototypes
; from the Visual Basic example that ships with libwmp3.
; Converting the rest of the functions should be easy...
; (Wrap everything in a nice GUI and we'll have a killer
; REBOL mp3 player (on my to do list... ;))


; ---------------------------------------------------------
; Required REBOL code starts here:
; ---------------------------------------------------------

; 1st, call the Initialize function:

initialized: Mp3_Initialize

; Then open an mp3 file (change the string to select a
; different file):

file: to-string to-local-file to-file request-file
Mp3_OpenFile initialized file 1000 0 0
; Mp3_OpenFile initialized "test.mp3" 1000 0 0

; Then start playing:

Mp3_Play initialized


; ---------------------------------------------------------
; THAT'S IT - EVERYTHING ELSE IS OPTIONAL (wait for play to
; complete, pause, resume, stop, fastforward/rewind, loop,
; adjust volume, EQ settings, effects, release the library,
; etc.)
; ---------------------------------------------------------


print "Here are a few example functions (after 10 seconds of play):^/"

wait 10
print "pause"
Mp3_Pause initialized

wait 3
print "resume"
Mp3_Resume initialized

wait 5
print "reverse"
Mp3_ReverseMode initialized 1

wait 7
print "back to normal"
Mp3_ReverseMode initialized 0

wait 5
print "remove vocals"
Mp3_VocalCut initialized 1

wait 5
print "back to normal"
Mp3_VocalCut initialized 0

wait 5
print "fast forward 10 seconds"
ptime: make struct! Mp3_Time [0 10 0 0 0 0 0 0]
Mp3_Seek initialized TIME_FORMAT_SEC ptime SONG_CURRENT_FORWARD
Mp3_Play initialized

wait 5
print "rewind 20 seconds"
ptime: make struct! Mp3_Time [0 -20 0 0 0 0 0 0]
Mp3_Seek initialized TIME_FORMAT_SEC ptime SONG_CURRENT_FORWARD
Mp3_Play initialized

wait 5
print "wave volume set to 10 out of 100"
Mp3_SetVolume initialized 10 10

wait 3
print "wave volume set to 100 out of 100"
Mp3_SetVolume initialized 100 100

wait 5
print "system volume set to 0 out of 100 (off)"
Mp3_SetMasterVolume initialized 0 0

wait 5
print "system volume set to 100 out of 100"
Mp3_SetMasterVolume initialized 100 100

wait 5
print ""
print "'status' holds the current status of mp3 play"
print "For example, status/fPlay holds a value > 0"
print "when an mp3 is playing.  Current status is:"
print ""
print status/fPlay
print ""
print "All status values are:"
print status


; ---------------------------------------------------------
; You can continually check the play status of the mp3 using
; the loop below.  Here it's used to manually run a function:
; ---------------------------------------------------------

Mp3_GetStatus initialized status
while [status/fPlay > 0] [
   ; wait .1        ; however often you want
   print "" print ""
   your-func: ask "Type a function to run (i.e., 'Mp3_Stop initialized'):   "
   do your-func
   print ""
   Mp3_GetStatus initialized status
]


; ---------------------------------------------------------
; Close and clean up resources:
; ---------------------------------------------------------

Mp3_Stop initialized
Mp3_Destroy initialized
free lib

print "^/Done.^/"
halt
