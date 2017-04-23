Rebol [
    title: "Simple Menu"
    date: 29-june-2008
    file: %simple-menu.r
    purpose: {
        A quick and dirty way to create menus in your GUI.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]
view center-face gui: layout/size [
    at 100x100 H3 "You selected:"
    display: field
    origin 2x2 space 5x5 across
    at -200x-200 file-menu: text-list "item1" "item2" "quit" [
        switch value [
            "item1" [
                face/offset: -200x-200
                show file-menu
                ; PUT YOUR CODE HERE:
                set-face display "File / item1"
            ]
            "item2" [
                face/offset: -200x-200
                show file-menu
                ; PUT YOUR CODE HERE:
                set-face display "File / item2"
            ]
            "quit" [quit]
        ]
    ]
    at 2x2
    text bold "File" [
        either (face/offset + 0x22) = file-menu/offset [
            file-menu/offset: -200x-200
            show file-menu
        ][
            file-menu/offset: (face/offset + 0x22)
            show file-menu
        ]
    ]
    text bold "Help" [
        file-menu/offset: -200x-200
        show file-menu
        ; PUT YOUR CODE HERE:
        set-face display "Help"
    ]
] 400x300