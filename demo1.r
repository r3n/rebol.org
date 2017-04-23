REBOL [
    Title: "Threads Demo"
    Date: 1-Dec-2004
    Version: 0.0.1
    Author: "François Jouen"
    File: %demo1.r
    Purpose: {
        show native multithreading with view 1.3
    }
    library: [
        level: 'intermediate
        platform: 'all
        type: [tool demo] 
        domain: [gui]   
        tested-under: 'win 
        support: none 
        license: 'pd 
        see-also: none
    ]
    
]


; to create an image
pic: make image! 640x480

;to plot warning new view 1.3 functions

plot: func [image x y color][
        pixel: to-pair compose [(x) (y)]
        poke image pixel color
]



mwin: layout [
	across
	at 5x5 visu: image pic
	with [	rate: none
			feel/engage: func [face action event][
            	switch action [time [face/Show_Image face]]
            ]
    ; first thread
    Show_Image: func [face]
	[ x: x + 1 if x > 640 [x: 0 visu/image/rgb: black] 
	y: random maxi  plot pic x y white 
	show face ]							
	]
	at 5x500 timer: info 150 
	with [
		rate: none
		feel/engage: func [face action event][
            	switch action [
                time [face/Show_Time face]
            	]
        ]
        ;second thread
  		Show_Time: func [face]
        	[
			face/text: join "Il est " now/time/precise
			show face
			]      	
	]

; to show asynchronous event process 
sl: slider 200x24 [maxi: to-integer sl/data * 450 slt/text: maxi show slt ]
slt: info 50 "450"	
	
	at 500x500 
	btn "Start" [maxi: 450 x: 0 visu/rate: 100 timer/rate: 100 show [visu timer]] ; start main thread
	btn "Stop" [visu/rate: timer/rate: none show [visu timer]]; stop main thread
	btn" Exit" [quit]
	do [sl/data: 1 show sl]
]
view center-face mwin
