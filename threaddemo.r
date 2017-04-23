REBOL [
    Title: "Threads Demo"
    Date: 5-Jan-2005
    Version: 1.0
    Author: "François Jouen"
    File: %threaddemo.r
    Purpose: {
        show multithreading with rebol (all versions)
    }
    library: [
        level: 'intermediate
        platform: 'all
        type: [tool demo] 
        domain: [gui]   
        tested-under: 'win 'Mac Classic 'Linux 'BeOS
        support: none 
        license: 'pd 
    ]
    
]

; Call RThread Library

free-mem: func ['word] [set :word make none! recycle]

Scheduler: func [/local athread ThreadCount] [
	make object! [
	ThreadCount: make integer! 0
	; public properties
	ThreadList: copy []
	Delay: make integer! 0
	;object methods
	AppendThread: func [athread] [append ThreadList athread ThreadCount: ThreadCount + 1]
	RemoveThread: func [id] [remove  at ThreadList id ThreadCount: ThreadCount - 1]
	StartLoop: does [
		for i 1 ThreadCount 1 [
			athread: pick ThreadList i
			athread/TAwake
			if athread/TActivated [athread/TExecute]
			athread/TSleep 0]
		]
	StartMessageLoop: does [
		for i 1 ThreadCount 1 [
			athread: pick ThreadList i
			athread/TCount: athread/TCount + 1
			athread/TGetMessage
			if athread/TActivated [athread/TExecute]
			wait delay

		]
	]
	]
	
]

RTHread: func [ id priority /local Tcount TCall] [
	make object! [
		; define first properties
		TCount: make integer! -1
		TCall: make integer! 0
		TId: id ; Thread number
		TPriority: priority ; thread priority. values: 1 to N  (High to Low)
		TTerminated: make logic! false ; Done?
		TActivated: make logic! false ; Suspended ?
		TFreeOnTerminate: make logic! true ; free memory on terminate
		TMessageList: copy []
		; define now the methods
		TSleep: make function! [value]
		[wait value TActivated: false]
		TAwake: make function! [] 
			[ if not TTerminated [
				TCount: TCount + 1
				tt: remainder TCount TPriority
				if tt == 0 [TActivated: true TCall: TCall + 1]]
		]
		TSendMessage: make function! [athread message] 
		[ 
		      append clear athread/TMessageList message; the message stored in the thread message list
		]
		
		
		TGetMessage: make function! [] 
				[message: last TMessageList
				
				switch message [
					"Activate" [TActivated: true]
					"Suspend" [TActivated: false]
					"Terminate" [TActivated: false TTerminated: true]
				]
				 
		]
		
		TExecute: [] ;please overide this function! 
		TTerminate:  [] ;please overide this function!
	]
]

x: 0
col: white
plot: copy [pen col line]


;first thread routine
Show_Image: does [
	x: x + 1 
	if x > 640 [Clear_Screen ] 
	y: random 450 + 10
	append plot to-pair compose [(x) (y)]
	; suspend the first thread and call the second one
	if not none? t2 [ t1/TsendMessage t1 "Suspend" t1/TsendMessage t2 "Activate"]
	;show points according to the thread priority
	tt: remainder t1/TCount t1/TPriority
	if tt == 0 [show visu]
	
]	
	
Clear_Screen: does [
	x: 0 
	plot: copy [pen col line]  
	append clear visu/effect reduce ['draw plot] 
	show visu
]
;second thread
Show_Time: does [
			; suspend the second thread and call the first one
			if not none? t1 [t2/TsendMessage t2 "Suspend" t2/TsendMessage t1 "Activate"]
			tt: remainder t2/TCount t2/TPriority
			;show time according to the thread priority
			tt: remainder t1/TCount t1/TPriority
			if tt == 0 [  timer/text: now/time  show timer]
]     



; create threads 1 and 2
t1: RThread 1 1
t2: RThread 2 10
; overide TExecute method for each thread
t1/TExecute: :Show_Image
t2/TExecute: :Show_Time
;create Scheduler
sch: Scheduler
;register threads
sch/AppendThread t1
sch/AppendThread t2
; set scheduler delay
sch/Delay: 0
; create messages
t1/TSendMessage  T1 "Activate"
t1/TSendMessage  T2 "Suspend"


mwin: layout [
	across
	at 5x5 visu: box 640x480 blue frame black
	at 5x500 timer: info 150 
	; to show asynchronous event process: modify Thread1 priority
	sl: slider 200x24 [maxi: to-integer sl/data * 60 
						if maxi < 1 [maxi: 1 ] t1/TPriority: maxi slt/text: maxi show slt]
	slt: info 40 "1"	
	
	at 420x500 
	button 50 "Clear" [Clear_Screen]
	button 50 "Start" [maxi: 60 stop: false append visu/effect reduce ['draw plot] 
						until [sch/StartMessageLoop  stop]] ; start scheduler Message Loop processing
	button 50 "Stop" [stop: true]; stop threads
	button 50 "Exit" [ if t1/TFreeOnTerminate [free-mem T1 ]  if t2/TFreeOnTerminate [free-mem T2 ] 
						free-mem sch quit]
	
]
view center-face mwin
