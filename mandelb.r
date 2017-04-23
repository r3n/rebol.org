REBOL [
    File: %mandelb.r
    Date: 19-Jul-2009
    Title: "Mandelbrot"
    Purpose: "Mandelbrot"
    Author: "Lami Gabriele"
    Email: koteth@gmail.com
]

x-siz: 400 y-siz: 400           
im: to-image layout [ origin 0x0 box black to-pair x-siz y-siz]
bg-color: 200.200.210	

make-col: func[ flo ][
	ic:   to-integer ( 10 * cosine ( erre * 100 ) )  
	ip:  to-integer ( 10 * ( 1 - cosine  ( erre * 100 ) )  ) 
	0.200.0 * ic  + ip  * 0.0.200 +  120.0.0
]

clear-im: func [im [image!] color [tuple!]][  repeat j im/size/x * im/size/y [poke im j color] ]

set-pixel: func [ im [image!] x [integer!] y [integer!] color [tuple!] ] [
    poke im (im/size/y - y * im/size/x + x) color
]

itmax: 30 minXPos: 0.0 minYPos: 0.0 zoom: 100.0 rmax: 3 
norma: func[ xx yy ] [  square-root ((yy ** 2) + (xx ** 2)) ] 
rescale: func[ coo zoo offs ] [  ( coo / zoo ) + offs ] 
 
calc-pixel: func [xPixel yPixel] [ 
    xStart: rescale xPixel zoom ( - 3.0 + minXPos ) yStart: rescale yPixel zoom ( - 2.0 + minYPos )   
    xcic: xStart ycic: yStart count: 0 r: 0.0  
    while [ r <= rmax and ( count < itmax ) ][ 
        xtem: (xcic ** 2 ) - (ycic ** 2) + xStart ycic: (2.0 * xcic * ycic ) + yStart
        r: norma xcic ycic xcic: xtem count: count + 1
    ]
    if (r < rmax)[ return r ] return -1
]

view layout [  
	text "threshold" tresInp: field to-string rmax
	text "iterations" iterInp: field to-string itmax
	text "zoom" zoomInp: field to-string zoom	
	text "x position" icsInp: field to-string minXPos	
	text "y position" ipsInp: field to-string minYPos	
	pgBar: progress 200x15 coal blue 0.0
	
    button "Draw" [
		zoom: to-decimal zoomInp/data itmax: to-integer iterInp/data
		minXPos: to-decimal icsInp/data minYPos: to-decimal ipsInp/data
		rmax: to-integer tresInp/data clear-im im bg-color
		repeat x x-siz [
			repeat y y-siz [
				erre: calc-pixel x y inrange: ( not-equal? erre -1 ) 
				if inrange[ set-pixel im x y make-col erre ]
			] 
			if ( x // 10 ) == 0  [ show img ]
			pgBar/data: ( x / x-siz ) show pgBar
		]
	    show img
	]
	at 240X10 img: image im 
]                             