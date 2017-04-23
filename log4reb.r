REBOL [
	File: %log4reb.r
	Date: 16-Feb-2006
	Title: "Logging Framework For Rebol"
	Purpose: {Logging within the context of program development constitutes inserting statements 
		into the program that provide some kind of output information that is useful to the developer. 
		Examples of logging are trace statements, dumping of structures and the familiar 'prin or 
		'print debug statements. log4reb offers a hierarchical way to insert logging statements within 
		a Rebol program. Multiple output formats and multiple levels of logging information are available.
		By using log4reb, the overhead of maintaining thousands of 'print statements is alleviated as 
		the logging may be controlled at runtime from configuration scripts. log4reb maintains the log 
		statements in the shipped code. By formalising the process of logging, some feel that one is 
		encouraged to use logging more and with higher degree of usefulness.}
	Library: [
		level: 'intermediate
		platform: 'all
		type: 'tool
		Domain: [debug testing]
		Tested-under: none
        Support: none
        License: 'gpl
        see-also: none
	]
	Version: 2.0.6
	
	Author: "Francois Vanzeveren"

	History: [
		0.0.1 [21-Nov-2003 "Created this file" "Francois"]
		0.0.2 [23-Nov-2003 {Modified implementation. The previous one 
				could not properly handle applications made of several 
				modules/scripts. I therefore change the way it works.} "Francois"]
		0.0.3 [27-Nov-2003 "Added /msg and /data refinements to specify the message and the data to log" "Francois"]
		0.0.4 [30-Nov-2003 {
			+ 'log function made global.
			+ Fixed and improved error logging
		} "Francois"]
		1.0.0 [1-Dec-2003 "First Public Release." "Francois"]
		1.1.0 [29-Dec-2003 {BUG FIX: an error occured when logging a block with words without meaning.
				Blocks are reduced using 'remold before being included in the error message. This triggered an error
				on blocks with words without meaning. On such blocks, 'mold is now applied rather than 'remold
		} "Francois"]
		2.0.0 [19-Sep-2004 {The framework has been enhanced and extended to
				handle appenders and layouts. New appenders and layouts can
				be easily added to the log4reb framework.
				Implemented appenders:
					+ console-appender
					+ file-appender
				Implemented layout:
					+ pattern-layout
		} "Francois"]
		2.0.1 [20-Sep-2004 {The level argument of the 'log function has been 
				replaced by refinements for clarity purpose. The available 
				refinements are /debug /info /warn /error /fatal} "Francois"
		]
		2.0.2 [3-Jul-2005 "Rebol header modified to comply with Rebol.org standards" "Francois"]
		2.0.3 [27-Jul-2005 {BUG Fix: local variable 'the-msg of 'log function holds a series and 
				the problem described at http://www.rebol.com/docs/core23/rebolcore-9.html#section-3.6 
				occured.} "Francois"]
		2.0.4 [28-Jul-2005 "Error formatting improved." "Francois"]
		2.0.5 [21-Aug-2005 {'init-log4reb can now be called mutiple times without 
							overriding existing loggers, appenders and layouts.} "Francois"]
		2.0.6 [16-Feb-2006 {New /override refinement to override existing loggers, appenders and layouts.} "Francois"]
	]
]

log4reb: context [
	comment {
		Possible levels:
			'off	The 'off has the highest possible rank and is intended to turn off logging.
			'fatal	The 'fatal level designates very severe error events that will presumably lead the application to abort.
			'error	The 'error level designates error events that might still allow the application to continue running.
			'warn	The 'warn level designates potentially harmful situations.
			'info	The 'info level designates informational messages that highlight the progress of the application at coarse-grained level.
			'debug	The 'debug Level designates fine-grained informational events that are most useful to debug an application.
			'all	The 'all has the lowest possible rank and is intended to turn on all logging.
	}
	_levels: make block! [off 6 fatal 5 error 4  warn 3 info 2 debug 1 all 0]
	_level-labels: make block! [fatal "FATAL" error "ERROR"  warn "WARN" info "INFO" debug "DEBUG"]
	
	_loggers: none
	_appenders: none
	_layouts: none
	
	; Skeleton of a logger
	logger!: make object! [
		name: threshold: appenders: level: none 
		
		log: func [usr-msg [string!] /local app] [
			forall appenders [
				app: select _appenders first appenders
				app/append usr-msg self
			]
			appenders: head appenders
		]
	]
	
	; ******************************* APPENDERS *******************************
	
	; Skeleton of an appender:	
	appender!: make object! [
		name: layout: logger: none
	]
	
	console-appender!: make appender! [
		append: func [usr-msg [string!] the-logger [object!]
			/local msg lay
		] [
			logger: the-logger
			lay: select _layouts layout
			msg: lay/format usr-msg self
			print msg
		]
	]
	
	file-appender!: make appender! [
		out: none
		
		append: func [usr-msg [string!] the-logger [object!] 
			/local msg lay path target
		] [
			logger: the-logger
			lay: select _layouts layout
			msg: lay/format usr-msg self
			do get in system/words 'append msg newline
			set [path target] split-path out
			if not exists? path [make-dir/deep path]
			attempt [write/append out msg]
		]
	]
	
	; ******************************** LAYOUTS ********************************
	
	;=====================================
	; Pattern Layout
	; ---------------
	; %c	logger name
	; %d\\dd MMM yyyy HH:MM:ss,SSS\\ Date
	; %m user-defined message
	; %p Level
	; %r Milliseconds since program start ; NOT YET IMPLEMENTED
	; %% individual percentage sign
	;=====================================
	pattern-layout!: make object! [
		name: none
		pattern: none
		
		format: func [usr-msg [string!] appender [object!] 
			/local 	msg begin ending date-format nnow begin2 ending2 tmp
		] [
			msg: copy pattern
			parse/all msg [
				any [
					begin: "%c" ending: (
						change/part begin appender/logger/name ending
					) :begin |
					begin: "%d\\" copy date-format to "\\"  (
						nnow: now/precise
						parse/all date-format [ any [
							begin2: "dd" ending2: (
								change/part begin2 nnow/day ending2
							) :begin2 |
							begin2: "MMM" ending2: (
								change/part begin2 nnow/month ending2
							) :begin2 |
							begin2: "yyyy" ending2: (
								change/part begin2 nnow/year ending2
							) :begin2 |
							begin2: "HH" ending2: (
								change/part begin2 nnow/time/hour ending2
							) :begin2 |
							begin2: "MM" ending2: (
								change/part begin2 nnow/time/minute ending2
							) :begin2 |
							begin2: "SSS" ending2: (
								tmp: nnow/time/second
								tmp: copy/part next find to-string
										subtract tmp to-integer tmp "." 6
								change/part begin2 tmp ending2
							) :begin2 |
							begin2: "ss" ending2: (
								change/part begin2 to-integer nnow/time/second ending2
							) :begin2 |
							skip
						]]
						
					) thru "\\" ending: (change/part begin date-format ending) :begin |
					begin: "%m" ending: (change/part begin usr-msg ending) :begin |
					begin: "%p" ending: (
						change/part begin select _level-labels appender/logger/level ending
					) :begin |
					begin: "%%" ending: (change/part begin "%" ending) :begin |
					skip
				]
			]
			msg
		]
	]
	
	
	set 'init-log4reb func [
		the-loggers [block!]
		the-appenders [block!]
		the-layouts [block!]
		/override "Overrides existing configuration."
		/local obj
	] [
		if any [override none? _loggers] [_loggers: make hash! []]
		if any [override none? _appenders] [_appenders: make hash! []]
		if any [override none? _layouts] [_layouts: make hash! []]
		
		foreach [name args] the-loggers [
			obj: make logger! args
			obj/name: name
			repend _loggers [name obj]
		]
		foreach [name appender-type args] the-appenders [
			obj: make get in log4reb appender-type args
			obj/name: name
			repend _appenders [name obj]
		]
		foreach [name layout-type args] the-layouts [
			obj: make get in log4reb layout-type args
			obj/name: name
			repend _layouts [name obj]
		]
	]

	set 'log function [ 
		name [string! file! url! word!]
		/debug /info /warn /error /fatal
		/msg the-msg [string!]
		/data the-data [any-type!]
	] [error-str tmp-block logger level] [
		level: select reduce [debug 'debug info 'info warn 'warn error 'error fatal 'fatal] true
		logger: select _loggers name
		logger/level: level
		if lesser-or-equal? select _levels logger/threshold
							select _levels level 
		[
			; To avoid the side effect of local variables that hold series
			; as described at http://www.rebol.com/docs/core23/rebolcore-9.html#section-3.6
			either msg [the-msg: copy the-msg] [the-msg: copy ""]
			trim/lines the-msg
			if error? the-data [
				tmp-block: make block! []
				error-str: rejoin [
					"** "
					get in 
						get in system/error 
							get in disarm the-data 'type 
						'type 
					": "
					reform bind append tmp-block 
						get in 
							get in system/error 
								get in disarm the-data 'type 
							get in disarm the-data 'id 
					in disarm the-data 'arg1 
					" - Near: "
					mold get in disarm the-data 'near
					" **"
				]
			]
			if data [
				append the-msg join " " trim/lines 
					either error? the-data 
						[error-str] 
						[ 
							use [tmp] [
								if error? tmp: try [remold the-data] [
									tmp: mold the-data
								]
								tmp
							]
						]
			]
			logger/log the-msg
		]
    ]
	
	attempt: func [
		{Tries to evaluate and returns result or NONE on error.}
		value
	][
		if not error? set/any 'value try :value [get/any 'value]
	]
]

; The following is a skeleton for the properties file.
; Copy this to a seperate file and adapt it to your needs.
; Then you do:
; do %log4reb.r
; do %log4reb.properties ; if you called the properties file log4reb.properties

comment {
use [ loggers appenders layouts] [
	
	; <logger name> <constructor arguments>
	loggers: make block! [
		logger1 [threshold: 'all appenders: [console-app file-app1]]
		logger2 [threshold: 'debug appenders: [file-app2 file-app3]]
		logger3 [threshold: 'info appenders: [file-app3]]
		logger4 [threshold: 'warn appenders: [file-app4 file-app5]]
		logger5 [threshold: 'error appenders: [file-app5 file-app6]]
		logger6 [threshold: 'fatal appenders: [console-app file-app1 file-app5]]
		logger7 [threshold: 'off appenders: [file-app6 file-app2 file-app4]]
	]
	
	; <appender name> <appender type> <constructor arguments>
	appenders: make block! [
		console-app	console-appender! 	[layout: 'short]
		file-app1 	file-appender! 		[layout: 'long out: %file1.log]
		file-app2 	file-appender! 		[layout: 'long out: %file2.log]
		file-app3 	file-appender! 		[layout: 'long out: %file3.log]
		file-app4 	file-appender! 		[layout: 'long out: %file3.log]
		file-app5 	file-appender! 		[layout: 'long out: %file2.log]
		file-app6 	file-appender! 		[layout: 'long out: %file1.log]
	]
	
	; <layout name> <layout type> <constructor arguments>
	layouts: make block! [
		short 	pattern-layout! 	[pattern: "[%c] Signe Pourcent:%% - %m."]
		long 	pattern-layout!  	[pattern: "[%c] The exact time: %d\\dd-MMM-yyyy @  HH:MM:ss,SSS\\ - %p - %m."]
	]
	init-log4reb loggers appenders layouts
]
}
