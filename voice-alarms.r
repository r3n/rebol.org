REBOL [
    title: "Voice Alarms"
    date: 18-Nov-2009
    file: %voice-alarms.r
    Author:  "Nick Antonaccio"
    purpose: {
        Record your voice or other sounds to be played as alarms for
        any number of multiple events.  Save and Load event lists.  All
        alarm sounds repeat until stopped.  Record yourself saying 'wake
        up you lazy bum' or 'hey dude, get up and walk the dog', then 
        set alarms to play those voice messages on any given day/time.
        If you set the alarm as a date/time, the alarm will go off only once,
        on that date.  If you set the alarm as a time, the alarm will go off
        every day at that time.  The .wav recording code is MS Windows
        only, but the program can play any wave file that is usable in
        REBOL.
        Taken from the tutorial at http://musiclessonz.com/rebol.html
    }
]

lib: load/library %winmm.dll
mci: make routine! [c [string!] return: [logic!]] lib "mciExecute"

write %play-alarm.r {
    REBOL []
    wait 0
    the-sound: load %tmp.wav
    evnt: load %event.tmp
    if (evnt = []) [evnt: "Test"]
    forever [
        if error? try [
             insert s: open sound:// the-sound wait s close s
        ] [
             alert "Error playing sound!"
        ]
        delay: :00:07
        s: request/timeout [
            join uppercase evnt " alarm - repeats until you click 'stop':"
            "Continue"
            "STOP"
        ] delay
        if s = false [break]
    ]
}

current: rejoin [form now/date newline form now/time]

view center-face layout [
    c: box black 400x200 font-size 50 current rate :00:01 feel [
        engage: func [f a e] [
            if a = 'time [
                c/text: rejoin [form now/date newline form now/time]
                show c
                if error? try [
                    foreach evnt (to-block events/text) [
                        if any [
                             evnt/1 = form rejoin [
                                 now/date {/} now/time
                             ]
                             evnt/1 = form now/time                            
                        ] [
                            if error? try [
                                 save %event.tmp form evnt/3
                                 write/binary %tmp.wav 
                                 read/binary to-file evnt/2
                                 launch %play-alarm.r
                            ] [
                                 alert "Error playing sound!"
                            ]
                            ; request/timeout [(form evnt/3) "Ok"] :00:05
                        ]
                    ]
                ] []  ; do nothing if user is manually editing events
            ] 
        ] 
    ]
    h3 "Alarm Events (these CAN be edited manually):"
    events: area  ; {[8:00:00am %alarm1.wav "Test Alarm - DELETE ME"]}
    across
    btn "Record Alarm Sound" [
        mci "open new type waveaudio alias wav"
        mci "record wav"
        request ["*** NOW RECORDING *** Click 'stop' to end:" "STOP"]
        mci "stop wav"
        if error? try [x: first request-file/file/save %alarm1.wav] [
            mci "close wav"
            return
        ]
        mci rejoin ["save wav " to-local-file x]
        mci "close wav"
        request [rejoin ["Here's how " form x " sounds..."] "Listen"]
        if error? try [
            save %event.tmp "test"
            write/binary %tmp.wav 
            read/binary to-file x
            launch %play-alarm.r
        ] [
            alert "Error playing sound!"
        ]
    ]
    btn "Add Event" [
        event-name: request-text/title/default "Event Title:" "Event 1"
        the-time: request-text/title/default "Enter a date/time:" rejoin [
            now/date {/} now/time
        ]
        if error? try [set-time: to-date the-time] [
            if error? try [set-time: to-time the-time] [
                alert "Not a valid time!"
                break
            ]
        ]
        my-sound: request-file/title/file ".WAV file:""" %alarm1.wav
        if my-sound = none [break]
        event-block: copy []
        append event-block form the-time
        append event-block my-sound
        append event-block event-name
        either events/text = "" [spacer: ""][spacer: newline]
        events/text: rejoin [events/text spacer (mold event-block)]
        show events
    ]
    btn "Save Events" [
        write to-file request-file/file/save %alarm_events.txt events/text
    ]
    btn "Load Events" [
        if error? try [
            events/text: read to-file request-file/file %alarm_events.txt
        ] [return]
        show events
    ]
]