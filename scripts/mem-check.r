Rebol [
	File: %mem-check.r
	Title: "Mem-Checker"
	Date: 12-Jan-2005
	Author: "Anton Reisacher"
	Purpose: "Checking the memory usage of a process running under Windows"
	Library: [
		Level: 'intermediate
		platform: [Windows]
		Notes: {from the Microsoft site on psapi.dll
			Client 	Requires Windows XP, Windows 2000 Professional, or Windows NT Workstation 4.0.
			Server 	Requires Windows Server 2003, Windows 2000 Server, or Windows NT Server 4.0.
		}
		type: [tool]
		tested-under: [WIN/NT WIN2000]
		domain: [win-api ]
		Support: none
		License: none
		Needs: [Command Pro]
	]

]
mem-check: context [
	kernel-lib: load/library %kernel32.dll
	
	GetError: make routine! [
		return: [integer!]
	] kernel-lib "GetLastError"
	
	FormatMsg: make routine! [
		flags			[integer!] ; 4096
		Source		[integer!] ; 0
		MsgID		[integer!]  ; errno
		Language	[integer!] ; 0
		Buffer		[string!]
		Size			[integer!]
		Arguments	[integer!] ; 0
		return: 		[integer!]
	] kernel-lib "FormatMessageA"
		
	System-Msg: func [
		msgid 
		/local len buf
	] [
		buf: head insert/dup make string! 1000  "^@" 1000
		
		len:  FormatMsg 4096 0 msgid 0 buf 1000 0 
		copy/part  buf len
	]
	
	
	OpenProc: make routine! [
		AccessFlag	[integer!]; 1 = Terminate; 2035711 all-flags
		Inherited	[integer!]
		ProcessID	[integer!]
		return:		[integer!]
	] kernel-lib "OpenProcess"


	FreeHandle: make routine! [
		handle		[integer!]
		return:		[integer!]
	] kernel-lib "CloseHandle"

	
	MY-ProcessId: make routine! [
		return: 		[integer!]
	] kernel-lib "GetCurrentProcessId"

	psapi-lib: load/library %psapi.dll
	
	ProcMemCounter-block: make block! [
		Size 					[integer!] ; in bytes
		PageFault 			[integer!] ; Number of page faults.
		PeakWorkingSize 	[integer!] ; Peak working set size
		WorkingSize 		[integer!] ; Current working set size
		QuotaPeakPaged 	[integer!]; Peak paged pool usage
		QuotaPaged 		[integer!] ; Current paged pool usage
		QuotaPeakNonPaged [integer!]; Current nonpaged pool usage
		QuotaNonPaged 	[integer!] ; Current nonpaged pool usage
		PageFile 			[integer!] ; Current space allocated for the pagefile
		PeakPageFile 		[integer!]; Peak space allocated for the pagefile
	]

	GetProcessMemory-block: compose/only [
		handle 		[integer!]
		pProcMemCounter (append/only [struct!] ProcMemCounter-block)
		return: 		[integer!]
	] 
	GetProcessMemory: make routine! GetProcessMemory-block psapi-lib "GetProcessMemoryInfo"
	
	set 'Get-Memory func [ [catch] ; '
		process-id [integer!]
		/local ProcMemCounter ProcHandle
	] [
		ProcMemCounter: make struct! ProcMemCounter-block none
		ProcMemCounter/size: length? third ProcMemCounter
		if any [
			0 = ProcHandle: OpenProc 2035711 1 process-id
			0 = GetProcessMemory ProcHandle ProcMemCounter
		] [
			throw make error! System-Msg GetError 
		]
		freehandle ProcHandle
		ProcMemCounter
	]
	
	
	Set 'Memory-Check func [
		/limit Range
		/local ProcessID Memory
	] [
		
	
		Memory:  Get-Memory ProcessId: MY-ProcessID
		Range: any [Range 15'000'000] ; 	15 Mb is very conservative  
		if all	[
			range < probe memory/pagefile 
			Memory/pagefile > probe memory/peakworkingsize
			probe join now "    starting anew"
		] [
			call rejoin [
				form to-local-file system/options/boot  " -s " 
				system/options/script " " 
				either system/options/args [system/options/args] [""]
			]
			free kernel-lib
			free psapi-lib
			quit
		]
	]



]





