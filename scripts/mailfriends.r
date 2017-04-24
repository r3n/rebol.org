REBOL [
    Title: "Email Friend Monitor"
    Date: 10-Sep-1999
    File: %mailfriends.r
    Purpose: {
        This example displays messages that come from
        "friends" only.  All others will be ignored.
    }
    Note: {
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
        if find/match/any mail/from/1 friend [print message]
    ]
]

close inbox
