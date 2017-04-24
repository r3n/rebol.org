#! /usr/bin/rebol274 -qs
REBOL [
    File: %ipaddress.r
    Date: 8-Dec-2006
    Title: "IP Addresses"
    Version: 1.0
    Author: "François Jouen"
    Rights: {Copyright © EPHE 2006}
    Purpose: {How to know local and wan addresses with Rebol}
    library: [
        level: 'intermediate
        platform: 'all
        type: 'tool
        domain: [shell tcp]
        tested-under: all plateforms
        support: none
        license: 'BSD
        see-also: none
    ]
]


; some variables
Local_host_address: system/network/host-address
local_host_name: system/network/host
wan_host_address: ""
wan_host_name: ""

;this list can be modified
flist: ["www.mywanip.com" "checkip.dyndns.org" "www.whatismyip.com" "www.adresseip.com"]


; ---------------
; Quit Application
;-------------------

Quit-Requested: does [
	if (confirm/with "Really Quit ?" ["Yes" "No"]) [
		quit]
]


Process_Html: func [afile][
if error? try [page: read to-file afile
	    				tags: copy [] ; list of tags included in the page
	    				ttext: copy []; text between tags
	    				; 2 alternate parsing rules separated by |
	    				html: [
	    						   copy tag ["<" thru ">" ](append tags tag)  |
	    						   copy str to "<" (append ttext str)
    					]
    					;process page
	    				parse page [to "<" some html]
	    				
	    				;now find the ip address in the parsed text		   
	    				digit-charset: charset [ #"0" - #"9" ]
						digit: [ some digit-charset ]
						ip-charset: [ digit #"." digit #"." digit #"." digit ]
						ip: [ some ip-charset ] ; that could be [1 3 ip-charset]
						ip-rule: [ copy token ip ( append ipliste to-tuple token ) | skip ]
						ipliste: copy []
						parse/all to-string ttext [some ip-rule]
						
						;get the wan address and wan name
						wan_host_address: first ipliste ; some servers replicate twice the ip address
						wan_host_name: read to-url join "dns://" wan_host_address
	    				;update the data
						wip/text: to-string wan_host_address		   
	  					lip/text: to-string local_host_address
	  					lname/text: to-string local_host_name
	  					wname/text: to-string wan_host_name
	     				show [wip lip lname wname]]
	    [ Alert "Error"]
	
	
]


; get and parse  a web page 
Get_Url: does [
	if error? try [commande: join "http://" faddress/text 
				fl: flash join "Retreiving address from " commande
				write join what-dir "page.html" read to-url commande 
				page: join what-dir "page.html"
				process_html page
				unview/only fl] [unview/only fl Alert "Error in downloading"]
				
				
				
]


ServerWin: layout [
	across
	space 5x5
	at 5x5 
	faddress: rotary silver 190x24 data flist
	btn 100 "Get IP Adressses" [ Get_Url]
	btn 70 "Quit" [Quit-Requested]
	 
	at 5x40 txt 110 left "Local IP Address" lip: info 100  center lname: info 150
	at 5x75 txt  110 left "Wan IP Address" wip: info 100x48 center wname: info 150X48 wrap
	
	
]

view/new center-face ServerWin
insert-event-func [
		either all [event/type = 'close event/face = ServerWin][quit-requested][event]
]
do-events