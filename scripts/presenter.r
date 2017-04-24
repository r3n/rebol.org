REBOL [
    Title: "Presentation viewer"
    Author: "Steven White"
    File: %presenter.r
    Date: 3-Nov-2011
    Purpose: {Display a little power-point-like slide show, where the
    slides are read from a text file and consist of VID code describing
    each slide.  It could be used by someone who wants to give a simple
    slide show without attacking a more useful, but also more complicated,
    presentation program.}
    library: [
        level: 'beginner
        platform: 'all
        type: [tutorial tool]
        domain: [gui vid]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This is a "simple" presentation view program.                             ]
;; [ It is simple in that it doesn't do much, and the source of the            ]
;; [ presentation is a simple text file of VID layout code.                    ]
;; [ However, it is not quite so simple in that one must KNOW VID code         ]
;; [ to write that presentation file.                                          ]
;; [                                                                           ]
;; [ The format of the presentation file is a bunch of blocks.                 ]
;; [ Each block is the VID code to make one window.  You should be able to     ]
;; [ run this VID code through the "layout" command and view it,               ]
;; [ because that is what this program does.                                   ]
;; [ The presentation file has many of these blocks of VID code, and will      ]
;; [ page forward and backward through them, running each through the          ]
;; [ "layout" function and displaying it.                                      ]
;; [ The presentation file DOES NOT have a beginning and ending bracket        ]
;; [ to make it into one big block.  The presentation file is multiple         ]
;; [ blocks of syntactically correct VID code.  The whole presentation file    ]
;; [ is brought into memory with the "load" function, and that creates         ]
;; [ one big block, with each member being one of the blocks in the            ]
;; [ presentation file.                                                        ]
;; [                                                                           ]
;; [ So, to restate, a presentation file looks like this:                      ]
;; [                                                                           ]
;; [     [VID code for window 1]                                               ]
;; [     [VID code for window 2]                                               ]
;; [     ...                                                                   ]
;; [     [VID code for window n]                                               ]
;; [                                                                           ]
;; [ The program will provide "next" and "prev" buttons to page through        ]
;; [ "n" windows created from those "n" blocks of VID code.                    ]
;; [ It is up to you to create correct VID code.                               ]
;; [                                                                           ]
;; [ Data items:                                                               ]
;; [                                                                           ]
;; [ CURRENT-LAYOUT       Result of a block of VID code run through layout     ]
;; [ CURRENT-POSITION     Number of the screen currently in view               ]
;; [ CURRENT-VID          Current block of vid code from SCREEN-BLOCKS         ]
;; [ DEMO-DATA            A small presentation file, compressed for demo       ]
;; [ PRESENTATION-FILE    Name of the file of VID code we loaded               ]
;; [ PRESENTATION-LOADED  Flag to indicate we have loaded a file               ]
;; [ PRESENTATION-SIZE    Number of blocks in the presentation file            ]
;; [ SCREEN-BLOCKS        The presentation file loaded into memory             ]
;; [---------------------------------------------------------------------------]

DEMO-DATA:
#{
789C9D964D6FDB2018C7EFF9148F72E965936C374BAB6A9A34B59AB45BA56EBB
4439101B3B280432C071BD4F3F5EFCD212A0DD7248147E7FFE7E5E00B35948F2
07C36D963DAFB30C160A3F2B587E05498E278AE124B0C44C214538D37F7823D0
7109379F32B8FCD49C29D818BB3B2856802869D81D5C957A3E16DBC1F9A7C475
4B81D4D0F3162ACEAE14ECD119832247FDC5816224183CF20E8B474E985A7ACE
F96DC4F981C81345BD846ECF75E41D6115EF247046FB0FC038D488953D48D5D6
F5321873D4F989920A4B400243293052B8825D0F7AA814644758036A8F8F4018
FCFAFE0025AFF0BB63BE470C2A17B70D54C78E94B399C93251E780F376B1997B
7A9365C3A3BE9959665CBAFEBDAB5B2F45AB6CBB046F2020BBBEF5647A20245B
FBB27550B6F265ABA0ACF0654550E6A7701D4CA1F053288229147E0A453085C2
4FA108A650F82914C1140A3F85229842EEA7900753C8FD14F2600AB99F421E4C
21F753D003AF97E37A5A8E3FCC77C92917FFB21E9FB0D21B5BED35707AEB7007
9FEDEFC78E8BEACBF62A56EE7B230223B29BF952864AC1A51CD43B8ACA83BF93
7564C3232DDE4EDAD66EFAA8B6C5A394A1739F901A3C4AB940AC31BE61A9C3A3
B8E1B44AF81A3C4A1562CBD0893D4835DE2E0456AD60C38492239AF036780A43
60CCE255B378D4EAA3BE4ED81A3C2F33FD2252D152383C7543F02E1183C5DB29
B5BAC6F11A3BEC9543BF04532D3478B2EF875A47EC7B3445A270B2C8068F52F4
BB4509A9C1A3B4D3AF2B11AF85C5A3561EFAD4BAD0D82BC40977CE3D3CC1E1D1
5DE02AE5AEF1A83C22C1398BDA3A3C379B24B7A9C1533704394AE31CE986C3A3
FA44D821516583BD7A4842CF897A383C67D9989B552C98014FC1B442DFC7E2A5
B678149F89BE01C5778BC393333AA11EC59D2D9E9BB833C3B1A007EC9785F12E
51488347FF1E536AC561A9C3D3F948C9F9E2AEF5E27C3478D65602EDE267A9C5
A3F8B047071237B6786AE370478DB55163AF1CDD9EA844D8168FEEE4CC451FD7
5A3C1DA784A58E5E8BA75D83499388C1E237AE92AAA7FF7D97D4223B5F8B76E6
C574B19E5E51483B10A51F58C63D06FE864BCB2A2C4C8DE246B324EDB5315183
7B2CCC93A2C6313DE8062CFE0294D66EF8A10D0000
}
CURRENT-VID: []          
CURRENT-LAYOUT: none     
CURRENT-POSITION: 0      
PRESENTATION-SIZE: 0     
PRESENTATION-LOADED: false

;; [---------------------------------------------------------------------------]
;; [ This function responds to the "Open" button.                              ]
;; [ It loads a whole presentation file into memory as a block of VID blocks.  ]
;; [---------------------------------------------------------------------------]

OPEN-BUTTON: does [
    PRESENTATION-FILE: request-file/only
    if not file? PRESENTATION-FILE [
        alert "No file was selected; program will quit"
        quit
    ]
    SCREEN-BLOCKS: copy []
    SCREEN-BLOCKS: load PRESENTATION-FILE
    PRESENTATION-SIZE: length? SCREEN-BLOCKS
    CURRENT-POSITION: 1
    CURRENT-VID: copy []
    CURRENT-VID: first SCREEN-BLOCKS
    CURRENT-LAYOUT: layout CURRENT-VID
    view/new center-face CURRENT-LAYOUT     
    PRESENTATION-LOADED: true
]

;; [---------------------------------------------------------------------------]
;; [ This function responds to a right-click of the "Open" button.             ]
;; [ It displays a short help screen.                                          ]
;; [---------------------------------------------------------------------------]

OPEN-BUTTON-HELP: does [
    inform layout [
        vh1 "The Open button"
        text {
The Open button will cause the program to ask for a file using
the standard request dialog.  The file you specify must be a
block of blocks of VID code.  If you need an example, use the
Demo button, and then, as you display the different windows,
capture them with the Debug button.
}
button 200 "Close help window" [hide-popup]
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This function responds to the "Close" button.                             ]
;; [ It clears out the block of VID blocks so we could use the "Open"          ]
;; [ button again if we wanted to.                                             ]
;; [---------------------------------------------------------------------------]

CLOSE-BUTTON: does [
    either PRESENTATION-LOADED [
        unview     
        SCREEN-BLOCKS: copy []
        PRESENTATION-LOADED: false
    ] [
        alert "No presentation loaded."
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This function responds to a right-click of the "Close" button.            ]
;; [ It displays a short help screen.                                          ]
;; [---------------------------------------------------------------------------]

CLOSE-BUTTON-HELP: does [
    inform layout [
        vh1 "The Close button"
        text {
The Close button will cause the program to ask reset everything 
to the state where it was when you started it.  At this point,
you may open another presentation, or run the demo, or quit.  
}
button 200 "Close help window" [hide-popup]
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This function responds to the "Next" button.                              ]
;; [ We keep track of where we are in the block of VID blocks, so the          ]
;; [ function goes to the next block, runs it through the "layout"             ]
;; [ function, and displays it.                                                ]
;; [---------------------------------------------------------------------------]

NEXT-BUTTON: does [
    either PRESENTATION-LOADED [
        either (CURRENT-POSITION = PRESENTATION-SIZE) [
            alert "The End."
        ] [
            unview     
            CURRENT-POSITION: CURRENT-POSITION + 1
            if (CURRENT-POSITION > PRESENTATION-SIZE) [ ;; should never happen
                CURRENT-POSITION: PRESENTATION-SIZE
            ]
            CURRENT-VID: copy []
            CURRENT-VID: pick SCREEN-BLOCKS CURRENT-POSITION
            CURRENT-LAYOUT: layout CURRENT-VID
            view/new center-face CURRENT-LAYOUT               
        ]
    ] [
        alert "No presentation loaded."
        exit
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This function responds to a right-click of the "Next" button.             ]
;; [ It displays a short help screen.                                          ]
;; [---------------------------------------------------------------------------]

NEXT-BUTTON-HELP: does [
    inform layout [
        vh1 "The Next button"
        text {
The Next button will cause the program to display the next window
of the group of windows it loaded with the Open or Demo button.
If there is no next window, the program will alert you that it is
at the end of the presentation.                                
}
button 200 "Close help window" [hide-popup]
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This function responds to the "Prev" button.                              ]
;; [ It is like the "Next" button, but goes back one windows instead of        ]
;; [ forward.                                                                  ]
;; [---------------------------------------------------------------------------]

PREV-BUTTON: does [
    either PRESENTATION-LOADED [
        either (CURRENT-POSITION = 1) [
            alert "At the start."
        ] [
            unview     
            CURRENT-POSITION: CURRENT-POSITION - 1
            if (CURRENT-POSITION < 1) [  ;; should never happen
                CURRENT-POSITION: 1
            ]
            CURRENT-VID: copy []
            CURRENT-VID: pick SCREEN-BLOCKS CURRENT-POSITION
            CURRENT-LAYOUT: layout CURRENT-VID
            view/new center-face CURRENT-LAYOUT               
        ]
    ] [
        alert "No presentation loaded."
        exit
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This function responds to a right-click of the "Prev" button.             ]
;; [ It displays a short help screen.                                          ]
;; [---------------------------------------------------------------------------]

PREV-BUTTON-HELP: does [
    inform layout [
        vh1 "The Prev button"
        text {
The Prev button will cause the program to display the previous window
of the group of windows it loaded with the Open or Demo button.
If there is no previous window, the program will alert you that it is
at the beginning of the presentation.                                
}
button 200 "Close help window" [hide-popup]
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This function responds to the "Quit" button.                              ]
;; [---------------------------------------------------------------------------]

QUIT-BUTTON: does [
    quit
]

;; [---------------------------------------------------------------------------]
;; [ This function responds to a right-click of the "Quit" button.             ]
;; [ It displays a short help screen.                                          ]
;; [---------------------------------------------------------------------------]

QUIT-BUTTON-HELP: does [
    inform layout [
        vh1 "The Quit button"
        text {
The Quit button will cause the program to quit immediately.         
No data is lost because this program does not update any data.  
}
button 200 "Close help window" [hide-popup]
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This function responds to the "Debug" button.                             ]
;; [ It displays the VID code for the window being shown, plus other           ]
;; [ data items that might be useful.                                          ]
;; [ This will open up a console window.  If you close the console window      ]
;; [ the whole program will quit.  If you are going to display a few           ]
;; [ windows, just minimize the console window and your displays still         ]
;; [ will be captured in it for later viewing.                                 ]
;; [---------------------------------------------------------------------------]

DEBUG-BUTTON: does [
    print ["CURRENT-POSITION: " CURRENT-POSITION]
    print ["PRESENTATION-SIZE: " PRESENTATION-SIZE]
    print "Current window on display:" 
    print mold CURRENT-VID
]

;; [---------------------------------------------------------------------------]
;; [ This function responds to a right-click of the "Debug" button.            ]
;; [ It displays a short help screen.                                          ]
;; [---------------------------------------------------------------------------]

DEBUG-BUTTON-HELP: does [
    inform layout [
        vh1 "The Debug button"
        text {
The Debug button will cause the program to open a console window and
display the VID code of the current window.  If you close the console
window, the whole program will end, so don't do that unless you do want
the program to end.  Every press of the Debug button will add more VID code
to the end of the display in the console window.  The purpose of this button
is to show you the code the program is supposed to be displaying, in case
the display is not what you expect.
}
button 200 "Close help window" [hide-popup]
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This function responds to the "Demo" button.                              ]
;; [ It operates just like the "Open" button, but instead of getting           ]
;; [ data from a file, it gets data from a test file that has been             ]
;; [ compressed and included in the program.                                   ]
;; [---------------------------------------------------------------------------]

DEMO-BUTTON: does [
    SCREEN-BLOCKS: copy []
    SCREEN-BLOCKS: load decompress DEMO-DATA
    PRESENTATION-SIZE: length? SCREEN-BLOCKS
    CURRENT-POSITION: 1
    CURRENT-VID: copy []
    CURRENT-VID: first SCREEN-BLOCKS
    CURRENT-LAYOUT: layout CURRENT-VID
    view/new center-face CURRENT-LAYOUT     
    PRESENTATION-LOADED: true
]    

;; [---------------------------------------------------------------------------]
;; [ This function responds to a right-click of the "Demo" button.             ]
;; [ It displays a short help screen.                                          ]
;; [---------------------------------------------------------------------------]

DEMO-BUTTON-HELP: does [
    inform layout [
        vh1 "The Demo button"
        text {
The Demo button will cause the program to operate just like you pressed the
Open button, except that it will not ask for a file, but instead will load
a small demo file that has been compressed and included in the program source
code.  This feature is provided to show you how to format a presentation file,
in case you are not familiar with VID code.
}
button 200 "Close help window" [hide-popup]
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This is the main window that the operator sees.                           ]
;; [ It is just navigation buttons.  It it designed to be tucked away at       ]
;; [ some corner of the screen so it will not be blocked by any                ]
;; [ presentation windows.                                                     ]
;; [---------------------------------------------------------------------------]

MAIN-WINDOW: [
    text "Right-click any button for help"
    across
    button 50 "Open"  [OPEN-BUTTON]  [OPEN-BUTTON-HELP]
    button 50 "Close" [CLOSE-BUTTON] [CLOSE-BUTTON-HELP]
    button 50 "Prev"  [PREV-BUTTON]  [PREV-BUTTON-HELP]
    button 50 "Next"  [NEXT-BUTTON]  [NEXT-BUTTON-HELP]
    button 50 "Quit"  [QUIT-BUTTON]  [QUIT-BUTTON-HELP] 
    button 50 "Debug" [DEBUG-BUTTON] [DEBUG-BUTTON-HELP]
    button 50 "Demo"  [DEMO-BUTTON]  [DEMO-BUTTON-HELP]
]

;; [---------------------------------------------------------------------------]
;; [ Start the program.                                                        ]
;; [---------------------------------------------------------------------------]

view layout MAIN-WINDOW
