REBOL [
    Title: "Images Buttons"
    Date: 20-May-2000
    File: %button-image.r
    Purpose: {Example of how to make buttons made from images. Clicking on a button updates text in the window.}
    library: [
        level: 'beginner 
        platform: none 
        type: [Demo How-to] 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

pic: load-thru/binary http://www.rebol.com/view/bay.jpg

view layout [
    backdrop 40.70.140
    stat: text bold "Click a Button" 100x20 240.140.40 center
    button "Bay Test"  pic 100x100 [stat/text: "Upper" show stat]
    button "Blue Test" pic 100x100 10.30.180 [stat/text: "Lower" show stat]
]
