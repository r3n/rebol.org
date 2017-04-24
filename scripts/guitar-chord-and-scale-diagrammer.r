REBOL [
    title: "Guitar Chord and Scale Diagrammer"
    date: 12-Jan-2014
    file: %guitar-chord-and-scale-diagrammer.r
    author:  Nick Antonaccio
    purpose: {
        A little example for the new tutorial at:
             http://re-bol.com/starting_computer_programming_with_rebol.html
        When the program starts, enter the number of frets you want in your diagram.
        (The default is 5 frets, but you could use 3 or 4 for smaller diagrams, 
        or more for full fretboard scale diagrams)
        Click any fret on any string to add a dot (finger position).
        Click any added dot to remove it (change it back to an empty position).
        Right-Click any fret on any string to add a character of your choice.
        (You could use this to add finger numbers, root note labels, interval labels, etc.)
        Click the title text ("Chord Name") to give the chord or scale a name.
        Right-Click the title to save the diagram to a .png image.
        (The default image file name is the title text entered above)
    }
]
f: request-text/title/default "Number of frets in each diagram:" "5"
g: [
    backdrop white
    across  origin 0x0  space 0x0
    style s box 20x20 "|" font-size 20 font-color black shadow 0x0 [
        face/text: either "|" = face/text ["O"] ["|"] 
    ] [
        face/text: request-text
    ]
    t: text 120x24 bold center font-size 18 "Chord Name" [
        face/text: request-text
    ] [
        attempt [
            save/png 
                request-file/save/only/file join t/text ".png" 
                to-image p
        ]
    ]
    return
]
loop to-integer f [append g [s s s s s s return]]
view center-face p: layout g