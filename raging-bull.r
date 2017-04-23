REBOL [
    Title: "Raging Bull page downloader"
    Date: 16-Sep-1999
    File: %raging-bull.r
    Author: "Jim Goodnow II"
    Purpose: {
        This script reads sequential pages from the
        Raging-Bull on-line bulletin board.
    }
    Note: {
        It parses the HTML page looking for the author and
        the text of the message. It then appends that
        information to an HTML page that is created. The idea
        is to allow much quicker scanning of the new posts to
        the bulletin board without having to hit click on the
        NEXT button and wait for each page to load. The last
        number read is saved in a text file that is loaded
        before reading pages and then written at the end.
    }
    library: [
        level: 'advanced 
        platform: none 
        type: [tool tutorial] 
        domain: [web markup text-processing] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

secure none

; load the next message number to read
; if not found, start at one and only read 10 messages, else read up to 50

either error? start: try [ load %amazon.txt ][
    start: 1
    max-msg: start + 10
] [
    max-msg: start + 50
]

; modify the AMZN below to the particular stock board you are interested in

addr: http://www.ragingbull.com/mboard/boards.cgi?board=AMZN&read=

f: open/new %amazon.html        ; this is where the output will go
append f "<html><body>^/"
whos: copy []
txts: copy []

while [ true ] [
    a: rejoin [ addr start ]
    print [ "reading" a ]

    ; if we get an error reading, just stop
    if error? try [ page: read a ][ break ]

    ; or if the parse fails, stop in case it's a page not found result
    ; So, the following skips over all the HTML till the ">By:" is found.
    ; Skips to the next HTML tag, copys the name to the WHO variable.
    ; Then it skips to the next TABLE tag and copys thru the end of the
    ; table to the TXT variable. Then it skips to the end.
    if not parse page [to ">By:" to "<" "<" thru ">" copy who to "<"
            to "<TABLE" copy txt thru "/TABLE>"
            to end ][ break ]

    ; display the message number followed by the author, followed by the
    ; message itself
    append f reduce [ start " By: " who "<BR>" txt "<BR>" ]

    ; bump the message number and if at max, stop
    start: start + 1
    if start = max-msg [ break ]
]

; save the new starting message number
save %amazon.txt start

; close out the document
append f "</body></html>^/"
close f
quit

