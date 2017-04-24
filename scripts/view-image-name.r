REBOL [
    Title: "View an Image and its File Name"
    Date: 1-Jun-2000
    File: %view-image-name.r
    Purpose: {Display an image in a window with its file name printed directly below it.}
    Note: {This script assumes your image is in the local directory.}
    library: [
        level: 'beginner 
        platform: none 
        type: [Demo one-liner] 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

file: %bay.jpg

view layout [image file  text form file]

