REBOL [
	title: "Visual sorting"
	file: %visual-sorting.r
	author: "Marco Antoniazzi"
	email: [luce80 AT libero DOT it]
	date: 21-03-2016
	version: 0.0.10
	Purpose: "Collect and show various sorting algorithms."
	History: [
		0.0.1 [23-02-2013 "Started"]
		0.0.2 [07-03-2013 "ok"]
		0.0.3 [08-03-2013 "Some aestethic fixes"]
		0.0.4 [27-10-2013 "Adapted to Rebol 3 (with vid1r3.r3)" ]
		0.0.5 [01-01-2014 "Little fixes and speed ups"]
		0.0.6 [03-01-2014 "Inserted wait in compare function again to better see comparing"]
		0.0.7 [12-01-2014 "Added pink line also to visually show swaps"]
		0.0.8 [11-01-2015 "Added 25 as number of items"]
		0.0.9 [12-04-2015 "Small gui changes"]
		0.0.10 [21-03-2016 "Fixed bug in Heap initial division"]
	]
	library: [
		level: 'intermediate
		platform: 'all
		type: [function tool]
		domain: [graphics visualization]
		tested-under: [View 2.7.8.3.1 Saphir-View 2.101.0.3.1]
		support: none
		license: 'public-domain
		
	]
	icon: http://i43.tinypic.com/2wq7srd.png
	notes: {
		I should say that these functions are made slow on pourpose.
		The functions are written for readability and simplicity, NOT FOR SPEED.
		Any optimization is left as an exercise to the reader ;)
		
		Do not esitate to help me improve this script by adding more algorithms.

		Algorithms taken from:
			* http://www.xtremevbtalk.com/showthread.php?p=386994
			* http://rosettacode.org/wiki/Category:Sorting_Algorithms
			* http://visualsort.appspot.com/
			* http://home.westman.wave.ca/~rhenry/sort/

		It is particularly interesting to see the various sorting operations in
		"slow motion" to better understand the similarities or the differences
		between them, and also to see in which way they could be improved.
	}
]
;**** set correct path to vid1r3.r3 and sdk sources (or use empty string to use default path to sdk) ****
if system/version > 2.7.8.100 [do/args %../../r3/local/vid1r3.r3 %../../sdk-2706031/rebol-sdk-276/source]

; cfor
	cfor: func [
		{General loop}
		[throw catch]
		init [block!]
		test [block!]
		inc [block!]
		body [block!]
		/local result
		] [
		do init while [do test] [set/any 'result do body do inc] get/any 'result
	]
;
; init, reset, start, stop
	widths-spaces: [
		45 5
		17 3
		8 2
		4 1
		2 0
		1 0
	]
	lengths: [10 25 50 100 250 500]
	array*: make block! 10
	running: false
	speed: 0.1
	secs: 0:0:0
	reset: does [
		if running [exit]
		scaley: 200 / items ; bars' y scaling factor
		origin: 10x30
		widths: pick widths-spaces slider-value * 2 - 1
		pad: origin  ; origin (upper-left) of bars
		gap: pick widths-spaces slider-value * 2; distance between bars
		gap: gap + widths * 1x0
		random/seed 18; fixed randomness
		clear array*
		; populate initial array
		for n 1 items 1 [
			insert array* switch get-face drop-type [
				"Random" "Almost-Sorted" "Sorted" "Rev-Sorted" [items - n + 1]
				"Many-Equals" "Equals" "Rev-Equals" [min items 4 + to-integer ((items / 5) * to-integer ((items - n) / (items / 5)))]
			]
		]
		switch get-face drop-type [
			"Almost-Sorted" [for n 1 to-integer items / 5 1 [array*/(random items): random items]]
			"Random" "Many-Equals" [array*: random array*]
			"Rev-Sorted" "Rev-Equals" [reverse array*]
		]
		comps: 0
		set-face text-comps comps
		swaps: 0
		set-face text-swaps swaps
		canvas/image/rgb: gray ; clear canvas to gray
		; create an array with all the x positions of the bars
		positions: copy []
		for n 1 length? array* 1 [
			insert tail positions pad
			pad: pad + gap
		]
		draw-bars black
	]
	start: does [
		time-start: now/time/precise
		set-face text-time "0:00:00.000"
		ticker/rate: 0:0:1 show ticker
		secs: 0:0:0
		text-running/font/color: blue set-face text-running "Running"
		running: true
		do to-word get-face drop-sorts array*
		final-draws
		stop
	]
	stop: does [
		running: false
		time-stop: now/time/precise - time-start
		set-face text-time time-stop
		ticker/rate: none show ticker
		secs: 0:0:0
		text-running/font/color: red set-face text-running "Stopped"
	]
	change-items-num: func [value [decimal!] /local temp][
		if running [exit]
		temp: get-face text-items
		set-face text-items items: pick lengths slider-value: round value * ((length? lengths) - 1) + 1
		if items != temp [reset] ; speed up things a little
	]
;
; drawing
	draw-triangle: func [color pos] [
		draw canvas/image compose [anti-alias off pen none fill-pen (color) triangle (pos - 0x10) (pos + (widths * 1x0) - 0x10) (pos - 0x10 + (widths / 2 * 1x0) + 0x5)]
	]
	draw-box: func [color pos1 pos2] [
		draw canvas/image compose [anti-alias off pen none fill-pen (color) box (pos1 - 2x30) (pos2 - -2x10 + (widths * 1x0))]
	]
	draw-arrow: func [color pos1 pos2 /local mid] [
		mid: (widths / 2 * 1x0)
		draw canvas/image compose [anti-alias off pen (color) fill-pen (color) line-width 2
		line (pos1 - 0x15 + mid) (pos1 - 0x25 + mid) (pos2 - 0x25 + mid) (pos2 - 0x15 + mid)]
	]
	draw-bar: func [color pos height] [
		draw canvas/image compose [anti-alias off pen none fill-pen (color) box (pos) (pos + as-pair widths height * scaley)]
	]
	draw-bars-erase: func [color pos1 pos2] [
		draw canvas/image compose [anti-alias off pen none fill-pen (color) box (pos1) (pos2 + as-pair widths (length? array*) * scaley)]
	]
	draw-bars-move: func [pos1 pos2 /local image2 size off jump] [
		off: 0x0
		jump: gap
		size: as-pair (abs pos2/x - pos1/x) 200
		if pos2/x < pos1/x [pos1: pos2 off: gap jump: 0x0]
		image2: copy/part at canvas/image pos1 + off size
		draw canvas/image compose/deep [image (image2) (pos1 + jump)]
		image2: none
	]
	draw-bars: func [color] [
		for n 1 length? array* 1 [
			draw-bar color positions/:n max 1 array*/:n
		]
		show canvas
	]
	final-draws: does [
		draw-box gray positions/1 positions/(length? array*)
		draw-bars white ; be sure to draw all bars in white color
		set-face text-comps comps
		set-face text-swaps swaps
	]
;
; compare, swap, move
	compare: func [array a b /local result][
		if not running [throw 0] ; allow execution stopping
		comps: comps + 1
		result: array/:a > array/:b

		either speed > 0 [
			; draw triangles
			draw-triangle red positions/:a
			draw-triangle either a != b [red][yellow] positions/:b
			show canvas
			; erase triangles
			draw-triangle gray positions/:a
			draw-triangle gray positions/:b
			
			set-face text-comps comps
		][
			show canvas
		]
		
		if not result [
			draw-bar black positions/:a array/:a
			draw-bar white positions/:b array/:b
		]

		wait speed ; listen gui events
		result
	]
	swap: func [[catch] array a b /local temp] [
		if not running [throw 0] ; allow execution stopping
		temp: length? array
		if any [a < 1 a > temp b < 1 b > temp][alert "Out of array limits" exit]
		; erase previous line
		draw-box gray positions/1 positions/(length? array)
		; erase current bars
		draw-bar gray positions/:a array/:a
		draw-bar gray positions/:b array/:b

		temp: array/:a
		array/:a: array/:b
		array/:b: temp

		; draw a line from a to b
		draw-arrow magenta positions/:b positions/:a
		; draw current bars
		draw-bar black positions/:a array/:a
		draw-bar white positions/:b array/:b

		swaps: swaps + 1
		if speed > 0 [set-face text-swaps swaps]
		wait speed ; listen gui events
	]
	move-to: func [[catch] array a b /local n] [
		if not running [throw 0] ; allow execution stopping
		if a = b [exit]
		; erase previous line
		draw-box gray positions/1 positions/(length? array)
		; erase old bars
		draw-bars-move positions/:b positions/:a
		draw-bar gray positions/:a array/:a
		draw-bar gray positions/:b array/:b

		move at array a b - a

		; draw a line from a to b
		draw-arrow green positions/:b positions/:a
		; draw current bars
		draw-bar black positions/:a array/:a
		draw-bar white positions/:b array/:b

		show canvas ; only for Radix sorts
		swaps: swaps + 1
		if speed > 0 [set-face text-swaps swaps] ; to show what is happening
		wait speed ; listen gui events
	]
;
; sorting functions
	do sorting-functions: [

	Bubble-simple: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count index-outer index
		][
		item-count: length? array
		for index-outer 1 item-count 1 [
			for index 1 item-count - index-outer 1 [
				if compare array index index + 1 [
					swap array index index + 1
				]
			]
		]
	]
	Bubble-exit: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count finished index
		][
		item-count: length? array
		until [
			finished: true
			item-count: item-count - 1
			for index 1 item-count 1 [
				if compare array index index + 1 [
					swap array index index + 1
					finished: false
				]
			]
			finished
		]
	]
	Odd-Even: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count index-outer index
		][
		item-count: length? array

		for index-outer 1 (item-count / 2) 1 [
			for index 1 item-count - 1 2 [
			    if compare array index index + 1 [
					swap array index index + 1
				]
			]
			for index 2 item-count - 1 2 [
			    if compare array index index + 1 [
					swap array index index + 1
				]
			]
		]
	]
	Slow: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count index-outer index
		][
		item-count: length? array
		for index-outer 1 item-count 1 [
			for index index-outer + 1 item-count 1 [
				if not compare array index index-outer [
					swap array index index-outer
				]
			]
		]
	]
	Cocktail: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count lower upper finished index
		][
		item-count: length? array

		lower: 0
		upper: item-count
		finished: false

		while [not finished] [

			lower: lower + 1
			upper: upper - 1
			finished: true

			for index lower upper 1 [
				if compare array index index + 1 [
					swap array index index + 1
					finished: false
				]
			]
			if finished [break]
			for index upper lower -1 [
				if compare array index index + 1 [
					swap array index index + 1
					finished: false
				]
			]
		]
	]
	Selection: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count iMax index-outer index
		][
		item-count: length? array
		for index-outer item-count 2 -1 [
			
			iMax: 1
			
			;Find the largest value in the subarray
			for index 1 index-outer 1 [
				if compare array index iMax [iMax: index]
			]
			
			;Swap with last slot of the subarray
			swap array iMax index-outer
		]
	]
	Selection-2: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count imin index-outer index
		][
		item-count: length? array
		for index-outer 1 item-count 1 [
			imin: index-outer
			
			;Find the smallest value in the subarray
			for index index-outer + 1 item-count 1 [
				if not compare array index imin [
					imin: index
					if array/(index-outer - 1) = array/(imin) [break] ; optimization
				]
			]
			
			;Swap with first slot of the subarray
			if imin <> index-outer [swap array imin index-outer]
		]
	]
	Shaker: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count lower upper imax imin index
		][
		item-count: length? array

		lower: 1
		upper: item-count

		while [lower < upper] [

			imin: lower
			imax: lower

			;find the largest and smallest values in the subarray
			for index lower + 1 upper 1 [
				if compare array imin index [imin: index]
				if compare array index imax [imax: index]
			]
			;swap the smallest with the first slot of the subarray
			swap array imin lower

			;swap the largest with last slot of the subarray
			either imax = lower [
				swap array imin upper
			][
				swap array imax upper
			]

			lower: lower + 1
			upper: upper - 1
		]
	]
	Insertion: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count index-outer index
		][
		item-count: length? array
		for index-outer 2 item-count 1 [
			;Move along the already sorted values shifting along
			for index index-outer 2 -1 [
				;No more shifting needed, we found the right spot!
				if compare array index index - 1 [break]
				swap array index - 1 index
			]
		]
	]
	Insertion-2: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count index-outer index
		][
		item-count: length? array
		for index-outer 2 item-count 1 [
			index: 1
			while [compare array index-outer index] [
				index: index + 1
				if index-outer = index [break]
			]
			move-to array index-outer index
		]
	]
	Gnome: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count pos prev
		][
		item-count: length? array

		pos: 2
		prev: 1
		while [pos <= item-count] [
			either not compare array pos - 1 pos [
				if prev != 1 [
					pos: prev
					prev: 1
				]
				pos: pos + 1
			][
				swap array pos - 1 pos
				if pos > 2 [
					if prev = 1 [
						prev: pos
					]
					pos: pos - 1
				]
			]
		]	   
	]
	Bisecting: func [
		{Insertion sort using bisection (binary search). This is my original idea. I have not found it anywhere, therefore it is:
		Copyright (C) 2013-2016 Marco Antoniazzi. All rights reserved.
		It is licensed under MIT licence (aknowledge is appreciated)}
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count index left right mid
		][
		item-count: length? array

		for index 2 item-count 1 [
			left: 1
			right: index - 1
			while [left <= right] [
				mid: shift left + right 1
				either compare array index mid [left: mid + 1][right: mid - 1]
			]
			move-to array index left 
		]
	]
	Comb: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count index-outer index spacing finished
		][
		item-count: length? array

		spacing: item-count
		until [
			if spacing > 1 [
				spacing: to-integer spacing / 1.3

				either spacing = 0 [
					spacing: 1  ;dont go lower than 1
				][
					if all [spacing > 8 spacing < 11] [spacing: 11] ;this is a special number, goes faster than 9 and 10
				]
			]

			;always go down to 1 before attempting to exit
			if spacing = 1 [finished: true]

			;combing pass
			for index item-count - spacing 1 -1 [ ; go in reverse order only to be able to draw from black to white
				if compare array index index + spacing [
					swap array index index + spacing
					;not finished
					finished: false
				]
			]

			finished
		]
	]
	Shell: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count spacing finished index-outer index
		][
		item-count: length? array

		spacing: item-count
		until [
			; 1st part equal to comb
			if spacing > 1 [
				spacing: to-integer spacing * 0.76 ;/ 1.3

				either spacing = 0 [
					spacing: 1  ;dont go lower than 1
				][
					if all [spacing > 8 spacing < 11] [spacing: 11] ;this is a special number, goes faster than 9 and 10
				]
			]

			;always go down to 1 before attempting to exit
			if spacing = 1 [finished: true]

			;2nd part similar to insertion
			for index-outer item-count 1 + spacing -1 [ ; go in reverse order only to be able to draw from black to white
				;Move along the already sorted values shifting along
				for index index-outer - spacing 1 -1 [
					;No more shifting needed, we found the right spot!
					if not compare array index index-outer [ break]
					swap array index index-outer
					finished: false
				]
			]
			finished
		]
	]
	Heap: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count reheap index
		][
		item-count: length? array

		reheap: func [low high /local j son x][
			j: low
			forever [
				if (x: j * 2) > high [break]
				either (x + 1) <= high [
					son: either compare array x x + 1 [x][x + 1]
				][
					son: x
				]
				either not compare array j son [
					swap array j son
					j: son
				][
					break
				]
			]
		]

		for index to-integer (item-count / 2) 1 -1 [
			reheap index item-count
		]
		for index item-count 2 -1 [
			swap array 1 index
			reheap 1 index - 1
		]
	]
	Radix-LSD: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count num nums radix index items
		][
		item-count: length? array

		nums: to-integer log-10 first maximum-of array
		for num 0 nums 1 [
			items: item-count
			for digit 0 9 1 [
				cfor [index: 1] [index <= items] [index: index + 1] [
					radix: to-integer (array/:index / (power 10 num)) // 10
					if radix = digit [
						; these instructions should be substituted using blocks (10 "buckets")
						move-to array index item-count 
						index: index - 1 ; go back to stay here
						items: items - 1
					]
					comps: comps + 1 ; keep track of right number of compares
				]
			]
		]
	]
	Radix-LSB: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count bit mask low high finished
		][
		item-count: length? array

		bit: 0
		finished: false
		until [
			mask: shift/left 1 bit
			low: 1
			high: item-count
			while [low <= high] [
				either 0 != (array/:low and mask) [
					move-to array low item-count
					finished: true
					high: high - 1
				][
					low: low + 1
				]
				comps: comps + 1 ; keep track of right number of compares
			]

			bit: bit + 1
			all [high = item-count finished]
		]
	]
	Radix-MSB: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count rsort max-bits
		][
		item-count: length? array

		rsort: func [low high bit /local left right mask][
			left: low
			right: high
			mask: shift/left 1 bit
			while [left < right] [
				while [all [left < right 0 = (array/:left and mask)]] [
					left: left + 1
					comps: comps + 1 ; keep track of right number of compares
				]
				while [all [left < right 0 != (array/(right - 1) and mask)]] [
					if speed > 0 [draw-bar white positions/(right - 1) array/(right - 1) show canvas wait speed] ; to show what is happening
					right: right - 1
					comps: comps + 1 ; keep track of right number of compares
				]
				if left < right [swap array left right: right - 1 left: left + 1]
				show canvas
			]
			if all [(left > low) bit != 0]  [rsort low left bit - 1]
			if all [(left < high) bit != 0] [rsort left high bit - 1]
		]
	
		max-bits: 1 + to-integer log-2 first maximum-of array
		rsort 1 item-count + 1 max-bits	
	]
	Merge: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count mergesort index
		][
		item-count: length? array

		mergesort: func [low high /local mid][
			if low = high [exit]
			if (low + 1) = high [
				if compare array low high [
					swap array low high
				]
				exit
			]
			mid: to-integer (low + high / 2)
			mergesort low mid
			mergesort mid + 1 high
			mid: mid + 1
			while [all [low < mid mid <= high]] [
				either compare array low mid [
					move-to array mid low
					mid: mid + 1
				][
					low: low + 1
				]
			]
		]

		mergesort 1 item-count
	]
	Quick: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count qsort
		][
		item-count: length? array

		qsort: func [low high /local left right pivot][
			if low >= high [exit]
			if (low + 1) = high [
				if compare array low high [
					swap array low high
				]
				exit
			]
			left: low
			right: high
			pivot: low
			while [left < right][
				while [compare array pivot left] [left: left + 1]
				while [compare array right pivot] [right: right - 1]
				if left <= right [
					if left != right [swap array left right]
					left: left + 1
					right: right - 1
				]
			]
			qsort low right
			qsort left high
		]
		
		qsort 1 item-count

	]
	Quick-2: func [
		[throw] ; this is necessary to stop execution
		array [block!]
		/local item-count qsort
		][
		item-count: length? array

		qsort: func [low high /local left right p q k][
			if high <= low [exit]
			left: low - 1
			right: high
			p: low - 1
			q: high

			while [true] [
				while [compare array high left: left + 1] []
				while [compare array right: right - 1 high] [if right = low [break]]
				if left >= right [break]
				swap array left right

				if array/:left = array/:high [swap array p: p + 1 left]
				if array/:right = array/:high [swap array q: q - 1 right]
				comps: comps + 2 ; keep track of right number of compares
			]
			swap array left high
			right: left - 1
			left: left + 1
			for k low p - 1 1 [swap array k right right: right - 1]
			for k high - 1 q + 1 -1 [swap array k left left: left + 1]

			qsort low right
			qsort left high
		]
		
		qsort 1 item-count
	]
	
	] ; do sorting-functions
	
;
; create block with sorting functions names
	algorithms: copy []
	forskip sorting-functions 4 [insert tail algorithms to-string first sorting-functions]
;
; gui
win: layout [
	do [sp: 4x2] origin sp space sp 
	Across 
	canvas: box make image! 520x250 
	guide 
	drop-type: drop-down 130 rows 6 with [text: first list-data: ["Random" "Almost-Sorted" "Sorted" "Rev-Sorted" "Many-Equals" "Equals" "Rev-Equals"]] [reset]
	return
	text "Items:"
	text-items: text "10" bold 30 right
	return
	slider-items: slider 130x20 0.0 [change-items-num to-decimal value] with [append init [redrag 0.6]]
	return
	drop-sorts: drop-down 130 rows 6 with [text: first list-data: algorithms]
	return 
	text "Speed:"
	text-speed: text "10" bold 30 right
	return
	slider 130x20 0.1 [set-face text-speed to-integer 100 * speed: round/to value / 2 0.01]
	return 
	btn "Run" [if not running [reset catch [start]]]
	btn "Stop" [if running [stop]]
	;btn "Step" 
	btn "Reset" [reset]
	return 
	space 4x-2
	text-running: text bold red "Stopped"
	return
	text bold "Comparisons:" 
	text-comps: text 40 "0" 
	return 
	text bold "Swaps:" 
	text-swaps: text 40 "0"
	return 
	text bold "Elapsed time:" 
	return
	text-time: text "0:00:00.000"
	return
	ticker: sensor 0x0 rate none feel [engage: func [face action event][if event/type = 'time [set-face text-time secs: secs + 1]]]
	do [
		canvas/effect: [] ; remove default colorize effect and avoid image scaling
		change-items-num 0.0
	]
]
view/new win

do-events
