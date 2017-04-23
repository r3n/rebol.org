   rebol [
    Title:      "Progress Bar With Read-thru"
    Date:       17-May-2006
    Name:     'progress-bar-with-read-thru
    Version:  0.1.0
    File:         %progress-bar-with-read-thru.r
    Author:   "R.v.d.Zee"
    Owner:    "R.v.d.Zee"
    Rights:    {Copyright (C) R.v.d.Zee 2006}
    Tabs:      4
Purpose: {
    "Progress Bar With Read-thru" was written to provide  a simple  progress bar script to the REBOL library.  When using REBOL's internal read-thru function, only 5 lines are required to update a progress bar - see note 2. "Read-thru"  is used to download a file to the disk cache - and to provide the data to move the progress bar.  
    
    The method used to retrieve the downloaded file from the disk cache is also illustrated. 
    }
    
     Notes: {
     
     1.  Missing Faces.  Without "face/para/scroll: 0x0", the button faces scroll out of sight when the slider dragger was moved. (may not always be needed)
     
     2.  Monitor Download.  These 5 lines show how to update the progress bar.
     
     3.  Recover Download.  How to retrieve the downloaded file from the disk cache.
     
     4.  Refrence/Credit 
             http://www.Codeconscious.com
	     - recovery of the downloaded file from the disk cache
	     
	      Jipe, CoDeuR.OrG   "Progress-bar qui fait pro"  
	      - updating the progress bar 
    }
    library: [
        level: 'beginner
        platform: 'all
        type: [tutorial how-to reference]
        domain: [user-interface]
        tested-under: 'linux
        support: none
        license: none
        see-also: none
    ]
]

fiveLines: {
    stop: false
    read-thru/progress/update theUrl func [total bytes][
        download-monitor/data: (bytes / total)
        show download-monitor
        not stop
    ]
}

theUrl: http://antwrp.gsfc.nasa.gov/apod/image/0605/iss2_sts114.jpg

progressBars: layout [
    size 540x430
    backcolor maroon
    across
    space 0
    seeImage: image 480x310 top left font-size 14 font-color gold
    seeImage-slider: slider 16x310 maroon olive [
        scroll-para seeImage seeImage-slider
	;------------------------------------------------------------------------------
	foreach face progressBars/pane [
            if face/style = 'buttons [face/para/scroll: 0x0]        ; Note 1
        ]
	;------------------------------------------------------------------------------
    ]
    return
    below
    credit: h3 300 silver
    space 3
    downLoad-monitor: progress maroon olive
    across
    space 0
    style buttons  button 67 maroon
    buttons "Download" [   
        either connected? [                                               
            hide  seeImage-slider
            home: what-dir                                                            
	    ;------------------------------------------------------------------------- 
            stop: false
            read-thru/progress/update theUrl func [total bytes][
                download-monitor/data: (bytes / total )             ; Note 2
                show download-monitor
                not stop
            ]
	    ;--------------------------------------------------------------------------
            change-dir home                                                      ; Note 3
            if not exists? %space-station.jpg [write/binary %space-station.jpg read-thru theUrl]
	    seeImage/image: load read-thru theUrl
	    ;--------------------------------------------------------------------------
            clear seeImage/text
	    seeImage/line-list: none
            show seeImage
	    downLoad-monitor/pane/size/x: 1
	    show downLoad-monitor
            credit/text: "International Space Station (NASA)"
            show credit
        ] [
            alert "No Internet!"
        ]  
    ]
    across
    space 0
    buttons "Script" [
        seeimage-slider/data: 0                   ;bring dragger to top of track
	show seeImage-slider
	seeImage/image: none
        clear seeImage/text
	seeImage/line-list: none
        seeImage/text: read %progress-bar-with-read-thru.r
	show seeImage
    ]
    space 200
    buttons "Copy" [
        hide seeImage-slider
        clear seeImage/text
        seeImage/line-list: none
        seeImage/image: none
        seeImage/text: copy fiveLines  
	show seeImage
	write clipboard:// seeImage/text
	]
 	
    image 140x25 logo.gif effect [colorize maroon]
    
]

seeImage-slider/show?: false

                                           view  progressBars

    