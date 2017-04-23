REBOL [
    Title: "Digital Clock"
    Date: 2-Apr-2001
    Version: 1.2.0
    File: %clock.r
    Author: "Carl Sassenrath"
    Purpose: "Displays a simple digital clock in its own window."
    Email: carl@rebol.com
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

view layout [
    origin 0
    banner "00:00:00" rate 1 effect [gradient 0x1 0.0.150 0.0.50]
        feel [engage: func [face act evt] [face/text: now/time  show face]]
]

