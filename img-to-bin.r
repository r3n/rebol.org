REBOL [
    Title: "Image to binary"
    Date: 26-Mar-2002/15:35+1:00
    Version: 1.0.0
    File: %img-to-bin.r
    Author: "Oldes"
    Purpose: "To return binary representation of the image."
    Email: oliva.david@seznam.cz
    library: [
        level: none 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

img-to-bin: func[
    "Converts image to binary pixels array"
    img [file! url! image!]
    /local bin
][
    if not image? img [img: load img]
    parse mold img [to "#" copy bin thru "}"]
    bin: load bin
]                   