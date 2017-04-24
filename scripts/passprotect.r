REBOL [
    Title: "Protecting Passwords"
    Date: 15-Sep-1999
    File: %passprotect.r
    Purpose: "Prompt for password to use before transfer."
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

pass: ask/hide "Password? "

data: read join ftp://user: [pass "@ftp.site.com/file"]
