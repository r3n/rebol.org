REBOL [
    Title: "periodic table"
	File: %periodictable.r
	Author: "Brian Tiffin"
	Date: 14-Jan-2007
	Version: 0.9.4
	Purpose: {Display a periodic table of the elements as REBOL buttons}
	History: [
            0.9.4 28-Jul-2007 btiffin "Added close button, experiment with plugin header field"
	    0.9.3 14-Jan-2007 btiffin "Idea for a draw effect generator from the orbits block..."
	    0.9.2 13-Jan-2007 btiffin "first addition - added seperate color for lanthanides and actinides, professionalized 'help about' title"
	    0.9.1 13-Jan-2007 btiffin "first correction - comment on elements missed weight and orbits"
        0.9.0 13-Jan-2007 btiffin "First cut - mistakes non-zero probable"
	]
	Library: [
		level: 'intermediate
		platform: [all plugin]
		type: [demo fun]
		domain: [gui scientific]
                plugin: [size: 740x252]
		tested-under: [view 1.3.2.4.2 Debian GNU/Linux 4.0 RC 1] 
		support: none
		license: GPL
		see-also: none
	]
]

; Define states as text color
gas: :white
liquid: :blue
solid: :black

; Define chemical series as button color
nonmetal: :green
alkali-metal: :blue
alkaline-earth-metal: :red
transition-metal: :yellow
metalloid: :magenta
halogen: :orange
poor-metal: sky
noble: :gold
lanthanide: :pink
actinide: :papaya

; Define the elements; Number, Symbol, Name, Group and period, chemical series, state at 0 celcius 1 atmosphere weight orbits
;    Group and period are a pair, with the pop-outs set to row (period) 9 and 10.  Groups run 1 to 18.
elements: [
    1 H Hydrogen 1x1 nonmetal gas 1.00794 [1]
	2 He Helium 18x1 noble gas 4.002602 [2]
	3 Li Lithium 1x2 alkali-metal solid 6.941 [2 1]
	4 Be Beryllium 2x2 alkaline-earth-metal solid 9.01218 [2 2]
	5 B Boron 13x2 metalloid solid 10.811 [2 3]
	6 C Carbon 14x2 nonmetal solid 12.011 [2 4]
	7 N Nitrogen 15x2 nonmetal gas 14.00674 [2 5]
	8 O Oxygen 16x2 nonmetal gas 15.9994 [2 6]
	9 F Fluorine 17x2 halogen gas 18.998403 [2 7]
	10 Ne Neon 18x2 noble gas 20.1797 [2 8]
    11 Na Sodium 1x3 alkali-metal solid 22.989768 [2 8 1]
	12 Mg Magnesium 2x3 alkaline-earth-metal solid 24.305 [2 8 2]
	13 Al Aluminum 13x3 poor-metal solid 26.981539 [2 8 3]
	14 Si Silicon 14x3 metalloid solid 28.0855 [2 8 4]
	15 P Phosphorus 15x3 nonmetal solid 30.973762 [2 8 5]
	16 S Sulphur 16x3 nonmetal solid 32.066 [2 8 6]
	17 Cl Chlorine 17x3 halogen gas 35.4527 [2 8 7]
	18 Ar Argon 18x3 noble gas 39.948 [2 8 8]
	19 K Potassium 1x4 alkali-metal solid 39.0983 [2 8 8 1] 
	20 Ca Calcium 2x4 alkaline-earth-metal solid 40.078 [2 8 8 2]
	21 Sc Scandium 3x4 transition-metal solid 44.95591 [2 8 9 2]
	22 Ti Titanium 4x4 transition-metal solid 47.88 [2 8 10 2]
	23 V Vanadium 5x4 transition-metal solid 50.9415 [2 8 11 2]
	24 Cr Chromium 6x4 transition-metal solid 51.9961 [2 8 13 1]
	25 Mn Manganese 7x4 transition-metal solid 54.93805 [2 8 13 2]
	26 Fe Iron 8x4 transition-metal solid 55.847 [2 8 14 2]
	27 Co Cobalt 9x4 transition-metal solid 58.9332 [2 8 15 2]
	28 Ni Nickel 10x4 transition-metal solid 58.6934 [2 8 16 2]
	29 Cu Copper 11x4 transition-metal solid 63.546 [2 8 18 1]
	30 Zn Zinc 12x4 transition-metal solid 65.39 [2 8 18 2]
	31 Ga Gallium 13x4 poor-metal solid 69.723 [2 8 18 3]
	32 Ge Germanium 14x4 metalloid solid 72.61 [2 8 18 4]
	33 As Arsenic 15x4 metalloid solid 74.92159 [2 8 18 5]
	34 Se Selenium 16x4 nonmetal solid 78.96 [2 8 18 6]
	35 Br Bromine 17x4 halogen liquid 79.904 [2 8 18 7]
	36 Kr Krypton 18x4 noble gas 83.8 [2 8 18 8]
	37 Rb Rubidium 1x5 alkali-metal solid 85.4678 [2 8 18 8 1]
	38 Sr Strontium 2x5 alkaline-earth-metal solid 87.62 [2 8 18 8 2]
	39 Y Yttrium 3x5 transition-metal solid 88.90585 [2 8 18 9 2]
	40 Zr Zirconium 4x5 transition-metal solid 91.224 [2 8 18 10 2]
	41 Nb Niobium 5x5 transition-metal solid 92.90638 [2 8 18 12 1]
	42 Mo Molybdenum 6x5 transition-metal solid 95.94 [2 8 18 13 1]
	43 Tc Technetium 7x5 transition-metal solid 97.9072 [2 8 18 13 2]
	44 Ru Ruthenium 8x5 transition-metal solid 101.07 [2 8 18 15 1]
	45 Rh Rhodium 9x5 transition-metal solid 102.9055 [2 8 18 16 1]
	46 Pd Palladium 10x5 transition-metal solid 106.42 [2 8 18 18 0]
	47 Ag Silver 11x5 transition-metal solid 107.8682 [2 8 18 18 1]
	48 Cd Cadmium 12x5 transition-metal solid 112.411 [2 8 18 18 2]
	49 In Indium 13x5 poor-metal solid 114.818 [2 8 18 18 3]
	50 Sn Tin 14x5 poor-metal solid 118.71 [2 8 18 18 4]
	51 Sb Antimony 15x5 metalloid solid 121.760 [2 8 18 18 5]
	52 Te Tellurium 16x5 metalloid solid 127.6 [2 8 18 18 6]
	53 I Iodine 17x5 halogen solid 126.90447 [2 8 18 18 7]
	54 Xe Xenon 18x5 noble gas 131.29 [2 8 18 18 8]
	55 Cs Cesium 1x6 alkali-metal solid 132,90543 [2 8 18 18 8 1]
	56 Ba Barium 2x6 alkaline-earth-metal solid 137.327 [2 8 18 18 8 2]
	57 La Lanthanum 3x9 lanthanide solid 138.9055 [2 8 18 18 9 2]
    58 Ce Cerium 4x9 lanthanide solid 140.115 [2 8 18 20 8 2]
    59 Pr Praseodymium 5x9 lanthanide solid 140.90765 [2 8 18 21 8 2]
    60 Nd Noedymium 6x9 lanthanide solid 144.24  [2 8 18 22 8 2]
    61 Pm Promethium 7x9 lanthanide solid 144.9127 [2 8 18 23 8 2]
    62 Sm Samarium 8x9 lanthanide solid 150.36 [2 8 18 24 8 2]
    63 Eu Europium 9x9 lanthanide solid 151.965 [2 8 18 25 8 2]
    64 Gd Gadolinium 10x9 lanthanide solid 157.25 [2 8 18 25 9 2]
    65 Tb Terbium 11x9 lanthanide solid 158.92534 [2 8 18 27 8 2]
    66 Dy Dysprosium 12x9 lanthanide solid 162.50 [2 8 18 28 8 2]
    67 Ho Holmium 13x9 lanthanide solid 164.93032 [2 8 18 29 8 2]
    68 Er Erbium 14x9 lanthanide solid 167.26 [2 8 18 30 8 2]
    69 Tm Thulium 15x9 lanthanide solid 168.93421 [2 8 18 31 8 2]
    70 Yb Ytterbium 16x9 lanthanide solid 173.04 [2 8 18 32 8 2]
	71 Lu Lutetium  17x9 lanthanide solid 174.967 [2 8 18 32 9 2]
	72 Hf Hafnium 4x6 transition-metal solid 178.49 [2 8 18 32 10 2]
	73 Ta Tantalum 5x6 transition-metal solid 180.9479 [2 8 18 32 11 2]
	74 W Tungsten 6x6 transition-metal solid 183.84 [2 8 18 32 12 2]
	75 Re Rhenium 7x6 transition-metal solid 186.207 [2 8 18 32 13 2]
	76 Os Osmium 8x6 transition-metal solid 190.23 [2 8 18 32 14 2]
	77 Ir Iridium 9x6 transition-metal solid 192.22 [2 8 18 32 15 2]
	78 Pt Platinum 10x6 transition-metal solid 195.08 [2 8 18 32 17 1]
	79 Au Gold 11x6 transition-metal solid 196.96654 [2 8 18 32 18 1]
	80 Hg Mercury 12x6 transition-metal liquid 200.59 [2 8 18 32 18 2]
	81 Tl Thallium 13x6 poor-metal solid 204.3833 [2 8 18 32 18 3]
	82 Pb Lead 14x6 poor-metal solid 207.2 [2 8 18 32 18 4]
	83 Bi Bismuth 15x6 poor-metal solid 208.98037 [2 8 18 32 18 5]
	84 Po Polonium 16x6 metalloid solid 208.9824 [2 8 18 32 18 6]
	85 At Astatine 17x6 halogen solid 209.9871 [2 8 18 32 18 7]
	86 Rn Radon 18x6 noble gas 222.0176 [2 8 18 32 18 8]
	87 Fr Francium 1x7 alkali-metal solid 223.0197 [2 8 18 32 18 8 1]
	88 Ra Radium 2x7 alkaline-earth-metal solid 226.0254 [2 8 18 32 18 8 2]
	89 Ac Actinium 3x10 actinide solid 227.0278 [2 8 18 32 18 9 2]
	90 Th Thorium 4x10 actinide solid 232.0381 [2 8 18 32 18 10 2]
	91 Pa Protactinium 5x10 actinide solid 231.03588 [2 8 18 32 20 9 2]
	92 U Uranium 6x10 actinide solid 238.0289 [2 8 18 32 21 9 2]
	93 Np Neptunium 7x10 actinide solid 237.048 [2 8 18 32 22 9 2]
	94 Pu Plutonium 8x10 actinide solid 244.0642 [2 8 18 32 24 8 2]
	95 Am Americium 9x10 actinide solid 243.0614 [2 8 18 32 25 8 2]
	96 Cm Curium 10x10 actinide solid 247.0703 [2 8 18 32 25 9 2]
	97 Bk Berkelium 11x10 actinide solid 247.0703 [2 8 18 32 26 9 2]
	98 Cf Californium 12x10 actinide solid 251.0796 [2 8 18 32 28 8 2]
	99 Es Einsteinium 13x10 actinide solid 252.083 [2 8 18 32 29 8 2]
	100 Fm Fermium 14x10 actinide solid 257.0951 [2 8 18 32 30 8 2]
	101 Md Mendelevium 15x10 actinide solid 258.1 [2 8 18 32 31 8 2]
	102 No Nobelium 16x10 actinide solid 259.1009 [2 8 18 32 32 8 2]
	103 Lr Lawrencium 17x10 actinide solid 262.11 [2 8 18 32 32 9 2]
	104 Rf Rutherfordium 4x7 transition-metal solid 261 [2 8 18 32 32 10 2]
	105 Db Dubnium 5x7 transition-metal solid 262 [2 8 18 32 32 11 2]
	106 Sg Seaborgium 6x7 transition-metal solid 266 [2 8 18 32 32 12 2]
	107 Bh Bohrium 7x7 transition-metal solid 264 [2 8 18 32 32 13 2]
	108 Hs Hassium 8x7 transition-metal solid 269 [2 8 18 32 32 14 2]
	109 Mt Meitnerium 9x7 transition-metal solid 268 [2 8 18 32 32 15 2]
	110 Ds Darmstadmium 10x7 transition-metal solid 269 [2 8 18 32 32 17 1]
	111 Rg Roentgenium 11x7 transition-metal solid 272 [2 8 18 32 32 18 1]
	112 Uub Ununbium 12x7 transition-metal liquid 277 [2 8 18 32 32 18 2]
	113 Uut Ununtrium 13x7 poor-metal solid n/a [2 8 18 32 32 18 3]
	114 Uuq Ununquadium 14x7 poor-metal solid 289  [2 8 18 32 32 18 4]
	115 Uup Ununpentium 15x7 poor-metal solid n/a [2 8 18 32 32 18 5]
	116 Uuh Ununhexium 16x7 poor-metal solid n/a [2 8 18 32 32 18 6]
	117 Uus Ununseptium 17x7 halogen solid n/a [2 8 18 32 32 18 7]
	118 Uuo Ununoctium 18x7 noble gas n/a [2 8 18 32 32 18 8]
]

; Define draw effect generator...assume going in a box 160 by 160
spins: func ["Generate draw effect circles from element orbits" orbits [block!] /local d o r x y] [
    d: copy []
	; background
	append d [draw [fill-pen ivory  pen black  circle 80x80 80]]
	; nucleus
	append d compose/deep [draw [fill-pen black  pen none circle 80x80 (add 2 length? orbits)  fill-pen none]]
	; orbital rings
	for i 1 7 1 [
	    append d compose/deep [draw [fill-pen none  pen black  circle 80x80 (add multiply i 10 10)]]
    ]
	; electrons
	o: 0
	foreach e orbits [
	    o: o + 1
	    loop e [
		    append d compose/deep [
			    draw [
				    fill-pen silver pen black
					(r: add add multiply o 10 random 5 2)
					(x: multiply either random true [1][-1] random r)
					(y: multiply either random true [1][-1] square-root subtract power r 2 power x 2)
      			    circle (as-pair  add 80 x  add 80 y) 3
			    ]
		    ]
		]
	]
	d
]

; Build up layout
; Start with the lines that pop out the lanthanide and actinide series
;   then put up a title and the clicked info area
;   then place the generated orbit image holder
pte: [
    backdrop effect [draw [pen black line 86x126 94x189 line 86x164 93x228]]
    at 100x0
	title "Periodic Table of the Elements" [
		inform/title center-face layout compose [
		    across
			image logo.gif
		    vh1 (to-string system/script/header/file)
 			text (to-string system/script/header/version)
			text (to-string system/script/header/date)
			text (to-string system/script/header/author)
			return
			area 484x110 para [wrap?: true] (remold [new-line/all/skip system/script/header/history true 4])
			return
			text "Chemical Series"
			return
			btn 115x22 nonmetal to-string 'nonmetal
			btn 115x22 noble to-string 'noble
			btn 115x22 alkali-metal to-string 'alkali-metal
			btn 115x22 alkaline-earth-metal to-string 'alkaline-earth-metal
			return
			btn 115x22 metalloid to-string 'metalloid
			btn 115x22 halogen to-string 'halogen
			btn 115x22 transition-metal to-string 'transition-metal
			btn 115x22 poor-metal to-string 'poor-metal
			return
			pad 123
			btn 115x22 lanthanide to-string 'lanthanide
			btn 115x22 actinide to-string 'actinide
			return
			text "State (zero degrees Celsius one atmosphere)"
            return
			btn 115x22 nonmetal "Gas" font [size: 10 color: gas]
			btn 115x22 halogen "Liquid" font [size: 10 color: liquid]
			btn 115x22 transition-metal "Solid" font [size: 10 color: solid]
			return
			bar 484
			return
			text "Help from http://en.wikipedia.org/wiki/Periodic_table, google, textbooks and gperiodic" 
			return
			pad 226
			btn "Ok"
		] "Help About...click anywhere to close"
	] 
	at 100x40
    clicked: info white 265x40 font [style: 'bold]	
	at 559x15
	img: box 161x161 effect []
        at 588x200
        logo: image logo.gif 

]

; build the buttons, positioned by group and period, pop out the lanthanide/actinide block by adding some pixels
; clicking a button fills in clicked area and the img effect block
foreach [el sym name pos series state weight orbits] elements [
    blurb: reform [el sym name series state newline  weight "[" orbits "]"]
	append pte reduce [
	    'at as-pair add either greater? pos/y 8 [7][0] multiply pos/x 29 multiply pos/y 21
    	'btn 29x22 to-string sym series 'font compose [color: (state)] compose/deep [set-face clicked (blurb)  img/effect: [(spins orbits)]  show img]
	]
]
append pte [at 29x199 btn "Quit" [quit]]

; and view it
view layout pte	