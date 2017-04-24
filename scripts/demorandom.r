#! /usr/bin/rebview -qs
REBOL [
	File: %demorandom.r
    Date: 17-June-2009
    Title: "Random Number Generator Demo"
    Version: 1.0
    Author: "François Jouen."
    Rights: {Copyright © EPHE 2009}
    Purpose: {Some examples how to use randomr lib}
    library: [
        level: 'intermediate
        platform: 'all
        type: [demo ]
        domain: [math]
        tested-under: all plateforms
        support: none
        license: 'BSD
        see-also: none
	]
]
; load random library
do %randomr.r

; some variables
psample: 500
baseline: 250
xpas: 1
yscale: 40
col: yellow
xy1: 0x59
xy2: 500x59

plot: copy [pen col line]
plot2: copy [pen col line]

; for fun
app-styles: stylize [
	app_btn: button 60  edge [size: 1x1 color: 0.0.0 ] font [ style: none colors/1: black shadow: none]
]	

; update slider
fix_slider: does [
					either 0 = length? calc/data [calc/sld/redrag 1] 
								[calc/sld/redrag calc/lc / length? calc/data]
] 

Clear_Screen: does [

	
	
	x: 0 
	plot: copy [pen col line]  
	append clear visu/effect reduce ['draw plot] 
	plot2: copy [pen white line xy1 xy2 pen col line-width 2 line]
	append clear visu2/effect reduce ['draw plot2] 
	show [visu visu2]
]

; Data visualization
show_law: func [lawname] [
	Clear_Screen
	buffer: copy calc/data
	n: length? calc/data
	normalized: copy []
	; calculate mean
	sigma: 0 
	for i 1 n 1 [ v: pick buffer i sigma: sigma + v]
	m: round/to sigma / n .001
	; calculate variance and SD
	sigma: 0
	for i 1 n 1 [ v: pick buffer i sigma: sigma + power (v - m) 2]
	variance: round/to sigma  / (n - 1) .001
	sd: round/to square-root variance .001
	
	; show  data in normal reduced law (x - m /sd)
	for i 1 n 1 [x: x + xpas  v: ((pick buffer i) - m ) / sd y: baseline -  ( yscale * v) 
			append plot to-pair compose [(x) (y)] 
			append normalized v]
	str: join lawname  [ newline " mean: " m newline "variance: " variance newline " SD: " sd]
	visu/text: str
	buffer: copy sort normalized
	x: 0
	
	;now show random value distribution in second window

	visu2/text: "Sorted Normalized Data [(x-m)/sd]"
	for i 1 n 1 [
		x: x + xpas v: pick buffer i y: 59 -  ( 29 * v)
	append plot2 to-pair compose [(x) (y)]
	]
	show [visu visu2]
	
]




MainWin: layout/size [
	styles app-styles
	origin 5x5
	space 2x2
	across
	at  5x2 box  875x30 bevel 
	at 95x2 text "Parameters" text "Sample" fsample: field 50 to-string psample [
		if error? try [psample: to-integer fsample/text][psample: 320]]
		
		
	; //CONTINUOUS LAWS//
	at 5x35  app_btn 90 "Exponential" [ if error? try [clear calc/data 
						for i 1 psample 1 [append calc/data rand_exp] 
						fix_slider show calc show_law face/text]
						[Alert "Error in processing"]
	]

	at 5x60  app_btn 90 "Exp with L°" [ if error? try [clear calc/data 
						for i 1 psample 1 [append calc/data rand_expm to-decimal expmp/text] 
						fix_slider show calc show_law face/text]
						[Alert "Error in processing"]
	]
	expmp: field 35 "1.0" 

	at 5x85 app_btn 90 "Normal" [if error? try [clear calc/data 
						for i 1 psample 1 [append calc/data rand_norm to-decimal normp/text] 
						fix_slider show calc show_law face/text]
						[Alert "Error in processing"]
	]
	normp: field 35 "1.0" 
	at 5x110  app_btn 90 "Gamma" [if error? try [clear calc/data 
						for i 1 psample 1 [append calc/data rand_gamma to-integer gamp1/text to-decimal gamp2/text] 
						fix_slider show calc show_law face/text]
						[Alert "Error in processing"]
	] 
	gamp1: field 35 "1" gamp2: field 35 "1.0"

	at 5x135 app_btn 90 "Chi-2" [if error? try [clear calc/data 
						for i 1 psample 1 [append calc/data rand_chi2 to-integer chip/text] 
						fix_slider show calc show_law face/text]
						[Alert "Error in processing"]
	] 
	chip: field 35 "2" 

	at 5x160 app_btn 90 "Erlang" [ if error? try [clear calc/data 
						for i 1 psample 1 [  append calc/data rand_erlang to-integer erp/text] 
						fix_slider show calc show_law face/text]
						[Alert "Error in processing"]
	]
	erp: field 35 "1"

	at 5x185 app_btn 90 "Student" [ if error? try [clear calc/data
					 	for i 1 psample 1 [append calc/data rand_student to-integer stud/text to-decimal stud2/text]
					 	fix_slider show calc show_law face/text]
						[Alert "Error in processing"]
	]
	stud: field 35 "3" stud2: field 35 "1.0"

	at 5x210 app_btn 90 "Fischer" [ if error? try [clear calc/data
					 	for i 1 psample 1 [append calc/data rand_fischer to-integer fisc1/text to-integer fisc2/text ]
					 	fix_slider show calc show_law face/text]
						[Alert "Error in processing"]
	]
	fisc1: field 35 "1" fisc2: field 35 "1"

	at 5x235 app_btn 90 "Laplace" [ if error? try [ clear calc/data 
						for i 1 psample 1 [  append calc/data rand_laplace to-decimal lp/text] 
						fix_slider show calc show_law face/text ]
						[Alert "Error in processing"]
	]
	lp: field 35 "1.0"

	at 5x260 app_btn 90 "Beta" [ if error? try [clear calc/data 
						for i 1 psample 1 [  append calc/data rand_beta to-integer beta1/text to-integer beta2/text] 
						fix_slider show calc show_law face/text ]
						[Alert "Error in processing"]
	]
	beta1: field 35 "1" beta2: field 35 "1"

	at 5x285 app_btn 90 "Weibull" [ if error? try [clear calc/data 
						for i 1 psample 1 [  append calc/data rand_weibull to-decimal a/text to-decimal lambda/text] 
						fix_slider show calc show_law face/text ]
						[Alert "Error in processing"]
	]
	a: field 35 "1.0" lambda: field 35 "1.0"

	at 5x310 app_btn 90 "Rayleigh" [ if error? try [clear calc/data 
						for i 1 psample 1 [  append calc/data rand_rayleigh to-decimal ra/text to-decimal rb/text] 
						fix_slider show calc show_law face/text ]
						[Alert "Error in processing"]
	]
	ra: field 35 "1.0" rb: field 35 "1.0"
	
	; DISCRETE LAWS
	
	at 5x335  app_btn 90 "Bernouilli" [ if error? try [clear calc/data 
						for i 1 psample 1 [  append calc/data rand_bernouilli to-decimal bp/text] 
						fix_slider show calc show_law face/text ]
						[Alert "Error in processing"]
	]
	bp: field 35 "0.5" 

	at 5x360 app_btn 90 "Binomial" [ if error? try [clear calc/data 
						for i 1 psample 1 [  append calc/data rand_binomial to-integer ob/text to-decimal bpp/text] 
						fix_slider show calc show_law face/text ]
						[Alert "Error in processing"]
	]
	ob: field 35 "1" bpp: field 35 "0.5"

	at 5x385 app_btn 90 "NegBinomial" [ if error? try [clear calc/data 
						for i 1 psample 1 [  append calc/data rand_binomialneg to-integer onb/text to-decimal nbpp/text] 
						fix_slider show calc show_law face/text ]
						[Alert "Error in processing"]
	]
	onb: field 35 "1" nbpp: field 35 "0.5"

	at 5x410 app_btn 90 "Geometric" [ if error? try [clear calc/data 
						for i 1 psample 1 [  append calc/data rand_geo to-decimal geop/text] 
						fix_slider show calc show_law face/text ]
						[Alert "Error in processing"]
	]
geop: field 35 "0.25"

at 5x435 app_btn 90 "Poisson" [ if error? try [clear calc/data 
						for i 1 psample 1 [  append calc/data rand_poisson to-decimal pp/text] 
						fix_slider show calc show_law face/text ]
						[Alert "Error in processing"]
	]
	pp: field 35 "1.5" 

	; REBOL LAWS
	at 5x460 app_btn 90 "Rebol Rand" [ if error? try [clear calc/data 
					for i 1 psample 1 [  append calc/data random to-integer rpp/text] 
					fix_slider show calc show_law face/text ]
					[Alert "Error in processing"]
	]
	rpp: field 35 "10" 

	at 5x485 app_btn 90 "Rebol  Real" [ if error? try [clear calc/data 
					for i 1 psample 1 [  append calc/data rand_real] 
					fix_slider show calc show_law face/text ]
					[Alert "Error in processing"]
	]
	at 175x35 calc: text-list 200x475 
	pad 5   visu: box blue + 100  500x350 font [valign: 'top] frame navy
	at 382x390 visu2: box blue + 100  500x118 font [valign: 'top] frame navy

	at 370x2 text "X Step" fxpas: field 50 to-string xpas [if error? try 
						[xpas: to-integer fxpas/text] 
						[xpas: 1 fxpas/text: "1"]]
	pad 5 text "Y Scale" fyscale: field 50 to-string yscale [if error? try 
							[yscale: to-integer fyscale/text]
							[yscale: 40 fyscale/text: to-string yscale]]
	pad 200 app_btn 90 "Quit" [Quit]
]885x520

view center-face MainWin