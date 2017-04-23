REBOL [
	Title: "REST-Friendly HTTP Protocol"
	Date: 9-Nov-2008
	Author: "Christopher Ross-Gill"
	Type: 'module
	Version: 0.1.0
	File: %rest.r
	Purpose: {
		An elementary HTTP protocol allowing more versatility when developing Web
		Services clients: REST, SOAP or other.
	}
	Note: {
		Proof of concept, perhaps not robust.  Should be more efficient, both in
		implementation and dialect.
	}
	History: [
		15-Aug-2006 0.0.1 "Original Version"
	]
	Library: [
		Level: 'advanced
		Platform: 'all
		Type: [module protocol]
		Domain: [http ldc protocol scheme web]
		License: 'cc-by-sa
	]
	Usage: [
		context load %rest.r
		read/custom rest://example.com/ [action: 'post content: "this=is&a=post&request"]
		read/custom rest://example.com/foo [action: 'delete]
		read/custom rest://example.com/ [action: 'put content: mold self type: 'text/x-rebol]
	]
]

add-protocol: func ['name id handler /with block][
	unless in system/schemes name [
		system/schemes: make system/schemes compose [
			(to-set-word name) (none)
		]
	]
	set in system/schemes name make system/standard/port compose [
		scheme: name
		port-id: (id)
		handler: (handler)
		passive: none
		cache-size: 5
		proxy: make object! [host: port-id: user: pass: type: bypass: none]
		(block)
	]
]

;--## REQUEST
;-------------------------------------------------------------------##
make-request: use [prototype to-header header-prototype][
	prototype: context [
		version: 1.1
		action: 'get
		headers: none
		target: content: content-length: none
		type: 'application/x-www-form-url-encoded
	]

	to-header: func [object [object!] /local header][
		header: make string! (20 * length? first object)
		foreach word next first object [
			if get word: in object word [
				insert tail header reduce [word ": " get word newline]
			]
		]
		header
	]

	header-prototype: context [
		Host: none
		Accept: "*/*"
		Connection: "close"
		User-Agent: rejoin ["REBOL/" system/product " " system/version]
		Content-Length: Content-Type: Authorization: Range: none
	]

	func [port /local request packet][
		request: make prototype any [port/state/custom []]
		request/headers: make header-prototype any [request/headers []]
		request/headers/host: port/host

		if request/content [
			request/content-length:
			request/headers/Content-Length: length? request/content
			request/headers/Content-Type: request/type
		]

		if all [port/user port/pass][
			request/headers/Authorization: join "Basic " enbase join port/user [#":" port/pass]
		]

		if port/state/index > 0 [
			request/version: 1.1
			request/headers/Range: rejoin ["bytes=" port/state/index "-"]
		]

		request/headers: rejoin [
			uppercase form request/action
			#" " any [port/path "/"] any [port/target ""]
			#" " "HTTP/" request/version
			newline to-header request/headers
		]

		request
	]
]

;--## RESPONSE
;-------------------------------------------------------------------##
make-response: use [prototype header-prototype][
	prototype: context [status: headers: content: type: length: none]

	header-prototype: context [
		Date: Server: Last-Modified: Accept-Ranges: Content-Encoding: Content-Type:
		Content-Length: Location: Expires: Referer: Connection: Authorization: none
	]

	func [port /local response key val][
		response: make prototype [
			status: pick port/sub-port 1

			unless none? status [
				status: parse status none
				status: attempt [to-integer second status]

				headers: make block! []

				while ["" <> line: pick port/sub-port 1][
					parse/all line [
						copy key to ": " ": " val: to end (
							repend headers [to-set-word key val]
						)
					]
				] ; pick off the headers

				headers: make header-prototype headers

				type: all [
					path? type: attempt [load headers/Content-Type]
					type
				]
				length: any [attempt [headers/Content-Length: to-integer headers/Content-Length] 0]

				set-modes port/sub-port [binary: true]
				; content: copy/part port/sub-port length
				content: copy port/sub-port
			]
		]
	]
]

;--## INITIATE TRANSACTION
;-------------------------------------------------------------------##
map-spec: use [chars rule][
	chars: charset [#"a" - #"z" #"0" - #"9" "-_!+%.,"]

	rule: [
		"rest://" (scheme: 'http)
		opt [copy user to #"@" (set [user pass] parse/all user ":") #"@"]
		copy host some chars ()
		opt [#":" copy port-id integer! (port-id: to-integer port-id)]
		copy path opt [#"/" any [some chars #"/"]]
		copy target to end
	]

	func [port [port!] spec [block! url!]][
		if url? spec [
			port/url: spec
			unless parse/all spec bind rule port [port/host: none]
		]
	]
]

;--## CONNECT
;-------------------------------------------------------------------##
make-connection: func [port][
	open/lines [
		scheme: 'tcp
		host: port/host
		user: port/user
		pass: port/pass
		port-id: port/port-id
		timeout: port/timeout
		path: port/path
		target: port/target
	]
]

;--## INSTALL PROTOCOL
;-------------------------------------------------------------------##
add-protocol rest 80 context [
	port-flags: system/standard/port-flags/pass-thru

	init: :map-spec

	open: func [port /local request][
		port/state/flags: port/state/flags or port-flags
		port/sub-port: make-connection port
		request: make-request port

		insert port/sub-port request/headers
		if request/content [
			write-io port/sub-port request/content request/content-length
		]
	]

	copy: :make-response

	close: func [port][system/words/close port/sub-port]
]