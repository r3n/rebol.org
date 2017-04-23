REBOL [
    Title: "Simple Emailer"
    Date: 24-Oct-1998
    File: %simple-mail.r
    Author: "Klaus Matuschek"
    Purpose: {
        A simple script, which uses the e-mail capabilities
        of REBOL in a more user friendly way.
    }
    Comment: {
        The user's email address must have been set up in %user.r prior
        to running this script.

        i.e.  system/user/email: user@domain.com
              system/schemes/default/host: "mail.domain.com"
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

; Input e-mail-adress request
receiver: to-email ask "Mail To: "

; Input subject
if (subj: ask "Subject: ") = "" [subj: "(None)"]

; Set up header information
header: make system/standard/email [from: system/user/email subject: subj]

print "Edit Message Text (End it by typing . in a seperated line.) :"

message: ""
temp: ""

; Reads the mail-message from the standard-input until the user quits
; with the specified ending sequence

while [not temp = "."][
    temp: ask "> "
    append message temp
    append message newline
]

remove/part tail message -2

; last chance to quit your intention
either (ask "^/Send mail (y/n)? ") = "y" [
    print ["Sending mail to " receiver]
    send/header receiver message header
][
    print "Sending cancelled !"
]
