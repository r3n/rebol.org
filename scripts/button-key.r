REBOL [
    Title: "A Button with Shortcut Key"
    Date: 1-Jun-2000
    File: %button-key.r
    Purpose: {Shows how to easily add a shortcut key to a button.}
    library: [
        level: 'beginner 
        platform: none 
        type: [How-to FAQ one-liner] 
        domain: [GUI VID] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

view layout [button "Quit" #"q" [quit]]
