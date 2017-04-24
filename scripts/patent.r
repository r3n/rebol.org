REBOL [
    Title: "Get Patent"
    Date: 25-Nov-2001/19:11-5:00
    Version: 1.2.0
    File: %patent.r
    Author: "Bob Paddock and Astrid Sindle"
    Purpose: {Downloads various types of patents from the l2.espacenet.com server.
Normally espace forces you to download the patents one page at a time.
This script gets all of the pages for you automatically.
Shows various progress bars and time estimates.
There may be patents that this does not get because I can not
find any documentation on how l2.espacenet encodes its URL's.
If you know how to encode a specific URL please let me know
so that I can add support for it. -  bpaddock@csonline.net

The program is also example of how to use Rebol's:
    request-download
    choice[]
    ProgressBars/Time Estimates
    How to change face text on button press, and how
    to dynamically enable/disable a button.
    Real world application of Events.
}
    Email: bpaddock@csonline.net
    Web: http:///www.csonline.net/bpaddock
    library: [
        level: none 
        platform: none 
        type: 'tutorial 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

GetPatent: func [
        {
         Request a Patent Number to download from the net.
         Show progress. Displays alert box then aborts script on error.
        }
        PatentServer
    PatentNumber
    /local url page pdf-url LastPage CurrentPage GetPageURL OutputNameFILE stop PatentDownload
] [
    url: probe to-url rejoin ["http://l2.espacenet.com/dips/bnsviewnav?DB=EPD&PN=" PatentServer PatentNumber "&ID=" PatentServer "+++" PatentNumber "A1+I+"]
    page: read url

; Uncomment the following to see what the page we just got looks like:
;       print PatentServer
;       Print PatentNumber
;       print page

        not-now1: "Service is temporarily unavailable"
        if find page not-now1 [alert not-now1 quit]

        not-now2: "The document request could not be processed"
        if find page not-now2 [alert not-now2 quit]

        ; Copy 10 chars after "TOPPG=" to find the number of pages in this patent
    LastPage: to-integer second parse copy/part find page "TOTPG=" 10 "=&"
    ;LastPage: 3 ; testing
        if LastPage < 1 [alert "Zero Pages to This Patent?" quit]

    print rejoin ["There are " LastPage " pages to this Patent, downloading now:"]

    pdf-url: rejoin ["l2.espacenet.com/dips/bns.pdf?&PN=" PatentServer PatentNumber "&ID=" PatentServer "+++" PatentNumber "A1+I+&PG="]

    ; Download all of the pages in the following loop,
    ; printout the URL and the name of the file being saved as we go:
    view/new center-face PatentDownload: layout [
        title: text 300 bold red black center
        ProgressBar: progress 300x30
        across
        toggle 90 "Cancel" "Stop" [stop: true]
        stat: text 240 bold red black middle
        return
        ElapsedTimeText: text 240 bold red black center
        return
        EstimatedTimeText: text 240 bold red black center
        return
        RemainingTimeText: text 240 bold red black center
    ]
    stop: false
    ProgressBar/data: 0

    title/text: reform ["Patent " PatentNumber " has " LastPage "pages"]
    show title

    StartTime: now/time
    ElapsedTimeText/text: reform ["Start Time: " StartTime]
    show ElapsedTimeText

        ; Do{}While CurrentPageNumber <= LastPage:
    repeat CurrentPageNumber LastPage [
            wait 1 ; Required to get the 'cancel' button to work
        if stop [break]

        stat/text: reform ["Downloading Page " CurrentPageNumber " Now"]
        show stat

        GetPageURL: probe to-url rejoin ["http://" pdf-url to-string CurrentPageNumber]
        OutputNameFILE: probe to-file rejoin [PatentServer PatentNumber "pg" CurrentPageNumber ".pdf"]

        ; Don't get pages that we do not need:
        if not exists? OutputNameFILE [
                    local-file: OutputNameFILE
                    if not request-download/to GetPageURL local-file [
                        alert "Download failed or canceled." quit
                    ]
        ]

        ProgressBar/data: ProgressBar/data + (1 / LastPage)

        elapsed: now/time - StartTime
        estimated: elapsed * ((LastPage + 1) / CurrentPageNumber)

        ElapsedTimeText/text:   reform ["Elapsed Time: "   elapsed]
        EstimatedTimeText/text: reform ["Estimated Time: " estimated]
        RemainingTimeText/text: reform ["Remaining Time: " estimated - elapsed]

        show [stat ProgressBar ElapsedTimeText EstimatedTimeText RemainingTimeText]
    ] ; Repeat
    unview/only PatentDownload
    print "Leaving GetPatent"
] ; GetPatent

view layout [
    backdrop 30.40.100 effect [grid 10x10]
    origin 40x20

    help-lbl: h2 white "Select Patent Server:"
    help-lbl-2: h3 white "" 200

    PatentServer: choice "Select" "EP" "US" "WO"
    [
        switch PatentServer/text [
            "Select" [ help-lbl/text: "Select patent server:"
                       help-lbl-2/text: ""
                     ]
            "US"     [ help-lbl/text: "Download US Patent:"
      help-lbl-2/text: "e.g. 4215330 or 6163242"
                     ]
            "WO"     [ help-lbl/text: "Download PCT Application [WO]:"
                       help-lbl-2/text: "e.g. 0177456 or 9912345"
                     ]
            "EP"     [ help-lbl/text: "Download EP Application:"
                       help-lbl-2/text: "e.g. 0234567 (7 digit)"
                     ]
        ]
        show help-lbl
        show help-lbl-2
    ]

    msg: field "Enter number here..." 210
    text white "Press button to retrieve patent:"
    across return
    button "Get Patent" [
        if all [not equal? msg/text "Enter number here..." not equal? PatentServer/Text "Select"][
                GetPatent PatentServer/text msg/text
        ]
    ]
    return

    button "Quit" [quit]
]
do-events
                                                                                                                                                               