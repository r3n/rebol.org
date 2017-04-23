REBOL[
    Title:   "Hunt the Wumpus"
    Date:    20-Jul-2003
    File:	 %wumpus.r
    Purpose: "A REBOL version of a retro text game. Just for fun."
    Author:  "Gregg Irwin"
    EMail:   greggirwin@acm.org
    Version: 1.0.1
     Library: [
        level: 'intermediate
        platform: 'all
        type: [script demo game]
        domain: [game]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
    Comment: {
        I found an old version, in C (by Eric Raymond), which was adapted from
        an even older version, in BASIC (by Magnus Olsson), that had been found
        in a SIMTEL archive. It's got lineage.

        As of 22-Oct-2001, it appears to work, though I haven't traced the
        arrow path'ing logic yet, nor made it smart. Arrows can go pretty much
        anywhere you tell them and, yes, you can shoot yourself as in the
        original.

        I tweaked a few strings, but the instructions are almost unscathed.

        Ahhh, it takes me back to my Dad's HP85 with the built-in 5 inch
        monochrome screen, tape drive, and thermal printer...
    }
    history: [
        1.0.0 22-Mar-2002 [{Initial Release}]
        1.0.1 11-Apr-2002 [
            {Fixed bug where the Wumpus might eat you after you shot him. GSI}
        ]
    ]
]

; Setup
;    initialize arrow count
;    randomly place bats, pits, wumpus, and player
;    make a working copy of the starting locations.
; Check-for-hazards
; Each Turn
;    ask player to move or shoot
;    if shoot
;        check for hit on self and wumpus
;        move wumpus
;    if move
;        check-for-hazards
; until player dead, wumpus dead, or out of arrows

arrow-count:  0

; indexes into location block
player: 1
wumpus: 2
pit-1:  3
pit-2:  4
bats-1: 5
bats-2: 6
protect [player wumpus pit-1 pit-2 bats-1 bats-2]

start-loc: []
loc: []
winner: none
finished: false

; The cave is a dodecahedron. Each block is a room containing the
; number for the rooms it is connected to.
cave: [
    [2 5 8]    [1 3 10]  [2 4 12]   [3 5 14]   [1 4 6]
    [5 7 15]   [6 8 17]  [1 7 9]    [8 10 18]  [2 9 11]
    [10 12 19] [3 11 13] [12 14 20] [4 13 15]  [6 14 16]
    [15 17 20] [7 16 18] [9 17 19]  [11 18 20] [13 16 19]
]

random-room: does [random 20]
random-direction: does [random 3]

get-num: func [prompt] [
    if error? try [return to-integer ask prompt] [
        return 0
    ]
]

print-instructions: does [
    print {
WELCOME TO 'HUNT THE WUMPUS' (love that all caps retro look)

THE WUMPUS LIVES IN A CAVE OF 20 ROOMS. EACH ROOM HAS 3 TUNNELS LEADING TO
OTHER ROOMS.

HAZARDS:
  BOTTOMLESS PITS - TWO ROOMS HAVE BOTTOMLESS PITS IN THEM. IF YOU GO THERE,
    YOU FALL INTO THE PIT (YOU LOSE!)
  SUPER BATS - TWO OTHER ROOMS HAVE SUPER BATS. IF YOU GO THERE, A BAT GRABS
    YOU AND TAKES YOU TO SOME OTHER ROOM AT RANDOM. (WHICH MAY BE TROUBLESOME)

WUMPUS: THE WUMPUS IS NOT BOTHERED BY HAZARDS (HE HAS SUCKER FEET AND IS TOO
    BIG FOR A BAT TO LIFT). USUALLY HE IS ASLEEP. TWO THINGS WAKE HIM UP: YOU
    SHOOTING AN ARROW OR YOU ENTERING HIS ROOM. IF THE WUMPUS WAKES HE MOVES
    ONE ROOM (75% chance) OR STAYS STILL (25% chance). AFTER THAT, IF HE IS
    WHERE YOU ARE, HE EATS YOU UP AND YOU LOSE!

YOU: EACH TURN YOU MAY MOVE OR SHOOT A CROOKED ARROW.
  MOVING: YOU CAN MOVE ONE ROOM (THROUGH ONE TUNNEL).
  ARROWS: YOU HAVE 5 ARROWS.  YOU LOSE WHEN YOU RUN OUT.
        EACH ARROW CAN GO FROM 1 TO 5 ROOMS. YOU AIM BY TELLING THE COMPUTER
        THE ROOMS YOU WANT THE ARROW TO GO TO. IF THE ARROW CAN'T GO THAT WAY
        (I.E. NO TUNNEL) IT MOVES AT RANDOM TO THE NEXT ROOM.
        * IF THE ARROW HITS THE WUMPUS, YOU WIN.
        * IF THE ARROW HITS YOU, YOU LOSE.

WARNINGS: WHEN YOU ARE ONE ROOM AWAY FROM A WUMPUS OR HAZARD, THE COMPUTER SAYS:
     WUMPUS:  'YOU SMELL A WUMPUS'
     BAT   :  'YOU HEAR BATS'
     PIT   :  'YOU FEEL A DRAFT'
}

    ask "Press <Enter> when you're ready to start the game"

]

check-for-hazards: func [/local i] [
    print ""
    print ["You are in room " loc/:player]
    print ["Tunnels lead to " pick cave loc/:player]
    ; Look at each of the 3 rooms around the player to see if the contain
    ; the wumpus, a pit, or bats.
    repeat i 3 [
        room: pick pick cave loc/:player i
        if (room = loc/:wumpus) [print "  You smell a wumpus!"]
        if any [(room = loc/:pit-1) (room = loc/:pit-2)] [
            print "  You feel a draft!"
        ]
        if any [(room = loc/:bats-1) (room = loc/:bats-2)] [
            print "  You hear bats!"
        ]
    ]
    print ""
]

move-or-shoot?: func [/local cmd] [
    cmd: ask "Shoot or move (S/M)? "
    ; The default case handles bad inputs and prompts the user again.
    switch/default cmd [
        "S" ['shoot]
        "M" ['move]
    ][move-or-shoot?]
]

move-arrow: func [room path /local i rnd-rm] [
    ;print reduce ["move arrow" room tab path]    ; FOR DEBUG USE
    if not tail? path [
        ; If they gave us a bogus target room, pick a random one.
        either find cave/:room first path [
            ; Next room in path is valid
            check-for-arrow-hit first path
            if finished [return]
            ; Recursive call
            move-arrow first path next path
        ][
            ; Pick a random direction
            i: random-direction
            check-for-arrow-hit rnd-rm: cave/:room/:i
            if finished [return]
            ; Recursive call
            move-arrow rnd-rm next path
        ]
    ]
]

shoot: func [/local path] [
    path: to-block ask "Enter 1 to 5 room numbers for the arrow's path: "
    move-arrow loc/:player path
    if not finished [
        print "Your arrow missed"
        move-wumpus
    ]
    ; See if the Wumpus moved onto the player
    if finished [return]

    arrow-count: arrow-count - 1
    if (arrow-count <= 0) [
        print reduce [newline "You ran out of arrows..."]
        winner: 'wumpus
        finished: true
        return
    ]

    check-for-hazards
]

check-for-arrow-hit: func [room] [
    if (room = loc/:wumpus) [
        print reduce [newline "You got the Wumpus!"]
        winner: 'player
        finished: true
        return
    ]
    if (room = loc/:player) [
        print reduce [newline "You shot yourself!"]
        winner: 'arrow
        finished: true
        return
    ]
]

; 75% chance that it will move
wumpus-moves?: does [either (random 4) < 4 [true][false]]

move-wumpus: does [
    if wumpus-moves? [loc/2: pick (pick cave loc/:wumpus) random-direction]
    if (loc/:wumpus = loc/:player) [
        winner: 'wumpus
        finished: true
    ]
]

move-player: func [/bat-move new-loc /local new-player-loc] [
    either bat-move [
        loc/1: new-loc
    ][
        new-player-loc: get-num "To which room? "
        ; Call recursively, then bail, if bad input
        if any [(new-player-loc < 1) (new-player-loc > 20)] [
            move-player
            return
        ]
        ; Call recursively, then bail, if illegal move
        if not find pick cave loc/:player new-player-loc [
            print "You can't move there, unless you plan to dig a new tunnel."
            move-player
            return
        ]
        ; It was a legal move, so update the player's location.
        change at loc player new-player-loc
    ]

    if (loc/:player = loc/:wumpus) [
        print "Yikes! You bumped the Wumpus!"
        move-wumpus
        ; See if the Wumpus moved onto the player
        if finished [return]
    ]
    if any [(loc/:player = loc/:pit-1) (loc/:player = loc/:pit-2) ] [
        print reduce [newline "Aaiiiiieeeee....(you fell in a pit)"]
        winner: 'pit
        finished: true
        return
    ]
    if any [(loc/:player = loc/:bats-1) (loc/:player = loc/:bats-2) ] [
        print "ZAP! Super-Bat snatch! Elsewhereville for you!"
        move-player/bat-move random-room
        return
    ]

    check-for-hazards

]

; This is ugly, but it works for now and avoids setup collisions.
; Don't really need items for this, but I'd like to improve it and then I might.
init-locations: func [/local items avail-rooms result offset] [
    random/seed now/time/precise
    items: [player wumpus pit-1 pit-2 bats-1 bats-2]
    avail-rooms: copy [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]
    result: make block! length? items
    repeat i length? items [
        ; Too dense for one line?
        ;append result pick avail-rooms offset: random length? avail-rooms
        offset: random/secure length? avail-rooms
        append result pick avail-rooms offset
        remove at avail-rooms offset
    ]
    return result
]

setup: func [/same-as-last] [
    ; Initialize arrow count.
    arrow-count: 5
    ; If we haven't setup before, or they want the same setup,
    ; there's no need to initialize.
    if any [(not same-as-last) (start-loc = none)] [
        ; Randomly place bats, pits, wumpus, and player
        start-loc: init-locations
    ]
    ; Make a working copy of the starting locations.
    loc: copy start-loc
]

do-game: func [/same-as-last] [
    either same-as-last [
        setup/same-as-last
    ][
        setup
    ]
    check-for-hazards
    while [not finished] [
        either move-or-shoot? = 'shoot [shoot][move-player]
    ]
    print switch winner [
        wumpus ["<SNARF> The Wumpus got you!!!"]
        player ["<BLARP> The Wumpus will get you next time!"]
        pit    ["<SPLAT> Better luck next time"]
        arrow  ["<GLURG> You really should be more careful"]
    ]
    print ""
]

start: does [
    if (ask "Would you like instructions (Y/N)? ") = "Y" [
        print-instructions
    ]
    play: "Y"
    same-setup: "N"
    while [play = "Y"] [
        either same-setup = "N" [
            do-game
        ][
            do-game/same-as-last
        ]
        play: ask "Play again (Y/N)? "
        if play = "Y" [
            winner: none
            finished: false
            same-setup: ask "Same setup (Y/N)? "
        ]
    ]
]

start