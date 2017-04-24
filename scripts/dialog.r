REBOL [
    Title: "Dialog Box"
    Date: 20-May-2000
    File: %dialog.r
    Purpose: {
        Pops up a dialog requestor that displays a message
        and waits for the user to click a button.
    }
    library: [
        level: 'beginner 
        platform: none 
        type: none 
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

dialog: layout [
    backdrop effect [gradient 1x1 0.0.0 0.0.180]
    h2 "Important Notice:" red
    text yellow 200x100 {
        REBOL/View is not a toy. Use only under the supervision
        of a highly trained evangelist.
    }
    button "I Promise" [hide-popup]
]

view layout [
    backdrop effect [gradient 0.100.0 0.0.0]
    title white "Example"
    button "Click for Dialog" [inform dialog]
    button "Quit" [quit]
]