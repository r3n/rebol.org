REBOL [
    Title: "Spooky Text"
    Date: 20-May-2000
    File: %spooky.r
    Author: "Jeff"
    library: [
        level: 'intermediate 
        platform: none 
        type: [Demo Game] 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Purpose: "Displays spooky text"
]

cycle: func [c start end inc][
    make face/feel [engage: func [f a e] compose/deep [
        all [a = 'time (to-set-path c/1) 
            do compose [(c/1) ([(pick [+ -] f/dir)]) (inc)]
            all [any [(end) = (c/1) (start) = (c/1)] 
                 f/dir: not f/dir reverse f/text]] show f]]]
t: make face [
    feel: cycle [f/font/color] white black 10.10.10 dir: on
    color: black edge: none effect: [key 0.0.0]
    font: make font [size: 16]]
lay: copy [] max-x: 0 spot: 10x30 
pieces: parse loop 4 [append # #red#rum#] {#}
forall pieces [
    append lay make t [ rate: 8 + random 3
        text: first pieces offset: spot size: 10x0 + size-text self 
        (spot: spot + (size * 1x0) max-x: max spot/x max-x) ;- no context set
        all [ 0 = ((index? pieces) // 12) spot: spot * 0x1 + 10x12]
   ]
]
view make face [
    dir: off rate: 3 feel: cycle [f/color] black 255.0.0 5.0.0 
    color: black pane: lay size: 20x50 + to-pair reduce [max-x spot/y]
    effect: [gradmul -1x-1 155.155.155 0.0.0]
]
