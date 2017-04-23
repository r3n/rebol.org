REBOL [
		Library: [
			Level: 'intermediate
			Platform: [windows]
			Type: [tool]
			Domain: [extension]
			Tested-under: [view 1.3.2.3.1 on "Windows XP SP2"]
			Support: none
			License: none
			See-also: none
        ]
		Author: "Arie van Wingerden"
		Date: 4-Sep-2006
		Email: xapwing@gmail.com
		File: %reb2exe.r
		Version: 1.0
		Title: "Create .EXE from Rebol script + other files using NSIS."
		Purpose: "Create .EXE (with ICON) from Rebol script with optional extra scripts or datafiles using NSIS."
		Prerequisites: {
			1. change the hardcoded lines in the PREPARE function in this script if needed
			2. install NSIS from http://nsis.sourceforge.net/Main_Page
			}
		Description: {
			To create a .EXE file from e.g. the following files:
				SCR1.R
				SCR2.R
				SCR3.R
				SCR.ICO
			which are in directory:
				SCRDIR
			do the following:
				1. open a command prompt
				2. go to the directory SCRDIR
				3. execute command:
					reb2exe.r SCR1 <rebol-cmdline-options>
					where rebol-cmdline-options can be "-s" or "-w -s" etc.
			After that in SCRDIR a file named SCR1.EXE can be found.
			}
		Notes: {
			1.	The first argument supplied to the start-script (e.g. SCR1.R) within the EXE file is
				the name of the directory in which the .EXE has been started
			2.	The second argument supplied to the start-script within the EXE file is the name of the
				EXE file (e.g.: SCR1.EXE)
			3.	All other arguments to the start-script within the EXE file are the commandline parameters
				specified by the user when (s)he invokes the .EXE file
			4.	The NSIS script named NSIS.NSI will be left intact in the target folder (together with
				the generated .EXE file)
			5.	Also a file called NSIS.LOG will be created and shown to the user  
			}
]  

prepare: func [/local args][
	; Create a global object to contain all global variables
	g: make object! [
		rebol-interpreter: copy ""
		rebol-interpreter-path: copy ""
		nsis: ""
		start-script: ""
		rebol-cmdline-options: ""
		ico-present: false
		reb2exe-dir: ""
		input-files: copy []
	]
	; Modify the next 3 hard-coded lines to your own requirements
	g/rebol-interpreter: "rebol.exe"
	g/rebol-interpreter-path: rejoin ["c:\program files\rebol\view\" g/rebol-interpreter]
	g/nsis: "C:\Program Files\NSIS\makensis.exe"
	
	; Get input args
	args: parse system/script/args none
	g/start-script: args/1
	if (g/start-script = none)
	or (to-logic find g/start-script "/")
	or (to-logic find g/start-script "\") [
		print "Error: no path allowed for input script - switch to input script directory"
		input
		quit
	]
	g/rebol-cmdline-options: skip system/script/args ((length? g/start-script) + 1)
	
	; Create list of all rebol files in current dir
	g/reb2exe-dir: system/script/parent/path
	g/input-files: read/lines to-file g/reb2exe-dir

	; Check if an .ICO file can be found
	if to-logic find g/input-files to-file rejoin [g/start-script ".ico"][
		g/ico-present: true
	]
]

tempdir: func [script-name /local uv] [
	random/seed uv: rejoin [now/yearday trim/with/all rejoin ["" now/time] ":"]
	rejoin [script-name random uv]
]

create-nsis-script: func [/local nsis-script] [
	nsis-script: copy []
	append nsis-script rejoin ["Name " g/start-script]
	append nsis-script "SilentInstall silent"
	append nsis-script rejoin ["OutFile ^"" rejoin ["" to-local-file rejoin [g/reb2exe-dir g/start-script]] ".exe^""]
	if g/ico-present [
		append nsis-script rejoin ["Icon ^"" g/start-script ".ico^""]
	]
	append nsis-script rejoin ["InstallDir $TEMP\" tempdir g/start-script]
	append nsis-script "Section ^"^""
	append nsis-script "    SetOutPath $INSTDIR"
	append nsis-script rejoin ["    File ^"" g/rebol-interpreter-path "^""]
	foreach file g/input-files [
		if ((uppercase to-string file) <> "NSIS.NSI")
		and ((uppercase to-string file) <> "NSIS.LOG")
		and ((uppercase to-string file) <> (rejoin [g/start-script ".ICO"]))
		and ((uppercase to-string file) <> (rejoin [g/start-script ".EXE"])) [  
			append nsis-script rejoin ["    File ^"" to-local-file file "^""]	
		]
	]
	append nsis-script rejoin [
		"    ExecWait '^"$INSTDIR\"
		g/rebol-interpreter
		"^" "
		g/rebol-cmdline-options
		" ^"$INSTDIR\" g/start-script
		".r^" ^"$EXEDIR^" "
		"$CMDLINE" 
		"'"]
	append nsis-script "    RMDir /r $INSTDIR"
	append nsis-script "SectionEnd"
	write/lines to-file rejoin [g/reb2exe-dir "nsis.nsi"] nsis-script
]

show-nsis-log: func [][
	foreach line (read/lines to-file rejoin [g/reb2exe-dir "nsis.log"]) [
		print line
	]
	print "Press ENTER to finish"
	input
]

create-exe: func [][
	call/output
		rejoin ["^"" g/nsis "^" ^"" to-local-file rejoin [g/reb2exe-dir "nsis.nsi^""]]
		to-file rejoin [g/reb2exe-dir "nsis.log"]
]

;;;
;;; Start main program
;;;

prepare
create-nsis-script
create-exe
show-nsis-log


