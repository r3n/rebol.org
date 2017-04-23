REBOL [ Title: "Chess moves generator"
        File: %chessmoves.r
        Date: 29-aug-2012
        Version: 0.1.2
        Author: "Arnold van Hofwegen"
        Purpose: "Generate all legitimate moves in any position."
        library: [
            level: 'intermediate
            platform: 'all
            type: [module game]
            domain: [game]
            tested-under: [Core 2.7.8 View 2.7.8 Windows MacOSX]
            support: "AltMe"
            license: 'lgpl
            see-also: [%cbh.r %chessimage.r]
        ]
]

{Goals for this program:
Achieved:
 - support a playable interface with moving pieces where all 
   reglementary moves of a selected piece show up on the board.
 - create a list with all allowed (legal) chessmoves in a given position.
 - support playing a game by two players.
To do:
 - support saving and reloading a game
Possible goals for future enhancements:
 - creating a UCI standards interface. (So this script can use any 
   open source chessengine using this interface to let it play a decent 
   game of chess. (Or have it give suggestions for the players).
 - support playing a game by two players over internet. This will need 
   checks for repetition of moves and the 50-moves rule(s).
 - create it's own simple algorithm to determine stronger moves from 
   bad moves and by doing so make it play a simple chess game.
 - support some analisys functions allowing comments and make it useful as a 
   demo and chesstutor application.
 - use databases for openingbooks and position-tables for the pieces during 
   the different stages of the game.
Advanced:
 - create an option to play random960 (FischerRandom) chess

If you think you can improve this script, you are hereby invited to 
improve this script.}

{Thinking of a smart way to import a game-position, the most human controllable
beside placing pieces on a board is probably entering a string representing 
the pieces and fields on the board and converting this to the internal format.

For example the string KanQanRanBanNanPan where a is a-h and n is 1-8 for white pieces
followed by a string for the black pieces. Each piece has its type specified, 
this makes checking the string for correctness a bit easier
 KE1 means K on field E1 still on initial position
 Ke1 means K on field e1 has moved. PE4 means the last move 
 was e2-e4 pawn coming from initial position 
 and thus allowing e.p. capture if possible.}

{Some basic rules for validating a valid chessgame situation.
Only 1 white King, only 1 black King, 
not more than 9 Queens for each side, 
not more than 10 rooks, 10 bisshops, 10 knights for each side, 
14 maximum total for each side.
maximum number of pawns for each side is 8. 
At most 16 white pieces, at most 16 black pieces.
At most 1 King is under attack, not both.
A field on the chessboard is empty or occupied by exactly 1 piece only.
Kings cannot be under attack by a pawn and a Knight at the same time.
No pawns on rows 1 and 8.}

{Pieces and fields under attack, counting in pieces attacking in the 
second degree, this is the influence representation of the board.
This could be possibly extended to keep a total of material values or an 
incremental list of values of pieces defending attacking the field.}

{For generated moves that result in a check, always check if it is checkmate.
Always check if there is at least 1 legal move left for the opponent, it could be
stalemate (or pat in dutch).}
;-------------------------------------------------------------------------------
; The code starts here
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; Initialisations
;-------------------------------------------------------------------------------
; Initialisation of the chessboard
empty-board: [ 0 0  0 0  0 0  0 0
               0 0  0 0  0 0  0 0
               0 0  0 0  0 0  0 0
               0 0  0 0  0 0  0 0
               0 0  0 0  0 0  0 0
               0 0  0 0  0 0  0 0
               0 0  0 0  0 0  0 0
               0 0  0 0  0 0  0 0 ]

; These items are different so declaration is seperate
black-board: copy empty-board
white-board: copy empty-board
 game-board: copy empty-board

;-------------------------------------------------------------------------------
; Initialisation of representational values of the pieces
  black:   1
 inipos:   2
   pawn:   4
 knight:   8
bisshop:  16
   rook:  32
  queen:  64
   king: 128
; Explanation of these values:  
; A field is occupied by a piece if the value on the board at the given
; fieldnumber is greater than 0.
; The white-king has a representational value of 128 and on his initial 
; position it will be 130. For the black-king these values are 129 and 131.
; Example: Test for a king.
; Given a valid number for a piece in the variable piece this test is
; piece and king = king (or test for: king and piece = king)
; Testing for the color of the piece could also be done like this
; piece and black = black (or piece and black = 1) this results in 
; true for black pieces and false for white pieces.
; But an even simpler test for color is:
; print either odd? piece ["This piece is black!"]["This piece is white!"]
;-------------------------------------------------------------------------------

; Initialisation of material values of the pieces
   matval-pawn:    1
 matval-knight:    3
matval-bisshop:    3
   matval-rook:    5
  matval-queen:    9
   matval-king: 9000

;-------------------------------------------------------------------------------
; Initial values for who is to play
white-to-move: not black-to-move: false

; Variables that come in handy later on
field-white-king: 0
field-black-king: 0
rochade: [1.1.1 1.1.1]

;-------------------------------------------------------------------------------
; Import a game position in to the program.
;-------------------------------------------------------------------------------
piece-value: func [piece-as-string] [
    switch piece-as-string [
        "p" "P" [return pawn]    ;-- most of the time most pieces are pawns
        "k" "K" [return king]    ;-- always kings on the board
        "r" "R" [return rook]
        "b" "B" [return bisshop]
        "n" "N" [return knight]
        "q" "Q" [return queen]   ;-- only 1 per color to start with
    ]
]

board-to-field: func [letternumber [string!] /local letter board-row] [
    letter: to-string first letternumber
    board-row: to-integer to-string last letternumber
    switch letter [
        "a" "A" [return board-row]
        "b" "B" [return 8 + board-row]
        "c" "C" [return 16 + board-row]
        "d" "D" [return 24 + board-row]
        "e" "E" [return 32 + board-row]
        "f" "F" [return 40 + board-row]
        "g" "G" [return 48 + board-row]
        "h" "H" [return 56 + board-row]
    ]
    return 0
]
 
; Reading in a position to the board
import-position: func [input-position [string!]
                       istomove [integer!]
                       ] [
    init-influence
    init-material-value
    init-pins
    white-pieces: head clear find/last copy input-position "K"
    black-pieces: replace copy input-position white-pieces ""
    either istomove = 0 [
        white-to-move: not black-to-move: false
    ][
        white-to-move: not black-to-move: true
    ]
    error-in-position: false
    error-description: copy ""
    if  48 < length? white-pieces [
        error-in-position: true
        error-description: repend error-description ["** Too many white pieces." newline]
    ]
    if  48 < length? black-pieces [
        error-in-position: true
        error-description: repend error-description ["** Too many black pieces." newline]
    ]

    white-pieces: head white-pieces
    while [all [not tail? white-pieces
                not error-in-position ]] [
        pieceval: piece-value copy/part white-pieces 1
        pieceline: copy/part next white-pieces 1
        piecefield:  copy/part next black-pieces 2
        fieldnr: board-to-field copy/part next white-pieces 2
         either all [integer? fieldnr
                    fieldnr > 0 
                    fieldnr < 65] [
           iniposval: either strict-equal? pieceline uppercase copy pieceline [inipos][0]
           either 0 = game-board/(fieldnr) [
               game-board/(fieldnr): white-board/(fieldnr): pieceval + iniposval
               if pieceval and king = king [field-white-king: fieldnr]
               add-value pieceval 0
          ][
               error-in-position: true
               error-description: repend error-description ["** Field " fieldnr 
                   " already occupied by another piece. Fieldvalue: " 
                   game-board/(fieldnr) newline]
           ]
        ][
            error-in-position: true
            error-description: repend error-description ["** Field unknown value " 
                piecefield newline]
        ]
        white-pieces: skip white-pieces 3
    ]
    black-pieces: head black-pieces
    while [all [not tail? black-pieces
                not error-in-position ]] [
        pieceval: piece-value copy/part black-pieces 1
        pieceline: copy/part next black-pieces 1
        piecefield:  copy/part next black-pieces 2
        fieldnr: board-to-field copy/part next black-pieces 2
        either all [integer? fieldnr
                    fieldnr > 0 
                    fieldnr < 65] [
            iniposval: either strict-equal? pieceline uppercase copy pieceline [inipos][0]
            either 0 = game-board/(fieldnr) [
                game-board/(fieldnr): black-board/(fieldnr): pieceval + iniposval + 1
                if pieceval and king = king [field-black-king: fieldnr]
                add-value pieceval 1
            ][
                error-in-position: true
                error-description: repend error-description ["** Field " fieldnr 
                    " already occupied by another piece. Fieldvalue: " 
                    game-board/(fieldnr) newline]
            ]
        ][
            error-in-position: true
            error-description: repend error-description ["** Field unknown value " 
                piecefield newline]
        ]
        black-pieces: skip black-pieces 3
    ]
    ; initialise all white pawns at 2nd row en black pawns on 7th row on initial position
    for n 2 58 8 [
        if  all [ pawn and game-board/(n) = pawn
                  black and game-board/(n) <> black] [
            game-board/(n): game-board/(n) or 2
            white-board/(n): game-board/(n)
        ]
    ]
    for n 7 63 8 [
        if  all [ pawn and game-board/(n) = pawn
                  black and game-board/(n) = black] [
            game-board/(n): game-board/(n) or 2
            black-board/(n): game-board/(n)
        ]
    ]
]
;-------------------------------------------------------------------------------
; Determining all valid chess moves from a given poition
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Tables, or move generation data.
;-------------------------------------------------------------------------------
; Rows and files of the chessboard
;---------------------------------
allrows:  [[   1   9  17  25  33  41  49  57  ]
           [   2  10  18  26  34  42  50  58  ]
           [   3  11  19  27  35  43  51  59  ]
           [   4  12  20  28  36  44  52  60  ]
           [   5  13  21  29  37  45  53  61  ]
           [   6  14  22  30  38  46  54  62  ]
           [   7  15  23  31  39  47  55  63  ]
           [   8  16  24  32  40  48  56  64  ]
] 
allfiles: [[  1   2   3   4   5   6   7   8  ]
           [  9  10  11  12  13  14  15  16  ]
           [ 17  18  19  20  21  22  23  24  ]
           [ 25  26  27  28  29  30  31  32  ]
           [ 33  34  35  36  37  38  39  40  ]
           [ 41  42  43  44  45  46  47  48  ]
           [ 49  50  51  52  53  54  55  56  ]
           [ 57  58  59  60  61  62  63  64  ]
]

fieldsinrow: func [fieldnr /local rownr] [
    fieldnr: fieldnr - 1
    rownr:  fieldnr // 8 + 1
    pick allrows rownr
]

fieldsinfile: func [fieldnr /local filenr] [
    fieldnr: fieldnr - 1
    filenr: to-integer fieldnr / 8 + 1
    pick allfiles filenr
]

; Diagonals
;---------------------------------
; linksonder naar rechtsboven (slash type diagonals)
dia-sl:  [[   8                              ] ;  1
          [   7  16                          ] ;  2
          [   6  15  24                      ] ;  3
          [   5  14  23  32                  ] ;  4
          [   4  13  22  31  40              ] ;  5
          [   3  12  21  30  39  48          ] ;  6
          [   2  11  20  29  38  47  56      ] ;  7
          [   1  10  19  28  37  46  55  64  ] ;  8
          [       9  18  27  36  45  54  63  ] ;  9
          [          17  26  35  44  53  62  ] ; 10
          [              25  34  43  52  61  ] ; 11
          [                  33  42  51  60  ] ; 12
          [                      41  50  59  ] ; 13
          [                          49  58  ] ; 14
          [                              57  ] ; 15
]
; rechtsonder naar linksboven (backslash type diagonals)
dia-bsl: [[  64                              ] ;  1 
          [  63  56                          ] ;  2
          [  62  55  48                      ] ;  3
          [  61  54  47  40                  ] ;  4
          [  60  53  46  39  32              ] ;  5
          [  59  52  45  38  31  24          ] ;  6
          [  58  51  44  37  30  23  16      ] ;  7
          [  57  50  43  36  29  22  15   8  ] ;  8
          [      49  42  35  28  21  14   7  ] ;  9
          [          41  34  27  20  13   6  ] ; 10
          [              33  26  19  12   5  ] ; 11
          [                  25  18  11   4  ] ; 12
          [                      17  10   3  ] ; 13
          [                           9   2  ] ; 14
          [                               1  ] ; 15
]

; compute which diagonal in dia-sl (slash)
dia-sl-nr: func [fieldnr] [
    fieldnr: fieldnr - 1
    return (to-integer fieldnr / 8) + 8 - (fieldnr // 8)
]

; compute which diagonal in dia-bsl (backslash)
dia-bsl-nr: func [fieldnr] [
    fieldnr: fieldnr - 1
    return 15 - (to-integer fieldnr / 8) - (fieldnr // 8)
]

knightsjump: [ 
     [ 11 18 ]       [ 12 17 19 ]          [  9 13 18 20 ]             [ 10 14 19 21 ]             [ 11 15 20 22 ]             [ 12 16 21 23 ]             [ 13 22 24 ]          [ 14 23 ]
     [  3 19 26 ]    [  4 20 25 27 ]       [  1  5 17 21 26 28 ]       [  2  6 18 22 27 29 ]       [  3  7 19 23 28 30 ]       [  4  8 20 24 29 31 ]       [  5 21 30 32 ]       [  6 22 31 ]
     [  2 11 27 34 ] [  1  3 12 28 33 35 ] [  2  4  9 13 25 29 34 36 ] [  3  5 10 14 26 30 35 37 ] [  4  6 11 15 27 29 36 38 ] [  5  7 12 16 28 32 37 39 ] [  6  8 13 29 38 40 ] [  7 14 30 39 ]
     [ 10 19 35 42 ] [  9 11 20 36 41 43 ] [ 10 12 17 21 33 37 42 44 ] [ 11 13 18 22 34 38 43 45 ] [ 12 14 19 23 35 39 44 46 ] [ 13 15 20 24 36 40 45 47 ] [ 14 16 21 37 46 48 ] [ 15 22 38 47 ]
     [ 18 27 43 50 ] [ 17 19 28 44 49 51 ] [ 18 20 25 29 41 45 50 52 ] [ 19 21 26 30 42 46 51 53 ] [ 20 22 27 31 43 47 52 54 ] [ 21 23 28 32 44 48 53 55 ] [ 22 24 29 45 54 56 ] [ 23 30 46 55 ]
     [ 26 35 51 58 ] [ 25 27 36 52 57 59 ] [ 26 28 33 37 49 53 58 60 ] [ 27 29 34 38 50 54 59 61 ] [ 28 30 35 39 51 55 60 62 ] [ 29 31 36 40 52 56 61 63 ] [ 30 32 37 53 62 64 ] [ 31 38 54 63 ]
     [ 34 43 59 ]    [ 33 35 44 60 ]       [ 34 36 41 45 57 61 ]       [ 35 37 42 46 58 62 ]       [ 36 38 43 47 59 63 ]       [ 37 39 44 48 60 64 ]       [ 38 40 45 61 ]       [ 39 46 62 ]
     [ 42 51 ]       [ 41 43 52 ]          [ 42 44 49 53 ]             [ 43 45 50 54 ]             [ 44 46 51 55 ]             [ 45 47 52 56 ]             [ 46 48 53 ]          [ 47 54 ]
]


{Moves are Piece start-field end-field }


; Putting a material value to the position on the board
; more is better, (un)fortunately in chess this is relative.
init-material-value: func [] [
    material-value-white: 0
    material-value-black: 0
]

add-value: func [piece-as-value] [
    switch piece-as-value [
          4   6 [material-value-white: material-value-white + matval-pawn]
          5   7 [material-value-black: material-value-black + matval-pawn]
        128 130 [material-value-white: material-value-white + matval-king]
        129 131 [material-value-black: material-value-black + matval-king]
         32  34 [material-value-white: material-value-white + matval-rook] 
         33  35 [material-value-black: material-value-black + matval-rook]
         16  18 [material-value-white: material-value-white + matval-bisshop] 
         17  19 [material-value-black: material-value-black + matval-bisshop]
          8  10 [material-value-white: material-value-white + matval-knight]
          9  11 [material-value-black: material-value-black + matval-knight]
         64  66 [material-value-white: material-value-white + matval-queen]
         65  67 [material-value-black: material-value-black + matval-queen]
    ]
]

;********************************************
; Collecting board information.
; Needed for influence (check a.o.) and pins.
;********************************************
; Pins/pinning (Penningen)
; test if an opponents queen or rook is on the same line/file or row as the own king
; test if an opponents queen or bisshop is on the same diagonal as the own king
; If a piece is pinned it stil can move legally along the direction of the pinning.
; Directions are -7 +1 +9
;                -8    +8
;                -9 -1 +7
; so values to be used are 1, 7, 8 and 9. (But if we use 2 instead of 1,
; then odd/even is our friend again).
; diagonal:	sl	bsl
; b         0   0
; w w       0   0
; w bb      9   7 -- one white piece then a black bisshop
; w bq      9   7
; w b       0   0 -- other piece
; 
; straight:  row file/line
; b          0   0
; w w        0   0
; w br       8   2
; w bq       8   2
; w b	     0	 0
; Only one pins-board is needed
                      
init-influence: func [] [
    infl-white: copy empty-board
    infl-black: copy empty-board
]

init-pins: func [] [
    pins-board: copy empty-board
]

get-pin-var: func [apiece own] [
    ; We are making a string of pieces 
    ; o for own piece
    ; k q r b n p for an enemy piece
    ; space for empty field
    if  0 = apiece [return " "]
    either odd? own [
        if odd? apiece [return "o"]
    ][
        if even? apiece [return "o"]
    ]
    switch/default apiece [
        64 64 65 66 [return "q"]
        32 33 34 35 [return "r"]
        16 17 18 19 [return "b"]
    ][return "x"] ;-- default value enemy piece "x"
]

king-infl-pins: func [a [series!] "fields in directions" 
                      i [integer!] "field the king is at"
                      kingpiece "Even is White odd is Black"
                      pindir "Direction of movement-freedom for pinned piece" 
                      /local b c pindex] [
    c: reverse copy/part a back b: find/tail a i
    if  not tail? c [
        either odd? kingpiece [
            infl-black/(first c): infl-black/(first c) + 1
        ][
            infl-white/(first c): infl-white/(first c) + 1
        ]
        pindex: 0
        pinstring: copy ""
        while [not tail? c] [ 
            pinstring: append pinstring get-pin-var game-board/(first c) kingpiece
            c: next c
        ]
        if found? find pinstring "o" [pindex: index? find pinstring "o"]
        pinstring: trim/all pinstring
        either odd? pindir [ ;-- diagonals
            if  parse pinstring ["ob" to end | "oq" to end] [
                c: head c
                pins-board/(c/:pindex): pindir
            ]
        ][
            if  parse pinstring ["or" to end | "oq" to end] [
                c: head c
                pins-board/(c/:pindex): pindir
            ]
        ]
    ]
    if  not tail? b [
        either odd? kingpiece [
            infl-black/(first b): infl-black/(first b) + 1
        ][
            infl-white/(first b): infl-white/(first b) + 1
        ]
        pindex: 0
        pinstring: copy ""
        while [not tail? b] [ 
            pinstring: append pinstring get-pin-var game-board/(first b) kingpiece
            b: next b
        ]
        if found? find pinstring "o" [pindex: index? find pinstring "o"]
        pinstring: trim/all pinstring
        either odd? pindir [ ;-- diagonals
            if  parse pinstring ["ob" to end | "oq" to end] [
                b: head b
                pins-board/(b/:pindex): pindir
            ]
        ][
            if  parse pinstring ["or" to end | "oq" to end] [
                b: head b
                pins-board/(b/:pindex): pindir
            ]
        ]
    ]
]

rook-infl-steps: func [steps [series!] w-or-b [integer!] 
                       /local loc temp step-on infl-value] [
    step-on: true
    infl-value: 1
    while [all [not tail? steps
                step-on        ]] [
        loc: first steps
        temp: game-board/(loc)
        either odd? w-or-b [
            infl-black/(loc): infl-black/(loc) + infl-value
        ][
            infl-white/(loc): infl-white/(loc) + infl-value
        ]
        if  0 <> temp [
            ; own color? enemy color?
            either any [all [odd? w-or-b 
                             odd? temp]
                        all [even? w-or-b 
                             even? temp] ][    
                either any [temp and queen = queen
                            temp and rook = rook] [
                    infl-value: 11
                ][
                    step-on: false
                ]
            ][  ;-- other color but look right through the enemy king
                if  not all [temp and king = king
                             any [all [odd? temp even? w-or-b]
                                  all [odd? temp even? w-or-b]]] [
                    step-on: false
                ]
            ]
        ]
        steps: next steps
    ]

]

rook-infl: func [i [integer!]
                 rookpiece [integer!]] [
    a: fieldsinrow i
    ; This short solution was suggested by Steeve
    c: reverse copy/part a back b: find/tail a i
    rook-infl-steps b rookpiece
    rook-infl-steps c rookpiece
    a: fieldsinfile i
    c: reverse copy/part a back b: find/tail a i
    rook-infl-steps b rookpiece
    rook-infl-steps c rookpiece
]

bisshop-infl-steps: func [steps [series!] w-or-b [integer!] 
                          /local loc temp step-on infl-value] [
    step-on: true
    infl-value: 1
    while [all [not tail? steps
                step-on        ]] [
        loc: first steps
        temp: game-board/(loc)
        either odd? w-or-b [
            infl-black/(loc): infl-black/(loc) + infl-value
        ][
            infl-white/(loc): infl-white/(loc) + infl-value
        ]
        if  0 <> temp [
            ; own color? enemy color?
            either any [all [odd? w-or-b 
                        odd? temp]
                        all [even? w-or-b 
                        even? temp] ][    
                either any [temp and queen = queen
                            temp and bisshop = bisshop] [
                    infl-value: 11  
                ][
                    step-on: false
                ]
            ][ ;-- other color but look right through the enemy king
                if  not all [temp and king = king
                             any [all [odd? temp even? w-or-b]
                                  all [odd? temp even? w-or-b]]] [
                    step-on: false
                ]
            ]
        ]
        steps: next steps
    ]
]

bisshop-infl: func [i [integer!]
                    bisshoppiece [integer!]] [
    a: dia-sl/(dia-sl-nr i)
    c: reverse copy/part a back b: find/tail a i
    bisshop-infl-steps b bisshoppiece
    bisshop-infl-steps c bisshoppiece
    a: dia-bsl/(dia-bsl-nr i)
    c: reverse copy/part a back b: find/tail a i
    bisshop-infl-steps b bisshoppiece
    bisshop-infl-steps c bisshoppiece
]

; The board is filled with values of pieces occupying the board
; Determine the influences
fill-influence: func [/local a pindir thispiece] [
    for i 1 64 1 [
        if  0 <> game-board/(i) [
            thispiece: game-board/(i)
            switch thispiece [
                128 130 129 131 [ ;-- king
                    a: fieldsinrow i
                    pindir: 8
                    king-infl-pins a i thispiece pindir
                    a: fieldsinfile i
                    pindir: 2
                    king-infl-pins a i thispiece pindir
                    a: dia-sl/(dia-sl-nr i)
                    pindir: 9
                    king-infl-pins a i thispiece pindir
                    a: dia-bsl/(dia-bsl-nr i)
                    pindir: 7
                    king-infl-pins a i thispiece pindir
                ]
                64 66 65 67   [ ;-- queen
                    ; do the steps for the rook
                    ; and those for the bisshop
                    rook-infl i thispiece
                    bisshop-infl i thispiece
                ]
                32 34 33 35   [ ;-- rook
                    rook-infl i thispiece
                ]
                16 18 17 19   [ ;-- bisshop
                    bisshop-infl i thispiece
                ]
                8 10 9 11    [ ;-- knight
                    foreach jump knightsjump/:i [
                        either odd? thispiece [
                            infl-black/(jump): infl-black/(jump) + 1
                        ][
                            infl-white/(jump): infl-white/(jump) + 1                           
                        ]
                    ]
                ]
                4 6 5 7     [ ;-- pawn or make this default / move to top
                    filenr: to-integer i - 1 / 8 + 1
                    either odd? thispiece [
                        if filenr < 8 [
                            infl-black/(i + 7): infl-black/(i + 7) + 1
                        ]
                        if filenr > 1 [
                            infl-black/(i - 9): infl-black/(i - 9) + 1
                        ]
                    ][
                        if filenr > 1 [
                            infl-white/(i - 7): infl-white/(i - 7) + 1
                        ]
                        if filenr < 8 [
                            infl-white/(i + 9): infl-white/(i + 9) + 1
                        ]
                    ]
                ]
            ]     
        ]
    ]    
]

;-----------------------------------------------------------------
; Influences filled and pins determined, time to create some moves
;
from-to-fields: copy []
played-moves: copy []
legal-moves: copy []
history-moves: copy []

init-moves: func [] [
    from-to-fields: copy []
    legal-moves: copy []
]
 
add-moves: func [thispiece [integer!] i [integer!] these-moves [series! block!]] [
; The legal-moves are the moves that will be shown in the display
; The from-to-fields block is to show the player what possible moves are valid
; for a certain piece.
    foreach move these-moves [
        legal-moves: append/only legal-moves compose[(piece-to-letter thispiece) " " 
                    (field-to-a1h8 i) " " (field-to-a1h8 move)]  
    ]
    either found? find from-to-fields i [
        append first next find from-to-fields i these-moves
    ][
        from-to-fields: append from-to-fields i
        from-to-fields: append/only from-to-fields these-moves
    ]
]

fieldnr-to-row: func [i [integer!]] [
    i - 1 // 8 + 1
]

fieldnr-to-file: func [i [integer!]] [
    to-integer i - 1 / 8 + 1
]

add-pawn-moves: func [thispiece [integer!] i [integer!] 
                      /local these-moves filenr rownr] [
    ; pawns can capture other pawns "en passant"
    ; Pawn moves are also promotions to either Q R B N
    ; black pawns move downward, white pawns upward (w-or-b)
    these-moves: copy []
    filenr: fieldnr-to-file i
    rownr: fieldnr-to-row i
    ; capturing moves
    either odd? thispiece [
        if  filenr < 8 [
            if  any [0 = pins-board/(i)
                     7 = pins-board/(i)] [
                if  0 <> white-board/(i + 7) [
                    these-moves: append these-moves i + 7
                ]
                if  all [4 = rownr
                    pawn and white-board/(i + 8) = pawn
                    inipos and white-board/(i + 8) = inipos] [
                    these-moves: append these-moves i + 7
                ]
            ]
        ]
        if  filenr > 1 [
            if  any [0 = pins-board/(i)
                     9 = pins-board/(i)] [
                if  0 <> white-board/(i - 9) [
                    these-moves: append these-moves i - 9
                ]
                if  all [4 = rownr
                         pawn and white-board/(i - 8) = pawn
                         inipos and white-board/(i - 8) = inipos] [
                    these-moves: append these-moves i - 9
                ]
            ]
        ]
    ][
        if  filenr > 1 [
            if  any [0 = pins-board/(i)
                     7 = pins-board/(i)] [
                if  0 <> black-board/(i - 7) [
                    these-moves: append these-moves i - 7
                ]
                if  all [5 = rownr
                         pawn and black-board/(i - 8) = pawn
                         inipos and black-board/(i - 8) = inipos] [
                    these-moves: append these-moves i - 7
                ]
            ]
        ]
        if  filenr < 8 [
            if       any [0 = pins-board/(i)
                          9 = pins-board/(i)] [
                if  0 <> black-board/(i + 9) [
                    these-moves: append these-moves i + 9
                ]
                if  all [5 = rownr
                         pawn and black-board/(i + 8) = pawn
                         inipos and black-board/(i + 8) = inipos] [
                    these-moves: append these-moves i + 9
                ]
            ]
        ]
    ]
; Normal pawn moves white
    if  all [even? thispiece 
             0 = game-board/(i + 1)
             any [0 = pins-board/(i)
                  2 = pins-board/(i)]] [
        these-moves: append these-moves i + 1
        if  all [2 = rownr
                 0 = game-board/(i + 2)] [
            these-moves: append these-moves i + 2
        ]
    ]
; Normal pawn moves black
    if  all [odd? thispiece 
             0 = game-board/(i - 1)
             any [0 = pins-board/(i)
                  2 = pins-board/(i)]] [
        these-moves: append these-moves i - 1
        if  all [7 = rownr
                 0 = game-board/(i - 2)] [
            these-moves: append these-moves i - 2
        ]
    ]
    if  resolve-chess [
        these-moves: intersect these-moves chess-resolvers
    ]
    if 0 < length? these-moves [add-moves thispiece i these-moves]
]

king-step: func [a [series!] i [integer!] thispiece [integer!]
                 /local b c t part-moves] [
    part-moves: copy []
    c: reverse copy/part a back b: find/tail a i
    either odd? thispiece [
        if  not tail? b [
            t: first b
            if  all [any [0 = game-board/(t) even? game-board/(t)]
                     0 = infl-white/(t)] [
                part-moves: append part-moves t
            ]
        ]
        if  not tail? c [
            t: first c
            if  all [any [0 = game-board/(t) even? game-board/(t)]
                     0 = infl-white/(t)] [
                part-moves: append part-moves t
            ]
        ]
    ][
        if  not tail? b [
            t: first b
            if  all [any [0 = game-board/(t) odd? game-board/(t)]
                     0 = infl-black/(t)] [
                part-moves: append part-moves t
            ]
        ]
        if  not tail? c [
            t: first c
            if  all [any [0 = game-board/(t) odd? game-board/(t)]
                     0 = infl-black/(t)] [
                part-moves: append part-moves t
            ]
        ]
    ]
    return part-moves
]

add-king-moves: func [thispiece [integer!] i [integer!] /local a these-moves] [
    ; King can only move to field that are not occupied by own pieces and 
    ; only then if the field is not under enemy attack (influence).
    ; King moves are also rochades, remember?
    these-moves: copy []
; Normal king moves
    a: fieldsinrow i
    these-moves: append these-moves king-step a i thispiece 
    a: fieldsinfile i
    these-moves: append these-moves king-step a i thispiece 
    a: dia-sl/(dia-sl-nr i)
    these-moves: append these-moves king-step a i thispiece 
    a: dia-bsl/(dia-bsl-nr i)
    these-moves: append these-moves king-step a i thispiece 

; White rochade on the queen-side (0-0-0)
    if  all [even? thispiece
             1 = rochade/1/2
             1 = rochade/1/1
             0 = game-board/(i - 8)
             0 = game-board/(i - 16)
             0 = infl-black/(i)
             0 = infl-black/(i - 8)
             0 = infl-black/(i - 16)] [
            these-moves: append these-moves i - 16        
     ]
; White rochade on the king-side (0-0)
    if  all [even? thispiece
             1 = rochade/1/2
             1 = rochade/1/3
             0 = game-board/(i + 8)
             0 = game-board/(i + 16)
             0 = infl-black/(i)
             0 = infl-black/(i + 8)
             0 = infl-black/(i + 16)] [
            these-moves: append these-moves i + 16        
     ]
; Black rochade on the queen-side (0-0-0)
    if  all [odd? thispiece
             1 = rochade/2/2
             1 = rochade/2/1
             0 = game-board/(i - 8)
             0 = game-board/(i - 16)
             0 = infl-white/(i)
             0 = infl-white/(i - 8)
             0 = infl-white/(i - 16)] [
            these-moves: append these-moves i - 16        
     ]
; Black rochade on the king-side (0-0)
    if  all [odd? thispiece
             1 = rochade/2/2
             1 = rochade/2/3
             0 = game-board/(i + 8)
             0 = game-board/(i + 16)
             0 = infl-white/(i)
             0 = infl-white/(i + 8)
             0 = infl-white/(i + 16)] [
            these-moves: append these-moves i + 16        
     ]
     if 0 < length? these-moves [add-moves thispiece i these-moves]
]

; No function add-queen-moves present for these moves are the rook moves 
; combined with the bisshop moves.

steps-rook-bisshop: func [steps [series!] w-or-b [integer!] 
                          /local part-moves step-on loc temp] [
    part-moves: copy []
    step-on: true
    while [all [not tail? steps
                step-on        ]] [
        loc: first steps
        temp: game-board/(loc)
        either 0 = temp [
            part-moves: append part-moves loc
        ][
            either any [all [odd? w-or-b
                        0 = white-board/(loc)]
                        all [even? w-or-b
                        0 = black-board/(loc)]][
                step-on: false
            ][
                part-moves: append part-moves loc
                step-on: false                
            ]
        ]
        steps: next steps
    ]
    return part-moves
]

add-rook-moves: func [thispiece [integer!] i [integer!] /local a b c these-moves] [
    ; these rook moves are also reused for moves of the queens
    ; The rochade will be considered with the king moves
    these-moves: copy []
    if  any [0 = pins-board/(i)
             8 = pins-board/(i)] [
        a: fieldsinrow i
        c: reverse copy/part a back b: find/tail a i
        these-moves: append these-moves steps-rook-bisshop b thispiece
        these-moves: append these-moves steps-rook-bisshop c thispiece
    ]
    if  any [0 = pins-board/(i)
             2 = pins-board/(i)] [
        a: fieldsinfile i
        c: reverse copy/part a back b: find/tail a i
        these-moves: append these-moves steps-rook-bisshop b thispiece
        these-moves: append these-moves steps-rook-bisshop c thispiece    
    ]
    if  resolve-chess [
        these-moves: intersect these-moves chess-resolvers
    ]
    if 0 < length? these-moves [add-moves thispiece i these-moves]
]

add-bisshop-moves: func [thispiece [integer!] i [integer!] /local a b c these-moves] [
    ; these bisshop moves are also reused for moves of the queens
    these-moves: copy []
    if  any [0 = pins-board/(i)
             9 = pins-board/(i)] [
        a: dia-sl/(dia-sl-nr i)
        c: reverse copy/part a back b: find/tail a i
        these-moves: append these-moves steps-rook-bisshop b thispiece
        these-moves: append these-moves steps-rook-bisshop c thispiece
    ]
    if  any [0 = pins-board/(i)
             7 = pins-board/(i)] [
        a: dia-bsl/(dia-bsl-nr i)
        c: reverse copy/part a back b: find/tail a i
        these-moves: append these-moves steps-rook-bisshop b thispiece
        these-moves: append these-moves steps-rook-bisshop c thispiece 
    ]   
    if  resolve-chess [
        these-moves: intersect these-moves chess-resolvers
    ]
    if 0 < length? these-moves [add-moves thispiece i these-moves]
]

add-knight-moves: func [thispiece [integer!] i [integer!] /local jump these-moves] [
    these-moves: copy []
    if 0 = pins-board/(i) [
        foreach jump knightsjump/:i [
            either odd? thispiece [
                if 0 = black-board/(jump) [these-moves: append these-moves jump]
            ][
                if 0 = white-board/(jump) [these-moves: append these-moves jump]
            ]
        ]
    ]
    if  resolve-chess [
        these-moves: intersect these-moves chess-resolvers
    ]
    if 0 < length? these-moves [add-moves thispiece i these-moves]
]

check-lines: func [fields dia-hv
                   /local result step-on thispiece] [
    result: copy []
    step-on: true
    return-fields: false
    while [all [not tail? fields
               step-on]] [
        result: append result first fields
        if  0 <> game-board/(first fields) [
            step-on: false
            thispiece: game-board/(first fields)
            either 1 = dia-hv [ ; diagonal, look for bisshop or queen
                if  any 
                    [all [ white-to-move
                           odd? thispiece
                           any [ queen and thispiece = queen
                                 bisshop and thispiece = bisshop]
                         ]
                     all [ not white-to-move
                           even? thispiece
                           any [ queen and thispiece = queen
                                 bisshop and thispiece = bisshop]
                         ]
                    ] [
                    return-fields: true
                ]
            ][  ; hor or vert, look for rook or queen
                if  any 
                    [all [ white-to-move
                           odd? thispiece
                           any [ queen and thispiece = queen
                                 rook and thispiece = rook]
                         ]
                     all [ not white-to-move
                           even? thispiece
                           any [ queen and thispiece = queen
                                 rook and thispiece = rook]
                         ]
                    ] [
                    return-fields: true
                ]
            ]
        ] 
        fields: next fields  
    ]
    either return-fields [return result][return copy []]
]

make-moves: func [/local n thispiece number-of-moves] [
    init-moves
    number-of-moves: 0
    info-txt: copy ""
    legal-moves: copy []
    ; Make all pawns of the own color on the 4 th row reset their inipos bit
    either white-to-move [
        for n 4 60 8 [
            if  all [pawn and game-board/(n) = pawn
                     black and game-board/(n) <> black
                     inipos and game-board/(n) = inipos] [
                white-board/(n): game-board/(n): game-board/(n) and 253
            ]
        ]
    ][
        for n 5 61 8 [
            if  all [pawn and game-board/(n) = pawn
                     black and game-board/(n) = black
                     inipos and game-board/(n) = inipos] [
                black-board/(n): game-board/(n): game-board/(n) and 253
            ]
        ]
    ]
    ; if chess
    resolve-chess: false
    chess-resolvers: copy []
    either white-to-move [
        if 0 < infl-black/(field-white-king) [
            info-txt: "White chess!"
            resolve-chess: true
        ]
    ][
        if 0 < infl-white/(field-black-king) [
            info-txt: "Black chess!"
            resolve-chess: true
        ]
    ]
    
   if  resolve-chess [
       either white-to-move [
            kings-field: field-white-king
            help-the-king: infl-black/(kings-field)
        ][ 
            kings-field: field-black-king
            help-the-king: infl-white/(kings-field)
        ]
        king-row: fieldnr-to-row kings-field
        king-file: fieldnr-to-file kings-field
        add-king-moves game-board/(kings-field) kings-field 
        thetens:  to-integer help-the-king / 10
        theunits: help-the-king // 10
        if  1 = (theunits - thetens) [
            ; Not more than 1 direction of chess so it is possible to place
            ; a piece in between the king and the attacker or 
            ; capture the attacker.
            ; determine the collection of target field moves to capture the
            ; attacker or place a piece in between the king and the attacker.
            ; check chess by a pawn (only possible for black king above 2nd row
            ; and white king below 7th row)
            if  any [all [white-to-move 
                          king-row < 7]
                     all [black-to-move
                          king-row > 2]] [
                if  king-file > 1 [
                    either white-to-move [
                        if  pawn and black-board/(kings-field - 7) = pawn [
                            chess-resolvers: append chess-resolvers kings-field - 7
                        ]
                    ][
                        if  pawn and white-board/(kings-field + 9) = pawn [
                            chess-resolvers: append chess-resolvers kings-field + 9
                        ]                        
                    ]
                ]
                if  king-file < 8 [
                    either white-to-move [
                        if  pawn and black-board/(kings-field + 9) = pawn [
                            chess-resolvers: append chess-resolvers kings-field + 9
                        ]
                    ][
                        if  pawn and white-board/(kings-field - 7) = pawn [
                            chess-resolvers: append chess-resolvers kings-field - 7
                        ]                        
                    ]
                ]
            ]
            ; check chess by a knight (Not placing pieces in between possible)
            if  0 = length? chess-resolvers [
                fromknight: knightsjump/:kings-field
                either white-to-move [
                    foreach jump fromknight [
                        if  knight and white-board/(jump) = knight [
                            chess-resolvers: append chess-resolvers jump
                        ]
                    ]
                ][
                    foreach jump fromknight [
                        if  knight and black-board/(jump) = knight [
                            chess-resolvers: append chess-resolvers jump
                        ]
                    ]
                ]
            ]
            ; check other directions if not some found at this point.
            ; In theory if the last move was by a queen, she must be the piece
            ; that attacks the king. Also this could be made smarter if the 
            ; number of bisshops, rooks and queens would be known, for if there 
            ; are for example no queens and rooks left the check for 
            ; horizontal and vertical lines is superfluous.
            if  0 = length? chess-resolvers [
                ; my guess is chess via verticals is less common, so start with
                ; diagonals and horizontal before vertical checks
                a: dia-sl/(dia-sl-nr kings-field)
                c: reverse copy/part a back b: find/tail a kings-field
                chess-resolvers: append chess-resolvers check-lines b 1
                if  0 = length? chess-resolvers [
                    chess-resolvers: append chess-resolvers check-lines c 1
                ]
                if  0 = length? chess-resolvers [
                    a: dia-bsl/(dia-bsl-nr kings-field)
                    c: reverse copy/part a back b: find/tail a kings-field
                    chess-resolvers: append chess-resolvers check-lines b 1
                ]
                if  0 = length? chess-resolvers [
                    chess-resolvers: append chess-resolvers check-lines c 1
                ]
                if  0 = length? chess-resolvers [
                    a: fieldsinrow kings-field
                    c: reverse copy/part a back b: find/tail a kings-field
                    chess-resolvers: append chess-resolvers check-lines b 0
                ]
                if  0 = length? chess-resolvers [
                    chess-resolvers: append chess-resolvers check-lines c 0
                ]
                if  0 = length? chess-resolvers [
                    a: fieldsinrow kings-field
                    c: reverse copy/part a back b: find/tail a kings-field
                    chess-resolvers: append chess-resolvers check-lines b 0
                ]
                if  0 = length? chess-resolvers [
                    chess-resolvers: append chess-resolvers check-lines c 0
                ]
            ]
            ; Sorting is not necessary here, handy while debugging, so kept it.
            chess-resolvers: sort chess-resolvers
            
            ; There is now a collection of destination fields, we can use 
            ; intersect series1 series2
            ; to get the moves to the attacking piece field or to the 
            ; intermediate fields
        ]
    ]
    ; creating the moves
	for n 1 64 1 [
		thispiece: 0
		if  all [white-to-move 
				 0 < white-board/(n)] [
			thispiece: white-board/(n)
		]    
		if  all [black-to-move 
				 0 < black-board/(n)] [
			thispiece: black-board/(n)
		]    
		if thispiece > 0 [
			switch thispiece [
				  4   5   6   7 [add-pawn-moves thispiece n]   
				128 129 130 131 [add-king-moves thispiece n]
				 32  33  34  35 [add-rook-moves thispiece n]   
				 16  17  18  19 [add-bisshop-moves thispiece n]   
				  8   9  10  11 [add-knight-moves thispiece n]   
				 64  65  66  67 [add-rook-moves thispiece n
								 add-bisshop-moves thispiece n]
			]
		]
	]

    number-of-moves: length? legal-moves
    if  0 = length? legal-moves [
        if  all [white-to-move 
                 0 = infl-black/(field-white-king)] [ ;-- white has no more move, not chess, pat
            info-txt: "White is put into PAT position/stalemate"
        ]
        if  all [white-to-move 
                 0 < infl-black/(field-white-king)] [ ;-- white has no more move, in chess, mate
            info-txt: "White is put into MATE position, Black has won!"
        ]
        if  all [black-to-move 
                 0 = infl-white/(field-black-king)] [ ;-- black has no more move, not chess, pat
            info-txt: "Black is put into PAT position/stalemate"
        ]
        if  all [black-to-move 
                 0 < infl-white/(field-black-king)] [ ;-- black has no more move, in chess, mate
            info-txt: "Black is put into MATE position, White has won!"
        ]
    ]
]

switch-player: func [] [
; Swap values for who is to play
    black-to-move: white-to-move
    white-to-move: not black-to-move
]

language: "E"
;language: "NL"

piece-to-letter: func [thispiece [integer!]] [
	either "NL" = language [
	    switch thispiece [
	          4   5   6   7 [return " "]
	        128 129 130 131 [return "K"]
	          8   9  10  11 [return "P"]
	         16  17  18  19 [return "L"]
	         32  33  34  35 [return "T"]
	         64  65  66  67 [return "D"]
	    ]
	][
	    switch thispiece [
	          4   5   6   7 [return " "]
	        128 129 130 131 [return "K"]
	          8   9  10  11 [return "N"]
	         16  17  18  19 [return "B"]
	         32  33  34  35 [return "R"]
	         64  65  66  67 [return "Q"]
	    ]
	]
]

field-to-a1h8: func [fieldnr [integer!] /local letter cyphre] [
    letter: to-string to-char fieldnr - 1 / 8 + 97
    cyphre:  (fieldnr - 1 // 8) + 1
    return rejoin [letter cyphre]
]
;--
move-object: make object! [
    pieceplayed:
    fieldfrom:
    fieldto:
    capture:
    move-info: none 
]

promotion: layout [
    text "What do you want this pawn to be promoted into?" 

    button "Queen"   [promoletter: "Q" promoval: queen   hide-popup]
    button "Rook"    [promoletter: "R" promoval: rook    hide-popup]
    button "Bisshop" [promoletter: "B" promoval: bisshop hide-popup]
    button "Knight"  [promoletter: "N" promoval: knight  hide-popup]    
]

perform-move: func [ffrom fto 
                    /local thispiece dest ptl connect addition disp-move
                    extra-board-info] [
    ; changes player
    switch-player
    ; Performs the move on the internal board(s)
    thispiece: game-board/(ffrom)
    ptl: piece-to-letter thispiece
    dest: game-board/(fto)
    extra-move-info: copy ""
    addition: ""
    promoletter: copy ""
    promoval: 0
    either 0 = dest [
        connect: "-"
    ][
        connect: "x"  
    ]
    either all ["K" = ptl
                9 < abs (fto - ffrom)] [
        either 0 < (fto - ffrom) [
            disp-move: "0-0"
            extra-move-info: "RK"
        ][
            disp-move: "0-0-0"
            extra-move-info: "RQ"
        ]
    ][  
        strfrom: field-to-a1h8 ffrom
        strto: field-to-a1h8 fto
        if all [0 = dest
                " " = ptl
                (first strto) <> (first strfrom)] [
            connect: "x"
            addition: "e.p."
            extra-move-info: "EP"
        ]
        if  all [" " = ptl
                 any [#"1" = second strto 
                      #"8" = second strto]] [
            inform promotion
            extra-move-info: rejoin ["P" promoletter]
            addition: rejoin [" " promoletter]
        ]
        disp-move: rejoin [ptl strfrom connect strto addition]
    ]
    new-move: make move-object []
    new-move/pieceplayed: thispiece
    new-move/fieldfrom: ffrom
    new-move/fieldto: fto
    either "EP" = extra-move-info [
        new-move/capture: inipos or black xor thispiece
    ][
        new-move/capture: dest
    ]
   ; Update the board internally
    game-board/(ffrom): 0
    either white-to-move [ ;-- We already switched players!
        black-board/(ffrom): game-board/(ffrom)
        if  king and thispiece = king [
            field-black-king: fto
        ]
    ][
        white-board/(ffrom): game-board/(ffrom)
        if  king and thispiece = king [
            field-white-king: fto
        ]
    ]
    either all [" " = ptl
                2 = abs (ffrom - fto)][
        game-board/(fto): thispiece  ;-- keep all values for a double pawn move??
    ][    
        either 0 = promoval [
            if  all [thispiece and king = king
                     thispiece and inipos = inipos
                     thispiece and black <> black] [
                rochade/1/2: 0
                if 0 = length? extra-move-info [extra-move-info: "IM"]
            ]
            if  all [thispiece and king = king
                     thispiece and inipos = inipos
                     thispiece and black = black] [
                rochade/2/2: 0
                if 0 = length? extra-move-info [extra-move-info: "IM"]
            ]
            if  all [thispiece and rook = rook
                     thispiece and inipos = inipos
                     thispiece and black <> black] [
                either ffrom < 9 [rochade/1/1: 0]
                                 [rochade/1/3: 0]
                extra-move-info: "IM"
            ]
            if  all [thispiece and rook = rook
                     thispiece and inipos = inipos
                     thispiece and black = black] [
                either ffrom < 9 [rochade/2/1: 0]
                                 [rochade/2/3: 0]
                extra-move-info: "IM"
            ]
            game-board/(fto): thispiece and 253 ;-- keep all values except inipos (2)            
        ][
            game-board/(fto): promoval or (black and thispiece)
        ]
    ]
    either white-to-move [ ;-- We already switched players!
        black-board/(fto): game-board/(fto)
        white-board/(fto): 0
    ][
        white-board/(fto): game-board/(fto)
        black-board/(fto): 0
    ]
    
    if  "RK" = extra-move-info [
        either white-to-move [ ;-- We already switched players!
            game-board/(64): black-board/(64): 0
            game-board/(48): black-board/(48): rook + 1
            rochade/2/3: rochade/2/2: 0
        ][
            game-board/(57): white-board/(57): 0
            game-board/(41): white-board/(41): rook 
            rochade/1/3: rochade/1/2: 0
        ]
    ]
    if  "RQ" = extra-move-info [
        either white-to-move [ ;-- We already switched players!
            game-board/(8): black-board/(8): 0
            game-board/(32): black-board/(32): rook + 1
            rochade/2/1: rochade/2/2: 0
        ][
            game-board/(1): white-board/(1): 0
            game-board/(25): white-board/(25): rook 
            rochade/1/1: rochade/1/2: 0
        ]
    ]
    if  "EP" = extra-move-info [
        either white-to-move [
            game-board/(fto + 1): white-board/(fto + 1): 0 ;-- white pawn was captured
        ][
            game-board/(fto - 1): black-board/(fto - 1): 0 ;-- black pawn was captured
        ]
    ]
    ; Save the move
    new-move/move-info: extra-move-info
    history-moves: append history-moves new-move
    ; updates, adds the move to, the table of performed moves.
    played-moves: append played-moves disp-move
 ]

take-move-back: func [/local new-history copy-move undo-move p f t cap] [
    ; Undoes the previous move from the table of performed moves
    ; updates, removes the last move from, the table of performed moves.
    ; changes player
    either 0 < length? history-moves [
        switch-player
        undo-move: last history-moves
        p: undo-move/pieceplayed
        f: undo-move/fieldfrom
        t: undo-move/fieldto
        cap: undo-move/capture
        infor: undo-move/move-info
        game-board/(f): p
        either "EP" = infor [
            either white-to-move [
                black-board/(t - 1): game-board/(t - 1): cap
            ][
                white-board/(t + 1): game-board/(t + 1): cap
            ]
            game-board/(t): 0
        ][  
            game-board/(t): cap
            if  all [0 <> length? infor 
                     #"R" = first infor] [ ;-- undo rochade
                either t = 17 [ ;-- Rochade Queenside
                    either black-to-move [
                        black-board/(t): game-board/(t)
                        black-board/(t + 8): game-board/(t + 8): 0
                        black-board/(t - 16): game-board/(t - 16): rook + inipos + black 
                        rochade/2/2: 1
                        rochade/2/1: 1
                    ][
                        white-board/(t): game-board/(t)
                        white-board/(t + 8): game-board/(t + 8): 0
                        white-board/(t - 16): game-board/(t - 16): rook + inipos                         
                        rochade/1/2: 1
                        rochade/1/1: 1
                    ]
                ][
                    either black-to-move [
                        black-board/(t): game-board/(t)
                        black-board/(t - 8): game-board/(t - 8): 0
                        black-board/(t + 8): game-board/(t + 8): rook + inipos + black 
                        rochade/2/2: 1 
                        rochade/2/3: 1
                    ][
                        white-board/(t): game-board/(t)
                        white-board/(t - 8): game-board/(t - 8): 0
                        white-board/(t + 8): game-board/(t + 8): rook + inipos                         
                        rochade/1/2: 1 
                        rochade/1/3: 1
                    ]
                ]
            ]
        ]
        either white-to-move [
            white-board/(f): game-board/(f)
            black-board/(t): game-board/(t)
            white-board/(t): 0
            if  king and p = king [
                field-white-king: f
                if  "IM" = infor [
                    rochade/1/2: 1 
                ]
            ]
        ][
            black-board/(f): game-board/(f)
            white-board/(t): game-board/(t)
            black-board/(t): 0
            if  king and p = king [
                field-black-king: f
                if  "IM" = infor [
                    rochade/2/2: 1 
                ]
            ]
        ]
        
        history-moves: head remove back tail history-moves
        played-moves: head remove back tail played-moves
        
        init-influence
        fill-influence
        make-moves
    ][ 
        info-txt: txt-information/text: "No more moves to take back!"
        show txt-information
    ]
]

init-standard-position: func [] [
; Standard starting position
    import-position "KE1Qd1RA1RH1Bc1Bf1Nb1Ng1PA2PB2PC2PD2PE2PF2PG2PH2KE8Qd8RA8RH8Bc8Bf8Nb8Ng8PA7PB7PC7PD7PE7PF7PG7PH7" 0
; Initial values for who is to play
    white-to-move: not black-to-move: false
; These variables probably come in handy later on
    field-white-king: 33
    field-black-king: 40
    rochade: [1.1.1 1.1.1]
    init-influence 
    fill-influence
    make-moves
]

; Test functions
test-cm: does [
    ;1 Standard starting position
    import-position "Ke1Qd1Ra1Rh1Bc1Bf1Nb1Ng1Pa2Pb2Pc2Pd2Pe2Pf2Pg2Ph2Ke8Qd8Ra8Rh8Bc8Bf8Nb8Ng8Pa7Pb7Pc7Pd7Pe7Pf7Pg7Ph7" 0
    ;2 No black officers
    ;import-position "Ke1Qd1Ra1Rh1Bc1Bf1Nb1Ng1Pa2Pb2Pc2Pd2Pe2Pf2Pg2Ph2Ke8Qd8Ra8Rh8Bc8Bf8Nb8Ng8Pa7Pb7Pc7Pd7Pe7Pf7Pg7Ph7" 0
    ;3 have a pin direction 2
    ;import-position "Ke1Qd1Ra8Rh8Ba5Bg5Kd8Bc8Bf8Nb8Pc7Pd7Pe7" 0
    either error-in-position [print  error-description] [
        init-influence 
        fill-influence
        init-moves
        make-moves
    ]
]
; And debug functions
debug-board: func [/local n m f] [
    ; looking at the board is no fun in the console
    print "The game board looks like this now:"
    for n 8 1 -1 [
        for m 1 8 1 [
            f: m - 1 * 8
            prin "^(tab)" prin game-board/(f + n)
        ]
        print ""
    ]
]
debug-w: func [/local n m f] [
    ; looking at the board is no fun in the console
    print "The white board looks like this now:"
    for n 8 1 -1 [
        for m 1 8 1 [
            f: m - 1 * 8
            prin "^(tab)" prin white-board/(f + n)
        ]
        print ""
    ]
]
debug-b: func [/local n m f] [
    ; looking at the board is no fun in the console
    print "The black board looks like this now:"
    for n 8 1 -1 [
        for m 1 8 1 [
            f: m - 1 * 8
            prin "^(tab)" prin black-board/(f + n)
        ]
        print ""
    ]
]
debug-p: func [/local n m f] [
    ; looking at the board is no fun in the console
    print "The pins board looks like this now:"
    for n 8 1 -1 [
        for m 1 8 1 [
            f: m - 1 * 8
            prin "^(tab)" prin pins-board/(f + n)
        ]
        print ""
    ]
]
debug-iw: func [/local n m f] [
    ; looking at the board is no fun in the console
    print "The influence board looks like this now:"
    for n 8 1 -1 [
        for m 1 8 1 [
            f: m - 1 * 8
            prin "^(tab)" prin infl-white/(f + n)
        ]
        print ""
    ]
]
debug-ib: func [/local n m f] [
    ; looking at the board is no fun in the console
    print "The influence board looks like this now:"
    for n 8 1 -1 [
        for m 1 8 1 [
            f: m - 1 * 8
            prin "^(tab)" prin infl-black/(f + n)
        ]
        print ""
    ]
]
debug-ftf: func [/local a b ] [
    ; from-to-fields
    print "The move in from-to-fields are now:"
    foreach [a b] from-to-fields [
        prin a prin "^(tab)" print b
    ]
]