Rebol [
    Title: "Send email"
    Date: 20-Jul-2003
    File: %oneliner-send-email.r
    Purpose: {Simple GUI for email sending. Displays a small "ok" window when email is sent.}
    One-liner-length: 130
    Version: 1.0.0
    Author: "DocKimbel"
    Library: [
        level: 'beginner
        platform: none
        type: [How-to FAQ one-liner]
        domain: [email other-net VID]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
view layout [e: field "Email" s: field "Subject" m: area "Body" btn
"Send"[send/subject to-email e/text m/text s/text alert "ok"]]
