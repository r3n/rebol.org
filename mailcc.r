REBOL [
    Title: "Email Send With CC"
    Date: 10-Sep-1999
    File: %mailcc.r
    Purpose: {
        Example of how to include CC addresses on an email
        header.
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

to: luke@rebol.com
cc: [fredrika@nab.dom dominica@ban.dom]

header: make system/standard/email compose [
    from: (system/user/email)
    to: (to)
    cc: (reduce [cc])
    subject: "Test message."
]

message: {
Hang loose.  Just testing a script example.

-Mendo
}

send/header/only join cc to message header