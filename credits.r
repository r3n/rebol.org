REBOL [
    Title: "Scrolling Movie Credits"
    Date: 16-May-2001
    Version: 1.0.1
    File: %credits.r
    Author: "Carl Sassenrath"
    Purpose: {Displays scrolling credits over an image. (Most of
this example is the text for the credits.)
}
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

pic: load-thru/binary http://www.rebol.com/view/bay.jpg

roller: layout [
    backdrop pic effect [multiply 60.20.30 fit]
    text center bold 240x30 "REBOL, The Movie" yellow font [size: 16]
    credits: text white bold center 240x180 rate 30 para [origin: 0x+100]
        feel [engage: func [f a e] [
            if a = 'time [f/para/origin: f/para/origin - 0x1 show f]
        ]
    ]
]

credits/text: {

Edit This File

To Add Your Own Credits


It is very simple to do.

Only takes a minute.



Only REBOL Makes It Possible...

}

view roller