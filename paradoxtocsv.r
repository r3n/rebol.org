REBOL [
  Title: "ParadoxTOCSV"
	Name: "ParadoxTOCSV"
	Author: "nicolas"
	File: %paradoxtocsv.r
	Date: 03/03/2011
	Purpose: "Paradox DB file convert to CSV"
  Library: [ 
    level: 'beginner 
    platform: 'all 
    type: [tool] 
    domain: [database] 
    tested-under: [windows] 
    support: none 
  ]	
 	Use: %paradox-protocol.r
	Usage: {
		>> rebol -v %paradoxtocsv.r %MES_FICHIERS_PARADOX/
	}
]

do %paradox-protocol.r
;===========================================================================
debug: false
reb-file: none
file-log: %paradoxtocsv.log
;=============================== FUNCTIONS =====================================
append-log: func [msg [string!] /console /only] [
	if debug [
  	if console [
  			print rejoin ["[" now "] " msg]	
  	]
  ]
 	if not only [
		write/append file-log rejoin ["[" now "] " msg newline]
	]
]
convert-to-csv: func [vfile [file!] /local db-port csv-file nbrows row] [
	db-port: open join paradox:// vfile
	;insert db-port "DESC" 
	nbrows: insert db-port "SELECT * FROM "
	either not none? nbrows [
  	either nbrows > 0 [
  		set [path file] split-path vfile
  		parse file [copy csv-file to "."]
  		append csv-file ".csv"
  		csv-file: to-file csv-file
  		if error? try [
  			write  csv-file ""	
  			foreach item copy db-port [
  				row: copy ""
  				foreach i item [
  					if (type? i) = date! [i: rejoin [i/day "/" i/month "/" i/year]]
  					either row = "" [row: i][row: rejoin [row "," i]]
  				]
  				write/append csv-file join row newline
  			]
  			append-log/console rejoin ["Convert paradox file " vfile " to " csv-file]	
  		][
  			append-log/console rejoin ["*** ERROR *** Could not convert paradox file " vfile " to " csv-file]
  		]
  	][
  		append-log/console rejoin ["Paradox file " vfile " : no data !"]	
  	]	
  ][append-log/console rejoin ["Paradox file " vfile " is empty !"]]
 	close db-port	
]
;=========================== MAIN ==========================================
either not none? system/script/args [
	ts: now
	append-log/console rejoin [system/script/header/name " : start convert"]
	reb-file: to-rebol-file system/script/args 
	either dir? reb-file [
		reb-file: dirize reb-file
		; Directory
		files: load reb-file
		foreach f files [
			if not dir? f [
				set/any 'err try [
          convert-to-csv to-file join reb-file f
        ]
        if error? get/any 'err [append-log disarm err]
			]
		]
	][
		; File
		set/any 'err try [
      convert-to-csv reb-file 
    ]
    if error? get/any 'err [append-log disarm err]
	]	
	te: now
	append-log/console rejoin [system/script/header/name " : end convert"]
	append-log/console rejoin [system/script/header/name " : total time = " difference te ts]
][
	print rejoin [
		"Usage: " newline 
		"rebol -v %paradoxtocsv.r file" newline 
		"rebol -v %paradoxtocsv.r directory"
	]
]
if debug [halt]
;======================== END OF PROGRAM ===================================