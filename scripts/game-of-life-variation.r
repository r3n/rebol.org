REBOL [
	Title: "A Variation on Conway's Game of Life "
	Author: "Ayrris Aunario"
	Email: aaunario@yahoo.com
	Purpose: { A GUI implementation of a modified version of the popular cellular automaton system.
			The rules:  1) Each cell (square) on the grid is either alive (blue) or dead (white) 
					2) For every iteration, each cell's next state depends on current state and # of live neighbors 
						a) if cell is alive, it stays alive <=> 2 or 3 neighbors are alive
						b) if cell is dead, becomes alive <=> exactly 3 neighbors are alive  
					3) Each cell's 8 neighbors comprise of adjacent cells unless it is on the edge, then use wrap-around rule
			Choose initial configuration of live cells (click cells to toggle between states) or "RANDOMIZE", start, and watch patterns emerge
	}
	Date: 20-Sep-2005/18:31:07-7:00
	Version: 0.0.4
	File: %game-of-life-variation.r
	Library: [
		Level: 'intermediate
                     Plugin: [size: 502x650 ]
		Platform: ['win plugin]
		Type: [demo fun game]
		Domain: [math gui vid game]
		Tested-under: none
		Support: none
		License: none
		See-also: none
	]
]

game_off?: true
gsl: 50	;specify grid side-length (in cells)
csl: 10 	;specify cell side-length (in pixels)
game_off?: true
affected: copy []	; used for keeping track of cells whose states might change for each iteration
alive: copy []	; stores live cells
grid-pane: copy [] ; list of all cells on the grid

; make prototype cell
cell: make face [
	id: none
	size: as-pair (csl) (csl)
	edge: none	
	offset: none
	neighbors: copy [] 
	nc: 0    ;count of cell's living neighbors
	color: none
	
	setneighbors: does [
		for j -1 1 1 [	
			for k -1 1 1[
				 if any [j <> 0 k <> 0] [
				 posx: to-string (-1 * j + 1 + (offset/x / csl)) 
				 posy: to-string (k * -1 + 1 + (offset/y / csl))
				 if (to-integer posx) > gsl [posx: to-string 1]				 
				 if (to-integer posy) > gsl [posy: to-string 1]
				 if posx = "0" [posx: to-string gsl]
				 if posy = "0" [posy: to-string gsl]	
				 append neighbors to-word rejoin ["cell" posx "x" posy] 
	 			]
			]
		]
	]



	
	ncreset: does [nc: 0]
	
	nc++: does [nc: nc + 1]
	
	;if cell is alive, tell each of its neighbors
	sendstate: does [
			append affected id
			foreach n neighbors [
				do in (get n) 'nc++
				append affected n
			]
	]

	;sets cell's state for next iteration based on number of neighbors
	setns: does [
		either show? [
			either any [nc > 3 nc < 2][
				show?: false
			][
				append alive id
			]
		][
			if nc = 3 [
				show?: true
				append alive id
			]
		]	
		ncreset
	]
	
	feel: make feel [
		engage: func [face action event] [
			if action = 'down [
				either face/color [
					face/color: none
					remove find alive face/id
				][
					append alive face/id
					face/color: blue
				]
			show face
			]
		]
	]
]	

		
; function called to run 1 each iteration
run_step: does [

		foreach a unique alive [
			do in (get a) 'sendstate
		]
		clear alive
		
				
		foreach af unique affected [
			do in (get af) 'setns
		]
		clear affected
] 

auto_steps: does [
	start_steps
	forever [
		if game_off? [break]
		run_step
		show cells
		wait 0.01
	]
]
	
stop_steps: does [
	game_off?: true
	foreach g grid-pane [g/show?: true g/color: none]
	foreach a alive [set in (get a) 'color blue]
] 
	

start_steps: does [
	foreach g grid-pane [ g/show?: false g/color: blue]
	foreach a alive [set in (get a) 'show? true]
	auto-init?: true
]		
;create the panel containing the grid of cells
cells: make face [
	size: as-pair (gsl * csl) (gsl * csl)
	offset: 0x0
	edge: none
	color: white
	gll: as-pair csl csl
	effect: [grid gll gll]
	pane: grid-pane
		
] 

window: make face [
	size: 502x650
	offset: 100x50 
	edge: make edge [
		color: 0.0.0
		size: 1x1
	]
	color: none
	pane: [cells input-panel]
]

;function that initializes each cell in the grid	
make-grid: func [g c /local p][
	
	;show progress of cell initializatin
	view/new p: layout [ 
		h5 "Initializing Grid:"
		progress snow 300x10 
	]
	for x 1 g 1 [
		for y 1 g 1 [
			set in last p/pane 'data ((g * (x - 1) + y) / ( g ** 2))
			show p
			append grid-pane set (to-word rejoin ["cell" to-string x "x" to-string y]) make cell[
				offset: as-pair (x - 1 * c) (y - 1 * c)
				id: to-word rejoin ["cell" to-string x "x" to-string y]
				setneighbors
			]	
		]
	]
	unview p
]

;function for picking random initial configuration of live cells
randinit: has [randcellind numcellspicked p][
	numcellspicked: random (gsl * gsl)
	
	view/new p: layout [
		h5 "Picking cells:"
		progress snow 300x10
	]
		
	for i 1 (numcellspicked) 1 [
		randcellind: random (gsl * gsl)
		set in last p/pane 'data (i / numcellspicked)
		show p
		a: pick grid-pane (randcellind)
		a/color: blue
		append alive a/id
	]
	unview p
]

;function for clearing grid
clear-grid: does [
	gameoff?: true
	auto-init?: false
	clear alive 
	clear affected 
	clear grid-pane
	make-grid gsl csl
]
		

;panel containing various control buttons
input-panel: make face [
	size: 500x150
	offset: 0x500
	edge: make edge [
		color: black
		size: 1x1
	]
	pane: reduce layout[
		toggle "START" "STOP" [either game_off?: not value [stop_steps] [auto_steps]] 
		return
		button "RUN 1 STEP" [if not game_off?[break] start_steps run_step stop_steps show cells]
		return
		button "CLEAR" [if not game_off? [break] clear-grid show cells]
		return
		button "RANDOMIZE" [if not game_off? [break] if not tail? alive [clear-grid] randinit show cells]
	]	
]

make-grid gsl csl
view window




	