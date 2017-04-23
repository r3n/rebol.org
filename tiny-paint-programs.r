Rebol [
    title: "Tiny Paint Programs"
    date: 29-june-2008
    file: %tiny-paint-programs.r
    purpose: {
        Three different small paint programs, including the shortest possible one-liner.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

; a small, but reasonably featured little scribbler:

view layout [
    h1 "Paint with the mouse:"
    scrn: box black 400x400 feel [
        engage: func [face action event] [
            if find [down over] action [
                append scrn/effect/draw event/offset show scrn
            ]
            if action = 'up [append scrn/effect/draw 'line]
        ]
    ] effect [draw [line]]
    btn "Save" [
        save/png %/c/painting.png to-image layout [
            origin 0x0 box black 400x400 effect pick get scrn 9
        ] alert "Saved to C:\painting.png"
    ]
    btn "Clear" [scrn/effect/draw: copy [line] show scrn]
]


; a shorter version, not so readable:

view layout[s: area 600x400 feel[engage: func[f a e][if a = 'over[append
s/effect/draw e/offset show s]if a = 'up[append s/effect/draw 'line]]]effect[
draw[line]]b: btn"Save"[save/png %a.png to-image s alert"Saved a.png"]
btn"Clear"[s/effect/draw: copy[line]show s]]


; the tiniest possible one-liner paint program I could come up with:

view layout[s: area feel[engage: func[f a e][if a = 'over[append s/effect/draw e/offset show s]]]effect[draw[line]]]