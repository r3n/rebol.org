#! /usr/bin/rebol -qs
REBOL [
	File: %nettools.r
    Date: 12-July-2006
    Title: "Network Tools"
    Version: 1.1
    Author: "François Jouen"
    Rights: {Copyright © EPHE 2006}
    Purpose: {Collection of network tools}
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

; some useful information
host_address: system/network/host-address
host_name: system/network/host

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

Update-Panel: func [pnl] [
        pnl/pane/offset: 0x0
        show [pnl]
]

Set_TimeOut: func [newto] [
	oldto: system/schemes/default/timeout
	system/schemes/default/timeout: newto
]

Restore_TimeOut: does [
	system/schemes/default/timeout: oldto 
]

Get_OS

; main window

MainWin: layout [
	origin 0x0
	space 0x0
	at 5x15 osinfo: info os 100 center
	at 5x45 b1: btn 100 "Host" [p1/pane: HostView update-panel p1]
	at 5x70 b2: btn  100 "DNS" [p1/pane: NetView update-panel p1]
	at 5x95 b3: btn  100 "Netstat" [p1/pane: NetStatView update-panel p1]
	at 5x120 b4: btn 100 "Ping" [p1/pane: PingView update-panel p1]
	at 5x145 b5: btn 100 "Finger" [p1/pane: FingerView update-panel p1]
	at 5x170 b6: btn 100 "Whois" [p1/pane: WhoisView update-panel p1]
	at 5x195 b7: btn 100 "Port Scan" [p1/pane: ScanView update-panel p1]
	at 5x220 bq: btn 100 "Quit" [Quit]
	at 120x5 p1: box 520x250 silver frame white 
]




; useful routines to access network interfaces associated to the hostview layout 


Get_Interfaces: func [] [
	i: 0
	cnx: open tcp://
	data: get-modes cnx 'interfaces
	close cnx
	ni: length? data
	ni_info/text: join "Network Interfaces [" [ni"]"]  
	clear ni_choice/data
	for i 1 ni 1 [append ni_choice/data i]
	show [ ni_info ni_choice]
	return ni
]

Get_Informations: func [number][
	card: pick data number
	nic_name/text: card/name
	nic_adress/text: card/addr
	nic_subnet/text: card/netmask
	either found? find card/flags 'broadcast [nic_badress/text: card/broadcast] [nic_badress/text: "None"]
	either found? find card/flags 'multicast [nic_multi/text: "Yes" ] [nic_multi/text: "No"]
	either found? find card/flags 'point-to-point [nic_ppp/text: card/dest-addr ] [nic_ppp/text: "None"]
	show [nic_name nic_adress nic_subnet nic_badress nic_multi nic_ppp]
]

; information about this computer

HostView: layout [
	backcolor silver
	across
	origin 0x0
	at 5x5 info1: info 150 to-string host_address info2: info host_name 
	at 5x30 ni_info: lbl 225 left "Network Interfaces "  ni_choice: rotary 120 silver  "" 
							[nc: to-integer face/text if nc > 0 [Get_Informations nc]]
	at 5x60 lbl 225 "Name"   left nic_name: field 120
	at 5x90 lbl 225 "Address" left nic_adress: field 120  
	at 5x120 lbl 225 "Subnet" left nic_subnet: field 120
	at 5x150 lbl 225 "Broadcast" left nic_badress: field 120
	at 5x180 lbl 225 "Multicast" nic_multi: field 120
	at 5x210 lbl 225 "Point to point" nic_ppp: field 120 
]

; exploring the network via DNS

Explore_Net: does [
	if error? try [
	clear dresult/text
	dresult/line-list: none
	;save default timeout
	Set_TimeOut 1.0
	;get the network base address
	ipx: to-tuple dinfo1/text
	adr: ipx and 255.255.255.0
	start: now/time/precise
	append dresult/text  join "Starting exploration " newline 
	show dresult
	for i 1 255 1 [
		adr: adr + 0.0.0.1
		str: join "dns://" adr
		machine: read  to-url str
		pg/text: adr pg2/data: i / 255 
		; just for the mac osx version. the delay is not necessary for linux or windows oses
		if os = "MacOSX" [wait 0.01]
		; alive? 
		if not none? machine [append dresult/text join adr [": " machine newline ] ]
		show [pg pg2 dresult ]
	]
	end: now/time/precise
	append dresult/text join "Network scanned in " end - start
	show dresult
	;restore default timeout
	Restore_TimeOut]
	[Alert "Error! Please use a valid IP Address!"]
]


NetView: layout [
	backcolor silver
	across
	origin 0x0
	space 5x0
	at 5x5 lbl 100 left "IP Address" dinfo1: field 175 to-string host_address 
	drep1: info 175 right btn "Get" [drep1/text: "" str: "dns://" drep1/text: read to-url str show drep1]
	at 5x30 lbl 100 left "Domain Name" dinfo2: field 175 "www.rebol.net" 
	drep2: info 175 right btn "Get" [drep2/text: "" adr: dinfo2/text str: str: join "dns://" adr 
									drep2/text: read to-url str show drep2]
	space 0X0
	at 5x55 dresult: area 490x145 sl: slider 16x145 [scroll-para dresult sl]
	at 5x205  pg: info 150 pad 5 pg2: progress 225x25 pad 5 btn "Explore the Network" [Explore_Net]
]


; whois tools
WhoisView: layout [
	backcolor silver
	across
	origin 0x0
	space 5x0
	at 5x5 lbl 120 left "Domain Name" winfo1: field 355 "rebol.com" 
	at 5x30 lbl 120 left "Whois Server" 
	slist: Choice 250 silver "whois.internic.net" "whois.networksolutions.com" "whois.arin.net"
	 btn 100 "Whois" [
			clear wresult/text
			wresult/line-list: none
			show wresult
			str: join "whois://" [winfo1/text "@" slist/text]
		 	if error? try [rep: read to-url str append wresult/text rep] [append wresult/text "Error in connection "]
		 	show wresult
	
	]
	space 0x0
	at 5x65 wresult: area 490x170 wrap wsl: slider 16x170 [scroll-para wresult wsl]	
]	

;Finger Tools

FingerView: layout [
	backcolor silver
	across
	origin 0x0
	space 0x0
	at 5x5 lbl 50 left "User" finfo1: field 150 "fjouen" txt "@" finfo2: field 200 to-string host_address 
	pad 5 btn "Finger" [
			clear fresult/text
			fresult/line-list: none
			show fresult
			wait 0.01
			str: join "finger://" [finfo1/text "@" finfo2/text]
			if error? try [rep: read to-url str append fresult/text rep] [append fresult/text "Error in connection "]
		 	show fresult
	]
	at 5x40 fresult: area 490x170 wrap 	fsl: slider 16x170 [scroll-para fresult fsl]
]

; scan ports

ScanView: layout [
	backcolor silver
	across
	origin 0x0
	space 0x0
	at 5x5 lbl 150 left "Internet Address" sinfo1: field 215 center to-string host_address
	at 5x30 lbl 150 left "Starting Port" sinfo2: field center 70 "1" 
	lbl left "Ending Port" sinfo3: field center 70 "1024" ; for standard port use
	pad 5 btn "Scan" [
		clear sresult/text
		sresult/line-list: none
		append sresult/text join "Port Scanning host: " [sinfo1/text newline]
		show sresult
		Set_TimeOut 0.1
		sstart: to-integer sinfo2/text
		send: to-integer sinfo3/text
		count: (send - sstart) + 1
		for n 1 count 1 [
				spg1/text: join "Port " n
				spg2/data: n / count 
				if error? try [close open to-url join "tcp://" [sinfo1/text " :" n ]
						append sresult/text join "Open TCP Port: "[ n newline]]	
			[]
			show [spg1 spg2 sresult]
			if os = "MacOSX" [wait 0.01]
			]
			;restore default timeout
			Restore_TimeOut
			append sresult/text "Port Scanning is done"
			show sresult 
			]
	at 5x60 sresult: area 490x150 wrap 	ssl: slider 16x150 [scroll-para sresult ssl]
	at 5x215 spg1: info 150 pad 5 spg2: progress 350x25
	
]	

;ping tools

; makes ping to the host
ping: does [
	buffer: copy ""
	clear presult/text
	presult/line-list: none
	append presult/text join "Connecting host " [pinfo1/text newline]
	show presult
	commande: join "ping " ["-" countos " " pinfo2/text " " pinfo1/text]
	
	if os = "MacOSX" [wait 0.01]
	; call external call
	call/output commande buffer
	
	append presult/text buffer
	; for Unices OS
	n: to-integer length? buffer
	if n = 0 [append presult/text "Network Error"]
	show  presult
]


PingView: layout [
		backcolor silver
		across
		origin 0x0
		space 5x0
		at 5x5 lbl  left "Host" pinfo1: field 150 to-string host_address
		10x40 lbl "Counts" left pinfo2: field 50 "2" 
		btn "Ping" [ping]
		space 0X0
		at 5x40 presult: area 490x180 wrap psl: slider 16x180 [scroll-para presult psl]
]

; Netstat tools

NetStat: does [
	buffer: copy ""
	clear nsresult/text
	nsresult/line-list: none
	append nsresult/text  join "Be patient! Connecting host " newline
	show nsresult
	switch option [
		1 [commande: "netstat -a"]
		2 [commande: "netstat -r"]
		3 [commande: "netstat -s"]
	]
	
	if os = "MacOSX" [wait 0.01]
	; call external call
	call/output commande buffer
	append nsresult/text buffer
	
	show  nsresult
]

NetStatView: layout [
		backcolor silver
		across
		origin 0x0
		space 5x0
		at 5x5 lbl "Display " 
		nsrot: text-list 300x50  "All Information" "Routing Tables" "Protocol Statistics" [option: to-integer face/cnt]
		btn "Statistics" [NetStat]
		space 0x0
		at 5x60 nsresult: area 490x180  nssl: slider 16x180 [scroll-para nsresult nssl]
]

option: 1
deflag-face nsresult tabbed
p1/pane: hostview
update-panel p1
tmp: Get_Interfaces 
if tmp > 0 [Get_Informations 1]
view center-face MainWin

