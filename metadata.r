#!/usr/bin/rebol -cs

Rebol [
    File: %metadata.r
    Date: 08-Jun-2006
    Title: "Access to Spotlight Metadata"
    Version: 1.0.
    Author: ["François Jouen" "ldci"]
    Rights: {Copyright © EPHE 2006}
    Purpose: {giving access to OSX Metadata}
    library: [
        level: 'advanced
        platform: 'mac
        type: 'tool
        domain: []
        tested-under: OSX 10.4
        support: none
        license: 'BSD
        see-also: none
    ]
    
]


command: ""



Do_Search: does [
	clear resu/data
	clear detail/data
	show detail
	command: join "mdfind " [searchstr/text " > .result.tmp"] call/wait command
	resu/data: read/lines to-file  %.result.tmp 
	either (resu/lc = 0)[
	resu/sld/redrag 1][
	resu/sld/redrag resu/lc / 25]
	resu/sld/data: 0
	show resu
	resu/line-list: detail/line-list: none
]

Show_Detail: does [
	str:  pick resu/data pindex
	ff/text: str
	clear detail/data
	command: join "mdls '"  [str "'" " > .detail.tmp"]
	call/wait command
	detail/data: read/lines to-file  %.detail.tmp 
	detail/sld/redrag 0.5
	detail/sld/data: 0
	show [detail ff]
	detail/line-list: none
]


MainWin: layout [
	across
	origin 0x0
	space 2x2
	at 5x5 searchstr: field "Rebol" [ Do_Search]
	btn "Find" [ Do_Search]
	btn "Quit" [Quit-Requested]
	at 5x40 resu: text-list 600x200 [pindex: face/cnt Show_Detail ]
	at 5x250 ff: info 600
	at 5x280 detail: text-list 600x200 


]


Quit-Requested: does [
	if (confirm/with "Really quit this program ?" ["Yes" "No"]) [
	if exists? to-file %.result.tmp [delete to-file %.result.tmp]  
	if exists? to-file %.detail.tmp [delete to-file %.detail.tmp] 
	Quit]
]

center-face MainWin
view/new MainWin

insert-event-func [
		
		switch event/type [
			key          []       	
			time         []                 	
			resize       []
        	maximize 	 []
        	restore	 []
        	scroll-line []
        	scroll-n-page []
        	
		]
		either all [event/type = 'close event/face = MainWin][quit-requested] [event]
]




do-events
