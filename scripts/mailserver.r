REBOL [
    Title: "Trivial Email List Server"
    Date: 10-Sep-1999
    File: %mailserver.r
    Purpose: "As simple as a list server gets."
    Note: {
        When email is received from particular address in the
        group, it will be sent to everyone in that group. The
        email that was sent is removed from the mailbox.
        Other email is left alone. Waits 10 minutes between
        each check for email.  Press ESCAPE to stop.
        Warning: don't put the address of the email server
        in the group or it will go into an infinite loop!
    }
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'Tool 
        domain: [email other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

group: [luke@rebol.com hans@falcon.dom]

popspec: load %popspec.r  ;file contains POP email box info

if find group system/user/email [print "Email loop detected!" halt]

forever [
    inbox: open popspec
    while [not tail? inbox] [
        mail: import-email message: first inbox
        either find group mail/from/1 [
            foreach user group [resend user system/user/email message]
            remove inbox
        ][inbox: next inbox]
    ]
    close inbox
    wait 0:10
]
