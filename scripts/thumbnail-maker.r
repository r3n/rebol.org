REBOL [
    File: %thumbnail-maker.r
    Date: 4-sep-2009
    Title: "Thumbnail Maker"
    Author:  Nick Antonaccio
    Purpose: {
        Create image preview sheets from a list of files.  Used to make the
        introductory image at http://musiclessonz.com/rebol.html        
    }
]


; THIS FIRST VERSION IS A DEMO CONTAINING AN EDITABLE BLOCK
; OF IMAGES, AND VARIABLES TO HOLD IMAGE SETTINGS.  YOU CAN
; ADJUST ALL THE VARIABLES MANUALLY IN THE CODE:


y-size: 200              ; height to which each image should be resized
mosaic-size: 600         ; width of the mosaic to create
padding: 30              ; space between the images
background-color: white  ; color of empty space between images

images: [
    http://musiclessonz.com/rebol_tutorial/invaders.jpg
    http://musiclessonz.com/rebol_tutorial/ski_game.jpg
    http://musiclessonz.com/rebol_tutorial/r3D.png
    http://musiclessonz.com/rebol_tutorial/gcdm.png
    http://musiclessonz.com/rebol_tutorial/web_cam.png
    http://musiclessonz.com/rebol_tutorial/demo5a.jpg
    http://musiclessonz.com/rebol_tutorial/demo5.jpg
    ; %yourpath/image1.jpg
    ; %yourpath/image2.jpg
    ; %yourpath/image3.jpg
    ; %yourpath/image4.jpg
    ; %yourpath/image5.jpg
]

mosaic: copy reduce ['backcolor background-color 'space padding 'across]
foreach picture images [
     flash rejoin ["Resizing " picture "..."]
     original: load picture
     unview
     either original/size/2 > y-size [
         new-x-factor: y-size / original/size/2
         new-x-size: round original/size/1 * new-x-factor
         new-image: to-image layout/tight [
             image original to-pair rejoin [new-x-size "x" y-size]
         ]
         append mosaic reduce ['image new-image]
     ][
         append mosaic reduce ['image original]
     ]
     current-layout: layout/tight mosaic
     if current-layout/size/1 > mosaic-size [
         insert back back tail mosaic reduce ['return]
     ]
]

filename: to-file request-file/file/save "mosaic.png"
save/png filename to-image layout mosaic
view center-face layout [image load filename]




; THIS SECOND VERSION HAS A GUI FRONT END, SO THAT USERS
; DON'T NEED TO EDIT ANY CODE TO CHANGE SETTINGS:


view center-face layout [
    text "Resize input images to this height:"
    height: field "200"
    text "Create output mosaic of this width:"
    width: field "600"
    text "Space between thumbnails:"
    padding-size: field "30"
    text "Color between thumbnails:"
    btn "Select color" [background-color: request-color/color white]
    text "Thumbnails will be displayed in this order:"
    the-images: area
    across
    btn "Select images" [
        some-images: request-file/title trim/lines {Hold
            down the [CTRL] key to select multiple images:} ""
        if some-images = none [return] 
        foreach single-image some-images [
           append the-images/text single-image
           append the-images/text "^/"
        ]
        show the-images
    ]
    btn "Create Thumbnail Mosaic" [
        y-size: to-integer height/text
        mosaic-size: to-integer width/text
        padding: to-integer padding-size/text
        if error? try [background-color: to-tuple background-color][
            background-color: white
        ]
        images: copy parse/all the-images/text "^/"
        if empty? images [alert "No images selected." break]
        mosaic: compose [
            backcolor (background-color) space (padding) across
        ]
        foreach picture images [
             flash rejoin ["Resizing " picture "..."]
             original: load to-file picture
             unview
             either original/size/2 > y-size [
                 new-x-factor: y-size / original/size/2
                 new-x-size: round original/size/1 * new-x-factor
                 new-image: to-image layout/tight [
                     image original to-pair rejoin [new-x-size "x" y-size]
                 ]
                 append mosaic compose [image (new-image)]
             ][
                 append mosaic compose [image (original)]
             ]
             current-layout: layout/tight mosaic
             if current-layout/size/1 > mosaic-size [
                 insert back back tail mosaic 'return
             ]
        ]
        filename: to-file request-file/file/save "mosaic.png"
        save/png filename (to-image layout mosaic)
        view/new layout [image load filename]
    ]
]