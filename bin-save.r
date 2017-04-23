REBOL [
    Title: "Encoding Binary Data in REBOL Scripts"
    Date: 30-May-2000
    File: %bin-save.r
    Purpose: {Example of how to save base-64 encoded binary data in REBOL scripts. (See bin-data.r as an example of how to decode the data.)}
    library: [
        level: 'beginner 
        platform: none 
        type: 'How-to 
        domain: 'file-handling 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

data: read/binary %rebol-banner.gif

system/options/binary-base: 64

save %banner.r data
