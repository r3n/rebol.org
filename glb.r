REBOL [
    Title:  "Global services module"
    Author: "Steven White"
    File: %glb.r
    Date: 7-Nov-2011
    Purpose: {This is an idea for packaging up code, plus some small 
    demos of how to do various things, harvested from the cookbook and 
    the mailing list.  They are things that are done so often and in so 
    many situations that the author found it helpful to package them up   
    in a file of personal functions.  All these techniques are shown in
    various places, but this module packages them as complete functions
    instead of demos or ideas.  If an experienced reader looks at them
    and decides that they are terrible ways to do things, that itself
    might be a commentary on the state of REBOL documentation.  Perhaps
    the motto would be, "simple things are simple, and complicated
    things are undocumented."}
    library: [
        level: 'beginner
        platform: 'all
        type: [tutorial tool]
        domain: [text-processing file-handling]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]

]

;; [---------------------------------------------------------------------------]
;; [ This is a file of global definitions that will be loaded                  ]
;; [ as the very first thing in a REBOL script.                                ]
;; [ This is done with:                                                        ]
;; [     do %glb.r                                                             ]
;; [---------------------------------------------------------------------------] 

;; [---------------------------------------------------------------------------]
;; [ Get the current date and time from the OS and format it in                ]
;; [ some assorted ways that we have found useful.                             ]
;; [ The method of getting a two-digit month or day might seem a               ]
;; [ bit obscure.  Take the month/day, add a zero to be sure it is             ]
;; [ at least two digits, reverse it, pick off two digits, and                 ]
;; [ reverse it again.  We store YYYYMMDD as a string because                  ]
;; [ it usually is used in a file name.                                        ]
;; [---------------------------------------------------------------------------]

GLB-NOW: now
GLB-YYYYMMDD: to-string rejoin [
    GLB-NOW/year
    reverse copy/part reverse join 0 GLB-NOW/month 2
    reverse copy/part reverse join 0 GLB-NOW/day 2
]
GLB-MMDDYY: to-string rejoin [
    reverse copy/part reverse join 0 GLB-NOW/month 2
    reverse copy/part reverse join 0 GLB-NOW/day 2
    reverse copy/part reverse to-string GLB-NOW/year 2
]

;; [---------------------------------------------------------------------------]
;; [ Get the current time, strip out the colons, add a leading zero            ]
;; [ if necessary, and return hhmmss.  This can be used for a time             ]
;; [ stamp.                                                                    ]
;; [ Get the time and trim out the colons.                                     ]
;; [ Put a zero on the front end in case one is needed.                        ]
;; [ Reverse the resulting string.                                             ]
;; [ Copy off six characters from the left, which now is the back              ]
;; [ end after the above reversal.                                             ]
;; [ Reverse it again to put the hours on the front.                           ]
;; [---------------------------------------------------------------------------]

GLB-HHMMSS: to-string rejoin [
    reverse copy/part reverse join "0" trim/with to-string now/time ":" 6
]

;; [---------------------------------------------------------------------------]
;; [ This function accepts a string, a starting position, and an               ]
;; [ ending position, and returns a substring from the starting                ]
;; [ position to the ending position.  If the ending position is -1,           ]
;; [ the procedure returns the substring from the starting position            ]
;; [ to the end of the string.                                                 ]
;; [ This technique was "borrowed" from the REBOL library.                     ]
;; [---------------------------------------------------------------------------]

GLB-SUBSTRING: func [
    "Return a substring from the start position to the end position"
    INPUT-STRING [series!] "Full input string"
    START-POS    [number!] "Starting position of substring"
    END-POS      [number!] "Ending position of substring"
] [
    if END-POS = -1 [END-POS: length? INPUT-STRING]
    return skip (copy/part INPUT-STRING END-POS) (START-POS - 1)
]

;; [---------------------------------------------------------------------------]
;; [ This is a function that accepts a file name (string or file)              ]
;; [ and picks off the extension (the dot followed by stuff) and               ]
;; [ returns everything up to the dot.                                         ]
;; [ This can be done in a one-liner, but I have trouble remembering           ]
;; [ that one line, and also had a little trouble making it work               ]
;; [ at one point, so I made this procedure that works all the time.           ]
;; [---------------------------------------------------------------------------]

GLB-BASE-FILENAME: func [
    "Returns a file name without the extension"
    INPUT-STRING [series! file!] "File name"
    /local FILE-STRING REVERSED-NAME REVERSED-BASE BASE-FILENAME
] [
    FILE-STRING: copy ""
    FILE-STRING: to-string INPUT-STRING
    REVERSED-NAME: reverse FILE-STRING
    REVERSED-BASE: copy ""
    REVERSED-BASE: next find REVERSED-NAME "."
    BASE-FILENAME: copy ""
    BASE-FILENAME: reverse REVERSED-BASE
    return BASE-FILENAME
]

;; [---------------------------------------------------------------------------]
;; [ For use in creating fixed-length lines of text (perhaps for               ]
;; [ printing), this function accepts an integer and returns a                 ]
;; [ string of blanks that many blanks long.  This filler can                  ]
;; [ be joined with other strings to space things out to a certain             ]
;; [ number of characters.  This would be useful mainly when                   ]
;; [ printing in a fixed-width font.                                           ]
;; [---------------------------------------------------------------------------]

GLB-FILLER: func [
    "Return a string of a given number of spaces"
    SPACE-COUNT [integer!]
    /local FILLER 
] [
    FILLER: copy ""
    loop SPACE-COUNT [
        append FILLER " "
    ]
    return FILLER
]

;; [---------------------------------------------------------------------------]
;; [ This is a procedure written for converting a number, which                ]
;; [ could be a decimal number, currency, string with commas and               ]
;; [ dollar signs, and so on, into an output string which is just              ]
;; [ the digits, padded on the left with leading zeros out to a                ]
;; [ specified length.  It was written as an aid in creating a                 ]
;; [ fixed-format text file.                                                   ]
;; [ The procedure works in a way that might not be immediatedly               ]
;; [ obvious.  It uses the trim function on a copy of the input                ]
;; [ string to filter OUT everything but digits.  The result of                ]
;; [ this first trimming will be any invalid characters in the                 ]
;; [ input string.  Then it trims the real input string to filter              ]
;; [ out all the non-numeric characters captured in the first                  ]
;; [ trim.  After the procedure gets a trimmed string of digits                ]
;; [ only, it reverses it and adds enough zeros on the right to                ]
;; [ pad it out to the desired length.  Then it reverses the                   ]
;; [ result again to get the extra zeros on the left and returns               ]
;; [ this final result to the caller.                                          ]
;; [---------------------------------------------------------------------------]

GLB-ZEROFILL: func [
    "Convert number to string, pad with leading zeros"
    INPUT-STRING
    FINAL-LENGTH
    /local ALL-DIGITS 
           LENGTH-OF-ALL-DIGITS
           NUMER-OF-ZEROS-TO-ADD
           REVERSED-DIGITS 
           FINAL-PADDED-NUMBER
] [
    ALL-DIGITS: copy ""
    ALL-DIGITS: trim/with to-string INPUT-STRING trim/with 
        copy to-string INPUT-STRING "0123456789"
    LENGTH-OF-ALL-DIGITS: length? ALL-DIGITS
    if (LENGTH-OF-ALL-DIGITS <= FINAL-LENGTH) [
        NUMBER-OF-ZEROS-TO-ADD: (FINAL-LENGTH - LENGTH-OF-ALL-DIGITS)
        REVERSED-DIGITS: copy ""
        REVERSED-DIGITS: reverse ALL-DIGITS    
        loop NUMBER-OF-ZEROS-TO-ADD [
            append REVERSED-DIGITS "0"
        ]
        FINAL-PADDED-NUMBER: copy ""
        FINAL-PADDED-NUMBER: GLB-SUBSTRING reverse REVERSED-DIGITS 1 FINAL-LENGTH
    ]
    return FINAL-PADDED-NUMBER
]

;; [---------------------------------------------------------------------------]
;; [ This is a function to take a string, and a length, and pad the            ]
;; [ string with trailing spaces.  It also, as a byproduct, trims off          ]
;; [ leading spaces based on the idea that this opertion would be              ]
;; [ the most commonly-wanted.                                                 ]
;; [---------------------------------------------------------------------------]

GLB-SPACEFILL: func [
    "Left justify a string, pad with spaces to specified length"
    INPUT-STRING
    FINAL-LENGTH
    /local TRIMMED-STRING
           LENGTH-OF-TRIMMED-STRING
           NUMBER-OF-SPACES-TO-ADD
           FINAL-PADDED-STRING
] [
    TRIMMED-STRING: copy ""
    TRIMMED-STRING: trim INPUT-STRING
    LENGTH-OF-TRIMMED-STRING: length? TRIMMED-STRING
    either (LENGTH-OF-TRIMMED-STRING < FINAL-LENGTH) [
        NUMBER-OF-SPACES-TO-ADD: (FINAL-LENGTH - LENGTH-OF-TRIMMED-STRING)
        FINAL-PADDED-STRING: copy TRIMMED-STRING
        loop NUMBER-OF-SPACES-TO-ADD [
            append FINAL-PADDED-STRING " "
        ]
    ] [
        FINAL-PADDED-STRING: COPY ""
        FINAL-PADDED-STRING: GLB-SUBSTRING TRIMMED-STRING 1 FINAL-LENGTH
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This is a function (and supporting data) to provide a finite              ]
;; [ trace of whatever a caller wants to trace.                                ]
;; [ Trace lines will be stored in a block of numbered entries,                ]
;; [ up to a certain size.  After that certain size is reached,                ]
;; [ the oldest entry will be dropped.                                         ]
;; [ This was created originally as a debugging trace.                         ]
;; [---------------------------------------------------------------------------]

GLB-TRACE: []
GLB-TRACE-SIZE: 100
GLB-TRACE-SEQ: 0
GLB-TRACE-FILE-ID: %glb-trace.txt
GLB-TRACE-FILE-BUFFER: ""
GLB-TRACE-EMIT: func [
    "Emit a submitted line to the finite trace block"
    TRACE-LINE [block!]
] [
    GLB-TRACE-SEQ: GLB-TRACE-SEQ + 1
    insert tail GLB-TRACE reform [GLB-TRACE-SEQ remold TRACE-LINE]
    head GLB-TRACE
    if > GLB-TRACE-SEQ GLB-TRACE-SIZE [
        remove GLB-TRACE
    ]
]
GLB-TRACE-PRINT: does [
    foreach TRACE-LINE GLB-TRACE [
        print TRACE-LINE
    ]
]
GLB-TRACE-SAVE: does [
    GLB-TRACE-FILE-BUFFER: copy ""
    foreach TRACE-LINE GLB-TRACE [
        append GLB-TRACE-FILE-BUFFER TRACE-LINE
        append GLB-TRACE-FILE-BUFFER newline
    ]
    write/lines GLB-TRACE-FILE-ID GLB-TRACE-FILE-BUFFER
]

;; [---------------------------------------------------------------------------]
;; [ This function, copied from the REBOL cookbook, provides a                 ]
;; [ logging file.  Actually, it provides several logging files                ]
;; [ since it is called with a file name as one of the parameters.             ]
;; [ This allows a program to write to any number of log files.                ]
;; [ Because the procedure appends a log line to a file, the file              ]
;; [ will remain if the program crashes.                                       ]
;; [---------------------------------------------------------------------------]

GLB-LOG-LINE: ""
GLB-LOG-EMIT: func [
    FILE-ID
    LOG-DATA
] [
    GLB-LOG-LINE: copy ""
    GLB-LOG-LINE: append trim/lines reform [now remold LOG-DATA] newline
    attempt [write/append FILE-ID GLB-LOG-LINE]
]

;; [---------------------------------------------------------------------------]
;; [ This is a function that can be used to pause a program and allow          ]
;; [ commands to be entered at the pause prompt.                               ]
;; [ To use, call GLB-PAUSE with a string parameter.  The string parameter     ]
;; [ will be displayed as a prompt, and the program will wait for input.       ]
;; [ Enter any REBOL command at the prompt, and the function will try          ]
;; [ to execute it.  To display a data value, just type the word whose         ]
;; [ value you want displayed.  To continue with the program, press the        ]
;; [ "enter" key with no input.                                                ]
;; [---------------------------------------------------------------------------]

GLB-PAUSE: func [GLB-PAUSE-PROMPT /local GLB-PAUSE-INPUT][
  GLB-PAUSE-INPUT: "none"
  while ["" <> trim/lines GLB-PAUSE-INPUT][
  GLB-PAUSE-INPUT: ask join GLB-PAUSE-PROMPT " >> "
  attempt [probe do GLB-PAUSE-INPUT]
  ]
]

;; [---------------------------------------------------------------------------]
;; [ This is a function harvested from the internet, by Gregg Irwin, who       ]
;; [ seems to be a notable REBOL expert.  It copies a specified directory      ]
;; [ to another directory of a specified name, and does it recursively.        ]
;; [ The original name was "copy-dir" but I changed it to "GLB-COPY-DIR"       ]
;; [ to match my naming scheme (which is not very REBOL-ish, but helps me      ]
;; [ keep track).                                                              ]
;; [---------------------------------------------------------------------------]

GLB-COPY-DIR: func [source dest] [
        if not exists? dest [make-dir/deep dest]
        foreach file read source [
            either find file "/" [
                GLB-COPY-DIR source/:file dest/:file
            ][
                print file
                write/binary dest/:file read/binary source/:file
            ]
        ]
    ]

;; ################################################################
