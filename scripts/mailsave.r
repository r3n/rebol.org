REBOL [
    Title: "Save Email to File"
    Date: 10-Sep-1999
    File: %mailsave.r
    Purpose: {
        This example reads all email and saves it to a file.
    }
    Note: {
        Does not remove the mail from the server.
        See the popspec.r file for examples of how
        to setup your mailbox connection.
    }
    library: [
        level: 'beginner 
        platform: none 
        type: none 
        domain: [email file-handling other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

inbox: open load %popspec.r  ;file contains POP email box info

forall inbox [
    write/append %inbox.txt first inbox
]

close inbox
