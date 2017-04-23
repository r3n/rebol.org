REBOL [
    Title: "Prompt for User and Password"
    Date: 15-Sep-1999
    File: %userprotect.r
    Purpose: {Prompt for username and password to use for a transfer.}
    library: [
        level: 'beginner 
        platform: none 
        type: 'tool 
        domain: [ftp other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

user: ask "Username? "
pass: ask/hide "Password? "

data: read join ftp:// [user ":" pass "@ftp.site.com/file"]
