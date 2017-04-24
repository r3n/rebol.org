REBOL [
	file: %smartudp.r
	date: 2004-08-22
	Purpose: {Send freely paramterized UDP packages, save and load your presets, choose targets from history.}
	title: "SmartUDP"
	author: "Varga Árpád"
	version: 1.0.0
	email: arpicheck@yahoo.com
	Library: [
		level: 'beginner
		platform: 'all
		type: 'tool
		domain: 'other-net
		tested-under: [view 1.3.2.3.1 on "Windows XP"]
		support: [author: "Arpad Varga" email: arpicheck@yahoo.com]
		license: 'gpl
	]
]

flat: func [ blk ][load replace/all replace/all mold blk "]" "" "[" ""]
add-param: has[ pname ][
	pname: request-text/title "Parameter name"
	if not any [none? pname empty? pname find extract flat paramlist 2 pname][
		append/only paramlist reduce [pname copy ""]
		params/data: paramlist
		params/size/2: max 10 + (19 * length? paramlist) 200
		controls/offset/2: params/offset/2 + params/size/2 + 8
		controls/parent-face/size/2: controls/offset/2 + controls/size/2 + 20
		show controls/parent-face
		show [params controls]
	]
]
add-value: func [ id /local ret param ][
	if not none? ret: request-text/title/default "Parameter value" copy pick pick paramlist id/1 id/2[
		either all [not-equal? to-string ret pick param: pick paramlist id/1 id/2 equal? id/2 1 find extract flat paramlist 2 to-string ret][
			alert "Parameter name not changed. Another parameter with the same name exists."
		][change at param id/2 to-string ret]
	]
	show params
]
move-me-up: func [ id /local c][
	if equal? id/1 1 [return]
	c: copy pick paramlist id/1
	remove at paramlist id/1
	insert/only at paramlist id/1 - 1 c
	show params
]
move-me-down: func [ id /local c][
	if equal? id/1 length? paramlist [return]
	c: copy pick paramlist id/1
	remove at paramlist id/1
	insert/only at paramlist id/1 + 1 c
	show params
]
remove-me: func [ id ][
	remove at paramlist id/1
	params/size/2: max 10 + (19 * length? paramlist) 200
	controls/offset/2: params/offset/2 + params/size/2 + 8
	controls/parent-face/size/2: controls/offset/2 + controls/size/2 + 20
	show controls/parent-face
	show [params controls]
]
load-preset: has [ file ][
	if not none? file: request-file/title/filter "Open" "Select preset to use" "*.udp" [
		paramlist: load to-file file
		cmd/text: copy last paramlist
		remove back tail paramlist
		presetname/text: first back back tail parse to-string file "/."
		show [params presetname cmd]
	]
]
save-preset: does [
	if empty? presetname/text [ alert "Please fill out the preset name field" focus presetname return]
	save to-file join presetname/text ".udp" join paramlist cmd/text
]
send-now: has [ package param hist act portnr ip][
	if error? try [ip: 0.0.0.0 + pick to-tuple tip/text 4][
		if error? try [ip: read join dns:// tip/text][
			alert "Bad IP address" focus tip return
		]
	]
	if any [error? try [portnr: to-integer tport/text] empty? tport/text lesser? portnr 0 greater? portnr 65535][alert "Bad port" focus tport return]
	if error? try [package: dehex to-string cmd/text][package: to-string cmd/text]
	foreach param paramlist [package: replace/all package rejoin ["{" param/1 "}"] param/2]
	insert p: open rejoin [udp:// ip ":" tport/text] package
	close p
	hist: any [attempt [load %history.txt] copy []]
	if none? find hist act: rejoin [tip/text ":" tport/text][save %history.txt append hist act ]
]
store-dbclick: func [face][reduce [face/text now/precise]]
is-dblclick: func [face variable][
	all [
		lesser? to-decimal difference now/precise variable/2 0.5 
		equal? face/text variable/1
	]
]
pick-from-history: has[hist last-choice][
	do-select: does [
		attempt [
			tip/text: first parse hist/picked/1 ":" 
			tport/text: second parse hist/picked/1 ":" 
			show [tip tport] 
			unview
		]
	]
	last-choice: store-dbclick make face []
	view/new center-face layout [
		backdrop effect [gradient 0x1 182.182.248 218.218.218]
		style btr btn 255.208.208
		style btg btn 208.255.208
		h2 "Target history"
		hist: text-list data any [attempt [load %history.txt] copy []] 200 [
			either is-dblclick face last-choice [do-select][last-choice: store-dbclick face]
		]
		btg "Use" 200 [do-select]
		across
		btr 96 "Truncate history" [
			if request/confirm "Would you like to keep only the last 20 entries in your history?" [
				hist: any [attempt [load %history.txt] copy []]
				if greater? length? hist 20 [clear at hist 21]
				save %history.txt hist
				unview
			]
		]
		btr 96 "Clear history" [
			if request/confirm "Would you like to clear all the entries in your history?" [
				save %history.txt copy []
				unview
			]
		]
	]
]
show-list: func [face count index][
	if none? v: pick paramlist count [
		face/color: snow 
		face/text: none 
		exit
	]
	face/color: either even? count [ivory - 50.50.50][ivory]
	txt: pick either lesser? index 3 [ v][copy [0 0 "remove" "up" "down"]] index
	face/text: either empty? txt ["-empty-"][txt]
	face/user-data: reduce [count index]
]
clear-values: has [param][
	foreach param paramlist [change at param 2 copy ""]
	show params
]
clear-params: does [
	clear paramlist
	show params
]
paramlist: copy []
lay: layout [
	backdrop effect [gradient 0x1 182.182.248 218.218.218]
	style t100 text 100
	style btr btn 255.208.208
	style btg btn 208.255.208
	style bty btn 255.255.208
	h2 "Smart UDP sender"
	bar 500
	
	across
	
	t100 "Target IP"
	tip: field 120
	text "Target port"
	tport: field 50
	btg "History" [pick-from-history]
	return
	bar 500 return

	t100 "Preset name"
	presetname: field "" 391
	return
	
	params: list gray 500x200 [
		space 1x2
		across 
		text 100 [attempt [add-value copy face/user-data]]
		text 270 [attempt [add-value copy face/user-data]]
		text 50 "remove" [attempt [remove-me face/user-data]]
		text 35 "up" [attempt [move-me-up face/user-data]]
		text 35 "down" [attempt [move-me-down face/user-data]]
		return
	] supply [show-list face count index]
	return
	
	controls: panel [
		across
		style t100 text 100
		origin 0x0
		btg "Add parameter" #"^A" [add-param]
		pad 54
		bty "Load preset" #"^L" [load-preset]
		bty "Save preset" #"^S" [save-preset]
		btr "Clear values" #"^V" [clear-values]
		btr "Clear parameters" #"^P" [clear-params]
		return
		bar 500
		return
		
		t100 "Package to send"
		cmd: field 390
		return
		btg "Send now" [send-now]
	]
]
focus tip
view center-face lay