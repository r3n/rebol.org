REBOL [
    Title: "POP Email Port Spec"
    Date: 10-Sep-1999
    File: %popspec.r
    Purpose: {
        POP port specification used to connect to an email
        server. All of the mail reading examples use this.
    }
    Note: {
        You can specify either a URL or a block containing
        the necessary information to open the POP port.
        The block approach is more general, as the username
        and password can be prompted for at run time.
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

;pop://user:pass@host.com  ; use this, or use:
[
    scheme: 'pop
    user: "user"
    pass: "pass"
    ;host: "pop.server.com"  ; uncomment if needed.
]
