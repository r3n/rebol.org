Rebol [
    title: "Object Game"
    date: 29-june-2008
    file: %objects-example.r
    author: Nick Antonaccio
    purpose: {
        A little game to demonstrate Rebol objects.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

hidden-prize: random 15x15
character: make object! [
    position: 0x0
    move: does [
        direction: ask "Move up, down, left, or right:  "
        switch/default direction [
            "up" [position: position + -1x0]
            "down" [position: position + 1x0]
            "left" [position: position + 0x-1]
            "right" [position: position + 0x1]
        ] [print newline print "THAT'S NOT A DIRECTION!"]
        if position = hidden-prize [
            print newline
            print "You found the hidden prize.  YOU WIN!"
            print newline
            halt
        ]
        print rejoin [
            newline
            "You moved character " movement " " direction
            ".  Character " movement " is now " 
            hidden-prize - position
            " spaces away from the hidden prize.  "
            newline
        ]
    ]
]

character1: make character[]
character2: make character[position: 3x3]
character3: make character[position: 6x6]
character4: make character[position: 9x9]
character5: make character[position: 12x12]
loop 20 [
    prin "^(1B)[J"
    movement: ask "Which character do you want to move (1-5)?  "
    if find ["1" "2" "3" "4" "5"] movement [ 
        do rejoin ["character" movement "/move"]
        print rejoin [
            newline
            "The position of each character is now:  "
            newline newline
            "CHARACTER ONE:   " character1/position newline
            "CHARACTER TWO:   " character2/position newline
            "CHARACTER THREE: " character3/position newline
            "CHARACTER FOUR:  " character4/position newline
            "CHARACTER FIVE:  " character5/position
        ]
        ask "^/Press the [Enter] key to continue."
    ]
]