REBOL [
    Title: "Image Slicer"
    Date: 20-Nov-2001
    Version: 1.0.0
    File: %slice.r
    Author: "Carl Sassenrath"
    Purpose: {Slices an image into a set of sub-images and stores
each as a local PNG file under its own name.
}
    Email: carl@pacific.net
    library: [
        level: none 
        platform: none 
        type: none 
        domain: [file-handling GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

if none? img: load-thru/binary http://www.rebol.com/graphics/desk-top.jpg [
    alert "Cannot download image." quit
]

sub-files: [
    %services  57x15 265x53
    %arenas    4x102 88x132
    %folderbar 95x67 310x41
    %icons     121x107 276x148
    %version   18x328 86x39
    %descrpt   75x331 155x36
    %connect   320x331 90x36
]

fac: make face [offset: 40x40 size: img/size image: img]

foreach [file xy wh] sub-files [
    fac/size: wh
    fac/effect: reduce ['crop xy wh]
    save/png join file %.png to-image fac
    print ["Created:" file]
]
                                   