REBOL [
	
	Title:   "EASY SOCCER"
	Date:	 23-Dec-2005
	Author:  ["Marco"]
	Version: 2.1.1
	Email:   [mvri@bluewin.ch]
	File:	 %easy-soccer.r
	Category: [web cgi]
	Library: [
		level: 'beginner
		platform: 'all
		type: [function tool module]
		domain: [cgi web compression encryption extension http protocol other-net ]
		tested-under: [win]
		support: marco@ladyreb.org
		license: PD
		see-also: none
	]
	Comment: {At the origin was Rugby, next Soccer and now Easy-Soccer}
	Purpose: {
		Easy-Soccer is a broker based on CGI which offer an easy way 
		to write and the deploy distributed Rebol application.
		
		Easy-Soccer makes very easy to expose function written in Rebol like services.
		Thus, you can use these functions as if they were defined locally.

		In a distributed environment Easy-Soccer uses a simple WEB server
		and CGI to execute Rebol code on the server. HTTP is used for the 
		transport of the messages like SOAP or X-RPC and so goes easily thru firewalls.

		Easy-Soccer allows not only to publish remote function, but can also provide
		the client part of the application. So you can have in the same Rebol script
		the client and the server part of your program.
		
		Even more, Easy-Soccer allows you to run your script as a monolithic application
		without any change and without anything else than your script. In the same spirit,
		if your script use VID, it can be run within REBOL/View or within the REBOL/Plugin
		without any change.
	}
	Modified: [
		[1.0.0 10-Apr-2004 marco@ladyreb.org {Création du programme sur la base de soccer}]
		[1.0.1 11-Apr-2004 marco@ladyreb.org {Petites corrections}]
		[1.0.2 17-Apr-2004 marco@ladyreb.org {Petites corrections}]
		[1.0.3 01-May-2004 marco@ladyreb.org {Permet de tourner en standalone dans view}]
		[1.0.4 02-May-2004 marco@ladyreb.org {Petites corrections}]
		[1.0.5 02-May-2004 marco@ladyreb.org {permet de tourner en standalone dans tous les cas}]
		[1.0.6 10-May-2004 marco@ladyreb.org {Ajout des rafinement /encloak et /compress à la fonction serve}]
		[1.0.7 11-May-2004 marco@ladyreb.org {Permet de mettre les clients dans des contexts}]
		[1.0.8 18-May-2004 marco@ladyreb.org {Suppression de la fonction default-soccer}]
		[1.0.9 09-Jul-2004 marco@ladyreb.org {Modification du code permettant d'avoir le client dans un context}]
		[1.1.0 14-Jul-2004 marco@ladyreb.org {Dernière correction (j'espère) pour le code dans le context}]
		[1.1.1 23-Jul-2004 marco@ladyreb.org {A small correction on the content-length header}]
		[1.1.2 24-Jul-2004 marco@ladyreb.org {English translation}]
		[1.1.3 01-Oct-2004 marco@ladyreb.org {serve/build refinement and micro bug correction}]
		[1.1.4 02-Oct-2004 marco@ladyreb.org {Suppress the /build refinement and apply always a compose to the do-script}]
		[1.1.5 02-Oct-2004 marco@ladyreb.org {Bug correction on stub building when type is block (compose/only)}]
		[1.1.6 11-Oct-2005 marco@ladyreb.org {Bug correction on stub building when type is lit-word}]
		[1.1.7 05-Dec-2005 marco@ladyreb.org {Major changes on stubs building and function execution}]
		[1.1.8 08-Dec-2005 marco@ladyreb.org {do-remote, try-remote and reduce-remote added}]
		[2.0.0 14-Dec-2005 marco@ladyreb.org {New release published on www.rebol.org}]
		[2.1.0 22-Dec-2005 marco@ladyreb.org {Enhanced request parsing for better control & security}]
		[2.1.1 23-Dec-2005 marco@ladyreb.org {Some bug correction}]
	]
	Defaults: {
		compress: true
		encloak: false
	}
	Usage: {
		In your script:
			- Write the functions you want to plublish and to be able to use remotly
			- If you want, write in a block also the client part of your application
			- initialize easy-soccer (do %easy-soccer.r)
			- invoke the serve function with the liste of the functions you authorize to access remotly
			  for example: serve [now]
			- If you publish also the client part of your application, use the refinement /do-script
			  for example serve/do-script [now] [print now]
			- You can also encrypt and/or compress the message between the client and the server by using the refinement /encloak and /compress
			  for example serve/do-script/compress/encloak [now] [print now] yes no
			- If you want to invoke many function in one remote call, use the do-remote, try-remote or reduce-remote function
			
		To run your script in a distributed mode:
			- within a script or within the console: do http://my.super.server/cgi-bin/my-super-script.cgi
			- to include the stubs in a un context ctx: context load do next load http://my.super.script/cgi-bin/my-super-script.cgi
			- whitin the plugin
				<OBJECT ID="RPluginIE" CLASSID="CLSID:9DDFB297-9ED8-421d-B2AC-372A0F36E6C5" 
					CODEBASE="http://www.rebol.com/plugin/rebolb5.cab#Version=0,5,0,0"
					WIDTH="800" HEIGHT="600"
				>
					<PARAM NAME="LaunchURL" VALUE="cgi-bin/my-super-script.cgi">
				</OBJECT>

		To run your script in a monolithic mode:
			- within a script or within the console: do %my-super-script.cgi
			- to include the stubs in a un context ctx: context load %my-super-script.cgi
			- whitin the plugin (no change from distributed env. if you use relative URL)
				<OBJECT ID="RPluginIE" CLASSID="CLSID:9DDFB297-9ED8-421d-B2AC-372A0F36E6C5" 
					CODEBASE="http://www.rebol.com/plugin/rebolb5.cab#Version=0,5,0,0"
					WIDTH="800" HEIGHT="600"
				>
					<PARAM NAME="LaunchURL" VALUE="cgi-bin/my-super-script.cgi">
				</OBJECT>
	}
]

; ***************
; Public function
; ***************

serve: none
do-remote: :do
reduce-remote: :reduce
try-remote: :try

	
; ******************************
; Context containing easy-soccer
; ******************************

make object! [

; **************
; Default values
; **************
	default: context [
		compress: true
		encloak: false
	]

; ************************************
; The serve function (public function)
; ************************************
	set 'serve func [
		{Exposes a set of function as a remote service and execute the request}
		'services  [word! block!]
			{The functions to expose}
		/do-script script [string! block! file! url!]
			{The script to run at the client}
		/compress compress-flag [logic!]
		/encloak encloak-flag [logic!]
		/local request response length err
	][
		either system/options/cgi/request-method [
			either equal? "GET" uppercase system/options/cgi/request-method [
				if error? err: try [
					response: build-client
						to block! services
						script
						either compress [compress-flag][default/compress]
						either encloak [encloak-flag][default/encloak]
						rejoin [http:// system/options/cgi/server-name ":" system/options/cgi/server-port system/options/cgi/script-name]
				][
					response: mold/only compose/deep [
						rebol [(either system/script/header [third system/script/header][[]])]
						to error! [(reduce bind copy/part at first err: disarm err 3 7 err)]
					]
				]
			][
				if error? err: try [
					length: to integer! system/options/cgi/content-length
					local: make string! (2 + length)
					while [0 < length] [
						length: length - read-io system/ports/input local length
					]
					response: execute-request local build-exec services
				][
					response: mold/all/only compose [
						(false)
						(disarm err)
						(false)
					]
				]
			]
			print [
				"Content-Type: text/text" newline
				"Content-Length:" length? response newline
				newline
				response
			]
		][
			if script [
				do compose load script
			]
		]
	]

; ****************************************
; Return the stubs and the client (if any)
; ****************************************
	build-client: func [
		exposed-services [block!]
		script [none! string! block! file! url!]
		compress-flag [logic!]
		encloak-flag [logic!]
		server [url!]
		/local response item base key
	][
		either script [
			if error? script: try [compose load script][
				return mold/only compose/deep [
					rebol [(either system/script/header [third system/script/header][[]])]
					to error! [(reduce bind copy/part at first script: disarm script 3 7 script)]
				]
			]
		][
			script: copy []
		]
		local: copy []
		response: copy [do-remote: reduce-remote: try-remote:]
		foreach item exposed-services [
			if not value? item [
				return mold/only compose/deep [
					rebol [(either system/script/header [third system/script/header][[]])]
					to error! (reform ["Serve error:" item "has no value"])

				]
			]
			append response to set-word! item
			local: compose [
				(local)
				(build-stub item)
			]
		]
		local: compose/deep [
			(local)
			(common)
			exec-remote: func [
				request [block!]
				/local binary-base response compress-flag encloak-flag 
			][
				compress-flag: (compress-flag)
				encloak-flag: (encloak-flag)
				if compress-flag or encloak-flag [
					request: mold/all/only request
					if compress-flag [request: compress request]
					if encloak-flag [request: encloak to binary! request to string! length? request]
				]
				binary-base: system/options/binary-base
				system/options/binary-base: 64
				set/any [
					compress-flag
					response
					encloak-flag
				] load send-request mold/all/only reduce [
					compress-flag
					request
					encloak-flag
				]
				system/options/binary-base: binary-base
				if compress-flag or encloak-flag [
					if encloak-flag [response: decloak response to string! length? response]
					if compress-flag [response: decompress response]
					set/any 'response load to string! response
				]
				if all [
					value? 'response object? response
					equal? [self code type id arg1 arg2 arg3 near where] first response
				][
					error? response: to error! reduce bind copy/part at first response 3 7 response
				]
				return get/any 'response
			]
			send-request: func [
				request [string!]
			][
				read/custom (server) reduce ['post request]
			]
		]
		either compress-flag or encloak-flag [
			local: insert mold/only local
			if not empty? script [script: mold/only script]
			item: copy []
			if compress-flag [
				local: compress local
				insert item 'decompress
				if not empty? script [script: compress script]
			]
			key: []
			if encloak-flag [
				key: checksum/secure to string! length? local
				local: encloak to binary! local key
				if not empty? script [script: encloak script key]
				insert tail item [decloak]
				key: reduce [key]
			]
			local: compose [
				bind load to string! (item) (local) (key) 'do-remote
			]
			if not empty? script [
				script: compose [
					do bind load to string! (item) (script) (key) 'do-remote
				]
			]
		][
			local: compose/only [(local)]
		]
		binary-base: system/options/binary-base
		system/options/binary-base: 64
		response: mold/only compose/deep [
			rebol [(either system/script/header [third system/script/header][[]])]
			(response) none
			context (local)
			(script)
		]
		system/options/binary-base: binary-base
		response
	]

	build-stub: func [
		f [word!]
		/local spec body item
	][
		either any-function? get f [
			compose/deep [
				set (to lit-word! f) func [
					(parse third get f [copy item [to /local | to end]] if none? item [item: []] item)
					/local item sub-item
					/no-exec
				][
					(compose/only [
						local: copy (to block! f)
						parse (first get f) [
							any [set item [word! | lit-word! | get-word!] (
								item: get item
								if word? :item [item: to lit-word! :item] ;;;???;;;
								insert/only tail local :item
							)]
							any [
								/local break
							|
								set item refinement! (
									item: bind item 'local
									if get item [insert tail local item]
									item: get item
								)
								any [
									set sub-item word! (if item [insert tail local get sub-item])
								]
							]
						]
						if no-exec [return local]
						exec-remote compose [try (local)]
					])
				]
			]
		][
			compose/deep [
				set (to lit-word! f) func [
					/no-exec
				][
					if no-exec [return (f)]
					exec-remote compose [try (f)]
				]
			]
		]
	]


	common: [
		set 'reduce-remote func [
			request [block!]
			/local  block
		][
			request: copy request
			local: copy [reduce]
			while [not empty? request][
				change/only request join to path! request/1 'no-exec
				set [block request] do/next request
				insert tail local block
			]
			exec-remote local
		]
		set 'do-remote func [
			request [block!]
		][
			try-remote request
		]
		set 'try-remote func [
			request [block!]
			/local
		][
			local: copy [try]
			while [not empty? request][
				set [block request] do/next compose [(append to path! first request 'no-exec) (next request)]
				insert tail local block
			]
			return exec-remote local
		]
	]

; *******************
; Execute the request
; *******************

	execute-request: func [
		request [string!]
		rule [block!]
		/local response item name compress-flag encloak-flag
	][
		set/any [
			compress-flag
			request
			encloak-flag
		] load request
		if compress-flag or encloak-flag [
			if encloak-flag [request: decloak request to string! length? request]
			if compress-flag [request: decompress request]
			request: load to string! request
		]
		bind rule 'local
		local: copy []
		if error? try [
			if not parse request [
				'try rule end (set/any 'response try local)
			|
				'reduce rule end (response: try [reduce local])
			][
				response: to error! reform ["Request error: Invalid request" mold request mold rule]
			]
		][
			response: disarm response
		]
		if compress-flag or encloak-flag [
			response: mold/all/only reduce [get/any 'response]
			if compress-flag [response: compress response]
			if encloak-flag [response: encloak to binary! response to string! length? response]
		]
		binary-base: system/options/binary-base
		system/options/binary-base: 64
		response: mold/all/only reduce [
			compress-flag
			get/any 'response
			encloak-flag
		]
		system/options/binary-base: binary-base
		response
	]

	build-exec: func [
		services [block!]
		/local
	][
		local: copy []
		foreach item services [
			either empty? local [
				local: build-rule item
			][
				local: compose [
					(local)
				|
					(build-rule item)
				]
			]
		]
		if not empty? local [
			local: compose/deep [
				any [(local)]
			]
		]
		local
	]

	build-rule: func [
		f [word!]
		/local item rule sub-rule word-rule arg-rule
	][
		either any-function? get f [
			arg-rule: [
				set item [word! | lit-word! | get-word!] (
					word-rule: either lit-word? item [
						[(insert/only tail local :item)]
					][
						[(if word? :item [item: to lit-word! item]
						insert/only tail local :item)]
					]
				)
				set item opt block! (
					item: either item [copy item][copy [any-type!]]
					forall item [
						if not head? item [
							item: insert item '|
						]
					]
					item: head item
					insert tail sub-rule compose/deep [
						set item [(item)]
						(word-rule)
					]
				)
				opt string!
			]
			rule: compose  [
				set item (to lit-word! f) (to paren! [
					insert tail local reduce [f: to path! item]
				])
			]
			sub-rule: copy []
			parse third get f [
				opt string!
				opt block!
				any arg-rule (
					insert tail rule sub-rule
				)
				any [
					/local to end
				|
					set item refinement! (sub-rule: compose [
						set item (item)
						(to paren! [insert tail f to word! item])
					])
					opt string!
					any arg-rule
					(insert tail rule compose/only [opt (sub-rule)])
				]
			]
		][
			rule: compose  [
				set item (to lit-word! f) (to paren! [
					insert tail local item
				])
			]
		]
		rule
	]
		
]
