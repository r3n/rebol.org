REBOL [
    title: "RebGUI Spreadsheet Example"
    date: 18-Apr-2010
    file: %rebgui-spreadsheet.r
    author:  Nick Antonaccio
    purpose: {
        A tiny demo of RebGUI's sheet widget, with save, load, print
        and data view features. 
        Taken from the tutorial at http://re-bol.com
    }
]

do load-thru http://re-bol.com/rebgui.r    ; Build#117

display "Spreadsheet" [
    x: sheet options [size 3x3 widths [8 8 10]] data [
        A1 32 A2 12 A3 "=a1 + a2" A4 "=1.06 * to-integer a3"
    ]
    return 
    button "Save" [
        x/save-data
        save to-file request-file x/data
    ]
    button "Load" [
        x/load-data load to-file request-file
    ]
    button "View" [
        x/save-data
        alert form x/data
    ]
    button "Print" [
        save/png %sheet.png to image! x
        browse %sheet.png  ; or call %sheet.png
    ]
] 
do-events