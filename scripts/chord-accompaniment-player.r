Rebol [
	title: "Chord Accompaniment Player"
	date: 29-june-2008
	file: %chord-accompaniment-player.r  
	author:  Nick Antonaccio
	purpose:  {
		Plays music backup tracks, based on chord progressions
		entered as text.  
		See http://musiclessonz.com/rebol_tutorial.html#section-31.11
		for a case study about how this program was created.		
	}
]

; load wave files for all chords:

do load-thru http://musiclessonz.com/rebol_tutorial/wave_data.r

; trap the close event:

play: false
insert-event-func [
    either event/type = 'close [
		if play = true [play: false close sound-port]
		really: request "Really close the program?"
		if really = true [quit]
    ][
		event
	]
]

; create the GUI (the "PLAY" button does most of the work):

view center-face layout [
	across
	h2 "Chords:"
	tab
	chords: area 392x300 trim {
		bm bm bm bm
		gb7 gb7 gb7 gb7
		a a a a 
		e e e e
		g g g g
		d d d d 
		em em em em
		gb7 gb7 gb7 gb7
		g g g g
		d d d d
		gb7 gb7 gb7 gb7
		bm bm bm bm
		g g g g
		d d d d
		em em em em
		gb7 gb7 gb7 gb7
	}
	return
	h2 "Delay:"
	tab
	tempo: field 50 "0.35" text "(seconds)"
	tabs 40 tab
	btn "PLAY" [
		play: true
		the-tempo: to-decimal tempo/text
		sounds: to-block chords/text
		wait 0
		sound-port: open sound://
		forever [
			foreach sound sounds [
				if play = false [break]
				do rejoin ["insert sound-port " reduce [sound]]
				wait sound-port
				wait the-tempo 
			]
			if play = false [break]
		]
	]
	btn "STOP" [
		play: false
		close sound-port
	]
	btn "Save" [save to-file request-file/save chords/text]
	btn "Load" [chords/text: load read to-file request-file show chords]
	btn "HELP" [
		alert {
			This program plays chord progressions.  Simply type in
			the names of the chords that you'd like played, with a
			space between each chord.  For silence, use the
			underscore ("_") character.  Set the tempo by entering a 
			delay time (in fractions of second) to be paused between
			each chord.  Click the start button to play from the 
			beginning, and the stop button to end.  Pressing start
			again always begins at the first chord in the 
			progression.  The save and load buttons allow you to 
			store to the hard drive any songs you've created.
			Chord types allowed are major triad (no chord symbol - 
			just a root note), minor triad ("m"), dominant 7th 
			("7"), major 7th ("maj7"), minor 7th ("m7"), diminished
			7th ("dim7"), and half diminished 7th ("m7b5").
			*** ALL ROOT NOTES ARE LABELED WITH FLATS (NO SHARPS)
			F# = Gb, C# = Db, etc...
 		}
	]
]
