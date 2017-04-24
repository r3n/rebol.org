REBOL [
    Title: "Display Black Text"
    Date: 1-Jun-2000
    File: %black-text.r
    Purpose: "Display black text on a white background."
    library: [
        level: 'beginner 
        platform: none 
        type: 'How-to 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

view layout [
    backdrop white
    text 800x600 read http://www.rebol.com font [color: black shadow: 0x0]
]

