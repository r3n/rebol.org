REBOL [
    title: "RebGUI Card File"
    date: 10-Mar-2010
    file: %rebgui-card-file.r
    author:  Nick Antonaccio
    purpose: {

        This is an implementation of the Card File program at 
        http://www.rebol.org/view-script.r?script=card-file.r
        using RebGUI instead of VID.  Notice that the GUI is resizable,
        the text fields have undo/redo and spellcheck capabilities,
        requestors are modal, and all the other features of RebGUI
        are available.

        Taken from the tutorial at http://re-bol.com

    }
]

REBOL []

do load-thru http://re-bol.com/rebgui.r    ; Build#117

write/append %data.txt ""
database: load %data.txt

display "RebGUI Card File" [
    text 20 "Select:"
    names: drop-list #LW data (sort extract copy database 4) [
        marker: find database pick names/data names/picked
        set-text n copy first marker
        set-text a copy second marker
        set-text p copy third marker
        set-text o copy fourth marker
    ]
    after 2
    text 20 "Name:"        n: field #LW ""
    text 20 "Address:"     a: field #LW ""
    text 20 "Phone:"       p: field #LW ""
    after 1 text "Notes:"  o: area #LW ""
    after 3
    button -1 "Save" [
        if (n/text = "") [alert "You must enter a name." return]
        if find (sort extract copy database 4) copy n/text [
            either true = question "Overwrite existing record?" [
               remove/part (find database n/text) 4
            ] [return]
        ]
        database: repend database [
            copy n/text copy a/text copy p/text copy o/text
        ]
        save %data.txt database
        set-data names (sort extract copy database 4)
        set-text names copy n/text
    ]
    button -1 "Delete" [
        if true = question rejoin ["Delete " copy  n/text "?"] [
            remove/part (find database n/text) 4
            save %data.txt database
            set-data names (sort extract copy database 4)
            set-values face/parent-face ["" "" "" "" ""]
        ]
    ]
    clear-button: button -1 "New" [
            set-values face/parent-face ["" "" "" "" ""]
    ]
]
do-events