REBOL [
    Title: "Printing module using PCL"
    Author: "Steven White"
    Date: 27-MAY-2014
    File: %pclprt.r
    Purpose: {A COBOL-like method for printing basic
    text-oriented business reports.}
    library: [
        level: 'beginner
        platform: 'all
        type: [function demo]
        domain: [printing]
        tested-under: "view 2.7.8 on Windows"
        support: none
        licnese: none
        see-also: none
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This is a module for primitive printing.                                  ]
;; [ It works in a specific situation, namely, where all printers are          ]
;; [ connected to a Windows print server, and all printers are made by         ]
;; [ Hewlett-Packard.                                                          ]
;; [ It also is designed for simple reports, lines of text only, like in       ]
;; [ the days of mainframe computers.                                          ]
;; [ The reason it works in this situation, and this situation is required     ]
;; [ to make it work, is that we can send stuff to a printer in a standard     ]
;; [ way, and what we send to the printer can contain embedded PCL codes       ]
;; [ to control the printer.                                                   ]
;; [ The module "prints" pre-formmated lines to a "file" which is just a       ]
;; [ big string in memory.  Then, it puts them on paper by writing to a        ]
;; [ printer through the print server.                                         ]
;; [ Without a network printer that is a Hewlett-Packard printer, this         ]
;; [ probably will not work.  But with a nice uniform network of HP printers   ]
;; [ running on a Microsoft network of networked printers, it works well.      ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ These items are the ones that would have to adjusted for a particular     ]
;; [ installation.  They could be pulled out into a configuration file         ]
;; [ if desired.                                                               ]
;; [ In the working version of this module at the site where it was            ]
;; [ written, these items have meaningful values.                              ]
;; [ If you are looking at a copy of the real module, sanitized for its        ]
;; [ demonstration value, these item will have obviously dummy values.         ]
;; [---------------------------------------------------------------------------]

PCLPRT-INSTALLATION-NAME: "Y O U R    I N S T A L L A T I O N"
PCLPRT-SERVER: %/printserver/
PCLPRT-DEFAULT-PRINTER: "printer001"
PCLPRT-PRINTER-LIST: [
    printer001  
    printer002  
    printer003 
    printer004 
]

;; [---------------------------------------------------------------------------]
;; [ A printer is controlled by putting codes ("escape sequences") into        ]
;; [ the data sent to the printer.                                             ]
;; [ These are the codes we use in this module, assembled here for             ]
;; [ organization.  They are commonly-used ones, but not even close to         ]
;; [ all of them.  There is a huge amount of stuff that this module            ]
;; [ does NOT do.                                                              ]
;; [---------------------------------------------------------------------------]

PCLPRT-RESET:            "^(esc)E"     ;; Send at beginning and end of job
PCLPRT-FORMFEED:         "^(page)"     ;; Page eject
PCLPRT-LANDSCAPE:        "^(esc)&l1O"  ;; Landscape orientation
PCLPRT-FONT-LINEPRINTER: "^(esc)(10U^(esc)(s0p16.67h8.5v0s0b0T" 
PCLPRT-MARGIN-LEFT-5:    "^(esc)&a5L"  ;; Five-column left margin
PCLPRT-MARGIN-TOP-4:     "^(esc)&l4E"  ;; Four-line top margin
PCLPRT-LPI-8:            "^(esc)&l8D"  ;; Eight lines per inch
PCLPRT-LINE-TERMINATION: "^(esc)&k2G"  ;; CR=CR, LF=CR-LF, FF=CR-FF

;; [---------------------------------------------------------------------------]
;; [ "Printing" is going to mean appending a print line to the end of          ]
;; [ this big string.  When we "close" the print "file," this big string       ]
;; [ will be written to a network printer.                                     ]
;; [---------------------------------------------------------------------------]

PCLPRT-FILE: ""

;; [---------------------------------------------------------------------------]
;; [ Here are some other important items, defined here so we can keep          ]
;; [ track of them.                                                            ]
;; [---------------------------------------------------------------------------]

PCLPRT-PRINTER: copy PCLPRT-DEFAULT-PRINTER
PCLPRT-PRINTER-PATH: none
PCLPRT-PAGE-SIZE: 57
PCLPRT-LINE-COUNT: 0

;; [---------------------------------------------------------------------------]
;; [ This procedure can be used to request a printer name if the default       ]
;; [ name is not acceptable, or if you want the operator to specify a          ]
;; [ printer.                                                                  ]
;; [---------------------------------------------------------------------------]

PCLPRT-REQUEST-PRINTER: does [
    PCLPRT-PRINTER: request-list "Select printer by name" PCLPRT-PRINTER-LIST
]

;; [---------------------------------------------------------------------------]
;; [ This procedure "opens" the print "file," which means we will clear        ]
;; [ out the string and put some initial printer control characters            ]
;; [ into it.                                                                  ]
;; [---------------------------------------------------------------------------]

PCLPRT-OPEN: does [
    PCLPRT-FILE: copy ""
    append PCLPRT-FILE PCLPRT-RESET
    append PCLPRT-FILE PCLPRT-LINE-TERMINATION
    PCLPRT-LINE-COUNT: 0
]

;; [---------------------------------------------------------------------------]
;; [ This procedure "closes" the print "file," which means we will             ]
;; [ put the appropriate printer reset characters at the end of the            ]
;; [ string and write it to the printer.                                       ]
;; [---------------------------------------------------------------------------]

PCLPRT-CLOSE: does [
    append PCLPRT-FILE PCLPRT-RESET
    PCLPRT-PRINTER-PATH: rejoin [
        PCLPRT-SERVER
        PCLPRT-PRINTER
    ]
    write/binary PCLPRT-PRINTER-PATH PCLPRT-FILE
]

;; [---------------------------------------------------------------------------]
;; [ This procedure causes a page skip by putting a form-feed character        ]
;; [ into the file.                                                            ]
;; [---------------------------------------------------------------------------]

PCLPRT-EJECT: does [
    append PCLPRT-FILE PCLPRT-FORMFEED 
    PCLPRT-LINE-COUNT: 0
]

;; [---------------------------------------------------------------------------]
;; [ This procedure "prints" a line passed to it, which means we will          ]
;; [ append the passed line to the file, and add a newline.                    ]
;; [ The refinement of "double" puts an extra newline at the end for           ]
;; [ double spacing.                                                           ]
;; [---------------------------------------------------------------------------]

PCLPRT-PRINT: func [
    PCLPRT-PRINT-LINE
    /DOUBLE
] [
    append PCLPRT-FILE PCLPRT-PRINT-LINE
    append PCLPRT-FILE newline
    PCLPRT-LINE-COUNT: PCLPRT-LINE-COUNT + 1
    if DOUBLE [
        append PCLPRT-FILE newline
        PCLPRT-LINE-COUNT: PCLPRT-LINE-COUNT + 1
    ]
]

;; [---------------------------------------------------------------------------]
;; [ Here is a separate procedure for sending the printer-reset codes.         ]
;; [---------------------------------------------------------------------------]

PCLPRT-RESET-PRINTER: does [
    append PCLPRT-FILE PCLPRT-RESET 
]

;; [---------------------------------------------------------------------------]
;; [ This procedure sets the font, etc., to a line-printer style.              ]
;; [ To find out what characters to use, use the control panel on the          ]
;; [ printer to get the PCL font list.  On the list are the exact escape       ]
;; [ sequences needed.                                                         ]
;; [---------------------------------------------------------------------------]

PCLPRT-SET-LINEPRINTER: does [
    append PCLPRT-FILE PCLPRT-LANDSCAPE
    append PCLPRT-FILE PCLPRT-FONT-LINEPRINTER
    append PCLPRT-FILE PCLPRT-MARGIN-LEFT-5
    append PCLPRT-FILE PCLPRT-MARGIN-TOP-4
    append PCLPRT-FILE PCLPRT-LPI-8
]

;; [---------------------------------------------------------------------------]
;; [ This procedure emits the characters to set the orientation to             ]
;; [ landscape.                                                                ]
;; [---------------------------------------------------------------------------]

PCLPRT-SET-LANDSCAPE: does [
    append PCLPRT-FILE PCLPRT-LANDSCAPE
]

;; [---------------------------------------------------------------------------]
;; [ The procedures below use the procedures above for printing in a           ]
;; [ classic COBOL manner.  They print headings automatically, check for       ]
;; [ page skips, and so on.                                                    ]
;; [ The caller of this module should "do" it early in the program to define   ]
;; [ the items below, and then set the following items to desired values:      ]
;; [ LP-PROGRAM:  Name of the program making the report.                       ]
;; [ LP-REPORT:   50-character report description.                             ]
;; [ LP-SUBTITLE: not used until we figure out how to center it.               ] 
;; [ What these procedures are going to give you is a report of text lines     ]
;; [ in a fixed-width font, like the line printer of the COBOL days.           ]
;; [ At the beginning of your program, call PCLPRT-LP-OPEN.                    ]
;; [ During your program, format a print line and call:                        ]
;; [     PCLPRT-LP-PRINT <your-pre-formatted-print-line>                       ]
;; [ At the end of your program, call PCLPRT-LP-CLOSE.                         ]
;; [---------------------------------------------------------------------------]

;; -- Items to be loaded before first use
PCLPRT-LP-PROGRAM: ""
PCLPRT-LP-REPORT: ""
PCLPRT-LP-SUBTITLE: ""
PCLPRT-LP-PAGE-COUNT: 1
PCLPRT-LP-TITLE: copy PCLPRT-INSTALLATION-NAME ;; will be at top of report
PCLPRT-LP-HEADING-1: ""
PCLPRT-LP-HEADING-2: ""
PCLPRT-LP-USER-HEADING-1: ""  ;;-+ 
PCLPRT-LP-USER-HEADING-2: ""  ;; |-> up to three report heading lines 
PCLPRT-LP-USER-HEADING-3: ""  ;;-+
PCLPRT-LP-USER-HEADING-COUNT: 0
PCLPRT-LP-PROG-LGH: 0
PCLPRT-LP-REPT-LGH: 0
PCLPRT-LP-PROG-20: ""  ;; program name chopped off at or padded to 20 
PCLPRT-LP-REPT-50: ""  ;; report name chopped off at or padded to 50

;; -- Helper functions for the main printing functions
PCLPRT-SUBSTRING: func [
    "Return a substring from the start position to the end position"
    INPUT-STRING [series!] "Full input string"
    START-POS    [number!] "Starting position of substring"
    END-POS      [number!] "Ending position of substring"
] [
    if END-POS = -1 [END-POS: length? INPUT-STRING]
    return skip (copy/part INPUT-STRING END-POS) (START-POS - 1)
]

PCLPRT-FILLER: func [
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

PCLPRT-SPACEFILL: func [
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
        FINAL-PADDED-STRING: PCLPRT-SUBSTRING TRIMMED-STRING 1 FINAL-LENGTH
    ]
]

;; -- Main printing functions 
PCLPRT-LP-PRINT-USER-HEADINGS: does [
    PCLPRT-LP-USER-HEADING-COUNT: 0
    if (PCLPRT-LP-USER-HEADING-1 <> "") [
        PCLPRT-PRINT PCLPRT-LP-USER-HEADING-1
        PCLPRT-LP-USER-HEADING-COUNT: PCLPRT-LP-USER-HEADING-COUNT + 1
    ]
    if (PCLPRT-LP-USER-HEADING-2 <> "") [
        PCLPRT-PRINT PCLPRT-LP-USER-HEADING-2
        PCLPRT-LP-USER-HEADING-COUNT: PCLPRT-LP-USER-HEADING-COUNT + 1
    ]
    if (PCLPRT-LP-USER-HEADING-3 <> "") [
        PCLPRT-PRINT PCLPRT-LP-USER-HEADING-3
        PCLPRT-LP-USER-HEADING-COUNT: PCLPRT-LP-USER-HEADING-COUNT + 1
    ]
    if (PCLPRT-LP-USER-HEADING-COUNT > 0) [
        PCLPRT-PRINT ""
    ]
] 
  
PCLPRT-LP-OPEN: does [
    PCLPRT-OPEN
    PCLPRT-SET-LINEPRINTER
    PCLPRT-LP-PAGE-COUNT: 1
    PCLPRT-LP-PROG-LGH: length? PCLPRT-LP-PROGRAM
    either (PCLPRT-LP-PROG-LGH >= 20) [
        PCLPRT-LP-PROG-20: PCLPRT-SUBSTRING PCLPRT-LP-PROGRAM 1 20
    ] [
        PCLPRT-LP-PROG-20: PCLPRT-SPACEFILL PCLPRT-LP-PROGRAM 20
    ]
    PCLPRT-LP-REPT-LGH: length? PCLPRT-LP-REPORT
    either (PCLPRT-LP-REPT-LGH >= 50) [
        PCLPRT-LP-REPT-50: PCLPRT-SUBSTRING PCLPRT-LP-REPORT 1 50
    ] [
        PCLPRT-LP-REPT-50: PCLPRT-SPACEFILL PCLPRT-LP-REPORT 50
    ]
    PCLPRT-LP-HEADING-1: rejoin [
        PCLPRT-LP-PROG-20
        PCLPRT-FILLER 43
        PCLPRT-LP-TITLE
        PCLPRT-FILLER 52
        now/date
    ]
    PCLPRT-LP-HEADING-2: rejoin [
        PCLPRT-LP-REPT-50
        PCLPRT-FILLER 13
        PCLPRT-FILLER 39    ;; subtitle, eventually
        PCLPRT-FILLER 52
        "Page "
        to-string PCLPRT-LP-PAGE-COUNT
    ]
    PCLPRT-PRINT PCLPRT-LP-HEADING-1
    PCLPRT-PRINT/DOUBLE PCLPRT-LP-HEADING-2
    PCLPRT-LP-PRINT-USER-HEADINGS
]

PCLPRT-LP-CLOSE: does [
    PCLPRT-CLOSE
]

PCLPRT-LP-PRINT: func [
    PCLPRT-LP-PRINT-LINE
    /DOUBLE  ;; not used at this time 
] [
    if (PCLPRT-LINE-COUNT >= PCLPRT-PAGE-SIZE) [
        PCLPRT-LINE-COUNT: 0
        PCLPRT-LP-PAGE-COUNT: PCLPRT-LP-PAGE-COUNT + 1
        PCLPRT-LP-HEADING-2: copy ""
        PCLPRT-LP-HEADING-2: rejoin [
            PCLPRT-LP-REPT-50
            PCLPRT-FILLER 13
            PCLPRT-FILLER 39    ;; subtitle, eventually
            PCLPRT-FILLER 52
            "Page "
            to-string PCLPRT-LP-PAGE-COUNT
        ]
        PCLPRT-EJECT
        PCLPRT-PRINT PCLPRT-LP-HEADING-1 
        PCLPRT-PRINT/DOUBLE PCLPRT-LP-HEADING-2
        PCLPRT-LP-PRINT-USER-HEADINGS
    ]
    PCLPRT-PRINT PCLPRT-LP-PRINT-LINE
]
    
    
    
