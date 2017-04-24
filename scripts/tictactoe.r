REBOL [
    Title: "Tic Tac Toe"
    Date: 27-Dec-2001/11:50:39-8:00
    Version: 1.0.3
    File: %tictactoe.r
    Author: "Ryan S. Cole"
    Purpose: "No known purpose."
    History: [
        23-Oct-2001 "Made things more colorful." 
        27-Dec-2001 "Fixed bug allowing win condition." 
        27-Dec-2001/11:50:39-8:00 "Now works properly with View or Link."
    ]
    Email: ryancole@usa.com
    Comments: {Special thanks to Larry Snyder
     for help in simplifying game logic.}
    library: [
        level: 'intermediate 
        platform: 'all 
        type: [Demo Game] 
        domain: [VID graphics] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

;;;;;;;;;;;;;;;;;
;;; game data ;;;
;;;;;;;;;;;;;;;;;

; represents the 9 positions available
game-grid: "         " ; 9 spaces

; the winning mark combinations
win-table: [
    "mmm??????" "???mmm???" "??????mmm" "m??m??m??"
    "?m??m??m?" "??m??m??m" "m???m???m" "??m?m?m??"
]

;;;;;;;;;;;;;;;;;;;;;;;;
;;; helper functions ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

; returns opposing players marker
other: func [m [char!]][either m = #"X" [#"O"][#"X"]]

; tests for a winning condition for a particular marker
win?: function [grid mark] [tmp-grid] [
    replace/all tmp-grid: copy grid mark #"m"
    foreach win win-table [
        if found? find/any tmp-grid win [return yes]
    ]
]

;;;;;;;;;;;;;;;;;;
;;; game logic ;;;
;;;;;;;;;;;;;;;;;;

; returns the best move
get-win-move: function [grid mark] [move] [
    if grid/5 = #" " [return poke grid 5 mark]
    if move: win-move? grid mark [return poke grid move mark]
    if move: win-move? grid other mark [return poke grid move mark]
    if grid/5 = mark and any [
        (grid/1 = grid/9) and (grid/1 = other mark)
        (grid/3 = grid/7) and (grid/3 = other mark)
    ] [
        return poke grid 4 mark
    ]
    either (grid/6 = other mark) or (grid/8 = other mark) [
        if grid/9 = #" " [return poke grid 9 mark]
        if grid/7 = #" " [return poke grid 7 mark]
        if grid/3 = #" " [return poke grid 3 mark]
        if grid/1 = #" " [return poke grid 1 mark]
    ] [
        if grid/1 = #" " [return poke grid 1 mark]
        if grid/3 = #" " [return poke grid 3 mark]
        if grid/7 = #" " [return poke grid 7 mark]
        if grid/9 = #" " [return poke grid 9 mark]
    ]
    replace grid #" " mark
]

; tries to return the move that would
; result an immediate win for a given marker
win-move?: func [grid mark] [
    repeat idx 9 [
        if grid/:idx = #" " [
            if win? poke copy grid idx mark mark [return idx]
        ]
    ]
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; game control and visual ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; creates a layout for the screen
lay-grid: does [
    lay: copy [
        backdrop white effect [merge gradcol 1x1 255.0.0 0.0.255]
        origin 0x0  space 3x3
        style square box 30x30 ivory font [color: red shadow: none]
    ]
    repeat idx length? game-grid [
        repend lay [ 'square to-string game-grid/:idx ]
        if game-grid/:idx = #"O" [ append lay [font [color: blue] ] ]
        if game-grid/:idx = #" " [ repend/only lay ['react-to-move idx] ]
        if zero? idx // 3 [append lay 'return]
    ]
    append lay [at 0x0 message: label 0x0 center font-size 26]
]

; reacts to users input when a space is pressed
react-to-move: func [index] [
    poke game-grid index #"X"
    check-state
    game-grid: get-win-move game-grid #"O"
    check-state
]

; checks for a lose or tie and updates screen
check-state: does [
    if win? game-grid #"O"
    	[clear-game "YOU^/LOSE!"]
    if not found? find game-grid #" "
    	[clear-game "TIE^/GAME!"]
    refresh
]

; Clears the game board with special effects.
Clear-game: function [msg] [color] [
    refresh
    message/text: msg
    message/size: 100x100
    message/effect: copy []
    color: 255.0.0
    loop 16 [
        message/font/color: color: color - 16.0.0 + 0.0.16
        append message/effect [merge blur]
        show main-face
        wait .2
    ]
    game-grid: copy "         "
]

; repaints the screen
refresh: does [
    main-face/pane: layout/offset lay-grid 0x0
    show main-face
]

;;;;;;;;;;;;;;;;;;;;;;;
;;; start game play ;;;
;;;;;;;;;;;;;;;;;;;;;;;

main-face: view/new layout lay-grid
do-events

