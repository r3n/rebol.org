REBOL [
    Title: "Demo sound player"
    Author: "Steven White with help from Rosemary de Dear"
    File: %wavplayer.r
    Date: 4-Nov-2011
    Purpose: {The is a complete program (as opposed to a code sample) 
    that plays a .wav file.  It is an annotated modification of a script 
    sent to the author in response to a question on the REBOL mailing list,
    namely, how to find out how long a .wav file will play.                
    Besides playing a sound file, this script is annotated to explain how
    to make a progress bar that tracks the playing time.  Its main usefulness
    probably is as an explanation of how to use the progress bar, a more
    detailed explanation than seems to be in the VID documentation.}
    library: [
        level: 'intermediate
        platform: 'all
        type: [tutorial tool]
        domain: [gui vid]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

;;; Comment from Rosemary de Dear:
;;; thanks to Anton Rolls who helped me with slider
;;; also see Ch. 4 of Olivier and Peter's book.

;; [-----------------------------------------------------------------]
;; [ This function plays the sound file.                             ]
;; [                                                                 ]
;; [ The calculation seems to find the length of the sound in        ]
;; [ milliseconds, for compatibility with timer events.              ]
;; [ The length of the sound data is in bytes.                       ]
;; [ A sample of sound takes more than one byte.                     ]
;; [ The number of bits divided by 8 gives the number of bytes in    ]
;; [ a sample, BUT, that must be multiplied by the number of         ]
;; [ channels to give the total number of bytes used in a sample.    ]
;; [ Dividing the total number of bytes in the file by the number    ]
;; [ of bytes in a sample gives the number of samples in the file.   ]
;; [ Dividing the number of samples by the samples per second        ]
;; [ gives the number of seconds of sound in the file.               ]
;; [ multiplying the number of seconds by 1000 gives the number      ]
;; [ of milliseconds that the sound will play.                       ]
;; [                                                                 ]
;; [ If that is confusing (as it is to me), look at it this way.     ]
;; [ The part of the calculation that is "bytes per sample"          ]
;; [ divided by "samples per second" really is "bytes per second."   ]
;; [ Dividing the bytes in the file by the bytes-per-second          ]
;; [ gives the number of seconds the sound will play.                ]
;; [                                                                 ]
;; [ In this procedure we load the sound file from disk,             ]
;; [ calculate how long it will play (for the progress bar),         ]
;; [ set a flag to indicate that the playing is in progress,         ]
;; [ and launch the sound into the sound port.                       ]
;; [-----------------------------------------------------------------]
WAVPLAYER-PLAY: func [WAVPLAYER-WAV-FILE][
    WAVPLAYER-LOADED-WAV: load WAVPLAYER-WAV-FILE
    WAVPLAYER-PLAY-TIME: 1000 * (             ; milliseconds per second
        (length? WAVPLAYER-LOADED-WAV/data) / ; bytes in the file
        ((WAVPLAYER-LOADED-WAV/bits / 8) * WAVPLAYER-LOADED-WAV/channels) 
        / WAVPLAYER-LOADED-WAV/rate  ;; bytes per sample / samples per second
    )
    WAVPLAYER-PLAYING?: true
    insert WAVPLAYER-SOUND-PORT WAVPLAYER-LOADED-WAV
]

;; [-----------------------------------------------------------------]
;; [ This is the function behind the "Play" button.                  ]
;; [ Redisplay the progress bar with a value of zero so that it      ]
;; [ shows no progress.  Then call the function to actually play     ]
;; [ the sound file.                                                 ]
;; [-----------------------------------------------------------------]
WAVPLAYER-PLAY-BUTTON: does [
    WAVPLAYER-WAV-FILES: request-file   ; Ask for name of sound file
    if not WAVPLAYER-WAV-FILES [        ; Just quit if nothing entered
        exit
    ]
    WAVPLAYER-WAV-FILE: first WAVPLAYER-WAV-FILES
    WAVPLAYER-PLAY WAVPLAYER-WAV-FILE
]

;; [-----------------------------------------------------------------]
;; [ This is the function behind the "Stop" button.                  ]
;; [ Reset the indicator that says whether or not playing is in      ]
;; [ progress.  Reset the start time in case we play again.          ]
;; [ Empty out the sound port to make the sound stop playing.        ]
;; [-----------------------------------------------------------------]
WAVPLAYER-STOP-BUTTON: does [
    WAVPLAYER-PLAYING?: false
    WAVPLAYER-START-TIME: none
    clear WAVPLAYER-SOUND-PORT
]

;; [-----------------------------------------------------------------]
;; [ This is the window that is displayed when the script is run.    ]
;; [ It is a "play" button, a "stop" button, a progress bar that     ]
;; [ will change as the sound plays, and a decorative box.           ]
;; [                                                                 ]
;; [ The decorative box has a rate attached to it.                   ]
;; [ The rate of 1 will cause a timer event to occur every second.   ]
;; [ This event will be processed by the                             ]
;; [ WAVPLAYER-TIMER-EVENT function                                  ]
;; [ defined below.                                                  ]
;; [-----------------------------------------------------------------]
WAVPLAYER-MAIN-WINDOW: layout [
    button "play" [WAVPLAYER-PLAY-BUTTON]
    button "stop" [WAVPLAYER-STOP-BUTTON]
    WAVPLAYER-PROGRESS-BAR: progress
    box 200x50 pewter rate 1
]

;; [-----------------------------------------------------------------]
;; [ This defines a function that will respond to events             ]
;; [ produced by the "rate 1" declaration in the                     ]
;; [ "WAVPLAYER-MAIN-WINDOW" window.                                 ]
;; [ It gives the function a                                         ]
;; [ name so we can remove it later, and puts it where it must be    ]
;; [ (insert-event-func) so that it will be called when events       ]
;; [ take place.                                                     ]
;; [                                                                 ]
;; [ The purpose of this function is to catch timer interrupts so    ]
;; [ that we can update the progress bar.  We only update the        ]
;; [ progress bar if the sound is playing.  (We set a flag for       ]
;; [ that when we played the sound.)                                 ]
;; [                                                                 ]
;; [ We use the WAVPLAYER-START-TIME to tell us if this is the first ]
;; [ interrupt.  If the WAVPLAYER-START-TIME is not set              ]
;; [ (meaning this is the                                            ]
;; [ first interrupt), we will set it to the time of the             ]
;; [ interrupt.  For every subsequent interrupt, we will subtract    ]
;; [ the start time from the subsequent time to give the time that   ]
;; [ has WAVPLAYER-ELAPSED from the start time,                      ]
;; [ which also is the length of                                     ]
;; [ time the sound has been playing.                                ]
;; [                                                                 ]
;; [ When we divide the length of time the sound has been playing    ]
;; [ by the total length of the sound, we get a fraction             ]
;; [ (a number between zero and 1) showing how much of the sound     ]
;; [ has played.  That number can be used to update the progress     ]
;; [ bar.  A progress bar uses a number between zero and one to      ]
;; [ show no progress (0) to 100 percent progress (1).               ]
;; [                                                                 ]
;; [ If our calculation of the fraction that shows how much of the   ]
;; [ sound has played gives a result of 1, that means that the       ]
;; [ sound is done playing.  In that case, we can reset the          ]
;; [ indicator to show that the sound is done, and reset the         ]
;; [ start time in case we play again.                               ]
;; [-----------------------------------------------------------------]
WAVPLAYER-TIMER-EVENT: insert-event-func func [face event] [
    if event/type = 'time [
        if WAVPLAYER-PLAYING? [
            either none? WAVPLAYER-START-TIME [
                WAVPLAYER-START-TIME: event/time
            ] [
                WAVPLAYER-ELAPSED: event/time - WAVPLAYER-START-TIME
                WAVPLAYER-PCT-DONE: min 1.0 WAVPLAYER-ELAPSED / WAVPLAYER-PLAY-TIME
                if WAVPLAYER-PCT-DONE <= 1.0 [
                    set-face WAVPLAYER-PROGRESS-BAR WAVPLAYER-PCT-DONE
                ]
                if WAVPLAYER-PCT-DONE >= 1.0 [
                    WAVPLAYER-PLAYING?: false 
                    WAVPLAYER-START-TIME: none
                ]
            ]
        ]
    ] 
    event
]

;; [-----------------------------------------------------------------]
;; [ Start the program.                                              ]
;; [-----------------------------------------------------------------]

WAVPLAYER-PLAYING?: none                ; Show nothing playing
WAVPLAYER-START-TIME: none              ; Clear our start time indicator
set-face WAVPLAYER-PROGRESS-BAR 0
WAVPLAYER-SOUND-PORT: open sound://     ; Necessary preparation to play
center-face WAVPLAYER-MAIN-WINDOW       ; Put the window in the center of screen
view WAVPLAYER-MAIN-WINDOW              ; Show the window

;; [-----------------------------------------------------------------]
;; [ Put the program in a state to respond to events (mouse clicks,  ]
;; [ button pushes, and, important here, timer interrupts).          ]
;; [ If an error happens, set the word "err" to the error object     ]
;; [ that is the result of an error.  Then, if we do have an error,  ]
;; [ "disarm" it to gain access to the values in it, "mold" it so    ]
;; [ that it looks like REBOL code, and then print it.               ]
;; [-----------------------------------------------------------------]

if error? set/any 'err try [do-events] [
    print mold disarm err
]

;; [-----------------------------------------------------------------]
;; [ When the "WAVPLAYER-MAIN-WINDOW" window is closed               ]
;; [ with the X in the corner,                                       ]
;; [ the program will resume running here.                           ]
;; [-----------------------------------------------------------------]

close WAVPLAYER-SOUND-PORT              ; Necessary cleanup
remove-event-func :WAVPLAYER-TIMER-EVENT () ; Inserted earlier, removed now
quit                          ; not quitting leaves rebol.exe in memory
