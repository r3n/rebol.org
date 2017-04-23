REBOL [
    Title: "Deluxe Email Spam Killer"
    Date: 10-Sep-1999
    File: %maildespam.r
    Purpose: {
        This is an example of a simple email filter that
        removes unwanted junk mail from your mailbox.}
    Note: {
        Deletes email from your server that has been SENT
        to you but was not ADDRESSED to you in any way.
        Specify valid addresses (like list servers) in the list.
        Wildcard addresses such as *.rebol.com are allowed.
        You will be prompted to confirm each removal.  You can
        change the script if you do not want to be prompted.
        Use at your own risk, as the email is deleted!
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

inbox: open load %popspec.r  ;file contains POP email box info

; List all valid email names for yourself. Include list servers!
valid: [luke@swr.dom *@rebol.* *@thule.no]

valid?: func ["Check for valid TO address" addresses] [
    if none? addresses [return false]
    foreach item addresses [
        if email? item [
            foreach target valid [
                if find/match/any item target [return true]
            ]
        ]
    ]
    false
]

print [length? inbox "messages"]

while [not tail? inbox][
    mail: import-email first inbox
    either any [
        valid? mail/to
        valid? mail/cc
        valid? mail/bcc
    ][inbox: next inbox][
        either confirm reform [
            "Junk mail from:" mail/from newline
            "  send to user:" mail/to newline
            "  with subject:" mail/subject newline
            "  Remove it? "
        ][next-msg: [remove inbox]][inbox: next inbox]
    ]
]

close inbox
