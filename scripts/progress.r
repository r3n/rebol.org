REBOL [
    Title: "Progress Bar"
    Date: 20-May-2000
    File: %progress.r
    Purpose: "Shows a progress bar in a dialog box."
    library: [
        level: 'beginner 
        platform: none 
        type: none 
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

progress: layout [
    text bold "Downloading the Internet"
    p: progress
    across pad 75x10
    button 60x24 "Do It" [
        loop 20 [wait .1 p/data: probe p/data + (p/size/x / 4000)  show p]
        p/data: 0
        hide-popup
    ]
    button 60x24 "Stop" [hide-popup]
]

view layout [
    button "View Progress" [inform progress]
    button "Quit" [quit]
]
