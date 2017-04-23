REBOL [
    Title: "Total Size of .r Files"
    Date: 24-Apr-1999
    File: %sizedir.r
    Purpose: {Print the total size of all .r files in the current directory.}
    library: [
        level: 'beginner 
        platform: 'all 
        type: 'tool 
        domain: 'file-handling 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

total: 0

foreach file load %./ [
    if find file ".r" [
        total: total + (size? file)
    ]
]

print [total "bytes"]
