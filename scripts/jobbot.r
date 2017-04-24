REBOL [
    Title: "Jobbot Email Server"
    Date: 8-Sep-1999
    File: %jobbot.r
    Author: "Carl Sassenrath"
    Purpose: {
        The email server we use for processing job related
        email.
    }
    library: [
        level: 'advanced 
        platform: none 
        type: none 
        domain: [email x-file other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

test-mode: off               ; test mode (no send/save)

;---Setup options and controls:
archive:  %msgs              ; directory to hold msgs
counter:  %msgcount.txt      ; message counter
sender:   jobs@rebol.com
manager:  carl@rebol.com
target:   [brenda@rebol.net carl@rebol.com]
insiders: [  ; don't send thank you to these people
    brenda@rebol.net
    brenda@rebol.com 
    jobs@rebol.com
    carl@rebol.com
    carl@rebol.net
]

mailbox: open [ ;--- Setup mailbox message port object:
    scheme: 'pop
    host: "mail.rebol.net"
    user: "jobs"
    pass: load %theword.r
]
set-net [jobs@rebol.com mail.rebol.net]

if test-mode [ ;replace functions to prevent actual operation
    save: func [file data] [print ["saving file:" file]]
    send: func [to msgs] [print ["sending to:" to "From:" from]]
    resend: func [to from msg] [
        print ["resending to:" to "From:" from newline ];msg]
        ;confirm "Next?"
    ]
]

quit-mail: func [] [close mailbox quit]

thanks: {I got your message.

Thank you for contacting us at REBOL Technologies. We will
review your message soon.

-Jobbot
}

process-msg: func [raw-mail] [
    mail: import-email raw-mail
    if any [
        find first mail/from "MAILER-DAEMON"
        find first mail/from "postmaster"
        find first mail/from jobs@rebol
        find first mail/from list@rebol
        not any [
            find mail/to jobs@rebol.com
            find mail/to jobs@rebol.net
        ]
    ][probe mail/to exit]
    save counter count: count + 1
    save archive/:count raw-mail
    print [count "From:" mail/from "Subject:" mail/subject "Date:" mail/date]
    print who: first either mail/reply-to [mail/reply-to][mail/from]
    sub: insert find/tail raw-mail "Subject:" reduce [" #" count ": "]
    insert find sub newline reduce [newline "X-Tag: jobbot processed"]
    either find insiders who [
        print "internal"
    ][
        send who thanks
    ]
    foreach user target [resend user manager raw-mail]
]

do-jobbot: func [] [
    print now
    count: load counter
    if tail? mailbox [print "no mail" quit-mail]
    print [length? mailbox "new messages"]
    while [not tail? mailbox] [
        process-msg msg: first mailbox
        either test-mode [mailbox: next mailbox][remove mailbox]
    ]
    print [count "messages to date"]
    quit-mail
]

do-jobbot
