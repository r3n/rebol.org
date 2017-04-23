REBOL [
	File:		%histogrammer.r
	Date:		15-Apr-2011
	Title:		"Histogram maker"
	Purpose:	{To produce a histogram from a data series,
				 to display it in a window, to save it as PNG file
				 and/or as a data file}

	Author:		"Rudolf W. Meijer"
	Home:		http://users.telenet.be/rwmeijer
	E-mail:		rudolf.meijer@telenet.be
	Version:	1.0.0
	Comment:	"Needs RebGUI (http://www.dobeash.com/rebgui.html)"

	History: [
				0.1.0 [9-Apr-2011 {Start of project} "RM"]
				1.0.0 [15-Apr-2011 {First release} "RM"]
	]

	Library: [
		level:			'intermediate
		platform:		'all
		type:			'function
		domain:			[scientific graphics]
		tested-under:	[SDK 2.7.8 "Windows XP"]
		support:		"Contact author by e-mail"
		license: {
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License (http://www.gnu.org/licenses)
 for more details.
}
	]
]
;---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|-

ctx-histo: context [

	; settable constants (parameters)
	bg-color: 255.255.240			; background for histogram
	bar-color: gray					; color of histo bars
	ind-size: 960x480				; indicative dimensions of histogram
	max-bar: 48						; max width of bar
	; "globals"
	rg-version: none				; set by call to make-histo
	ofile: none						; for Save and List options

	set 'make-histo func [
		{Produces, displays and saves a histogram from a data series.
		 Needs RebGUI (http://www.dobeash.com/rebgui.html).}
		h-data [block! string! binary!]
			{if a block, must be flat sequence of fixed size records;
			 if a string or binary, may also have fixed size records.}
		rec-size [integer!]		{the record size;
			length? h-data must be an integral multiple of rec-size}
		field-no [integer!]		{the index of the field to be histogrammed;
			this must be of same type integer! or char! in all records;
			this condition is not checked! and may lead to errors}
		intval [integer!]		{the size of a single interval}
		/title title-text [string!]
								{will be displayed on top}
		/size histo-size [pair!]
								{specify approx. size in pixels}
		/start start-val [integer! char!]
								{lowest value on x-axis}
		/local					; in order of appearance
		 integral? text-size s-mold get-file
		 cell-size nr-points sorted min-val max-val nr-bars histo limit
		 h-size v-size max-freq v-scale o-magn vdiv-width
		 field-height nr-vdiv v-div v-frac bar-width hdiv-width h-div
		 hdiv-size vdiv-size window v-bias v-margin
		 nth-vdiv v-pos tall nth-hdiv div-val nth-divval
	][

		integral?: func [n][n = to-integer n]

		text-size: func [v [integer! char!]][
			case [
				char? v		[20 / cell-size]
				; rare case of max-val = min-val = 0
				v = 0		[12 / cell-size]
				; normal case: non-zero integer
				true [
					round/ceiling (8 * to-integer log-10 abs v) + 12
					+ (either negative? v [8][0]) / cell-size
				]
			]
		]

		s-mold: func [v [integer! char!] /local m][
			m: mold v if char? v [m: copy/part at m 3 back tail m] m]

		get-file: func [ext [file!] /local filter-text][
			; calling convention changed between 1xx and 2xx
			filter-text: join uppercase to-string next ext " files"
			either rg-version < 200 ; set immediately below
			[request-file/save/only/filter filter-text to-string join "*" ext]
			[request-file/save/title/filter filter-text ext]
		]

		; check that RebGUI is loaded
		; ---------------------------

		either value? 'ctx-rebgui
		[
			rg-version: ctx-rebgui/build		; used by getfile
			cell-size: ctx-rebgui/sizes/cell
		][
			alert "RebGUI missing! Get it from http://rebgui.codeplex.com"
			exit
		]

		; check settings and arguments
		; ----------------------------

		if any [
			cell-size > 4
			cell-size < 3
		][alert "Incorrect RebGUI settings! Check ctx-rebgui/sizes/cell = 3 or 4" exit]

		if any [
			not tuple? bg-color
			not tuple? bar-color
			not pair? ind-size
			ind-size/x < 1
			ind-size/y < 1
			not integer? max-bar
			max-bar < 1
		][alert "Incorrect parameter settings! Check ctx-histo" exit]

		nr-points: length? h-data
		if any [
			nr-points = 0
			rec-size < 1
			field-no < 1
			intval < 1
			field-no > rec-size
			not integral? nr-points / rec-size
		][alert "Incorrect or empty input!" exit]

		; compute histogram
		; -----------------

		; first sort the data
		sorted: copy h-data
		sort/skip/compare sorted rec-size field-no
		sorted: at sorted field-no
		; compute minimum and maximum value and number of bars
		min-val: first sorted
		if all [start (type? start-val) = (type? min-val)][
			min-val: min start-val min-val
		]
		max-val: pick sorted nr-points - rec-size + 1
		nr-bars: 1 + to-integer max-val - min-val / intval
		; initialize histogram
		histo: array/initial nr-bars 0
		; scan the data and tally the values
		; intervals are closed on the left and open on the right
		limit: min-val + intval
		while [not tail? sorted][
			either (first sorted) < limit
			[
				change histo 1 + first histo
				sorted: skip sorted rec-size
			][
				histo: next histo
				limit: limit + intval
			]
		]
		histo: head histo

		; make histogram (graph) in window
		; --------------------------------

		; first compute the dimensions of the histogram display:

		either all [size (histo-size/x > 0) (histo-size/y > 0)]
		[h-size: to-integer histo-size/x / cell-size
		 v-size: to-integer histo-size/y / cell-size]
		[h-size: to-integer ind-size/x / cell-size
		 v-size: to-integer ind-size/y / cell-size]

		; size of tallest bar, vertical scale factor and adjusted v-size
		; for v-scale < 1, we round to nearest "nice" value:
		; .5, .2, .1, .05, .02., .01, .005 etc.
		max-freq: first sort/reverse copy histo
		v-scale: v-size / max-freq
		either v-scale < 1
		[
			o-magn: 10 ** round/floor log-10 v-scale
			v-scale: o-magn * pick [1 1 2 2 2 5 5 5 5 5 5 5 5 5 10 10 10 10 10 10]
				to-integer 2 * v-scale / o-magn
		][
			v-scale: to-integer v-scale
		]
		v-size: max-freq * v-scale
		vdiv-width: text-size max-freq

		; height of text fields for divisions (title field is twice high)
		; this may be set to between 12 and 20 without compromising the graph
		; the smaller field-height, the closer the vertical divisions will
		; be together
		field-height: to-integer 20 / cell-size
		; nr-vdiv is max. number of vertical divisions that can be shown
		; v-div is the step y-value shown at the divisions
		nr-vdiv: to-integer v-size / field-height
		v-div: max 1 to-integer max-freq / nr-vdiv
		o-magn: to-integer 10 ** to-integer log-10 v-div
		unless integral? v-frac: v-div / o-magn [
			v-div: o-magn * to-integer v-frac + 1
		]

		; actual bar width (limited to max-bar)
		bar-width:	min to-integer max-bar / cell-size
					max 1 to-integer h-size / nr-bars

		; size of division field on x axis
		hdiv-width: 8 / cell-size + 
			either any [char? max-val (abs max-val) > (abs min-val)]
			[text-size max-val][text-size min-val]
		; h-div is the step in x-values needed to make sure hdiv-width is
		; available for the text field
		h-div: hdiv-width / bar-width
		unless integral? h-div [h-div: to-integer h-div + 1]

		vdiv-width: max vdiv-width hdiv-width
		hdiv-size: as-pair hdiv-width field-height
		vdiv-size: as-pair vdiv-width field-height


		; compose the window for display

		window: make block! [
			graph: panel bg-color data []
		]

		either all [title not empty? title-text]
		[
			; re-adjust graph sizes and insert the title text field
			h-size: nr-bars * bar-width + vdiv-width + (20 / cell-size)
			v-bias: 2 * field-height
			v-size: v-size + v-bias
			insert last window compose/deep [
				at 0x0 text (as-pair h-size v-bias)
				(title-text) bold font [align: 'center size: 18]
			]
		][
			v-bias: 0
		]

		v-margin: to-integer 12 / cell-size
		; position the vertical (y-value) divisions
		; the while condition guards against overlap of the highest y-value
		; below max-freq with that of max-freq itself
		nth-vdiv: 0
		while [(v-bias + v-margin) <= (v-pos: v-size - to-integer v-scale * nth-vdiv)][
			insert tail last window compose [
				at (as-pair 0 v-pos) text (vdiv-size)
				(to-string nth-vdiv) font [align: 'right]
			]
			nth-vdiv: nth-vdiv + v-div
		]
		; insert y-value of tallest bar
		insert tail last window compose [
			at (as-pair 0 v-bias) text (vdiv-size)
			(to-string max-freq) font [align: 'right]
		]

		; construct the bars and insert them
		repeat i nr-bars [
			tall: to-integer v-scale * histo/:i
			unless histo/:i = 0 [tall: max 1 tall]
			insert tail last window compose [
				at (as-pair i - 1 * bar-width + vdiv-width + 2
						v-size - tall + v-margin)
				box (as-pair max 1 bar-width - 1 tall) (bar-color)
			]
		]

		; show the horizontal (x-value) divisions
		nth-hdiv: 0
		div-val: h-div * intval
		nth-divval: min-val
		while [nth-divval <= (max-val + div-val)][
			insert tail last window compose [
				at (as-pair nth-hdiv * bar-width + vdiv-width - hdiv-width + 3
					v-size + v-margin)
				text (hdiv-size) (join s-mold nth-divval "|")
				font [align: 'right]
			]
			nth-hdiv: nth-hdiv + h-div
			nth-divval: nth-divval + div-val
		]

		; insert the Save, List and Close buttons
		insert tail window [
			return
			button "Save" [
				either ofile: get-file %.png
				[save/png ofile to-image graph][exit]
			]
			button "List" [
				either ofile: get-file %.txt
				[save ofile head insert histo reduce [min-val intval]][exit]
			]
			button "Close" [hide-popup]
		]

		; display the window to show the histogram
		; ----------------------------------------
		display/dialog "Histogrammer v. 1.0.0" window

	] ; end make-histo

] ; end context-histo