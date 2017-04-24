REBOL [
    File: %core-email.r
    Date: 9-Oct-2009
    Title: "Core Email"
    Author:  Nick Antonaccio
    Purpose:  {
 
         A simple email program that can run in REBOL/Core - entirely
          at the command line (no VID GUI components or View graphics 
          are required).  You can store configuration information for as
          many email accounts as you'd like in the "accounts" block, and
          easily switch between them at any point in the program.

         Taken from the tutorial at http://musiclessonz.com/rebol.html
    }
]

accounts: [
    ["pop.server" "smtp.server" "username" "password" you@site.com]
    ["pop.server2" "smtp.server2" "username" "password" you@site2.com]
    ["pop.server3" "smtp.server3" "username" "password" you@site3.com]
]

empty-lines: "^/"
loop 400 [append empty-lines "^/"]  ; # of lines it takes to clear screen
cls: does [prin {^(1B)[J}]
a-line:{*****************************************************************}
b-line: replace/all copy a-line "*" "-"

select-account: does [
    cls
    print b-line
    forall accounts [
        print rejoin ["^/" index? accounts ":  " last first accounts]
    ]
    print join "^/" b-line
    selected: ask "^/Select an account #:  "
    if selected = "" [selected: 1]
    t: pick accounts (to-integer selected)
    system/schemes/pop/host:  t/1
    system/schemes/default/host: t/2
    system/schemes/default/user: t/3 
    system/schemes/default/pass: t/4 
    system/user/email: t/5
]
send-email: func [/reply] [
    cls
    print rejoin [b-line "^/^/Send Email:^/^/" b-line] 
    either reply [
        print join "^/^/Reply-to:  " addr: form pretty/from
    ] [
        addr: ask "^/^/Recipient Email Address:  "
    ]
    either reply [
        print join "^/Subject:  " subject: join "re: " form pretty/subject
    ] [
        subject: ask "^/Email Subject:  "
    ]
    print {^/Body (when finished, type "end" on a seperate line):^/}
    print join b-line "^/"
    body: copy ""
    get-body: does [
        body-line: ask ""
        if body-line = "end" [return]
        body: rejoin [body "^/" body-line]
        get-body
    ]
    get-body
    if reply [
        rc: ask "^/Quote original email in your reply (Y/n)?  "
        if ((rc = "yes") or (rc = "y") or (rc = "")) [
            body: rejoin [
                body 
                "^/^/^/--- Quoting " form pretty/from ":^/"
                form pretty/content
            ]
        ]
    ]
    print rejoin ["^/" b-line "^/^/Sending..."]
    send/subject to-email addr body subject 
    cls 
    print "Sent^/" 
    wait 1
]
read-email: does [
    pretty: none
    cls
    print "One moment..."
    mail: open to-url join "pop://" system/user/email
    cls
    while [not tail? mail] [
        print "Reading...^/"
        pretty: import-email (copy first mail)
        either find pretty/subject "***SPAM***" [
            print join "Spam found in message #" length? mail
            mail: next mail
        ][
            print empty-lines
            cls
            prin rejoin [
                b-line
                {^/The following message is #} length? mail { from:  } 
                system/user/email {^/} b-line {^/^/}
                {FROM:     } pretty/from {^/}
                {DATE:     } pretty/date {^/}
                {SUBJECT:  } pretty/subject {^/^/} b-line
            ]
            confirm: ask "^/^/Read Entire Message (Y/n):  "
            if ((confirm = "y") or (confirm = "yes") or (confirm = "")) [
                print join {^/^/} pretty/content
            ]
            print rejoin [
                {^/} b-line {^/}
                {^/[ENTER]:  Go Forward  (next email)^/}
                {^/    "b":  Go Backward (previous email)^/}
                {^/    "r":  Reply to current email^/}
                {^/    "d":  Delete current email^/}
                {^/    "q":  Quit this mail box^/}
                {^/  Any #:  Skip forward or backward this # of messages}
                {^/^/} b-line {^/}
            ]
            switch/default mail-command: ask "Enter Command:  " [
                ""  [mail: next mail]
                "b" [mail: back mail]
                "r" [send-email/reply]
                "d" [
                    remove mail
                    cls 
                    print "Email deleted!^/" 
                    wait 1
                ]
                "q" [
                    close mail
                    cls
                    print"Mail box closed^/"
                    wait 1 
                    break
                ]
            ] [mail: skip mail to-integer mail-command]
            if (tail? mail) [mail: back mail]
        ]
    ]
]

select-account

forever [
    cls
    print b-line
    print rejoin [
        {^/"r":  Read Email^/}
        {^/"s":  Send Email^/}
        {^/"c":  Choose a different mail account^/}
        {^/"q":  Quit^/}
    ]
    print b-line
    response: ask "^/Select a menu choice:  "
    switch/default response [
        "r" [read-email]
        "s" [send-email]
        "c" [select-account]
        "q" [
            cls
            print "DONE!"
            ; print rejoin [b-line "^/^/DONE!^/^/" b-line]
            wait .5 
            quit
        ]
    ] [read-email]
]