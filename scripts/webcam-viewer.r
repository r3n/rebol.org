Rebol [
    title: "Webcam Viewer"
    date: 29-june-2008
    file: %webcam-viewer.r
    purpose: {
        Display video feeds from live webcam servers.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

; try http://www.webcam-index.com/USA/ for more webcam links.

temp-url: "http://209.165.153.2/axis-cgi/jpg/image.cgi"
while [true]  [
    webcam-url: to-url request-text/title/default trim {
        Enter the web cam URL:} temp-url
    either attempt [webcam: load webcam-url] 
        [break]
        [either request [trim {
            That webcam is not currently available.} trim {
            Try Again} "Quit"]
            [temp-url: to-string webcam-url]
            [quit]
    ] 
] 
resize-screen: func [size] [
    webcam/size: to-pair size
    window/size: (to-pair size) + 40x72
    show window
]
window: layout [
    across 
    btn "Stop" [webcam/rate: none show webcam]  
    btn "Start" [
        webcam/rate: 0 
        webcam/image: load webcam-url 
        show webcam
    ]
    rotary "320x240" "640x480" "160x120" [
        resize-screen to-pair value 
    ]
    btn" Exit" [quit] return
    webcam: image load webcam-url  320x240 
    with [
        rate: 0
        feel/engage: func [face action event][
            switch action [
            time [face/image: load webcam-url show face]
            ] 
        ] 
    ] 
]
view center-face window