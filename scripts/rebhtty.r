REBOL [
	file: %rebhtty.r
	name: "RebHTTY"
	title: "RebHTTY"
	purpose: "HTTP console in REBOL like HTTY console in Ruby"
	date: 23/06/2011
	version: 0.2.1
	author: "RedChronicle"
	url: http://www.red-chronicle.com
	history: [
	  0.2.1 23/06/2011 {
	    Fix ISSUE#0003
	    Add inside-tag inner function (to replace body function and to add new function)
	    Remove | in switch (thx guest2 RebelBB)
	    Add title, debug functions
	  }
	  0.2.0 22/06/2011 "Merge %htty.r and %rebhtty.r"
	  0.1.2 22/06/2011 "Add r | reuse functions"
	  0.1.1 21/06/2011 "Add headers | headers-response | body | body-response"
		0.1.1 22/06/2011 "Add error management, proxy config in a config file"
		0.1.0 20/06/2011 "Creation of the program"	  
		0.1.0 20/06/2011 "Creation of the program"
	]
	scripts: [%my-proxy-config.r]
  comments: {
    ISSUE#0001: Pb with display of console-header (
    ** Script Error: Cannot use path on none! value
    ** Where: halt-view
    ** Near: system/script/header/version newline
    ISSUE#0002: do-rebol do not work
    ISSUE#0003: r | reuse do not work
    ** Script Error: Invalid argument: 2
    ** Where: to-integer
    ** Near: to integer! :value
    ISSUE#0004: debug false
    ** Script Error: false word has no context
    ** Where: execute-action
    ** Near: false
    
    TO IMPLEMENT:
    
    # fol[low] : Change the address of the request to the value of the response's 'Location' header
    # fragment-c[lear] : Alias for fragment-u[nset]
    # fragment-s[et] FRAGMENT : Sets the fragment of the request's address
    # fragment-u[nset] : Removes the fragment from the request's address
    # history-verbose : Displays the details of previous request-response activity in this session
    # ho[st-set] HOST : Changes the host of the request's address
    # por[t-set] PORT : Changes the TCP port of the request's address
    # query-a[dd] NAME [VALUE [NAME [VALUE ...]]] : Adds query-string parameters to the request's address
    # ...
  }
]

;foreach script system/script/header/scripts [do script]
rebhtty: context [
	mode: 'console
	debug: false
	console-history: make block! []
	http-port: make port! http://0.0.0.0/
	open-http: func [url [url!]] [
    emit join "Try to connect to " url
		http-port: make port! url
		open http-port
		if debug [write %http-port.txt http-port]
		emit join "Connected to " url
	]
	close-http: does [
	  if http-port/host <> "0.0.0.0" [
	    emit join "Closing connection to " http-port/url
      close http-port
	    emit "Connection closed."
    ]
	]
	address: func [adr [string!]] [
		if debug [emit rejoin ["[address] " adr]]
		if adr <> http-port/url [
		  close-http
		  open-http to-url adr
	  ]
	]
	body: has [http-body [string!]] [
		parse http-port/state/inbuffer [thru "<body" skip to #"<" copy http-body to </body>]
		return http-body
 	]
 	headers: does [
		http-port/locals/headers
 	]
 	inside-tag: func [tag-name [string!] /local tag-content [string!] ts [string!] te [string!] res [logic!]] [
 	  ts: join "<" tag-name
 	  te: rejoin ["</" tag-name ">"]
 	  res: parse http-port/state/inbuffer [thru ts skip to #"<" copy tag-content to te]
 	  if not res [
   	  ts: rejoin ["<" tag-name ">"]
 	    parse http-port/state/inbuffer [thru ts copy tag-content to te]
    ]
 	  return tag-content 	  
	]
	emit: func [msg] [
		switch mode [
			console [print msg]
			html [print reform [<div> s </div>]]
		]
	]
  console-header: [
  	reduce [
  		{RebHHTY - HTTP TTY Rebol console} newline
  		"version : " system/script/header/version newline		
  	]
  ]
  console-help: {
help : display this help
a | address ADDRESS         : Change the address of the request
headers | headers-respsonse : Display the header of the response
body-req | body-request     : Display the body of the request
title                       : Display the title of the request
cd | path PATH              : Change the path of the request's address
r | reuse INDEX             : Copies a previous request by the index number shown in history
debug true | false          : Turn On/Off debug mode
history                     : Displays previous request-response activity in this session
	}
	execute-action: func [type-cmd [word!] arg [string! block!]] [
		if debug [emit rejoin ["[execute-action] " type-cmd " = " arg]]
		switch type-cmd [
			address a [
				address to-string arg	
			]
			path cd [
				http-port/path: to-string arg				 
			]
			r reuse [
				execute/nohistory pick console-history arg
			]
			do-rebol [
			  emit "DO REBOL :"
			  do arg
		  ]
		  debug [
		    ; ISSUE#0004
		    ;debug: do arg
	    ]
		]
	]
	rules: [
		any [
			['quit | 'exit] (
			  either mode = 'console [
  			  emit "Exiting RebHHTY console..."
  				close-http
  			  emit "RebHHTY console TERMINATED !"
  				break
			  ][
			    emit "Not supported !"
		    ]
			)
			| 'help (
				emit console-help
			)
			| ['body | 'body-response] (emit inside-tag "body")
			| 'title (emit inside-tag "title")
			| ['headers | 'headers-response] (emit headers)
			| 'history (
				hist: head console-history			
				while [not tail? hist] [
					emit rejoin [index? hist " " mold first hist]
					hist: next hist
				]
			)
			| 
			set action ['address | 'a | 'path | 'cd | 'r | 'reuse | 'do-rebol | 'debug] 
			set arg [string! | block!] (
				execute-action action arg
			)
		]
	]
	prompt: has [prt [string!]] [
		prt: rejoin ["htty:" http-port/url "> "]
	]
	execute: func [cmd /nohistory /local blk sub-blk] [
		if debug [emit join "[execute] " cmd]
		either nohistory [
			blk: cmd
		][
			blk: to-block cmd
			either (length? blk) > 1 [
			  sub-blk: copy []
			  append sub-blk first blk
        append/only sub-blk next blk
				append/only console-history sub-blk
			][
				append/only console-history to-block cmd
			]
			blk: last console-history
		]
		parse blk rules
	]
	run-console: does [
	  output: 'console
    ; ISSUE#0001
    ;emit console-header
    forever [
      set/any 'err try [
        execute ask prompt
      ]
      if error? get/any 'err [
        if debug [emit mold disarm err]
      ]
    ]
  ]
]