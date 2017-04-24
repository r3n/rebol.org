REBOL [
    title: "Pig Latin"
    date: 4-Dec-2013
    file: %piglatin.r
    author:  Nick Antonaccio
    purpose: {Enter text, it displays the Pig Latin translation.}
]
view layout [
    f: area wrap 
    btn "Pig Latin" [
        t: copy ""
        foreach w parse copy f/text none [
            x: first parse w "aeiou"
            append t rejoin [
                either q: find/match w x [q] [w] 
                " " x either q ["ay"] ["hay"] " "
            ]
        ]
        f/text: copy t  show f
    ]
]

; AND HERE'S A ONE-LINE CONSOLE VERSION:

foreach t parse ask""""[x: parse t"aeiou"prin rejoin[either q: find/match t x/1[q][t]x/1 either q["ay"]["hay"]" "]]