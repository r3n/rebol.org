REBOL [
	Title: "RebCall system"
	File:  %rebcall.r
	Date:  15-Dec-2005
	Version: 1.0.0
	Author: "Pascal Hurni"
	Library: [
		level: 'intermediate
		platform: 'windows
		type: [module]
		domain: [external-library extension win-api]
		tested-under: [w2k view 1.3.1 view 1.3.2]
		support: http://mortimer.devcave.net/projects/rebcall
		license: 'bsd
		see-also: http://mortimer.devcave.net
	]
	Purpose: { Call DLL functions efficiently with REBOL/View without the need for REBOL/View/Pro or REBOL/Command.
		This script only works on Windows with a patched REBOL interpreter.
		Details available at http://mortimer.devcave.net/projects/rebcall
		
		Actually only the types that fits in 32 bits are supported
		for the parameters. Thus decimal! values are not.
		
		It could also work on future REBOL/Core, here are the requierements:
			- get-env has to be defined (and get process environment variables)
			- struct! datatype must be available.
	}
]

;-- Already set?
if not value? 'rebcall [

;-- defines operator & and cast*
do %addr.r

rebcall: make object! [
	;-- Because RebCall starts when WinSock is initialized, use some network function to do so
	close open udp://127.0.0.1:0

	;-- TCP port of the in-process call handler
	port-no: to-integer get-env "_REBCALL_PORT"

	;-- Protocol:
	;--		LoadLibrary		1	0		LibraryName
	;--		FreeLibrary		2	hLib
	;--		GetProcAddress	3	hLib	ProcName
	;--		Call (stdcall)		4	pFunc	NumOfParam ParamArray
	;--		Call (cdecl)		5	pFunc	NumOfParam ParamArray
	
	cmd-loadlibrary: #{01000000}
	cmd-freelibrary: #{02000000}
	cmd-getprocaddress: #{03000000}
	cmd-call-std: #{04000000}
	cmd-call-c: #{05000000}

	;-- The rebol port connected to the handler
	call-port: none

	;-- The command buffer
	command: make binary! 128
	
	;-- The result buffer
	result: make binary! 4
	
	to-bin: func [value][reverse load join "#{" [to-hex to-integer value "}"]]
	
	;-- Work variables. Defined here, so the global context is not poluated.
	dummy-string: make struct! [s [string!]] none
	retval: none

	;-- Connect to handler
	connect: func [ /port portno][
		;-- Already connected?
		if not call-port [
			either error? try [call-port: open/direct/binary join tcp://127.0.0.1: any [portno port-no]][
				call-port: none
			][
				call-port/timeout: 60
			]
		]
	]

	;-- Disconnect from handler
	disconnect: does [
		close call-port
		call-port: none
	]
	
	;-- Test if connected
	connected?: does [
		found? call-port
	]

	;-- LoadLibrary
	set 'load-library func [libname [string! file!]][
		clear result
		clear command
		append command reduce [cmd-loadlibrary #{00000000} form libname #{00}]
		write-io call-port command length? command
		read-io call-port result 4
		copy result
	]
	
	;-- FreeLibrary
	set 'free-library func [lib [binary!]][
		;-- Sanity check
		if 4 <> length? lib [
			make error! "Lib has to be 4 bytes"
		]
		clear result
		clear command
		append command reduce [cmd-freelibrary lib]
		write-io call-port command length? command
		read-io call-port result 4
		to-integer result
	]

	;-- Create a rebol function that calls the target DLL function
	set 'make-routine func [spec [block!] lib [binary!] func-name [string!] /cdecl /debug /local func-spec ret-type ret stub call-cmd][
		;-- Sanity check
		if 4 <> length? lib [
			make error! "Lib has to be 4 bytes"
		]
		;-- Ask our handler if the func-name is available
		clear result
		clear command
		append command reduce [cmd-getprocaddress lib func-name #{00}]
		write-io call-port command length? command
		read-io call-port result 4
		if zero? to-integer result [
			make error! "This function is not exported by the passed library"
		]

		;-- determine the return type
		func-spec: copy spec
		ret-type: reduce [none]
		if ret: find func-spec [return: ][
			ret-type: second ret
			remove/part ret 2
		]
		
		;-- create the stub
		stub: copy []
		forskip func-spec 2 [
			switch func-spec/2/1 [
				binary! [append stub compose [append command & (func-spec/1)]]
				struct! [append stub compose [append command & (func-spec/1)]]
				string! [append stub compose [append command & (func-spec/1)]]
				integer! [append stub compose [append command to-bin (func-spec/1)]]
				long [append stub compose [append command to-bin (func-spec/1)]]
				short [append stub compose [append command to-bin (func-spec/1)]]
				char [append stub compose [append command to-bin (func-spec/1)]]
				logic! [append stub compose [append command to-bin (func-spec/1)]]
				block! [append stub compose [
					;-- We must create a dynamic stub because a block! is like a vararg
					foreach p (func-spec/1) [
						switch to-word type? p [
							binary! [append command & p]
							struct! [append command & p]
							string! [append command & p]
							integer! [append command to-bin p]
							long [append command to-bin p]
							short [append command to-bin p]
							char [append command to-bin p]
							logic! [append command to-bin p]
						]
					]
					;-- Don't forget to modify the param count
					change at command 9 to-char add length? (func-spec/1) pick command 9
				]]
			]
			if debug [
				append stub compose/deep [print reform ["^-REBCALL>^- Param: " (mold func-spec/1) (func-spec/1)]]
			]
		]

		call-cmd: either cdecl [cmd-call-c][cmd-call-std]

		;-- create the function
		func-spec: head func-spec
		make function! func-spec compose/deep [
			(either debug [compose [print join "^-REBCALL> " (func-name)]][])
			;-- Create the param array
			clear result
			clear command
			append command (call-cmd)
			append command (result)
			append command to-char (divide length? func-spec 2)
			append command #{000000}
			(stub)
			write-io call-port command length? command
			read-io call-port result 4
			retval: (switch/default ret-type/1 [
				none [[none]]
				char [[to-integer copy/part result 1]]
				short [[to-integer head reverse copy/part result 2]]
				long [[to-integer head reverse copy/part result 4]]
				integer! [[to-integer head reverse copy/part result 4]]
				logic! [[to-logic to-integer head reverse copy/part result 4]]
				string! [[ do [
					change third dummy-string result
					copy any [dummy-string/s ""]
				]]]
				binary! [
					;-- For now I don't know what to do with binary return value, I could return a pointer to a struct.
					;-- The problem is that the length is not known.
				]
			][
				;-- Defaults to LONG
				[to-integer head reverse copy/part result 4]
			])
			(either debug [ compose/deep [print reform ["^-REBCALL>^- return: " result retval] retval ]][])
		]
	]
]

]	; endif not value?

;-----------------------------------------------------------
;-- Process script arguments if any

if equal? system/script/args 'connect [rebcall/connect]
