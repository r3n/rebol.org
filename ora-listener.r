REBOL[
    Title: "Analyze of Oracle listener logs"
    Date:  10-Jun-2004
    Version:  1.1.0
    File: %ora-listener.r
    Author: "Philippe Le Goff (with help of Ladislav Mecir)"
    Purpose: "Oracle SGBD rebtool to analyze listener log"
    Email: lp.legoff@free.fr
    note: {- v. 1.0.0 : This script analyze Oracle listener log, 
            and returns two files : user access stats, and  listener-start stats;
            works with 9.x Ora SGBD 
            - v. 1.1.0 : with a GUI for selecting log file }
    library: [
        level: 'beginner 
        platform: all 
        type: 'tool 
        domain: [database] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]

]


;/////////////////// RULES Defs //////////////////////
digit: charset [#"0" - #"9"]
alpha: charset [#"a" - #"z" #"A" - #"Z"]
; date rule
date: [2 digit "-" 3 alpha "-" 4 digit]
; time rule
time: [2 digit ":" 2 digit ":" 2 digit]
;sid rule
sid: [thru "SID=" copy text to #")" ]
;program rule
program: [thru "PROGRAM=" copy text to #")" ]
; host rule
host: [thru "HOST=" copy text to #")" ]
; user rule
user: [thru "USER=" copy text to #")" ]
;port rule
port: [thru "PORT=" copy text to #")" ]
; date rule
date-TNS: [some date]
; time rule
time-TNS: [some time]

;/////////////////// HANDLERS Defs //////////////////////
; CID Handler definition  => user access
CID-handler: [
    copy dat date (append result-CID dat)
    copy tm time (append result-CID tm)
    sid (append result-CID text)
    program (append result-CID text)
    host (append result-CID text)
    user (append result-CID text)
    host (append result-CID text)
    port (append result-CID text)
]

; TNS (listener) Handler definition => listener on/off
TNS-start-handler: [
	;start-TNS (	append result-TNS rejoin [ entab text tab "start" ])
	thru "Production on "
	copy daty date-TNS (append result-TNS daty)
    copy tmy time-TNS (
    		append result-TNS tmy 
	append result-TNS "start")
]
TNS-stop-handler: [
    copy dat-tns date-TNS  (append result-TNS dat-tns)
    copy tm-tns time-TNS (
    		append result-TNS tm-tns 
    		append result-TNS "stop"
    	)

]

;/////////////////// LAYOUT Defs //////////////////////
; Layout definition  => GUI 

ssh: system/script/header
my-ora-log: none
log-analyse-file: none
select-btn: false
; ///////////

; trame image de fond
img-fond: load 64#{
R0lGODlhgACAAOYAAAAAAAEBAQICAgMDAwQEBAUFBQYGBgcHBwgICAkJCQoKCgsL
CwwMDA0NDQ4ODg8PDxAQEBERERISEhMTExQUFBUVFRYWFhcXFxgYGBkZGRoaGhsb
GxwcHB0dHR4eHh8fHyAgICEhISIiIiMjIyQkJCUlJSYmJicnJygoKCkpKSoqKisr
KywsLC0tLS4uLi8vLzAwMDExMTIyMjMzMzQ0NDU1NTY2Njc3Nzg4ODk5OTo6Ojs7
Ozw8PD09PT4+Pj8/P0BAQEFBQUJCQkNDQ0REREVFRUZGRkdHR0hISElJSUpKSktL
S0xMTE1NTU5OTk9PT1BQUFFRUVJSUlNTU1RUVFVVVVZWVldXV1hYWFlZWVpaWltb
W1xcXF1dXV5eXl9fX2BgYGFhYWJiYmNjY2RkZGVlZWZmZmdnZ2hoaGlpaWpqamtr
a2xsbG1tbW5ubm9vb3BwcHFxcXJycnNzc3R0dHV1dXZ2dnd3d3h4eHl5eXp6ent7
e3x8fH19fX5+fn9/fyH5BAAAAAAALAAAAACAAIAAQAf/gFVYVlZOUVdWV1pSTlRS
TYJWVFBWg1NTjVdVVIdRT1FZWFRPT1RYV1KDo1RWTVCnV1FQVVJRg1BUWlVRUbVT
VrpOVVdUVVOzUoSTUY7EvcmbpVKpUFKbWKFWU6Ss2lJTVIhU4ZPAU01UU0y2u6WD
37PavViMkcdPUohTltVYTlBaCEGhVOvULFEDp0SZQoxKIyybel2BuAmXFWi4ZmXh
NM2Wo2MTEfFywpCeFEfKqkiCsm+crEoQB5q6WCvcEyZVsixkOEohq3EQF0Ihtu8K
qnAFrcSbVAoXFoa8BnmakkWSsYPWlDqismVXR0myqGykZa2JLZNXfm0iRJaey0RW
/7JgGvfE2Dcsnqos+sbKWhSwRqH8ZUWrkpW/qIYqrTSJpLUrrw5L+lZFZd8nhJhp
vRRQIUilUQSBq+wwFb1f49ZaaReLFWJgqzZZI2s6tOCc4yhNMopPE0QnlaQ8wSIq
XBQmYjllenvF0KCLhKtAwfxR67QtG3v9reJ8I1tOiUxqUSiJ7blpKhFf2cIonHTE
05xN+XblSaMsxv5qlVTMSSrhhGSFiTLHTGYVI8mIcpJK7100Gi7jhLLLS9oQUl5l
x6RjEhaCrcaWFLg8Zg1xF2nGS4HgeEMWKofws09l07CSYXnVjSLJfAQxpBKIUwiC
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
EmloEoSaSDX4pDU9QRy/UkiRcIcXkR5Guz18uFkBw5vTsN8ckcOxyBuBgoix+zvt
1eqMUBKzBRrV8xNpSJ+XmP+J60SQQzEedlQ7oMhqDkWpEZUvFBUc6Ma4KKjeb9Sv
W7mVX0cM4JOI2AA1lOqIv4WOzjFrlChbAeV3mcgRNWULcfIdiCEe4CGKVrPpiuAl
SeVIDoOCzdEItwGLqb60LEOWrENKBzw+6xXsaOMcGb5CBESjIVJNh1NTWoSMpcvu
7CHoIIno0LgIy1FLB44zDEEKB0M6WSiLgUIIkBDOjAFJRZ9VMIISaHQWwU4RpNCq
1jEFXNDyclRGycjuiyBe9six6VFMkCMMLDILc/Uj9HFU1LIoZMJPNOKN9Dao5zCO
k7EWaIa2+OJSBCWMl4AdE7KJm0O2lYZBHfLrcxFAMHH/PsaxNtoiOH54vUgVFnix
jUDXjfTiRQEkjgs59+mhT1sBJT6zz1pRDO0Yt5IBQRgCIRsy+OaBM3jjI/jsGgUF
3+rFLKvz+hRBHhkNXL3BQ8GuDcCR+c0ggZ9gUikiiA4CM+MwLX1/Mh7CIFdxKVWM
ViA5Ka2fcevIwS6pIirpathDEVrDPQ/ilugGVb9/W97g/U60gRLIEruQ/KJiOl8V
CVmBnwL2fRQTZia0W84zNZZYE30GCFZSU4JSV1NQVlhWVFBTWFVVU1RTUYmCVFVR
UYxUVlWDjE9XjFNPVlOGVYJPUlWLVFKZiFZWUJlUUZ6opJZQVVmNkbuUnJ5SUVhS
/1KftY1TVbfKVIvQochVT5OfUY/LqLektqqMg8y1soK/VZ6xhFSnklKJU4SrUtqv
wbfsp7arlR4JuoJl068sloY5q8QIlBRlzCIx4vfklawroFAdixLtYjRqqVA9oSIO
yrlyDDUxEvmOXb2JpeYJenSv1Stl/KY4+ZRIk64sgl75soJwXaZOzGY9DMkOHKWK
BanlwiSIo8ldI7MwlOKEZC2TtTAO4qSpFzxVLqGppCRTFpZYUWwCNbkK3qedtrpp
sRLlIbJTWjaxOyoryhUqsR7GKnWoIj6LUpld47RpF0etHPF55XtULMNci/iRjbnK
mLkrrpRtcuJKSzZXkvxdgv/yk1WhUVlod0IX6zDbt/ZI0uIK+S2zlwwrf62ipVIs
bVjEHo20zNiT6CM/QUM1qLTLZVigZaneyorrkfeghObZbZGUJojxKQJLiVvvtMY/
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
}



;////////////
aPropos: func [/local lay] [
	lay: copy [
		across origin 0x0 space 0x0
		backtile img-fond
		style vtext text white bold right middle font-size 12 font-name "Courrier"  with [
			feel: none
			append init [font: make font []]
		]
		style text text 200 white font-size 11 font-name "Courrier" font-color white  with [
			append init [font: make font [colors: [0.0.0 255.255.255]]]
		]
		image logo.gif box 200x24 
		effect [merge gradmul 1x0 0.0.0 128.128.128] return
		pad 10x10 guide
	]
	foreach [name value] third ssh [
		if not none? value [
			append lay reduce [
				'vtext mold :name 'tab 'text form value
			]
			switch/default type?/word value [
				string! [append lay mold [with [feel: none]]]
				email! [append/only lay compose/deep [
						alive?: true error? try [emailer/to (value)]
					]]
				url! [append/only lay compose/deep [
						error? try [browse (value)]
					]]
				file! [append/only lay compose/deep [
						error? try [editor (value)]
					]]
			] [append lay [with [feel: none]]]
			append lay 'return
		]
	]
	append lay [
		pad -10x10
		box 200x24 effect [merge gradmul 1x0 128.128.128 0.0.0]
		button "Close" black [unview/only lay] edge [size: none]
	]
	view/new/title center-face lay: layout lay join ssh/title ssh/version
]

; /////// main layout ///////
main: layout/tight [
	style bout btn  gray  center middle 85x20 font-size 11 font-name "Courrier" font-color white 
	style tx-inf text ivory font-size 10 font-name "Courrier" middle center 

	space 2 
	tabs [30 100]
	backtile img-fond
	text "   " 0x5
	return
	across
	at 0x15
	tab
	bout "Select File" [my-ora-log: request-file 
				f1/text: my-ora-log
				select-btn: true
				show f1
				]
	build-stats: bout "Build Stats" [ either all [ select-btn   not none? f1/text  not equal? "none" to-string f1/text ] [ 

			info-from-log: split-path clean-path  to-file my-ora-log
			path-to-log: info-from-log/1
			name-of-log: info-from-log/2
			build to-file my-ora-log 
			][
			inform layout [
				backtile img-fond
				text " Please, select a log file before !" white font-name "Courrier" font-size 12
				at 80x50
				btn-cancel 60x20 "Cancel" escape [none hide-popup]
				]   ; fin layout
			]  ; fin either 
	] ; fin action bout

	bout "View Stats" [ either  log-analyse-file [ editor to-file log-analyse-file ][
			inform layout [
			backtile img-fond
			text " Please, select a log file and build stats before !" white font-name "Courrier" font-size 12
			at 80x50
			btn-cancel 60x20 "Cancel" escape [none hide-popup]
			]   ; fin layout
		]  ; fin either 
	] ; fin action bout

	
	bout "Info" 40x20 167.17.17 [apropos]
	bout "Quit" 40x20 124.154.220 [quit]

	at 0x40
	across
	tx-inf "File:" bold ivory right middle  
	tab
	f1: info 343x15 205.205.205 left middle font-name "Courrier" font-size 10 
	text "     "  15x20
	return
across
at 0x65
text " "
at 30x65
tx1: tx-inf "Reading " 50x20 ;underline
at 160x65
tx2: tx-inf "Parsing " ;underline
at 295x65
tx3: tx-inf "Writing " ;underline
return
across 
at 30x85
prog1: progress 70x7 coal yellow with [ edge: none color: white ]
prog2: progress 190x7  coal red with [ edge: none color: white ]
prog3: progress 80x7  coal green with [ edge: none color: white ]
return
at 30x100
text "     "  15x15


]
;///////////  End GUI defs ///////////////////


;/////////////////// MAIN //////////////////////

build: func [ my-file [file!] ][
	; read the log-file
	; if the file is very long, it can be replaced by a port access

	logs: read/lines to-file my-file
	logs-num-line: length? logs
	
	; analysed blocks
	result-CID: make block! 0
	result-TNS: make block! 0
	compteur: make integer! 0

	foreach record logs [
	; handlers need a different behaviour
		if all [ find record "CID" find record "SID" ] [ parse record CID-handler ]
		if any [find record " stop " find record "TNSLSNR" ] [ parse record TNS-stop-handler ]
		if all [find record "TNSLSNR" find record "Production"] [ parse record TNS-start-handler ]
		prog1/data: compteur  / logs-num-line 
		compteur: compteur + 1
		show prog1
	]
	tx1/font/color: yellow
	show tx1
	
	;/////////////////// WRITING LOGS //////////////////////
	; Now write results in CID-log file
	log-analyse-file: rejoin [ path-to-log "analyze-ora-log.txt" ]
	;print log-analyse-file
	info-log-header: rejoin ["DAY" tab "TIME" tab "USER" tab  "HOST" tab "ADDR. IP" tab "PORT" tab "SID" tab "PROGRAM" ]
	write/append/lines  to-file log-analyse-file info-log-header
	logs-res-CID: length? result-CID

	; LOGS : 20380
	; result-CID : 157000  --> 19625

	compteur: make integer! 0
	foreach [date-log heure-log sid-log prog-log host-log user-log ip-host-log port-log] result-CID [
			info-log: rejoin [date-log tab heure-log tab user-log tab  host-log tab ip-host-log tab port-log tab sid-log tab prog-log ]
			write/append/lines to-file log-analyse-file info-log
			prog2/data: ( 8 * compteur ) / logs-res-CID 
			; le chiffre 8 vient du fait que les 157000 lignes de result-CID
			; sont manipulées par blocs de 8 (date-log --> prog-log), soit 19625
			compteur: compteur + 1
			show prog2
	]
	
	
	tx2/font/color: red
	show tx2

	; Now write results in TNS-log file
	compteur: make integer! 0
	logs-res-TNS: length? result-TNS
	log-tns-file: rejoin [ path-to-log "analyze-tns-arret.txt" ]
	info-tns-header: rejoin ["DAY" tab "TIME" tab "STATE"]
	write/append/lines   to-file log-tns-file info-tns-header
	foreach [date-log-tns heure-log-tns state-log-tns ] result-TNS [
			info-tns: rejoin [date-log-tns tab heure-log-tns tab state-log-tns ]
			write/append/lines  to-file  log-tns-file info-tns
			prog3/data: ( 3 * compteur ) / logs-res-TNS
			; manipulation par blocs de 3 d'où le chiffre 3
			compteur: compteur + 1
			show prog3
	]
	tx3/font/color: green
	show tx3

] ; end of build function

view center-face main

;/////////////////// end MAIN //////////////////////
