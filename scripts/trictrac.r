REBOL [
    title: "Tric Trac"
    date: 7-Nov-2013
    file: %trictrac.r
    author:  Nick Antonaccio
    purpose: {
        A quick implementation of a simple board game.  Created with a 
        student as a tutorial example.
        The point is to roll the dice, and match the rolled number with
        any combination of available number buttons above.  For example,
        if you roll a 6, you can match it with the number button 6, or
        5 + 1, or 4 + 2, or 3 + 2 + 1, etc.  Once a number button has
        been selected, it cannot be used again for the rest of the game.
        The game is over when you have no possible combinations of number
        buttons to match the rolled value.  To determine your final score,
        sum the remaining number buttons (see the bottom left of the
        screen).  The goal is to get the lowest final score.  When playing
        against others, each player takes turns clearing the board - or
        you can just play against yourself, always trying to get the
        lowest possible score.
        Another way to play is to count the total number of rolls required
        to clear the board.  The goal is to turn all the buttons in the
        fewest number of rolls.  To make this game go faster, play with
        only numbers 5-10.
    }
]
random/seed now/time
count: 0
view center-face layout [
    backdrop white across
    style tog toggle tan 50x100 [
        sum: 0
        show face
        foreach bttn [a b c d e f g h i j k l] [
            do rejoin [
                {if not find } bttn {/text "(" [sum: sum + to-integer }
                bttn {/text]}
            ]
        ]
        if not find u/text "(" [u/text: rejoin ["(" u/text ")"]  show u]
        t/text: form sum  show t
    ]
    a: tog "1" ""
    b: tog "2" ""
    c: tog "3" ""
    d: tog "4" ""
    e: tog "5" ""
    f: tog "6" ""
    g: tog "7" ""
    h: tog "8" ""
    i: tog "9" ""
    j: tog "10" ""
    k: tog "11" ""
    l: tog "12" ""
    return
    u: btn 690x50 font-size 20 "Roll" [
        face/text: (form (1 + random 11)) show face
        count: count + 1
        cnt/text: count  show cnt
    ]
    return
    text "Score:"
    t: text bold "000"
    text "Save" [write %trictrac t/text]
    text "Previous High" [attempt [alert read %trictrac]]
    text "Count:"
    cnt: text bold "000"
]

; And just for fun, here's a 1 line version:

random/seed now g: [across btn "Roll" [alert form 1 + random 11]] repeat i 12 [append g reduce ['text mold i 'check]] view layout g