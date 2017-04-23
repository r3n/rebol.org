REBOL [
    Title: "Email Ping (Confirmation)"
    Date: 10-Sep-1999
    File: %mailping.r
    Purpose: "Confirm certain email that contains a key word."
    Note: {
        Autoreplies to email when subject line contains a special word.
        Does not remove the mail from the server.
        See the popspec.r file for examples of how
        to setup your mailbox connection.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [email other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

magic-word: "confirm!" ; must appear somewhere on subject line

inbox: open load %popspec.r  ;file contains POP email box info

forall inbox [
    mail: import-email first inbox
    if find mail/subject magic-word [
        send first mail/from join "Got it." [
            newline "Got your email: " mail/subject newline
        ]
    ]
]

close inbox

