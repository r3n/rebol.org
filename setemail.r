REBOL [
    Title: "EMail Setup (for Send)"
    Date: 6-Nov-1997
    File: %setemail.r
    Purpose: {
        Minimum set-up for sending email messages from REBOL.
    }
    Comment: {
        Two steps are required before email can be sent:

            1. The smtp email message port must be initialized
               by providing at least the name of an email server
               which will relay the message.

            2. The default email header must be given a "From"
               address to use in addressing the message.  This
               header will be used for all "headerless" email that
               is sent.

        ** If these lines are added to your user.r file, then email
        will be setup each time REBOL is started.
    }
    library: [
        level: 'beginner 
        platform: none 
        type: none 
        domain: [email other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

set-net [user@domain.dom mail.domain.dom]
