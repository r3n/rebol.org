REBOL [
    Title: "Email Sniffer"
    Date: 10-Sep-1999
    File: %mailsniff.r
    Purpose: {
        Example of how to search all incoming email for
        particular keywords.
    }
    Note: {
        Does not remove the mail from the server.
        Any string (word) may be given, even partial words.
        Strings (words) are not case sensitive.
        FOREACH returns a value, just like other functions.
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

word-list: ["REBOL" "Luke" "messag" "language"]

inbox: open load %popspec.r  ;file contains POP email box info

forall inbox [
    mail: import-email first inbox
    foreach word word-list [
        if find mail/content word [
            print ["Found in:" mail/from mail/subject]
            break
        ]
    ]
]

close inbox

