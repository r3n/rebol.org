REBOL [
	Title: "CouchDB Client"
	Author: "Ingo Hohmann"
	Version: 0.0.11
	Date: 2010-01-22
	File: %couchdb3.r
	Needs: [2.100.96]
	Purpose: {Use couchdb as a datastore ( http://couchdb.apache.org/ )}
   Comments: {
      Api to access a CouchDB instance.
      - no special handling of login
      - no https
      - no error handling
   }
	library: [ 
		level: 'intermediate 
		platform: 'all 
		type: [tool module] 
		domain: [database http] 
		tested-under: {R3 2.100.96.3.1, couchdb 0.10.0} 
		support: none 
		license: bsd
		see-also: none 
	] 
	History: [
		0.0.1 - 0.0.10 "lost in time"
		0.0.11 "update to json module 0.0.6"
	]
]

secure [debug allow]
trace/back on

;do %json3.r

json: module [
	Title: "JSON to Rebol Converter"
	Name: 'json
	Version: 0.0.6
	Type: 'module
	Exports: [json-to-rebol rebol-to-json]
	Comments: {
		The json.r script on rebol.org doesn't work on r3, and instead of trying to 
		make it work, I thought, I'd just write a really basic json converter to play
		with. (My first version was abuot ten lines all in all). In the end, this is what
		happened.
	}
	History: [
		0.0.1 "first version trying to be complete"
		0.0.2 "in work attach"
		0.0.3 "in work view query"
		0.0.4 "start of bulk api"
		0.0.5 "error handling"
		0.0.6 "rebol-to-json: nested objects, rebol-to-json: problem in escape-string"
	]
	Todo: [
		"string: handling of special characters"
		"Testing"
		"check, if all datatypes are handled correctly"
		"embedded objects in rebol"
		"error handling!"
	]
	Done: []
][
	;======== Helper Functions ========
	to-isodate: funct [date [date!] /timestamp][
		rejoin [date/year #"-" either date/month < 10 [#"0"][""] date/month #"-" either date/day < 10 [#"0"][""] date/day either timestamp [rejoin [#" " date/time #"+" date/zone]][""]]
	]

	;======= JSON to REBOL ==========
	object: [remove #"{" opt members spc remove #"}"]
	embedded-object: [change #"{" "#[object! [" opt members spc change #"}" "]]"]
	members: [ pair any [change #"," #" " members]]
	pair: [ spc name-string remove spc #":" insert #" " spc value]
	array: [#"[" spc opt elements spc #"]"]
	elements: [ value spc any [change #"," #" " spc value ]]
	value: [ string | number | embedded-object | array | vtrue | vfalse | vnull]
	vtrue: [change "true" "#[true]"]
	vfalse: [change "false" "#[false]"]
	vnull: [change "null" "#[none]"]
	string: [change #"^"" #"{" any chars change #"^"" #"}"]
	name-string: [remove #"^"" any chars remove #"^""]
	chars: [ 
		any [char | change "{" "^{" | change "}" "^}" ;| change "^^"  "^^^^"
			| remove #"\" [ 
				#"^"" | #"\" | #"/" 
				| change #"b" #"^H" | change #"f" #"^L" | change #"n" #"^/" 
				| change #"r" #"^M" | change #"t" #"^-" 
	]]]
	char: complement charset {"\^{^}}
	hexdigit: charset [#"a" - #"f" #"A" - #"F" #"0" - #"1"]
	number: [int opt [frac | exp opt frac]]
	int: [ opt [#"-" | #"+"] some digit ]
	digit: charset [#"-" #"0" - #"9"]
	frac: [#"." some digit]
	exp: [ e some digit]
	e: [[#"e" | #"E"] opt [#"+" | #"-"]]
	space: charset " ^/^-"
	spc: [any space]

	json-to-rebol: func [
		"Converts JSON String to Rebol object! / block!"
		json [string! binary!] /local type
	][
		if binary? json [json: to-string json]
		parse c: json [object (type: 'object)| array (type: 'array)]
		either 'object = type [
			make object! load c
		][
			load c
		]
	]
	
	;========== REBOL to JSON ===========
	json-string: none
	name: none
	o: none
	rebol-object: [(emit #"{") any [rname (emit #":") rvalue (emit #",")] (change back tail json-string #"}")]
	rebol-block: [(emit #"[") any [rvalue (emit #",")] (change back tail json-string #"]")]
	rname: [set name skip (emit mold form to-word name)]
	rvalue: [ rnumber | rstring | into rebol-block | set o object! (parse to-block o rebol-object) | robject | rnone | rtrue | rfalse | rfile | rdate | copy v skip (emit mold form v)]
	robject: [and change copy o object! (to-block o) into rebol-object]
	rnumber: [set v number! (emit v)]
	rnone: [none! (emit "null")]
	rtrue: [true (emit "true")]
	rfalse: [false (emit "false")]
	rfile: [ set v file! (emit mold json-escape-string to-local-file v)]
	rstring: [set v string! (emit json-escape-string v)]
	rblock: [and block! into [any rvalue]]
	rdate: [set v date! (emit mold to-isodate/timestamp v)]
    escape-table: [
        {\\} "\"
        {\"} "^""
        {\/} "/"
        {\>} ">"
        {\b} "^H"
        {\f} "^L"
        {\r} "^M"
        {\n} "^/"
        {\t} "^-"
    ]

	json-escape-string: func[s [string!]][
		foreach [json rebol] escape-table [
			replace/all s rebol json 
		]
		insert s {"}
		append s {"}
		s
	]
	
	rebol-to-json: func [
		"Converts Rebol object! to JSON String"
		val [object!]
		;/local json-string
	][
		json-string: copy ""
		emit: func[v][append json-string v]
		
		if object? val [
			val: copy/deep to-block val
			parse val rebol-object
		]
		json-string
	]
]

couchdb: module [
	Title: "CouchDB Client"
	Name: 'couchdb
	Version: 0.0.4
	Type: 'module
	Author: "Ingo Hohmann"
	Exports: []
	Todo: [
		"work with views"
		"attachments"
		"bulk api"
	]
][
	url: none
	
	; ---- Helpers
	write-db: func [
		"Use write to send data to the database"
		url [url!] data
	][
		json/json-to-rebol write url data
	]
	
	read-db: func[
		"Use read to read data from the database"
		url [url!]
	][
		json/json-to-rebol read url
	]
	
	payload: func [
		"Wrap data into an object"
		data
	][
		make object! compose [data: (data)]
	]
	
	; ---- Database level api
	db-open: func [
		"Open a database"
		db-url [url! word! string!]
	][
		either url? url [
			url: dirize db-url
		][
			url: join http://localhost:5984/ form db-url
		]
		read-db url
	]
	
	db-create: func [
		"Create a new database"
		db [url! string! word!] /local parts base-url
	][
		if not url? db [db: join first split-path url db]
		write-db db [PUT]
	]
	
	db-delete: func [
		"Delete a database"
		db [url! string! word!] 
		/local parts base-url
	][
		if not url? db [db: join first split-path url db]
		write-db db [DELETE]
	]
	
	db-info: func[
		"Return Database META-information"
	][
		read-db url
	]
	
	db-changes: func [
		"Return database changes information"
		/since seq
	][
		my-url: rejoin [url "_changes" either since [join "?since=" seq][""]]
		read-db my-url
	]
	
	db-compact: func [][
		write-db url/_compact ""
	]
	
	; ------ helper functions --------
	uuid: func [
		"Get a UUID from the server" /local server-url answer
	][
		server-url: first split-path url
		answer: read-db server-url/_uuids
		answer/uuids/1
	]
	
	; -------- Server API
	server: func [
		"read arbitrary data from server" 
		path [file! string!]
		/local server-url response
	][
		server-url: first split-path url
		read-db server-url/:path
	]
	
	replicate: func [
		"Replicate databases"
		source-db
		target-db
		/continuous-replication
		/create-target-db
		/local request
	][
		request: make object! [source: source-db target: target-db]
		if continuous-replication [extend request 'continuous true]
		if create-target-db [extend request 'create-target true]
		write-db join first split-path url "_replicate" json/rebol-to-json request 
	]
	; -------- Document API -----------
	; Single Document API
	get: func [ 
		"Get a single document by id, does not consider conflicts"
		id [word! string!]
	][
		read-db url/:id
	]

	post: func [ 
		"Save a document, returns error if conflicting"
		data [object! string!]
	][
		either object? data [
			write-db url json/rebol-to-json data
		][
			write-db url data
		]
	]

	copy-doc: func [
		"Copy a document"
		id [word! string!]
		to [word! string!]
		/local parts
	][
		write-db url/:id compose/deep [COPY [Destination: (to)] ""]
	]
	

	; bulk document API
	doc: func [ 
		"Get a single document and all conflicting revisions by id" 
		id [word! string!] 
		/save
	][
		read-db join url/:id '?open_revs=all
	]
	
	save-doc: func [
		"Save a single document, possibly creating conflicts"
		data [object! string!] 
		/local template
	][
		template: json/rebol-to-json make object! [
			all_or_nothing: true
			docs: either object? data [probe json/rebol-to-json data][data]
		]
		data: rejoin [ 
			{^{"all_or_nothing":true,"docs":[}               ;}
			either object? data [json/rebol-to-json data][data]
			"]}"
			]
		write-db url/_bulk_docs data
	]
	
	save-bulk: func [
		"Save a block of documents, possibly creating conflicts"
		data [block!] "block of rebol objects"
		;/noconflict "do not create confliciting documents"
		/local template
	][
		template: json/rebol-to-json make object! [
			all_or_nothing: true
			docs: either object? data [json/rebol-to-json data][data]
		]
		data: rejoin [ 
			{^{"all_or_nothing":true,"docs":[}               ;}
			either object? data [json/rebol-to-json data][data]
			"]}"
			]
		write-db url/_bulk_docs data
	]
	
	; ------- Other document functions
	view: func [ 
		"query a view"
		design "design name"
		view "view name"
		/key "to get a single document by key-value"
			key-value 
		/range "to get a range of documents"
			start-value [string!] end-value [string!]
		/local my-url
	][
		assert [not all [key range] any [key range] "exactly 1 of key / range needs to be set"] 
		my-url: url/_design/:design/_view/:view
		either key [
			my-url: rejoin [my-url "?key=" mold key-value]
		][
			if range [my-url: rejoin [my-url "?startkey=" mold start-value "&endkey=" mold end-value]]
		]
		read-db my-url
	]
	
	update-doc: funct [ 
		"to update design documents, etc ..."
		id 
		json-data [object!]
		/local olddoc data
	][
		olddoc: get id
		data: json/json-to-rebol json-data
		extend data '_rev olddoc/_rev
		post data
	]

	attach: funct [ 
		"Add an attachment to document with id: id"
		id [string!] "document ID to attach to"
		attachment-name "Name the attachment"
		data [string! binary! file!] "Data to attach"
		/rev revision
		/get-rev "get revision of current document"
		/type mime-type "set mimetype if attachment (defaults to text/plain)"
		/local parts dummy
	][
		if get-rev [
			dummy: get id
			revision: dummy/_rev
			rev: true
		]
		parts: decode-url url
		default mime-type "text/plain"
		if file? data [data: read data]
		my-url: rejoin [url id "/" attachment-name either rev [join "?rev=" revision][""]]

		write-db my-url compose/deep [PUT [Content-Type: (mime-type)] (data)]
	]
]

test: func [ testcase][
	print [newline "===>" testcase]
	probe try [do testcase]
]

tests: [
	test [couchdb/db-create http://localhost:5984/hoh_test_db]
	test [couchdb/db-open http://localhost:5984/hoh_test_db]
	test [couchdb/post payload "Dies ist ein Test"]
	test [couchdb/post make object! [_id: "test" data: "Noch ein Test"]]
	test [couchdb/attach "test2" "attachment" "Test-string" ]
	test [couchdb/attach/get-rev "test2" "attachment" "Test-string 2" ]
	test [couchdb/db-delete "hoh_test_db"]
	;test [couchdb/db-open http://localhost:8200/db2]
	;test [rtj json-to-rebol to-string read http://localhost:5984/db2/3 ]
	;test [json-to-rebol to-string read http://localhost:5984/db2/3 ]
	;test [rebol-to-json json-to-rebol to-string read http://localhost:5984/db2/3 ]
	;test [x: couchdb/get "3"]
	;test [v: couchdb/get  "_design/example/_view/foo"]
	;test [couchdb/view 'example 'foo]
	;test [couchdb/view/key 'example 'foo "3"]
	;test [couchdb/view/range 'example 'foo "3" "4"]
	;test [couchdb/update-doc "_design/example" to-string read %design.json]
	;test [couchdb/attach "9" "attachment" "Test-string" ]
	;test [couchdb/attach/get-rev "13" "attachment" "Test-string" ]
	;test [x: couchdb/doc "3"]
	;test [x: couchdb/get "3"]
	;x/data: join "x" x/data
	;test [couchdb/save-doc x]
	;x/data: join "x" x/data
	;test [couchdb/save-doc x]
	;test [couchdb/copy-doc "3" "test3"]
	;test [json/rebol-to-json make object! [date: now]]
]

;do tests

tests-json: [
	test [json/rebol-to-json probe make object! [ob: make object! [b: 1 c: 2] b: [1 2]]]
	test [json/rebol-to-json make object! [a: [1 2 3]]]
]
;do tests-json 

'done