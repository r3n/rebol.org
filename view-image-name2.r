REBOL [
    Title: "View an Image behind File Name"
    Date: 1-Jun-2000
    File: %view-image-name2.r
    Purpose: "Display an image with its file name on top of it."
    Note: {This script assumes your image is in the local directory.}
    library: [
        level: 'beginner 
        platform: none 
        type: 'one-liner 
        domain: [graphics GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

file: %bay.jpg

view layout [image file form file]

