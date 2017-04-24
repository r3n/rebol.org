REBOL [
	author: "François Jouen"
	title: "Visual Illusions Series:  Kanizsa's Figures"
	date: 15-Jun-2005
	File: %kanizsa.r
    Purpose: {
        show some visual illusions with rebol (view 1.3)
    }
    library: [
        level: 'intermediate
        platform: 'win
        type: [tool demo] 
        domain: [gui]   
        tested-under: "win "
        support: none 
        license: 'pd ]
]

xr: yr: 60
c1: 190x130
c2: 390x130
c3: 190x330
c4: 390x330

t1: 290x130
t2: 190x330
t3: 390x330

sq: false
n: 2
bcolor: 255.187.0
fcolor: white


cplot: copy [	pen fcolor  
				line-width n	
				circle c1 xr yr 
				circle c2 xr yr
				circle c3 xr yr
				circle c4 xr yr 
				pen none none
			 	fill-pen bcolor
			 	polygon c1 c2 c4 c3
]
				
tplot: copy [pen fcolor
			 line-width n
			 circle t1 xr yr
			 circle t2 xr yr
			 circle t3 xr yr
			 pen none none
			 fill-pen bcolor
			 triangle t1 t2 t3 bcolor bcolor bcolor 0.0]
			 

Show_Square: does [append clear cplot  
						[pen fcolor  
						line-width n
						circle c1 xr yr  
						circle c2 xr yr
						circle c3 xr yr
						circle c4 xr yr 
						pen none none
			 			fill-pen bcolor
			 			polygon c1 c2 c4 c3]
]

Show_Triangle: does [append clear tplot  
			[pen fcolor
			 line-width n
			 circle t1 xr yr
			 circle t2 xr yr
			 circle t3 xr yr
			 pen none none
			 fill-pen bcolor
			 triangle t1 t2 t3 bcolor bcolor bcolor 0.0]
]
			 	
			
Win: layout/size [
	origin 0x0
	across
	bck: backdrop bcolor
	at 30x5 btn 100 "Square" [sq: true sl/data: 0 n: 1 append clear bx/effect reduce['draw cplot] show [sl bx] ]
			btn 100 "Triangle" [sq: false  sl/data: 0 n: 1 append clear bx/effect reduce['draw tplot]  show [sl bx]]
			btn 100 "Back Color" [tcolor: request-color/color bcolor if not none? tcolor [bcolor: tcolor bck/color: bcolor] show win]
			btn 100 "Object Color" [tcolor: request-color/color fcolor if not none? tcolor [fcolor: tcolor] show bx]
			pad 50
			btn 100 "Quit" [Quit]
	at 30x30 bx: box 580x450  bottom edge [size: 1x1] 
	at 30x490 sl: slider 580x20  [n: 1 +  (sl/data * yr)
								 either sq [Show_Square n] [Show_Triangle n] show bx]
	at 30x515 info center  580 "Select a figure and play with the slider. Enjoy!" 
] 640x550

view center-face Win
