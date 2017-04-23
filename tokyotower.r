REBOL [
    Title: "Tokyo Tower Watcher"
    Date: 29-Nov-2001
    Version: 1.0.0
    File: %tokyotower.r
    Author: "graspee"
    Purpose: {To display a picture of the Tokyo Tower, updating every 60s}
    History: [29-Nov-2001 "It is begun."]
    Email: graspee@btinternet.com
    Comments: {I wrote this within an hour of first hearing about rebol so excuse sloppiness!}
    library: [
        level: 'beginner 
        platform: none 
        type: 'Demo 
        domain: [broken GUI web] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]


view layout [
    image  load-image/update http://info.nttls.co.jp/webcam/image/tower.jpg
    rate 00:01:00 feel [
        engage: func [face] [
            error? try [
                face/image: load-image/update http://info.nttls.co.jp/webcam/image/tower.jpg
                show face
                ]
            ]
    ]
]   
                         