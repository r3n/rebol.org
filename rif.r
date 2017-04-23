REBOL [ File: %rif.r
	Title: "RIF"
	Author: "Pavel"
        Type: 'module
	Version: 0.0.2
	Date: 11-10-2010 
	Needs: [2.100.96]
	Purpose: {  Minimalistic Rebol Indexed file, "append only" database manager}
	Fileformat: {
		records are appended in data file "as is" in binary form. The respective offsets are saved in index file .
		record size is calculated from actual and next offset. Records numbers are not saved but computed from possition (array).
		offset are saved in 8 byte size (to-binary integer!)
		}
	to-do: {additional searching indexes 
		working with block!
		module encapsulation 0.0.3
		extension partially compiled
		potentially RIF// schema 0.0.3
		concurrence, large files insertion
		compression, encryption
		single file format with no speed restriction
		}
	History: [0.0.1	Single file Rif inserts slowed due of Lookup table movement
		0.0.2 .dat .idx files constant get/insert speed
                0.0.3 created RIF scheme 
		]
	Library:  [ level: 'intermediate
		platform: 'R3
		type: [tool database protocol module]
		domain: [file database module]
		tested-under: {R3 2.100.99.3.1 windows XP}
		license: pd
		support: none
		see-also: none
		]
        Credits: {Andreas, Graham, Steeve, Greg and everybody who helps me construct the scheme in AltMe}
]


;; Local functions

Append-RIF: func [port [port!] record [binary!] ][

	write/append port/locals/2 to-binary length? head port/locals/1		;index port the end of data file will be beginning of new record
	write/append port/locals/1 record							        ;data port new record into data file

	return shift length? head port/locals/2 -3					        ;number of records 8 bytes per record
]

Get-RIF: func [ port [port!] i [integer!] /local numentry indexpos recpos recend value ][

    numentry: shift length? head port/locals/2 -3                       ;number of records 8 bytes per record

	if any [i = 0 i > numentry] [return none]                           ;numbering starts at 1 ends at file end

	indexpos: multiply subtract i 1 8					                ;compute index offset
	recpos: to-integer read/seek/part port/locals/2 indexpos 8
		either ( (8 * i) = length? head port/locals/2 ) [				;last record special case
		recend: length? head port/locals/1
		][
		recend: to-integer read/seek/part port/locals/2 add indexpos 8 8		;internal record
		]
	return read/seek/part port/locals/1 recpos subtract recend recpos
]

;; Scheme definition
make-scheme [
	name: 'rif
	title: "RIF Protocol"
	spec: make system/standard/port-spec-head []
    awake: none

	actor: [
		open: func [port [port!] /local path ] [
            parse port/spec/ref [thru #":" 0 2 #"/" path:]
            append port/spec compose [path: (to-file path)]
            port/locals: copy []
            either (0 = length? port/locals) [
                append port/locals open/seek rejoin [port/spec/path ".dat"]
                append port/locals open/seek rejoin [port/spec/path ".idx"]
                ][
                port/locals/1 open/seek rejoin [port/spec/path ".dat"]
                port/locals/2 open/seek rejoin [port/spec/path ".idx"]
            ]
        return port
        ]

        close: func [port [port!]] [
            foreach  port port/locals [close port]
        ]

        read: func [port [port!] /seek number [integer!] ] [

		if empty? port/locals [	open port]
		return Get-RIF port number
		
		
        ]

        write: func [port [port!] record [binary!]] [
		if empty? port/locals [	open port]
		Append-RIF port record
        ]

    ]
]

Comment { DATA ARE STORED AS BINARY ONLY
Usage:
load %rif.r
write rif://data/file to-binary 123   ; creates files file.dat and file.idx in directory ./data
1                                              ; returns number of record in db
read/seek rif://data/file 1
#{000000000000007B}                ;binary 123

or

db-port: open rif://data/file
number-of-record: write db-port to-binary "importand text"
== 2
to-string read/seek db-port number-of-record
"importand text"
close port
and so on million times
}




