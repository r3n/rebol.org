Rebol [
    title: "Tiny Tile Game"
    date: 29-june-2008
    file: %tiny-tile-game.r
    purpose: {
        A very short GUI game example.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

view center-face layout [
    origin 0x0 space 0x0 across 
    style p button 60x60 [
        if not find [0x60 60x0 0x-60 -60x0] face/offset - empty/offset [exit]
        temp: face/offset face/offset: empty/offset empty/offset: temp
    ]
    p "A" p "B" p "C" p "D" return p "E" p "F" p "G" p "H" return
    p "I" p "J" p "K" p "L" return p "M" p "N" p "O"  
    empty: p 200.200.200 edge [size: 0]
]