#! /usr/bin/rebol274 -qs
REBOL [
    File: %netscan.r
    Date: 17-Dec-2006
    Title: "NetScan"
    Version: 1.0
    Author: "François Jouen"
    Rights: {Copyright © EPHE 2006}
    Purpose: {How to scan a computer network with Rebol}
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


Quit-Requested: does [
	if (confirm/with "Really Quit ?" ["Yes" "No"]) [quit]
]

;some variables
Local_host_address: system/network/host-address
local_host_name: system/network/host
broacast_address: Local_host_address + 0.0.0.255
buffer: copy ""

;which version of os

Get_Os: does [
	switch system/version/4 [
		3 [os: "Windows" countos: "n"]
		2 [os: "MacOSX" countos: "c"]
		4 [os: "Linux" countos: "c"]
		5 [os: "BeOS" countos: "c"]
		7 [os: "NetBSD" countos: "c"]
		9 [os: "OpenBSD" countos: "c"]
		10 [os: "SunSolaris" countos: "c"]
	]
]

;explore the network

Scan_Net: does [
	if error? try [
	stime: now/time
	status/text: "Scanning Network ...." show status
	netw/text: ""
	netw/line-list: none
	show netw
	; first a ping test to the network broadcast address in order to refresh arp table data
	commande: join "ping " ["-" countos " " 1 " " broacast_address]
	if os = "MacOSX" [wait 0.01]
	; call external call
	call/output commande buffer
	if os = "MacOSX" [wait 0.01]
	; now we can use arp protocol to know the active computers
	commande: "arp -a" 
	call/output commande %arp.txt
	netw/text: read/string %arp.txt
	etime: now/time
	diff: etime - stime 
	status/text: join "Process completed in " diff]
	[status/text: "Error in Network scanning"]
	show [netw status]
]

Get_OS
ServerWin: layout [
	across
	space 5x5
	at 8x5 
	osinfo: info os 100 center info 100 to-string Local_host_address
	btn 100 "Scan Network" [Scan_Net]
	btn 70 "Quit" [Quit-Requested] 
	space 0x0
	at 5x50 netw: area 380x150 white white
	sl: slider 16x150 [scroll-para netw sl]
	at 5x205 status: info 395 ""
]


deflag-face netw tabbed
view/new center-face ServerWin


insert-event-func [
		either all [event/type = 'close event/face = ServerWin][quit-requested][event]
]

do-events
