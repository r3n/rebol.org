REBOL [
	File:		%color-converter.r
	Date:		18-Apr-2011
	Title:		"Color converter (RGB to HSL v.v.)"
	Purpose:	{To convert RGB color values to HSL values v.v.
				 and to show them visually}

	Author:		"Rudolf W. Meijer"
	Home:		http://users.telenet.be/rwmeijer
	E-mail:		rudolf.meijer@telenet.be
	Version:	1.0.0
	Comment:	"Needs RebGUI (http://www.dobeash.com/rebgui.html)"

	History: [
				0.1.0 [7-Apr-2011 {Start of project} "RM"]
				1.0.0 [18-Apr-2011 {First release} "RM"]
	]
	Library: [
		level:			'beginner
		platform:		'all
		type:			[demo tool]
		domain:			'graphics
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

; check that RebGUI is loaded
; ---------------------------

unless value? 'ctx-rebgui [
	alert "RebGUI missing! Get it from http://rebgui.codeplex.com"
	halt
]

to-int: func [d [integer! decimal!]][to-integer round d]
to-hex: func [b [binary!]][rejoin ["#" copy/part at form b 3 6]]

hsl-rgb: func [
	hsl [tuple!]
	/local L S C H' X R G B mi
][
	either 3 <> length? hsl
	[
		0.0.0
	][
		S: hsl/2 / 240
		L: hsl/3 / 240
		C: (1 - abs 2 * L - 1) * S
		H': mod hsl/1 / 40 6
		X: C * (1 - abs ((mod H' 2) - 1))
		set [R G B] case [
			H' < 1 [reduce [C X 0]]
			H' < 2 [reduce [X C 0]]
			H' < 3 [reduce [0 C X]]
			H' < 4 [reduce [0 X C]]
			H' < 5 [reduce [X 0 C]]
			H' < 6 [reduce [C 0 X]]
			true   [[0 0 0]]
		]
		R: to-int R * 255
		G: to-int G * 255
		B: to-int B * 255
		mi: to-int L - (C / 2) * 255
		(to-tuple reduce [R G B]) + mi
	]
]

rgb-hsl: func [
	rgb [tuple! binary!]
	/local R G B Ma mi C H' L S
][
	either 3 <> length? rgb
	[
		0.0.0
	][
		R: rgb/1 / 255
		G: rgb/2 / 255
		B: rgb/3 / 255
		Ma: max max R G B
		mi: min min R G B
		C: Ma - mi
		H': case [
			C = 0  [0]
			Ma = R [mod G - B / C 6]
			Ma = G [    B - R / C + 2]
			Ma = B [    R - G / C + 4]
		]
		L: Ma + mi / 2
		S: either C = 0 [0][C / (1 - abs 2 * L - 1)]
		to-tuple reduce [to-int H' * 40 to-int S * 240 to-int L * 240]
	]
]

update-hsl: func [
	/local hsl clr
][
	hsl: rgb-hsl clr: to-tuple reduce [
		to-integer rfield/text
		to-integer gfield/text
		to-integer bfield/text
	]
	set-text hfield to-string hsl/1
	set-text sfield to-string hsl/2
	set-text lfield to-string hsl/3
	if side/picked <= 2 [
		lresult/color: clr show lresult
		set-text lcolor clr
	]
	if side/picked >= 2 [
		rresult/color: clr show rresult
		set-text rcolor clr
	]
]

update-rgb: func [
	/local clr
][
	clr: hsl-rgb to-tuple reduce [
		to-integer hfield/text
		to-integer sfield/text
		to-integer lfield/text
	]
	set-text rfield to-string clr/1
	set-text gfield to-string clr/2
	set-text bfield to-string clr/3
	if side/picked <= 2 [
		lresult/color: clr show lresult
		set-text lcolor clr
	]
	if side/picked >= 2 [
		rresult/color: clr show rresult
		set-text rcolor clr
	]
]


display "RGB to HSL v.v." compose [
	at  0x0 label -1 "R" bold
	at  6x0 rfield: spinner 12 options [0 255 8] data 0 [update-hsl]
	at 22x0 label -1 "G"  bold
	at 28x0 gfield: spinner 12 options [0 255 8] data 0 [update-hsl]
	at 44x0 label -1 "B"  bold
	at 50x0 bfield: spinner 12 options [0 255 8] data 0 [update-hsl]
	at  0x8 label -1 "H"  bold
	at  6x8 hfield: spinner 12 options [0 240 8] data 0 [update-rgb]
	at 22x8 label -1 "S"  bold
	at 28x8 sfield: spinner 12 options [0 240 8] data 0 [update-rgb]
	at 44x8 label -1 "L"  bold
	at 50x8 lfield: spinner 12 options [0 240 8] data 0 [update-rgb]
	at 28x16 text "Step size"
	at 50x16 spinner 12 options [1 10 1] data 8 [
		rfield/options/3: to-integer face/text
		bfield/options/3: to-integer face/text
		gfield/options/3: to-integer face/text
		hfield/options/3: to-integer face/text
		sfield/options/3: to-integer face/text
		lfield/options/3: to-integer face/text
	]
	at 10x24 side: radio-group 48x5 data [ 2 "left" "both" "right"][
		switch face/picked [
			1 [
				set-text rfield to-string lresult/color/1
				set-text gfield to-string lresult/color/2
				set-text bfield to-string lresult/color/3
			]
			3 [
				set-text rfield to-string rresult/color/1
				set-text gfield to-string rresult/color/2
				set-text bfield to-string rresult/color/3
			]
		]
		update-hsl
	]
	at 0x32 panel data [tight
	lresult: box 31x62 black rresult: box 31x62 black]
	at  0x96 lcolor: text 31 "0.0.0" font [align: 'center]
	at 31x96 rcolor: text 31 "0.0.0" font [align: 'center] return

	at 23x103 button 16 "Exit" [quit]
] do-events