REBOL [
    Title: "Email Auto-reply"
    Date: 10-Sep-1999
    File: %mailautoreply.r
    Purpose: {
        This example confirms email received from
        "friends" only.  All others will be ignored.
    }
    Note: {
        Will not reply to email from itself.
        Does not remove the mail from the server.
        You can use wildcards in the email names.
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

friends: [elvis@earth.net jobs@apple.com *@rebol.*]

inbox: open load %popspec.r  ;file contains POP email box info

forall inbox [
    mail: import-email message: first inbox
    foreach friend friends [
        if all [
            mail/from/1 <> system/user/email
            find/match/any mail/from/1 friend
        ][
            send first mail/from join "Got your email." [
                newline "With subject: " mail/subject newline
            ]
        ]
    ]
]

close inbox
