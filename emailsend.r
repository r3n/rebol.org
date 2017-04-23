REBOL [
    Title: "Send Email with Buttons"
    Date: 20-May-2000
    File: %emailsend.r
    Purpose: {
        A very simple email sending application that
        shows how text is input and buttons are used.
    }
    library: [
        level: 'beginner 
        platform: none 
        type: none 
        domain: [GUI email] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

view layout [
    backdrop 30.40.100 effect [grid 10x10]
    origin 40x20
    h2 white "Send REBOL Email:"
    msg: field "Type a message here..." 210x50
    text white "Send to:"
    across return
    button "Docs" [send docs@rebol.com msg/text]
    button "Carl" [send carl@rebol.com msg/text]
    return
    button "Webmaster" [send webmaster@rebol.com msg/text]
    button "Cancel" [quit]
]
