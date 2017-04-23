REBOL [
    Title: "Hello World Window"
    Date: 20-May-2000
    File: %hello.r
    Purpose: {Opens a window that displays text and a quit button}
    library: [
        level: 'beginner 
        platform: none 
        type: 'one-liner
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

view layout [text "Hello World!" button "Quit" [quit]]

