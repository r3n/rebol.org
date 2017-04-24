REBOL [
    Title: "Email Headers"
    Date: 10-Sep-1999
    File: %mailheader.r
    Purpose: "Send email with a custom header."
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

header: make system/standard/email [
    To: luke@rebol.com
    From: han@rebol.com
    Reply-To: han@rebol.com
    Subject: "Testing this!"
    Organization: "REBOL Base"
    X-mailer: [REBOL] 
    MIME-Version: 1.0 
    Content-Type: "text/plain"
]

message: {
Just testing scripts again...

-han
}

send/header luke@rebol.com message header
