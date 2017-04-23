REBOL [
    Title: "Text Size Check"
    Date: 1-Jun-2000
    File: %text-size.r
    Purpose: "Compare text font sizes"
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [text-processing GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

data: [space 0x0]

for size 32 8 -2 [
    append data compose/deep
        [text (join "Text Size " size) font [size: (size)]]
]

view layout data
