REBOL [
    Title: "Non-echoing Input"
    Date: 15-Sep-1999
    File: %inhide.r
    Purpose: "Hide input for passwords (no echo characters)"
    library: [
        level: 'beginner 
        platform: none 
        type: [one-liner tool]
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

print ask/hide "Password: "

