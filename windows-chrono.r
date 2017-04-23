rebol [
	title: "Chrono - High-precision time measurement" 
	file: %windows-chrono.r
	author: "Maxim Olivier-Adlhoch"
	version: 1.0.2
	license: 'MIT
	date: 2010-08-25
	disclaimer: "Absolutely no guarantees, use at own risk."
	notes: "Routines & utility functions for VERY precise counters on MS Windows 2000 and up."
]

;=====================================================
;                     libs
;=====================================================
k32-lib: load/library join to-rebol-file get-env "systemroot" %"/system32/Kernel32.dll"



;=====================================================
;                     structs
;=====================================================
; MSDN docs here: http://msdn.microsoft.com/en-us/library/aa383713%28VS.85%29.aspx
i64-struct: make struct! [
	low [integer!]
	hi [integer!]
] [ 0 0]



;=====================================================
;                     routines
;=====================================================
QueryPerformanceCounter: make routine! compose/deep [
	; MSDN docs here: http://msdn.microsoft.com/en-us/library/ms644904%28v=VS.85%29.aspx
	time-ptr [struct* [(first i64-struct)]]
	return: [integer!]
] k32-lib "QueryPerformanceCounter"

QueryPerformanceFrequency: make routine! compose/deep [
	time-ptr [struct* [(first i64-struct)]]
	return: [integer!]
] k32-lib "QueryPerformanceFrequency"


;=====================================================
;                     functions
;=====================================================
;-----------------
;-    i64-to-float()
;-----------------
i64-to-float: func [
	i64 [struct!]
][
	either negative? i64/low [
		(i64/hi * 4294967296.0) + 2147483648.0 + (i64/low AND 2147483647 ) ; {}
	][
		(i64/hi * 4294967296.0) + (i64/low)
	]
]


;-----------------
;-    get-tick()
;
; CAUTION! no error checking done for speed reasons. 
;
; QueryPerformanceCounter actually returns 0 when an error occurs or non-zero otherwise. 
; if there is no performanceCounter, the lib will fail anyways, when GLOBAL_TICK-RESOLUTION is 
; set.
;
; so its pretty safe even if we don't do any check on the return value of the routine.
;-----------------
get-tick: func [/local s][
	s: make struct! first i64-struct [0 0]
	QueryPerformanceCounter s
	i64-to-float s
]


;-----------------
;-    get-tick-resolution()
;-----------------
get-tick-resolution: func [/local s][
	s: make struct! first i64-struct [0 0]
	if 0 = QueryPerformanceFrequency s [
		to-error "NO performance counter on this system"
	]
	reduce [ s/hi s/low]
]

;-----------------
;-    time-lapse()
;
; note that we do not set the processor/thread affinity and this COULD lead to 
; different CPUS returning different counter values
;
; multi-core CPUS  use the same clock for all cores, so for the vast 
; majority of cases, this simple func is ok.
;
; AFAIK, the BIOS or HAL should synchronise both clocks (or always return the 
; clock for the same CPU), but some multi-processor motherboards might have issues.
;-----------------
time-lapse: func [
	blk [block!]
	/local start
][
	start: get-tick
	do blk
	; return diff in seconds
	to-time ((get-tick - start) / GLOBAL_TICK-RESOLUTION)
]


;-----------------
;-    chrono-time()
;-----------------
chrono-time: func [
][
	GLOBAL_CHRONO-TIMED + to-time ((get-tick - GLOBAL_CHRONO-INITIAL-TICK) / GLOBAL_TICK-RESOLUTION)
]




;=====================================================
;                     GLOBALS
;=====================================================
; used for converting to time 
GLOBAL_TICK-RESOLUTION: second get-tick-resolution

; used to provide more precise time via chrono-time
GLOBAL_CHRONO-TIMED: now/precise
GLOBAL_CHRONO-INITIAL-TICK: get-tick




;=====================================================
;                     TESTS
;=====================================================
; un-comment to test library
comment [
	probe time-lapse [print "."]
	probe time-lapse [prin "."]
	probe time-lapse [sine 45]
	probe time-lapse [wait 1.75] ; this actually highlights how imprecise the rebol timers really are!
	probe time-lapse [wait 1.75] ; this actually highlights how imprecise the rebol timers really are!
	probe time-lapse [wait 1.75] ; this actually highlights how imprecise the rebol timers really are!
	ask "!"
]