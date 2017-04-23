REBOL [
	file: %pt.r
	date: 2006-07-06
	Purpose: {
		I am working in multiple porjects at the same time, so i wanted to have a tool, to track my time spent for each project.
		This simple tool makes this available.
	}
	title: "Project Time"
	author: "Varga Árpád"
	version: 1.0.0
	email: varga@cason.hu
	Library: [
		level: 'beginner
		platform: 'all
		type: 'tool
		domain: 'database
		tested-under: [view 1.3.2.3.1 on "Windows XP"]
		support: [author: "Arpad Varga" email: arpicheck@yahoo.com]
		license: 'gpl
	]
]

nulls: func [num][either num < 10 [join "0" num][num]]

cancel: false
today: copy []
projects: none
main-projects: none
times: none

load-data: does [
	if not exists? %projects.txt [write %projects.txt decompress #{789C530A28CACF4A4D2E5170545288560A2E4D02730C9514E06C23A5582E25982A272504DB194987522C003362163B49000000}]
	if not exists? %times.txt [write %times.txt ""]
	
	projects: load %projects.txt
	main-projects: copy []
	foreach proj projects [if string? proj [append main-projects proj]]
	times: load %times.txt
]
load-data

preformat: has [
	date block
	formatted
][
	load-data
	times: sort/skip/reverse times 2
	formatted: copy ""
	foreach [date block] times [
		append formatted join mold date newline
		append formatted rejoin ["^-" replace/all mold copy block newline "" newline]
	]
	write %times.txt formatted
]

doCalc: has [
	load-data
	today today-projects
	last-time last-project
	started project theme
	sum-time
	fullist
][
	if error? try [to-date calc-date/text] [
		alert {Field "Day" must contaion a valid date.}
		exit
	]
	today: any [select times to-date calc-date/text copy []]
	today-projects: unique extract/index today 3 2
	today-projects: tail today-projects
	while [not head? today-projects][
		today-projects: back today-projects
		insert next today-projects [0:0:0]
	]
	last-time: none
	last-project: none
	foreach [started project theme] today [
		if not none? do last-time [
			sum-time: find/tail today-projects last-project
			change find/tail today-projects last-project ((first sum-time) + (started - last-time))
		]
		last-time: started
		last-project: project
	]
	attempt [
		fullist: join [] rejoin [calc-date/text ", " to-string first today " - " last-time ]
		foreach [project sum-time] today-projects [if (greater? sum-time 0:0) [append fullist rejoin [project " ^-" sum-time]]]
		append/only fullist copy []
		append all-projects/data fullist
		show all-projects
	]
]

doCalcWeek: has [
	start old-string 
	thisday
][
	if error? try [to-date calc-date/text] [
		alert {Field "Day" must contaion a valid date.}
		exit
	]
	old-string: copy calc-date/text
	start: to-date calc-date/text
	start: start - start/weekday + 1
	for thisday start start + 6 1 [
		calc-date/text: rejoin [thisday/year "-" nulls thisday/month "-" nulls thisday/day]
		doCalc
	]
	calc-date/text: copy old-string
]

copy-all: has [ text row ][
	text: copy ""
	foreach row all-projects/data [append text join row newline]
	write clipboard:// text
]

subsel: has [ subs ][
	if not-equal? main-projects proj/list-data [
		proj/list-data: main-projects
		proj/reset
		show proj
	]
	subs: attempt [copy select projects proj/text]
	either all [not none? subs block? subs] [
		insert head subs copy "-"
		sub/text: first sub/list-data: copy subs
		sub/reset
		show sub
	][
		sub/text: first sub/list-data: copy ["-"]
		sub/reset
		show sub
	]
]

save-task: has [ today ][
	load-data
	today: select times to-date date/text
	if none? do today [
		append times reduce [to-date date/text copy []]
		today: select times to-date date/text
	]
	append today reduce [to-time time/text copy proj/text copy sub/text]
	save %times.txt times
]

ok-date-time?: does [
	if error? try [to-date date/text] [
		alert {Field "Day" must contaion a valid date.}
		return false
	]
	if error? try [1 + to-time time/text] [
		alert {Field "Time" must contaion a valid time.}
		return false
	]
	true
]

layCalc: layout [
	backdrop effect [gradient 1x1 180.190.224 210.210.210]
	across
	text "Day:" bold
	calc-date: field 80 rejoin [now/year "-" nulls now/month "-" nulls now/day]
	pad 5x0
	btn "Day" 220.248.220 [ clear all-projects/data doCalc ]
	btn "Week" 220.220.248 [ clear all-projects/data doCalcWeek ]
	btn "Copy" 248.248.220 [ copy-all ]
	btn "Close" 248.220.220 [ unview ]
	return
	box 316x2 black return
	return
	all-projects: text-list 316x200 today
]

layNewtask: layout [
	backdrop effect [gradient 1x1 180.190.224 210.210.210]
	do [cancel: true]
	proj: drop-down 300 with [show-arrow? false rows: 6] data main-projects [subsel]
	sub: drop-down 300 with [show-arrow? false rows: 4] "-"
	do [proj/text: proj/list-data/1]
	do [subsel]
	
	pad 220x30 
	btn "Start task" 80 220.248.220 [save-task unview]
	btn "Cancel" 80 248.220.220 font [space: 2x0] [unview]
]

view center-face layout [
	backdrop effect [gradient 1x1 200.220.244 220.220.220]
	across
	text "Day:" 53 bold
	date: field 100 rejoin [now/year "-" nulls now/month "-" nulls now/day]
	text "Time:" 53 bold
	time: field 100 to-string now/time
	return
	box 330x2 black return
	btn "New task now" 220.248.220 [ if ok-date-time? [load-data subsel view/new center-face layNewtask] ]
	btn "Calc day" 248.248.220 [ view/new center-face layCalc ]
	btn "Edit project list" 248.220.220 [editor %projects.txt]
	btn "Edit archives" 248.220.220 [preformat editor %times.txt]
]