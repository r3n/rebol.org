REBOL [
    Title:  "Make Header Index"
    File:   %make-header-idx.r
    Author: "Gregg Irwin"
    Email:  greggirwin@mindspring.com
    Purpose: {Create the header index file for scripts in the library.}
    Type:   'link-app
    Version: 0.2.0
    History: [
        0.0.1 [29-dec-2002 {Initial Release} GSI]
        0.0.2 [16-jan-2003 {Trims time from date info} GSI]
        0.0.3 [17-jan-2003 {Uses active library files} GSI]
		0.0.4 [25-jan-2003 {Makes filenames all lowercase} GSI]
		0.0.5 [25-feb-2003 {Added /args check to avoid halt if DOne.} GSI]
		0.0.6 [02-mar-2003 {Changes spaces to hyphens in filenames.} GSI]
        0.0.7 [09-mar-2003 {Uses %scripts.lst to get list of files to index now.} GSI]
        0.0.8 [06-may-2003 {Added more error info on dump when error occurs.} GSI]
        0.1.0 [15-Jul-2003 {Adapted to run CGI or IOS or user.} Sunanda]
        0.2.0 [14-aug-2003
            {Uses system/script/args in place of shared globals now.}
            {Added default config settings if none are provided.}
            {Lots of changes for config setup. Experimental for comment.}
            {Added outer USE block since we're called from elsewhere now.}
            {Lots of code reorganization.}
            {Rolled back from gen-print to print.}
            GSI
        ]
        0.2.1 [8-Oct-2003  {Uses file timestamp rather than header/date now.} GSI]
    ]
    Comment: {
        25-feb-2003 {Moved to /support and renamed from indexer-0.r} GSI
    }
    TBD: {
        Add logging capability for remote troubleshooting?
    }
    Usage: {
        Call with do/args and pass a block containing an object spec.
        Example:
            do/args %make-header-idx.r compose [
            	;in-dir:  %../../scripts/              ; Librarian
                ;in-dir:   (join link-root %library/)  ; IOS
                %../library/scripts/                   ; CGI
                out-dir:  %./
                out-file: %header-index.rix
                script-list-file: %scripts.lst
                quiet:    true
            ]
    }
]

;; Note we can be running in one of three modes:
;; 1. as a cgi on REBOL.org -- if so, the prefs object exists
;; 2. as a script on the REBOL IOS server -- if so link-root exist
;; 3. From the unpacker of Library.r --

; Now that we're going to be called from other places, we'll try
; to be good namespace citizens.
use [ ; main USE block
    env? emit time-diff
    prefs out-data def-idx files start-time err
    hdr src idx lib couldnt-load-count error-count
    timestamp
] [


    ; == Functions ==============================================

    emit: func [line] [
        repend out-data [mold line newline]
    ]

    env?: does [
    	;;either link? ['ios][either view? ['view]['cgi]]	;; sunanda nov-2003
    	either link? ['view][either view? ['view]['cgi]] ;; sunanda nov-2003
    ]

    time-diff: func [a b] [
        ; See if the spec block for the first param in DIFFERENCE's
        ; interface will accept a date! value. This is only necessary
        ; if we want to use the native DIFFERENCE function internally
        ; on newer versions of REBOL.
        either find first find third :difference block! date! [
            difference a b
        ][
            a: either date? a [a/time][a]
            b: either date? b [b/time][b]
            a - b
        ]
    ]

;; ===============================================================
load-the-script: func [script-name
   /local
   hrd
   scr
   full-scr
][
error? try [
  set [hdr src] load/header/next script-name
  return reduce [hdr scr]
  ]

;; Okay we blew it
;; ---------------
;; But maybe that is because we are an earlier
;; version of REBOL that is trying to load a
;; script with a
;;     needs:
;; header that is later than us. Let's try
;; making that a comment, and retrying. If
;; we fail, the caller's error? try wrapper
;; will pick up the problem.


full-scr: read script-name
replace full-scr "needs:" ";needs:"
set [hdr src] load/header/next full-scr

return reduce [hdr scr]

]


    ; == Setup ==================================================

    ; Start with best-guess defaults.
    prefs: make object! [
        in-dir: switch env? [
            ios  [join link-root %library/]
            view [%../../scripts/]
            cgi  [%../library/scripts/]
        ]
        out-dir:  %./
        out-file: %header-index.rix
        script-list-file: %scripts.lst
        quiet:    false
    ]
    ; Use system/script/args to override defaults
    attempt [prefs: make prefs system/script/args]

    ;print: get in system/words either prefs/quiet ['comment]['print]
    if prefs/quiet [print: :comment]

    out-data: make string! 200'000

    def-idx: copy []
    foreach word [file size title author date version purpose library] [
        repend def-idx [word none]
    ]
    def-idx/library: copy []
    foreach word [level platform type domain tested-under support license] [
        repend def-idx/library [word none]
    ]
    ;-- Is this (below) any better? Do we see this as a good reusable function?
    ; insert-foreach: func [series value /local result] [
    ;     result: make series 2 * length? series
    ;     foreach item series [repend result [:item :value]]
    ;     result
    ; ]
    ; def-idx: insert-foreach [
    ;     file size title author date version purpose library
    ; ] none
    ; def-idx/library: insert-foreach [
    ;     level platform type domain tested-under support license
    ; ] none

    ; This assumes %scripts.lst is in the same dir we are.
    files: sort load prefs/script-list-file


    ; == Environment Checks =====================================

    print ["input  directory is " prefs/in-dir]
    print ["output file is " join prefs/out-dir prefs/out-file]
    print ["Processing" length? files "files"]

    if not all [
        exists? prefs/in-dir
        exists? prefs/out-dir
    ][
        print "One of the needed directories does not exist. Unable to continue"
    ]

    ; == Main Loop ==============================================

    start-time: now/precise
    couldnt-load-count: error-count: 0

    foreach file files [
        either error? set/any 'err try [
            set [hdr src] load-the-script prefs/in-dir/:file
        ][
            couldnt-load-count: couldnt-load-count + 1
        	print [
                "...could not load "  prefs/in-dir/:file newline
                mold disarm err
            ]
        ][
            if error? set/any 'err try [
                idx: copy/deep def-idx
                forskip idx 2 [
                    fld: idx/1
                    switch/default fld [
                        file    [idx/2: lowercase replace/all copy hdr/file " " "-"]	; added 25-jan-2003 / 2-mar-2003

                        size    [
                                 idx/2: size? prefs/in-dir/:file            ;; default: length of file
                                 error? try [idx/2: length? trim copy src]  ;; preferred: length - length of header
                                ]
                        ;date    [idx/2: hdr/date/date]	; added 16-jan-2003 - trim time from date info
                        ; 8-Oct-2003 Changed index to use file timestamp, not header date.
                        date    [
                            timestamp: modified? prefs/in-dir/:file
                            idx/2: timestamp/date
                        ]
                        library [
                            lib: idx/2
                            forskip lib 2 [
                                lib/2: none
                                error? try [lib/2: select hdr/library to set-word! lib/1]

                            ]
                        ]
                    ][idx/2: hdr/:fld]
                ]
                emit head idx
            ][
                error-count: error-count + 1
                print ["ERROR!" file fld mold disarm err]
                if not prefs/quiet [attempt [probe hdr]]
            ]
        ]
    ]


    ; == Output =================================================

    write join prefs/out-dir prefs/out-file out-data
    print [
        "Wrote file: " join prefs/out-dir prefs/out-file
        "  Length:" length? out-data newline
    ]

    ; == Finalization / Cleanup =================================

    print "Done."
    print [
        "Processing took" time-diff now/precise start-time newline
        couldnt-load-count "files couldn't be loaded"   newline
        error-count "other errors occurred" newline
    ]

] ; end of main USE block

