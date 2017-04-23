REBOL [
    Title: "Local Font Mapping"
    Date: 4-Jun-2000
    Version: 1.0.3
    File: %font-styles.r
    Author: "Allen Kamp"
    Purpose: {Shows which fonts are being mapped to 
              the system independent font styles on your system}
    Email: allenk@powerup.com.au
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

example: stylize [
    fixed text [font: [name: font-fixed]]
    fixed24 fixed [font: [size: 24]]
    sans-serif text [font: [name: font-sans-serif]]
    sans-serif24 sans-serif [font: [size: 24]]
    serif text [font: [name: font-serif]]
    serif24 serif [font: [size: 24]]
] 

view layout [
    styles example 
    size 500x300
    backdrop 0.0.0
    title "Rebol Font Styles"
    space 0x10
    text {Shows which fonts are being mapped to 
              the system independent font styles on your system}
    240.240.204 220
    space 0x10
    text white font [name: font-fixed size: 24] (join "font-fixed:" mold font-fixed)
    text white font [name: font-sans-serif size: 24] (join "font-sans-serif: " mold font-sans-serif)
    text white font [name: font-serif size: 24] (join "font-serif: " mold font-serif)
]

