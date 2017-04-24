Rebol [
    title: "Guitar Chord Diagram Maker"
    date: 29-june-2008
    file: %guitar-chord-diagram-maker.r
    purpose: {
        A demo program that creates, saves, and prints collections of guitar chord fretboard diagrams.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

fretboard: load 64#{
iVBORw0KGgoAAAANSUhEUgAAAFUAAABkCAIAAAB4sesFAAAACXBIWXMAAAsTAAAL
EwEAmpwYAAAA2UlEQVR4nO3YQQqDQBAF0XTIwXtuNjfrLITs0rowGqbqbRWxEEL+
RFU9wJ53v8DN7Gezn81+NvvZXv3liLjmPX6n/4NL//72s9l/QGbWd5m53dbc8/kR
uv5RJ/QvzH42+9nsZ7OfzX62nfOPzZzzyNUxxh8+qhfVHo94/rM49y+b/Wz2s9nP
Zj+b/WzuX/cvmfuXzX42+9nsZ7OfzX4296/7l8z9y2Y/m/1s9rPZz2Y/m/vX/Uvm
/mWzn81+NvvZ7Gezn8396/4l2/n+y6N/f/vZ7Gezn81+tjenRWXD3TC8nAAAAABJ
RU5ErkJggg==
}

barimage: load 64#{
iVBORw0KGgoAAAANSUhEUgAAAEoAAAAFCAIAAABtvO2fAAAACXBIWXMAAAsTAAAL
EwEAmpwYAAAAHElEQVR4nGNsaGhgGL6AaaAdQFsw6r2hDIa59wCf/AGKgzU3RwAA
AABJRU5ErkJggg==
}

dot: load 64#{
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAIAAAACUFjqAAAACXBIWXMAAAsTAAAL
EwEAmpwYAAAAFElEQVR4nGNsaGhgwA2Y8MiNYGkA22EBlPG3fjQAAAAASUVORK5C
YII=
}

movestyle: [
    engage: func [face action event] [
        if action = 'down [
            face/data: event/offset
            remove find face/parent-face/pane face
            append face/parent-face/pane face
        ]
        if find [over away] action [
            face/offset: face/offset + event/offset - face/data
        ]
        show face
    ]
]

gui: [
    backdrop white
    currentfretboard: image fretboard 255x300
    currentbar: image barimage 240x15 feel movestyle
    text "INSTRUCTIONS:" underline
    text "Drag dots and other widgets onto the fretboard."
    across  
    text "Resize the fretboard:"
    tab 
    rotary "255x300" "170x200" "85x100" [
        currentfretboard/size: to-pair value show currentfretboard
        switch value [
            "255x300" [currentbar/size: 240x15 show currentbar]
            "170x200" [currentbar/size: 160x10 show currentbar]
            "85x100" [currentbar/size: 80x5 show currentbar]
        ]
    ]   
    return
    button "Save Diagram" [
        filename: to-file request-file/save/file "1.png"
        save/png filename to-image currentfretboard
    ]
    tab
    button "Print" [
        filelist: sort request-file/title "Select image(s) to print:"
        html: copy "<html><body>"
        foreach file filelist [
            append html rejoin [
                {<img src="file:///} to-local-file file {">}
            ]
        ]
        append html [</body></html>]
        write %chords.html trim/auto html
        browse %chords.html 
    ]
]

loop 50 [append gui [at 275x50 image dot 30x30 feel movestyle]]
loop 50 [append gui [at 275x100 image dot 20x20 feel movestyle]]
loop 50 [append gui [at 275x140 image dot 10x10 feel movestyle]]
loop 6 [append gui [at 273x165 text "X" bold feel movestyle]]
loop 6 [append gui [at 273x185 text "O" bold feel movestyle]]

view layout gui