Rebol [
    Title: "Image viewer"
    Date: 20-Jul-2003
    File: %oneliner-image-viewer.r
    Purpose: {Displays a picture in a window. Click on it to select another one.}
    One-liner-length: 132
    Version: 1.0.0
    Author: "Vincent Ecuyer"
    Library: [
        level: 'beginner
        platform: none
        type: [How-to FAQ one-liner]
        domain: [vid gui file-handling]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
view l: layout[origin 0x0 b: box "Load" [error? try [b/image: i: load first request-file b/text: "" l/size: b/size: i/size show l]]]
