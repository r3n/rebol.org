REBOL [
    title: "RebGUI Editor"
    date: 18-Apr-2010
    file: %rebgui-editor.r
    author:  Nick Antonaccio
    purpose: {
        A minimal text editor program, written to demonstrate menus and a few
        other basic features of RebGUI.  
        Taken from the tutorial at http://re-bol.com
    }
]

unless exists? %ui.dat [
    write %ui.dat read http://re-bol.com/ui-editor.dat
]
do load-thru http://re-bol.com/rebgui.r    ; Build#117
; do %rebgui.r

filename: %temp.txt
make-dir %./edit_history/

backup: does [
    if ((length? x/text) > 0) [
        write rejoin [
            %./edit_history/ 
             last split-path filename 
             "_" now/date "_"
             replace/all form now/time ":" "-"
        ] x/text
    ]
]
ctx-rebgui/on-fkey/f5: does [
    backup
    write filename x/text
    launch filename
]

display/maximize/close "RebGUI Editor" [
    tight
    menu #LW data [
        "File" [
            "  New  " [
                if true = question "Erase Current Text?" [
                    backup
                    filename: %temp.txt set-text x copy ""
                ]
            ]
            "  Open  " [
                filetemp: to-file request-file/file filename
                if filetemp = %none [return]
                backup
                set-text x read filename: filetemp
            ]
            "  Save  " [
                backup
                write filename x/text
            ]
            "  Save As  " [
                filetemp: to-file request-file/save/file filename
                if filetemp = %none [return]
                backup
                write filename: filetemp x/text
            ]
            "  Save and Run  " [
                backup
                write filename x/text 
                launch filename
            ]
            "  Print  "  [
                write %./edit_history/print-file.html rejoin [
                    {<}{pre}{>} x/text {<}{pre}{>}
                ]
                browse %./edit_history/print-file.html
            ]
            "  Quit  " [
                if true = question "Really Close?" [backup quit]
            ]
        ]
        "Options" [
            "  Appearance  " [request-ui]
        ]
        "Help" [
            "  Shortcut Keys  " [
                alert trim {
                    F5:       Save and Run
                    Ctrl+Z:   Undo
                    Ctrl+Y:   Redo
                    Esc:      Undo All
                    Ctrl+S:   Spellcheck
                }
            ]
        ] 
    ] return
    x: area #LHW
] [
    if true = question "Really Close?" [backup quit]
] 

do-events
