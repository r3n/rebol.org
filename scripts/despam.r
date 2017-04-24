REBOL [
    Title: "Email Spam Filter"
    Date: 6-Jun-1999
    File: %despam.r
    Author: "Scrip Rebo"
    Purpose: {
        Filters spam by removing all messages from your
        incoming email that were not sent directly to you.
        Valid email is not affected and remains on server.
    }
    Note: "Deletes email.  Use at your own risk."
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

;-- Email sent to these addresses is not considered spam:
accept-to: [rebo@ober.dom coder@inet.dom]

do %secrets.r  ; obtain user and pass

mailbox: open join pop:// [user ":" pass "@mail.server.dom"]

print [length? mailbox "messages on server"]

list: make block! 10

while [not tail? mailbox] [
    mail: import-email first mailbox
    clear list
    if mail/to  [append list mail/to]
    if mail/cc  [append list mail/cc]
    if mail/bcc [append list mail/bcc]
    either foreach name accept-to [
        if find list name [break/return true]
        false
    ][
        mailbox: next mailbox
    ][
        print ["removing spam from" mail/from]
        mailbox: remove mailbox
    ]
]

close mailbox
