REBOL [ Title: "Chess board handler"
        File: %cbh.r
        Date: 28-aug-2012
        Version: 0.1.0
        Author: "Arnold van Hofwegen"
        Purpose: {Function as a chess board interface. 
                         Support playing a game of chess according to the rules of the game of chess. }
        Library: [ 
            level: 'intermediate
            platform: 'all 
            type: [game demo] 
            domain: [all] 
            tested-under: [View 2.7.8 Windows MacOSX] 
            support: "AltMe"
            license: 'lgpl
            see-also: [%chessmoves.r %chessimage.r] 
        ]
]
;**********
; Constants
;**********
grootte: 40 ;-- field size on the GUI
transplborder: 0.0.255.128 ; blue
transplfill: 164.200.255.128 ; sky
do %chessimage.r
do %chessmoves.r
;**********
; Variables
;**********
board-line-width: 1
pen-board: Black
pen-legal-move: Blue
;*******************************************************************************
; Functions
;*******************************************************************************
;*******************
; Initialize screens
;*******************
init-draw-board-box: func [/local n m x y adder field-shape] [
    draw-board-box: copy []
    draw-board-box: append draw-board-box reduce ['pen 'black 'fill-pen 'silver 'line-width board-line-width]
    draw-board-box: append draw-board-box compose [line 0x0 (to-pair reduce [0 8 * grootte])]
    draw-board-box: append draw-board-box compose [line 0x0 (to-pair reduce [8 * grootte 0])]
    draw-board-box: append draw-board-box compose [line (to-pair reduce [0 8 * grootte]) (to-pair reduce [8 * grootte 8 * grootte])]
    draw-board-box: append draw-board-box compose [line (to-pair reduce [8 * grootte 0]) (to-pair reduce [8 * grootte 8 * grootte])]
    
    for m 0 7 1 [
        for n 0 3 1 [
            ; donkere velden, bepaal begin punt en teken een vierkant
            adder: either odd? m [0][1]
            x: (n * 2 + adder) * grootte
            y: m * grootte
            draw-board-box: append draw-board-box compose [shape]
            field-shape: copy []
            field-shape: append field-shape compose [move (as-pair x y)]
            field-shape: append field-shape compose ['hline (grootte)]
            field-shape: append field-shape compose ['vline (grootte)]
            field-shape: append field-shape compose ['hline (- grootte)]
            field-shape: append field-shape compose ['vline (- grootte)]
            draw-board-box: append/only draw-board-box field-shape
        ]
    ]
]

init-board-box: func [] [
    init-draw-board-box
]

init-draw-legal-moves: func [/local x y t field-shape] [
    draw-legal-moves-box: copy []
	legal-moves-box/effect: reduce ['draw draw-legal-moves-box]
	show legal-moves-box
]

make-draw-legal-moves: func [fieldnr /local x y t field-shape] [
    draw-legal-moves-box: copy []
    ;draw-legal-moves-box: append draw-legal-moves-box reduce ['pen 'blue 'fill-pen 'sky 'line-width board-line-width]
    draw-legal-moves-box: append draw-legal-moves-box reduce ['pen 'transplborder 'fill-pen 'transplfill 'line-width board-line-width]
    destinations: select from-to-fields fieldnr
	if  not none = destinations [
	    foreach field destinations [
	        x: grootte * to-integer field - 1 / 8
            t: (field - 1) // 8 + 1
            y: 8 - t * grootte
            draw-legal-moves-box: append draw-legal-moves-box compose [shape]
	    	field-shape: copy []
	    	field-shape: append field-shape compose [move (as-pair x y)]
	    	field-shape: append field-shape compose ['hline (grootte)]
	    	field-shape: append field-shape compose ['vline (grootte)]
	    	field-shape: append field-shape compose ['hline (- grootte)]
	    	field-shape: append field-shape compose ['vline (- grootte)]
	    	draw-legal-moves-box: append/only draw-legal-moves-box field-shape
	    ]
	]
	legal-moves-box/effect: reduce ['draw draw-legal-moves-box]
	show legal-moves-box
]

place-pieces-init: func [/local piece-order kleur n img-piece] [
  piece-order: "RNBQKBNR"
  kleur: "-white"
  for n 1 8 1 [
      img-piece: to-word rejoin ["img-" pick piece-order n kleur]
      pieces/pane/:n/image: get img-piece
      pieces/pane/:n/size: 41x41
      pieces/pane/:n/offset: as-pair n - 1 * grootte 7 * grootte
  ]
  for n 9 16 1 [
      pieces/pane/:n/image: img-P-white
      pieces/pane/:n/size: 41x41
      pieces/pane/:n/offset: as-pair n - 9 * grootte 6 * grootte
  ]  
  kleur: "-black"
  for n 17 24 1 [
      pieces/pane/:n/image: img-P-black
      pieces/pane/:n/size: 41x41
      pieces/pane/:n/offset: as-pair n - 17 * grootte grootte
  ]
  for n 25 32 1 [
      img-piece: to-word rejoin ["img-" pick piece-order n - 24 kleur]
      pieces/pane/:n/image: get img-piece
      pieces/pane/:n/size: 41x41
      pieces/pane/:n/offset: as-pair n - 25 * grootte 0
  ]  
  show pieces
]

pieceval-to-letter: func [piece [integer!]] [
    switch piece [
          4   5   6   7 [return "P"]
        128 129 130 131 [return "K"]
         32  33  34  35 [return "R"]
         16  17  18  19 [return "B"]
          8   9  10  11 [return "N"]
         64  65  66  67 [return "Q"]
    ]
]

field-as-offset: func [n /local x y ] [
    x: grootte * to-integer n - 1 / 8
    y: 7 - (n - 1 // 8) * grootte
    return as-pair x y
]

place-pieces: func [/local n piecenr thispiece letter kleur img-piece] [
    ;-- use the generated block from the chess-move generator to place the pieces on the board
    ; This block looks like:
    ; [128 [3] 64 [20 21]] or something like that
    ;-- first clear old images from the board
    for n 1 32 1 [pieces/pane/:n/offset: -200x-200]
    ;-- 
    piecenr: 1
    for n 1 64 1 [
        thispiece: game-board/(n)
        if  0 < thispiece [
            letter: pieceval-to-letter game-board/(n)
            kleur: either odd? thispiece ["-black"]["-white"]
            img-piece: to-word rejoin ["img-" letter kleur]
            pieces/pane/:piecenr/image: get img-piece
            pieces/pane/:piecenr/offset: field-as-offset n
            piecenr: piecenr + 1
        ]
    ]        
]

compute-offset-field: func [xy [pair!]
    /local rij kol veldpaar] [
    rij: to-integer (xy/2 / grootte) + 1
    kol: to-integer (xy/1 / grootte) + 1
    veldpaar: as-pair kol rij 
]

xy-to-field: func [xy [pair!] /local t] [
    t: xy/1 - 1 * 8 + 9 - xy/2
]

validate-moving: func [from-field destination [pair!] /fieldnr] [
    ;-- use the generated block from-to-fields from the chessmoves.r 
    ;   generator to determine the valid destination fields of the 
    ;   selected piece
    ; This block looks like:
    ; [1 [2 3] 64 [20 21]]
    destinations: select from-to-fields from-field
    ;-- Start by checking inside the board boundaries
    either all [destination/1 > 0
        destination/1 < 9
        destination/2 > 0
        destination/2 < 9] [
        fieldnr: xy-to-field destination
        if  none = destinations [return false]
        if  found? find destinations fieldnr [return true]
        return false
    ][ 
        return false
    ]
]
;--------------
; Button actions
action-import-position: func [] [
    importstring: copy new-white-pos/text
    importstring: append importstring new-black-pos/text
    wb: either check-move/data [1][0]
    ; this is a function from %chessmoves.r
    import-position importstring wb
    either error-in-position [
        print error-description
    ][   
        init-influence 
        fill-influence
    ]
    fill-pieces
]

action-take-back-move: func [] [
	; call function from %chessmoves.r
	;print "action-take-back-move"
	take-move-back
	update-interface
	show pieces
]

action-help: func [] [
    alert "Sorry, not implemented at this moment."
]
;---------------------------------------------------
; Move the selected piece to the "end" of the layout 
; effectively to the top of the z-index
;-- function copied from %display-chess-board.r from rebol.org by Sunanda
move-to-top: func [series item /local item-index item-value] [
    item-index: find series item
    item-value: first item-index
    remove item-index
 
    append series item-value
    show last series
    show item-value
    
]

update-interface: func [] [
    hintbox/color: either white-to-move [white][black]
	who-is-to-move-txt/text: either white-to-move ["White"]["Black"]
	show hintbox
	show who-is-to-move-txt
	list-played/data: played-moves
	show list-played
	init-influence 
	fill-influence
	make-moves
	place-pieces
	list-legal/data: legal-moves
	show list-legal
	txt-number-legal/text: length? legal-moves
	show txt-number-legal
	txt-information/text: either 0 = length? info-txt ["Message area"][info-txt]
	show txt-information
]

movestyle: [
    engage: func [face action event] [
        if  action = 'down [
            position: face/offset
            startfield: compute-offset-field face/offset + event/offset
            fieldfrom: startfield/1 - 1 * 8 + 9 - startfield/2
            move-to-top pieces/pane face
            make-draw-legal-moves fieldfrom
            start: event/offset
            ]
        if  find [over away] action [
            face/offset: face/offset + event/offset - start
            show face
        ]
        if  action = 'up [
            fieldto: compute-offset-field face/offset + event/offset           
            either validate-moving fieldfrom fieldto [
                face/offset: 0x0 + as-pair fieldto/1 - 1 * grootte  fieldto/2 - 1 * grootte
                ; give move to the chessmoves module
                perform-move fieldfrom xy-to-field fieldto
                update-interface
            ][
                face/offset: position
            ]
            init-draw-legal-moves
            show face
        ]
    ]
]

piece-styles: stylize [
    apiece: image red-pixel feel movestyle
]
;**********************************************************
; Layout applicationscreen
;**********************************************************
main: layout [
    ;size 800x700
    below
    styles piece-styles
    hier: at
    at hier + 0x50
    board-box: box " " 320x320 white 
    txt-information: text teal ivory 320 center "Message area"
    across
    btn-back: button 100 "Undo move" [action-take-back-move]
    text 130 "Player to move next:"
    who-is-to-move-txt: text "White"
    hintbox: box 20x20 white
    return
    thispos: text "Input your gameposition" 
    return
    text "White pieces (KE1Dd2RA1Rh4Bc1Bf1Nb1Ng1Pa2 etc):" 
    return
    new-white-pos: field 300 ""
    return
    text "Black pieces (KE8Dd5RA8Rh6Bc8Bf8Nb8Ng8Pa7 etc):" 
    return
    new-black-pos: field 300 ""
    return
    check-move: check false [either check-move/data [move-for-txt/text: "Black to move"] 
                                                    [move-for-txt/text: "White to move"] 
                             show move-for-txt]
    move-for-txt: text "White to move"
    return
    last-move-txt: text 80 "Last move"
    last-move: field 100 "" 
    btn-import: button 90 "Import Pos." [action-import-position]
    btn-help: button 50 "Help" [action-help]
    at hier + 0x50
    legal-moves-box: box " " 1x1 white
    at hier + 0x50
    pieces: panel [below size 320x320
        apiece apiece apiece apiece apiece apiece apiece apiece
        apiece apiece apiece apiece apiece apiece apiece apiece
        apiece apiece apiece apiece apiece apiece apiece apiece
        apiece apiece apiece apiece apiece apiece apiece apiece        
    ]
    at 380x20
    vh2 "Legal moves list:"
    at 380x50
    list-legal: text-list 150x500 ""
    at 380x560
    txt-number-legal: text 60 teal ivory "Number"
    at 540x20
    vh2 "Played moves:"
    at 540x50
    list-played: text-list 150x500 ""
    across
    at hier
    btn-debug:         button "Debug draw" [print hier]
    btn-inform:         button "Info" [i: to-image main save/png %screenshot.png i]
    btn-herstart: button "Herstart" [unview/all do %cbh.r]   
]

;**********************************************************
; Program
;**********************************************************
;box-size: to-pair reduce [8 * grootte + 1 8 * grootte + 1]
box-size: to-pair reduce [8 * grootte  8 * grootte]
board-box/size: box-size
legal-moves-box/size: box-size
legal-moves-box/color: none
pieces/size: box-size

init-board-box
board-box/effect: reduce ['draw draw-board-box]
place-pieces-init
init-standard-position
update-interface

view main