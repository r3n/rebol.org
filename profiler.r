REBOL [
	Title: "Rebol Profiler"
	Author: "Ingo Hohmann"
	Date: 2003-10-10
	Purpose: {For profiling parts of Rebol scripts}
	file: %profiler.r
	library: [
		level: 'intermediate
		platform: 'all
		type: [tool]
		domain: [all]
                support: none
                license: gpl
		tested-under: [View-2.8.1.4.2 Core-2.5.6.4.2 and-others]
	]
	Usage: {
		I use it mostly to check runtime effect of little rebol snippets, e.g.
  		profiler/test [do reduce [1 = 0]] 1000000
		against
		  profiler/test [first reduce [1 = 0]] 1000000
		}
]

profiler: context [
	markers: []
	
	mark: func [
    "adds a profiler mark"
		marker [word!]
	] [
		insert tail markers reduce [ marker now/time/precise ]
	]

	

	show: func [
    "shows time since setting a profiler mark"
		marker [word!]
		/local t walk ret-val last-val tmp-val
	] [
		ret: copy []
		t: now/time/precise
		if walk: find markers marker [
			walk: next walk
			last-val: first walk
			while [walk: find walk marker] [
				walk: next walk
				append ret (first walk) - last-val
				last-val: first walk
			]
		]
		ret
	]

	test: func [
		{tests a block for speed *!* clears the markers block *!*}
		block [block!]
		times [integer!]
	] [
		block: copy/deep block
		clear
		mark 't
		loop times [do block]
		mark 't
		show 't
	]
	
	clear: func [
		"Clears all markers"
		/only marker [word!]
		/local walk
	] [
		either only [
			walk: find markers marker
			until [
				remove/part walk 2
				not found? find walk marker
			]
		] [
			system/words/clear markers
		]
	]

	;
	; EXPERIMENTAL CODE FOLLOWING
	;

	next-marker: 1
	
	_func: function!
	;
	; ToDo:
	; create a list of marks, find a way to name the functions
	;
	profiling-func: func [
		{Adds profiling data to a normal function}
		    [catch] 
    spec [block!] {Help string (opt) followed by arg words (and opt type and string)} 
    body [block!] "The body block of the function"
		/local pre post
	][
		pre: copy [catch/name ]
		post: copy ['profiling-return]
		insert body compose [profiler/mark (to-word join 'm next-marker)]
		next-marker: next-marker + 1
		insert tail insert/only tail pre body post
		probe pre
	]
	
	install: func [
		{Installs a profiling 'func
			every new func after this will create a profiling function}
	][
		_func: :func
		func: :profiling-func
	]
	
]

	