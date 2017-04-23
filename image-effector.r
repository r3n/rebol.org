Rebol [
    title: "Image Effector"
    date: 29-june-2008
    file: %image-effector.r
    purpose: {
        A simple GUI demo application.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

effect-types: ["Invert" "Grayscale" "Emboss" "Blur" "Sharpen" "Flip 1x1" "Rotate 90" "Tint 83" "Contrast 66" "Luma 150" "None"] 
image-url: to-url request-text/title/default {Enter the url of an image to use:} trim {http://rebol.com/view/demos/palms.jpg}
gui: [
    across
    space -1 
    at 20x2 choice 160 tan trim {
        Save Image} "View Saved Image" "Download New Image" trim {-------------} "Exit" [
        if value = "Save Image" [ 
            filename: to-file request-file/title/file/save trim {Save file as:} "Save" %/c/effectedimage.png
            save/png filename to-image picture
        ]
        if value = "View Saved Image" [
            view-filename: to-file request-file/title/file trim {View file:} "Save" filename
            view/new center-face layout [image load view-filename]
        ] 
        if value = "Download New Image" [
            new-image: load to-url request-text/title/default trim {Enter a new image url} trim {http://www.rebol.com/view/bay.jpg}
            picture/image: new-image
            show picture ; update the GUI display
        ]
        if value = "-------------" [] ; don't do anything
        if value = "Exit" [quit]       
    ]
    choice tan "Info" "About" [alert "Image Effector - Copyright 2005, Nick Antonaccio"]
    below
    space 5
    pad 2
    box 550x1 white
    pad 10
    vh1 "Double click each effect in the list on the right:"     
    return
    across

    picture: image load image-url

    text-list data effect-types [
        current-effect: to-string value 
        picture/effect: to-block form current-effect 
        show picture
    ]
]

view/options center-face layout gui [no-title] 
