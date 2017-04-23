REBOL [
    Title: "Cellphone reminder"
    Date: 16-Jun-2000
    Version: 0.2
    File: %remind.r
    Author: "Graham Chiu"
    Purpose: {
        Reads a file 'data.txt' containing appointment data, and sends 
        my cell phone a text message 5 minutes before the appointment.
    }
    Comment: {
        The data.txt file can be manually updated, but 'remind' also polls a
        pop mail box daily for messages with 'add' in the subject line.
        If present, it appends the first line of the message body 
        to the data.txt file.

        data occurs in the following format per line

        period time description 

        period ( there are no daily reminders - use your brain! )
        - weekday, then is a weekly reminder
        - day, then is a monthly reminder
        - month, then is a yearly reminder
        - date, then is a one off reminder

        time
        is a time string, or in the case of yearly reminders, a day of the
        month.  With yearly reminders, the message is sent at 8 am.

    The following is sample data.

    "Friday" 19:30 "Farscape Ch2"
    20 9:00 {PAYE returns}
    "December" 25 {Xmas is coming}
    1/1/2000 9:00 {New Millenium?}
    1/1/2001 9:00 {Another New Millenium?}
    "Thursday" 18:00 {News Ch1}
    "Saturday" 18:00 "weekly test"

    4-Dec-99 19:00 {one off test}
    4 18:04 {monthly test}
    "December" 4 {annual test}
    "February" 30 {Will this choke?}    
    "Janvier" 1 {Test error condition}

    }
    Email: gchiu@compkarori.co.nz
    Lefts: 'GNU
    Inspiration: { Missing the second part of a two part Star Trek Voyager 
        episode because I tuned into the wrong channel was the mother of
        this script. }
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: [file-handling other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

secure none

do %mycellphone.r

; uncomment this if you just want to test
; call-cellphone: func [message] [
;   print join "Cellphone: at " [ now " " message ]
; ]

weekday: ["Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" "Sunday" ]
months: [ "January" "February" "March" "April" "May" "June" "July" "August" 
    "September" "October" "November" "December" ]

weekly?: func [period] [find weekday period]

monthly?: func [period] [
    either integer? period [
        if ( ( period > 0 ) and ( period < 32)) [true] 
    ][
        false
    ] 
]

yearly?: func [period] [find months period]

oneoff?: func [period] [
    testdt: period
    either error? try [to-date testdt] [false][true]
]

weekly-today?: func [period] [
    period = pick weekday now/weekday
]

monthly-today?: func [period] [
    period = now/day 
]

oneoff-today?: func [period] [
    testdt: period
    now/date = to-date testdt
]

yearly-today?: func [month day] [
    ( month = pick months now/month )
        and
    ( day = now/day )
]

parse-data: [
    foreach [period ptime description] datafile [
        either weekly? period [
            if weekly-today? period [
                append datablock reduce [ptime description]
            ]
        ][
            either monthly? period [
                if monthly-today? period [
                    append datablock reduce [ptime description]
                ]
            ][
                either yearly? period [
                    if yearly-today? period ptime [
                        append datablock reduce [8:00 description]
                    ]

                ][
                    either oneoff? period [
                        if oneoff-today? period [
                            append datablock reduce [ptime description]
                        ]
                    ][
                        prin [period ptime description ]
                        print join "" [ " **data error - unrecognised period '" period "' in the data.txt" ]
                    ]
                ]
            ]
        ]
    ]
    sort/skip datablock 2
]

send-messages: [
    foreach [stime message] datablock [
        either (now/time + 00:05) > stime [
            ; less than 5 mins to scheduled event or
            ; already past the event - so go for it
            call-cellphone message
        ][
            wait ( stime - now/time - 00:05 )
            call-cellphone message
        ]
    ]
]

wait-till-2am: [
    either now/time < 2:00 [
        wait ( 2:00 - now/time )
    ][
        wait ( 24:00 - now/time + 2:00 )
    ]
]   

get-new-messages: [ 
    do wait-till-2am
    inbox: open load %popspec.r  ;file contains POP email box info
    remove-mail: true

    while [not tail? inbox] [
        mail: import-email message: first inbox
        print mail/subject
        print mail/content

        subject: trim mail/subject
        if subject = "add" [
            write %mail.txt mail/content        ; there must be an
            text: first read/lines %mail.txt    ; easier way to do this!
            text: join text newline
            write/append %data.txt text
        ]
    either remove-mail [remove inbox][inbox: next inbox]
    ]

    close inbox
]

remind: [
    print "Reminder now active ..."
    forever [
        datafile: load %data.txt    ; get the new data each day
        datablock: make block! 100  ; reinitialise the data block each day
        do parse-data               ; get the events scheduled for today
        do send-messages            ; send all the messages
        do get-new-messages         ; look for new data, and change the data.txt file
    ]
]       
