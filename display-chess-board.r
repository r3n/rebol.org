REBOL [
    Title: "Display chess board"
    Date: 7-oct-2003
    File: %display-chess-board.r
    Author: "Sunanda"
    Helpers: ["Gabriele Santilli" "Carl Read" "Anton Rolls"]
    Purpose: {Display a basic chess board and some
    		moveable counters (use a mouse to drag and drop). The
    		most-recently selected counter comes to the front, if it
    		was obscured by other counters.
    		Intended as a get-you-started set of ideas if you intend
    		to write a board game, and a demo of VID feel and other
    		useful techniques}
 
    Comment: {
        Derived from a basic example of mine and a question asked on
        the REBOL mailing list Sep-2002. Most of the ideas in the
        actual code come from the above named helpers. Definitely
        a stone soup script, this one. Thanks, guys.
    }
    library: [
        level: 'intermediate 
        platform: [all plugin]
        type: [demo game]
        domain: [game vid]
        plugin: [size: 470x500]
        tested-under: none 
        support: none 
        license: pd 
        see-also: none
    ]
    Version: 1.0.0
]


unview/all
;;	===========================
;;	Makes an image from a layout
;;	============================
make-counter: func [color [tuple!] /local image][
    layout [
        image: box 30x30 effect [draw [
            pen none
            fill-pen color none
            circle 14x14 15
        ]]
    ]
    to-image image
]


;;	================================
;;	Define styles for board elements	
;;	================================

Board-elements: Stylize [
    black-square: box 100.100.100 50x50
    white-square: box white 50x50
    ;;	-----------------------------------------------
    ;;	counter is now an image -  note the 'key effect 
    ;;	user to make the black in the image transparent.
    ;;	------------------------------------------------
    counter: box 30x30 effect [key 0.0.0 oval]
    feel [engage: func [face action event] [
        if action = 'down [move-to-end board/pane face start: event/offset]
        if find [over away] action [
            face/offset: face/offset + event/offset - start
            show face
        ]
    ]]
]

;;	==================================
;;	Move counter to "end" of layout --
;;	Thus popping it to the top of the
;;	"z axis" -- so if the counter was
;;	partially covered, it is now on top
;;	====================================

move-to-end: func [series item /local item-index item-value][
    item-index: find series item
    item-value: first item-index
    remove item-index
 
    append series item-value
    show last series
    show item-value
    
    ]
    


;;	-----------------------
;;	Define the board layout
;;	-----------------------

board-row: copy []
loop 4 [
	append board-row 'black-square
	append board-row 'white-square
	]
append board-row 'return

board: copy [styles board-elements
    space 0x0
    across]
    
;;		8 rows of alternating white and black squares
;;		---------------------------------------------    
loop 8 
	[append board head reverse/part board-row 8]

append board
	[button 200x24 "change Color on Counter 1" [
        	counter-array/1/color: random 255.255.255
        	show counter-array/1
	   ]
        return
        ]

;;	add counters to bottom of board 
;;	-------------------------------
counter-array: copy []

loop 8
	[append board [
		temp: counter
		do [append counter-array temp]
		]
	]


view/new board: layout board

;;	set random colors for counters
;;	------------------------------

foreach c counter-array
		[c/color: random 127.127.127
		 show c
		]

do-events
