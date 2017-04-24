REBOL [
   Title: "patched HTTP/HTTPS protocol with cookies support"
   Author: cyphre@seznam.cz
   Company: "Prolific Publishing, Inc."
   Date: 18-Aug-2006
   File: %my-http.r
   Purpose: "Provide an HTTP/HTTPS handler that transparently supports cookies"
   Library: [
        level: 'advanced 
        platform: 'windows 'linux
        type: [module tool]
        domain: [http protocol web]
        tested-under: [Command 2.5.6 Command 2.5.125 WindowsXP Linux]
        license: 'MIT
        support: none
        see-also: none
      ]
   ]



cookies-db: copy []

cookie-object: make object! [
	domain:
	path:
	name:
	value:
	expires:
	none
]

get-cookies: func [port /local result domain path found?][
	result: copy "Cookie: "
;	print "GET COOKIES"
	domain: join "." port/host
	path: any [join "/" port/path ""]
	foreach c cookies-db [
		if all [
		 	find/part/reverse tail domain c/domain length? c/domain
			find/part path dirize c/path 1 + length? c/path
		][
			found?: true
			insert tail result rejoin [c/name "=" c/value "; "]
		]
	]
	remove/part back back tail result 2
	insert tail result newline
	either found? [result][""]
]

set-cookies-http: func [
	port
    /direct cookie
	/local result digits chars found? c make-cookie
][
;	print "SET COOKIES"
	digits: charset [#"0" - #"9"]
	chars: charset [#"A" - #"Z" #"a" - #"z"]
	make-cookie: func [	c ][
		result: make cookie-object [
			domain: either port [join "." port/host][""]
			path: "/"
			expires: now + 365
		]
		insert tail c ";"
		parse c [
			some [
				copy name to "=" skip copy value to ";" skip (
					switch/default name [
						"expires" [
							parse/all value [
								some [
									mark: 2 digits [" " | "-"] 3 chars [" " | "-"] 4 digits " " 2 digits ":" 2 digits ":" 2 digits (
										mark/3: #"-"
										mark/7: #"-"
										mark/12: #"/"
										result/expires: (to-date copy/part mark 20) + now/zone
									)
									| skip
								]
							]
						]
						"path" [result/path: value]
						"domain" [result/domain: value]
						"version" []
						"HTTPOnly" []
						"secure" []
					][result/name: name result/value: value]
				)
				| skip
			]
		]
        if all [series? result/path not empty? result/path][
            found?: false
            foreach c cookies-db [
                if all [
                    c/domain = result/domain
                    c/path = result/path
                    c/name = result/name
                    found?: true
                    (difference result/expires c/expires) > 0:00
                ][
                    c/expires: result/expires
                    c/value: result/value
                    break
                ]
            ]
            if not found? [
                insert tail cookies-db result
            ]
        ]
	]
    either port [
        foreach [n v] header-rules/head-list [
            if n = to-set-word 'set-cookie [
                if string? v [ make-cookie v ]
                if block? v [ foreach c v [ make-cookie c ] ]
            ]
        ]
    ][
        make-cookie cookie
    ]
    remove-each c cookies-db ["EXPIRED" = c/value]
]


system/schemes/http/user-agent: "Mozilla/5.0 (Windows; U; Windows NT 5.1; cs; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1"

system/schemes/http/handler: make system/schemes/http/handler [
	crlf-mode?: false
    open: func [
        port "the port to open"
        /local http-packet http-command response-actions success error response-line
        target headers http-version post-data result generic-proxy? sub-protocol
        build-port send-and-check create-request line continue-post
        tunnel-actions tunnel-success response-code forward proxyauth
	][
        port/locals: make object! [list: copy [] headers: none]
        generic-proxy?: all [port/proxy/type = 'generic not none? port/proxy/host]

        build-port: func [] [
            sub-protocol: either port/scheme = 'https ['ssl] ['tcp]
            open-proto/sub-protocol/generic port sub-protocol
            port/url: rejoin [lowercase to-string port/scheme "://" port/host either port/port-id <> 80 [join #":" port/port-id] [copy ""] slash]
            if found? port/path [append port/url port/path]
            if found? port/target [append port/url port/target]
            if sub-protocol = 'ssl [
                if generic-proxy? [
                    HTTP-Get-Header: make object! [
                        Host: join port/host any [all [port/port-id (port/port-id <> 80) join #":" port/port-id] #]
					]
                    user: get in port/proxy 'user
                    pass: get in port/proxy 'pass
                    if string? :user [
                        HTTP-Get-Header: make HTTP-Get-Header [
                            Proxy-Authorization: join "Basic " enbase join user [#":" pass]
						]
					]
                    http-packet: reform ["CONNECT" HTTP-Get-Header/Host "HTTP/1.1^/"]
                    append http-packet net-utils/export HTTP-Get-Header
                    append http-packet "^/"
                    net-utils/net-log http-packet
                    insert port/sub-port http-packet
                    continue-post/tunnel
				]
                system/words/set-modes port/sub-port [secure: true]
			]
		]

		; smarter query
		http-command: either querying ["HEAD"] ["GET"]
        create-request: func [/local target user pass u] [
            HTTP-Get-Header: make object! [
                Accept: "*/*"
                Connection: "close"
                User-Agent: get in get in system/schemes port/scheme 'user-agent
                Host: join port/host any [all [port/port-id (port/port-id <> 80) join #":" port/port-id] #]
			]

            if all [block? port/state/custom post-data: select port/state/custom 'header block? post-data] [
                HTTP-Get-Header: make HTTP-Get-Header post-data
			]

            HTTP-Header: make object! [
                Date: Server: Last-Modified: Accept-Ranges: Content-Encoding: Content-Type:
                Content-Length: Location: Expires: Referer: Connection: Authorization: none
			]

            http-version: "HTTP/1.0^/"
            all [port/user port/pass HTTP-Get-Header: make HTTP-Get-Header [Authorization: join "Basic " enbase join port/user [#":" port/pass]]]
            user: get in port/proxy 'user
            pass: get in port/proxy 'pass
            if all [generic-proxy? string? :user] [
                HTTP-Get-Header: make HTTP-Get-Header [
                    Proxy-Authorization: join "Basic " enbase join user [#":" pass]
				]
			]
            if port/state/index > 0 [
                http-version: "HTTP/1.1^/"
                HTTP-Get-Header: make HTTP-Get-Header [
                    Range: rejoin ["bytes=" port/state/index "-"]
				]
			]
            target: next mold to-file join (join "/" either found? port/path [port/path] [""]) either found? port/target [port/target] [""]

            post-data: none
            if all [block? port/state/custom post-data: find port/state/custom 'post post-data/2] [
                http-command: "POST"
                HTTP-Get-Header: make HTTP-Get-Header append [
                    Referer: either find port/url #"?" [head clear find copy port/url #"?"] [port/url]
                    Content-Type: "application/x-www-form-urlencoded"
                    Content-Length: length? post-data/2
				] either block? post-data/3 [post-data/3] [[]]
                post-data: post-data/2
			]

            http-packet: reform [http-command either generic-proxy? [port/url] [target] http-version]
            append http-packet net-utils/export HTTP-Get-Header

			append http-packet get-cookies port
			if all [crlf-mode? port/scheme = 'https][
	            append http-packet "^/"
	            replace/all http-packet lf crlf
	        ]
			http-packet
			]

        send-and-check: func [] [
            net-utils/net-log http-packet
            insert port/sub-port http-packet
            if post-data [write-io port/sub-port post-data length? post-data]
            continue-post
		]

		continue-post: func [/tunnel /local digit space] [
            response-line: system/words/pick port/sub-port 1
            net-utils/net-log response-line
            either none? response-line [do error] [
				; fixes #3494: should accept an HTTP/0.9 simple response.
				digit: charset "1234567890"
				space: charset " ^-"
				either parse/all response-line [
					; relaxing rule a bit
					;"HTTP/" digit "." digit some space copy response-code 3 digit some space to end
					"HTTP/" digit "." digit some space copy response-code 3 digit to end
				] [
					; valid status line
					response-code: to integer! response-code
					result: select either tunnel [tunnel-actions] [response-actions] response-code
					either none? result [do error] [do get result]
				] [
					; could not parse status line, assuming HTTP/0.9
					port/status: 'file
				]
			]
		]

        tunnel-actions: [
            200 tunnel-success
		]

        response-actions: [
            100 continue-post
            200 success
            201 success
            204 success
            206 success
            300 forward
            301 forward
            302 forward
            304 success
            407 proxyauth
		]

        tunnel-success: [
            while [ ( line: pick port/sub-port 1 ) <> ""] [net-log line]
		]

        success: [
            headers: make string! 500
            while [(line: pick port/sub-port 1) <> ""] [append headers join line "^/"]
            port/locals/headers: headers: Parse-Header HTTP-Header headers
            port/size: 0
            if querying [if headers/Content-Length [port/size: load headers/Content-Length]]
            if error? try [port/date: parse-header-date headers/Last-Modified] [port/date: none]

			if not error? try [port/locals/headers/Set-Cookie] [
				set-cookies-http port
			]

            port/status: 'file
		]

        error: [
            system/words/close port/sub-port
            net-error reform ["Error.  Target url:" port/url "could not be retrieved.  Server response:" response-line]
		]

        forward: [
            page: copy ""
            while [(str: pick port/sub-port 1) <> ""] [append page reduce [str newline]]
            headers: Parse-Header HTTP-Header page

			if not error? try [headers/Set-Cookie] [
				set-cookies-http port
			]

            insert port/locals/list port/url
            either found? headers/Location [
                either any [find/match headers/Location "http://" find/match headers/Location "https://"] [
                    port/path: port/target: port/port-id: none
                    net-utils/URL-Parser/parse-url/set-scheme port to-url port/url: headers/Location
                    if not port/port-id: any [port/port-id all [in system/schemes port/scheme get in get in system/schemes port/scheme 'port-id]] [
                        net-error reform ["HTTP forwarding error: Scheme" port/scheme "for URL" port/url "not supported in this REBOL."]
					]
				] [
                    either (first headers/Location) = slash [port/path: none remove headers/Location] [either port/path [insert port/path "/"] [port/path: copy "/"]]
                    port/target: headers/Location
                    port/url: rejoin [lowercase to-string port/scheme "://" port/host either port/path [port/path] [""] either port/target [port/target] [""]]
				]
;                if find/case port/locals/list port/url [net-error reform ["Error.  Target url:" port/url "could not be retrieved.  Circular forwarding detected"]]
                system/words/close port/sub-port
                build-port
                create-request
                send-and-check
			] [
                do error]
			]

        proxyauth: [
            system/words/close port/sub-port
            either all [generic-proxy? (not string? get in port/proxy 'user)] [
                port/proxy/user: system/schemes/http/proxy/user: port/proxy/user
                port/proxy/pass: system/schemes/http/proxy/pass: port/proxy/pass
                if not error? try [result: get in system/schemes 'https] [
                    result/proxy/user: port/proxy/user
                    result/proxy/pass: port/proxy/pass
				]
			] [
                net-error reform ["Error. Target url:" port/url "could not be retrieved: Proxy authentication denied"]
			]
            build-port
            create-request
            send-and-check
		]
        build-port
        create-request
        send-and-check
	]

	query: func [port] [
		if not port/locals [
			querying: true
			open port
			; port was kept open after query
			; attempt for extra safety
			; also note, local close on purpose
			attempt [close port]
			; RAMBO #3718
			querying: false
		]
		none
	]

	close: func [port] [system/words/close port/sub-port]
]

if find first system/schemes 'https [
	system/schemes/https/user-agent: "Mozilla/5.0 (Windows; U; Windows NT 5.1; cs; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1"
	system/schemes/https/handler: make system/schemes/https/handler [
		crlf-mode?: false
	    open: func [
	        port "the port to open"
	        /local http-packet http-command response-actions success error response-line
	        target headers http-version post-data result generic-proxy? sub-protocol
	        build-port send-and-check create-request line continue-post
	        tunnel-actions tunnel-success response-code forward proxyauth
		][
	        port/locals: make object! [list: copy [] headers: none]
	        generic-proxy?: all [port/proxy/type = 'generic not none? port/proxy/host]
	        build-port: func [] [
	            sub-protocol: either port/scheme = 'https ['ssl] ['tcp]
	            open-proto/sub-protocol/generic port sub-protocol
	            port/url: rejoin [lowercase to-string port/scheme "://" port/host either port/port-id <> 80 [join #":" port/port-id] [copy ""] slash]
	            if found? port/path [append port/url port/path]
	            if found? port/target [append port/url port/target]
	            if sub-protocol = 'ssl [
	                if generic-proxy? [
	                    HTTP-Get-Header: make object! [
	                        Host: join port/host any [all [port/port-id (port/port-id <> 80) join #":" port/port-id] #]
						]
	                    user: get in port/proxy 'user
	                    pass: get in port/proxy 'pass
	                    if string? :user [
	                        HTTP-Get-Header: make HTTP-Get-Header [
	                            Proxy-Authorization: join "Basic " enbase join user [#":" pass]
							]
						]
	                    http-packet: reform ["CONNECT" HTTP-Get-Header/Host "HTTP/1.1^/"]
	                    append http-packet net-utils/export HTTP-Get-Header
	                    append http-packet "^/"
	                    net-utils/net-log http-packet
	                    insert port/sub-port http-packet
	                    continue-post/tunnel
					]
	                system/words/set-modes port/sub-port [secure: true]
				]
			]
            http-command: either querying ["HEAD"] ["GET"]
	        create-request: func [/local target user pass u] [
	            HTTP-Get-Header: make object! [
	                Accept: "*/*"
	                Connection: "close"
	                User-Agent: get in get in system/schemes port/scheme 'user-agent
	                Host: join port/host any [all [port/port-id (port/port-id <> 80) join #":" port/port-id] #]
				]
	            if all [block? port/state/custom post-data: select port/state/custom 'header block? post-data] [
	                HTTP-Get-Header: make HTTP-Get-Header post-data
				]
	            HTTP-Header: make object! [
	                Date: Server: Last-Modified: Accept-Ranges: Content-Encoding: Content-Type:
	                Content-Length: Location: Expires: Referer: Connection: Authorization: none
				]
	            http-version: "HTTP/1.0^/"
	            all [port/user port/pass HTTP-Get-Header: make HTTP-Get-Header [Authorization: join "Basic " enbase join port/user [#":" port/pass]]]
	            user: get in port/proxy 'user
	            pass: get in port/proxy 'pass
	            if all [generic-proxy? string? :user] [
	                HTTP-Get-Header: make HTTP-Get-Header [
	                    Proxy-Authorization: join "Basic " enbase join user [#":" pass]
					]
				]
	            if port/state/index > 0 [
	                http-version: "HTTP/1.1^/"
	                HTTP-Get-Header: make HTTP-Get-Header [
	                    Range: rejoin ["bytes=" port/state/index "-"]
					]
				]
	            target: next mold to-file join (join "/" either found? port/path [port/path] [""]) either found? port/target [port/target] [""]
	            post-data: none
	            if all [block? port/state/custom post-data: find port/state/custom 'post post-data/2] [
	                http-command: "POST"
	                HTTP-Get-Header: make HTTP-Get-Header append [
	                    Referer: either find port/url #"?" [head clear find copy port/url #"?"] [port/url]
	                    Content-Type: "application/x-www-form-urlencoded"
	                    Content-Length: length? post-data/2
					] either block? post-data/3 [post-data/3] [[]]
	                post-data: post-data/2
				]
	            http-packet: reform [http-command either generic-proxy? [port/url] [target] http-version]
	            append http-packet net-utils/export HTTP-Get-Header
				append http-packet get-cookies port
				if all [crlf-mode? port/scheme = 'https][
		            append http-packet "^/"
		            replace/all http-packet lf crlf
		        ]
				http-packet
				]
	        send-and-check: func [] [
	            net-utils/net-log http-packet
	            insert port/sub-port http-packet
	            if post-data [write-io port/sub-port post-data length? post-data]
	            continue-post
			]
			continue-post: func [/tunnel /local digit space] [
	            response-line: system/words/pick port/sub-port 1
	            net-utils/net-log response-line
	            either none? response-line [do error] [
					digit: charset "1234567890"
					space: charset " ^-"
					either parse/all response-line [
						"HTTP/" digit "." digit some space copy response-code 3 digit to end
					] [
						response-code: to integer! response-code
						result: select either tunnel [tunnel-actions] [response-actions] response-code
						either none? result [do error] [do get result]
					] [
						port/status: 'file
					]
				]
			]
	        tunnel-actions: [
	            200 tunnel-success
			]
	        response-actions: [
	            100 continue-post
	            200 success
	            201 success
	            204 success
	            206 success
	            300 forward
	            301 forward
	            302 forward
	            304 success
	            407 proxyauth
			]
	        tunnel-success: [
	            while [(line: pick port/sub-port 1) <> ""] [net-log line]]
	        success: [
	            headers: make string! 500
	            while [(line: pick port/sub-port 1) <> ""] [append headers join line "^/"]
	            port/locals/headers: headers: Parse-Header HTTP-Header headers
	            port/size: 0
	            if querying [if headers/Content-Length [port/size: load headers/Content-Length]]
	            if error? try [port/date: parse-header-date headers/Last-Modified] [port/date: none]
				if not error? try [port/locals/headers/Set-Cookie] [
					set-cookies-http port
				]
	            port/status: 'file
			]
	        error: [
	            system/words/close port/sub-port
	            net-error reform ["Error.  Target url:" port/url "could not be retrieved.  Server response:" response-line]
			]
	        forward: [
	            page: copy ""
	            while [(str: pick port/sub-port 1) <> ""] [append page reduce [str newline]]
	            headers: Parse-Header HTTP-Header page
				if not error? try [headers/Set-Cookie] [
					set-cookies-http port
				]
	            insert port/locals/list port/url
	            either found? headers/Location [
	                either any [find/match headers/Location "http://" find/match headers/Location "https://"] [
	                    port/path: port/target: port/port-id: none
	                    net-utils/URL-Parser/parse-url/set-scheme port to-url port/url: headers/Location
	                    if not port/port-id: any [port/port-id all [in system/schemes port/scheme get in get in system/schemes port/scheme 'port-id]] [
	                        net-error reform ["HTTP forwarding error: Scheme" port/scheme "for URL" port/url "not supported in this REBOL."]
						]
					] [
	                    either (first headers/Location) = slash [port/path: none remove headers/Location] [either port/path [insert port/path "/"] [port/path: copy "/"]]
	                    port/target: headers/Location
	                    port/url: rejoin [lowercase to-string port/scheme "://" port/host either port/path [port/path] [""] either port/target [port/target] [""]]
					]
;	                if find/case port/locals/list port/url [net-error reform ["Error.  Target url:" port/url {could not be retrieved.  Circular forwarding detected}]]
	                system/words/close port/sub-port
	                build-port
	                create-request
	                send-and-check
				] [
	                do error
				]
			]
	        proxyauth: [
	            system/words/close port/sub-port
	            either all [generic-proxy? (not string? get in port/proxy 'user)] [
	                port/proxy/user: system/schemes/http/proxy/user: port/proxy/user
	                port/proxy/pass: system/schemes/http/proxy/pass: port/proxy/pass
	                if not error? try [result: get in system/schemes 'https] [
	                    result/proxy/user: port/proxy/user
	                    result/proxy/pass: port/proxy/pass
					]
				] [
	                net-error reform ["Error. Target url:" port/url {could not be retrieved: Proxy authentication denied}]
				]
	            build-port
	            create-request
	            send-and-check
			]
	        build-port
	        create-request
	        send-and-check
		]
		query: func [port][
			if not port/locals [
				querying: true
				open port
				attempt [close port]
				querying: false
			]
			none
		]
	]
]
