REBOL [
    title: "Generic Playing Card Game Framework"
    date: 13-Jan-2010
    file: %playing-card-framework.r
    author:  Nick Antonaccio
    purpose: {
        A simple demonstration of how to use the images in %playing-cards.r
        to create card games.  In this example, the cards are arranged in a way
        that can be used to play the game of Freecell.   The rules of that particular
        game are not enforced in this example, to keep the code simple and under-
        standable (you can play a full game of Freecell with this code alone, but no
        particular moves are allowed or disallowed, stacks of cards can not be moved
        at once, etc.).  See freecell.r for a more complete implementation of the Freecell
        game, using this outline.

        Taken from the tutorial at http://re-bol.com
    }
]

do http://www.rebol.org/download-a-script.r?script-name=playing-cards.r

random/seed now
loop 156 [
    pos1: pick cards rnd1: (random 52) * 5
    pos2: pick cards rnd2: (random 52) * 5
    poke cards rnd1 pos2
    poke cards rnd2 pos1
]

movestyle: [
    engage: func [face action event] [
        if action = 'down [
            start-coord: face/offset
            face/data: event/offset
            remove find face/parent-face/pane face
            append face/parent-face/pane face
        ]
        if find [over away] action [
            unrounded-pos: (face/offset + event/offset - face/data)
            snap-to-x: (round/to first unrounded-pos 80) + 20
            snap-to-y: (round/to second unrounded-pos 20) + 20
            face/offset: (as-pair snap-to-x snap-to-y)
        ]
        if action = 'up [
            if any [
                (find cards face/offset)
                (face/offset/2 < 20)
            ] [
                if (face/offset/2 < 398) [face/offset: start-coord]
            ]
            replace cards start-coord face/offset
            arrange-cards
        ]
        show face
    ]
]

positions: does [
    temp: copy []
    foreach item cards [if ((type? item) = pair!) [append temp item]]
    return sort temp
]

arrange-cards: does [
    foreach position positions [
        foreach card system/view/screen-face/pane/1/pane [
            if (card/offset = position) and (position/2 < 398) [
                remove find system/view/screen-face/pane/1/pane card
                append system/view/screen-face/pane/1/pane card
            ]
        ]
    ]
    show system/view/screen-face/pane/1/pane
]

gui: [size 670x510 backdrop 0.150.0 across ]
foreach [card label num color pos] cards [
    append gui compose [
        at (pos) image load to-binary decompress (card) feel movestyle
    ]
]

box-pos: 18x398
loop 4 [
    append gui compose [
        at (box-pos) box green 72x2
        at (box-pos) box green 2x97
        at (box-pos + 320x0) box white 72x2
        at (box-pos + 320x0) box white 2x97
    ]
    box-pos: box-pos + 80x0
]

view/new center-face layout gui
arrange-cards
do-events