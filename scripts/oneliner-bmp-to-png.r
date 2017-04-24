Rebol [
    Title: "BMP to PNG"
    Date: 20-Jul-2003
    File: %oneliner-bmp-to-png.r
    Purpose: {Reads all .bmp files in a directory and saves them out as .png files.}
    One-liner-length: 92
    Version: 1.0.0
    Author: "Bohdan Lechnowsky"
    Library: [
        level: 'beginner
        platform: none
        type: [How-to FAQ one-liner]
        domain: [file-handling]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
foreach file load %. [if find file %.bmp [save/png replace copy file %.bmp %.png
load file]]
