REBOL [
    Title: "Save to Mailbox File"
    Date: 10-Sep-1999
    File: %mailboxsave.r
    Purpose: {
        This example reads email and appends it to a standard
        mailbox file (which can be read by most email apps).
    }
    Note: {
        Set the remove-mail flag true if you want to delete
        the email from your server as it is saved.
        See the popspec.r file for examples of how
        to setup your mailbox connection.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [email file-handling other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

remove-mail: false

file: %inbox.mbx
days: [Mon Tue Wed Thu Fri Sat Sun]
months: [Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]
pad: [#"0" ""]
spc: #" "

inbox: open load %popspec.r  ;file contains POP email box info
print [length? inbox "messages"]
when: now

while [not tail? inbox] [
    mail: import-email message: first inbox
    write/append file rejoin [
        "From " mail/from spc
        pick days when/weekday spc
        pick months when/month spc
        pick pad when/day < 10  when/day spc
        pick pad when/time < 10:00  when/time spc
        when/year
        newline first inbox newline
    ]
    either remove-mail [remove inbox][inbox: next inbox]
]

close inbox
