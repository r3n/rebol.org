REBOL [
    title: "Choice Button Menu Example"
    date: 25-Sep-2010
    file: %choice-button-menu-example.r
    author:  Nick Antonaccio
    purpose: {A quick way to add a simple menu to VID GUIs}
]
request: do replace/all mold :request "bold" ""  ; not required for menus


menu: [[
    "Options" []
    "_________________________^/" []
    "Open File" [attempt [a1/text: read request-file/only show a1]]
    "Copy to Clipboard" [do-face b1 1]
    "Paste from Clipboard" [a1/text: read clipboard:// show a1]
    "_________________________^/" []
    "About" [alert "This menu is just a choice button widget :)"]
    "_________________________^/" []
    "Halt" [halt]
    "Quit" [quit]
][
    "Preferences" []
    "_________________________^/" []
    "Option 1" [alert "Option 1"]
    "Option 2" [alert "Option 2"]
    "Option 3" [alert "Option 3"]
]]
foreach m menu [foreach i (at m 3) [unless find i "_____" [insert head i "     "]]]
clr: func [face] [face/text: face/texts/1  show face]
menu-color: 235.240.245  svv/vid-face/color: 253.253.253
view center-face layout [
    size 440x250 
    style mnu choice 190x20 left menu-color with [
        edge: none  font: [style: none  shadow: none  colors: [0.0.0]]
        para: [indent: 4x0]  colors: reduce [menu-color 215.220.225]
    ]
    across  origin 0x0  space 0x0  box menu-color 8x20
    mnu data (extract menu/1 2) [do select menu/1 value  clr face]
    at 70x0 mnu data (extract menu/2 2) [do select menu/2 value  clr face]
    box menu-color 2000x20  origin 20x40  space 20x20  below
    a1: area wrap with [colors: [254.254.254 248.248.248]]
    b1: btn "Copy" [write clipboard:// a1/text alert "Copied"]
]