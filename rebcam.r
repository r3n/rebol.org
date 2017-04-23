REBOL [
    Title: "REBOL Vision"
    Date: 22-May-2001
    Version: 1.0.1
    File: %rebcam.r
    Author: "Allen Kamp"
    Purpose: {Fetch Webcam image at a specified refresh interval.}
    Email: allenk@powerup.com.au
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [GUI other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

main-face: layout [
    origin 0 size 640x480
    webcam: image 640x480 make image! 640x480 rate 0:05 top center font-size 16
]

webcam/feel: make webcam/feel [
    engage: func [f a e] [
        f/text: "Updating..."
        show f
        f/image: load http://demo.rebol.net/webcam/webcam.jpg
        f/text: none
        show f
    ]
]

view main-face
