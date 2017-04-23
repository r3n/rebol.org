Rebol [
    title: "Simple Multitasking Example"
    date: 29-june-2008
    file: %simple-multitasking.r
    purpose: {
        A simple example demonstrating multitasking using 'feel and 'rate.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

webcam-url: http://209.165.153.2/axis-cgi/jpg/image.cgi
view layout [
    across 
    btn "Start Camera 1" [
        webcam/rate: 0 
        webcam/image: load webcam-url 
        show webcam
    ]
    btn "Stop Camera 1" [webcam/rate: none show webcam]
    btn "Start Camera 2" [
        webcam2/rate: 0 
        webcam2/image: load webcam-url 
        show webcam2
    ]
    btn "Stop Camera 2" [webcam2/rate: none show webcam2]
    return 
    webcam: image load webcam-url 320x240 rate 0 feel [
        engage: func [face action event][
            if action = 'time [
                face/image: load webcam-url show face
            ] 
        ] 
    ]
    webcam2: image load webcam-url 320x240 rate 0 feel [
        engage: func [face action event][
            if action = 'time [
                face/image: load webcam-url show face
            ] 
        ] 
    ] 
]