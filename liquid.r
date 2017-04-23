rebol [
	title: "LIQUID - core dataflow programming engine."
	; -- basic rebol header --
	file: 		%liquid.r
	version:	0.6 ; bump.r 
	date: 		2006-11-01 ; bump.r 
	author:		"Maxim Olivier-Adlhoch"
	copyright:	"Copyright (c) 2004-2006 Maxim Olivier-Adlhoch"

	;-- slim parameters --
	slim-name: 	'liquid
	slim-prefix: none
	slim-version: 0.9.5.7
	
	
	;-- REBOL.ORG header --
	library: [
		level:          'advanced
		platform:       'all
		type:           [ module ]
		domain:         [ external-library scientific ]
		tested-under:   [win view 1.3.2 sdk 2.6.2]
		support:        "http://www.pointillistic.com/open-REBOL/moa/steel/liquid/index.html"
		license:        'MIT
	]


	;-- extended rebol header --
	purpose:	"Create procedural processing networks."
	notes:		"Needs STEEL|LIBRARY MANAGER (slim) package to be installed prior to usage."
	e-mail:		"moliad a-t aei d-o-t ca"
	license:    {Copyright (c) 2004-2006, Maxim Olivier-Adlhoch

		Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
		and associated documentation files (the "Software"), to deal in the Software without restriction, 
		including without limitation the rights to use, copy, modify, merge, publish, distribute, 
		sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
		is furnished to do so, subject to the following conditions:
		
		The above copyright notice and this permission notice shall be included in all copies or 
		substantial portions of the Software.}
		
	disclaimer: {THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
		INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
		PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
		FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ]
		ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
		THE SOFTWARE.}
	
	to-do: {
		-----------------
		NOTE - probably not be up to date or even valid:
		-----------------
		-link() does not consider pipes as exclusive connections.. pipe connections should always operate
		 in exclusive mode, so at the top of the func, it should enable "/exclusive" for pipes. 
		 must debug/test this whole procedure within liquid.
		-support string! on link() and unlink() label modes?
		-link()/attach (link to subordinate's pipe) TO DO
		-add more return values to functions like link, fill and connect, to allow interactive reactions to failed operations...
		-propagate any state, not just dirty. (ex: error)
		-make ALL func tails (returns) GC friendly
		-make "fast" version of lib: no vprint, no GC cleanup.
		-support label being present in list more than once (complements exclusive wrt labeled linking mode)
		-once piped, a plug should not become dirty, unless its pipe is dirty.  It should ignore any dirty
		 calls comming from its (temporarily useless) subordinates.
		-when attaching two piped plugs, add a callback to allow a pipe server to de-allocate itself safely when it detects it has no more pipe clients.
	}
	
	history: {
	
	v0.5.1
		-finalise new piping and mud mechanism
		
	v0.5.2
		-link()/exlusive implementation

	v0.5.3
		-add /as to liquify
		
	v0.5.4
		-add stats method to valve.
		-fully test and enable labeled mode for linking
		-add valve/links/labels
		-add valve/links/labeled
		-finish block optimisation in instigate returning all subordinate values directly.
		
	v0.5.5 - 24-Apr-2006/13:13:13
		-added disregard
		-rebuilt unlink using disregard (cause v0.5.4 didn't unlink observers! MAJOR BUG)
		-link() should return an error when trying to link a pipe server using /label (not likely, but for advanced users this must be explicitely disallowed)
		-support multiple plugs per label

	v0.5.6 - 26-Apr-2006/11:14:34
		-added /fill refinement to liquify

	v0.5.7 - 27-Apr-2006/3:35:39
		-removed all double comments (;;) from code
		-improved comments on valve/setup and explicitely state that we can call link at that point.
		-added valve/sub()
		-cycle? now officially part of miscelaneous methods
		-added /link refinement to liquify


	v0.5.8 - 29-Apr-2006/14:31:40
		-verbose is now off by default, from now on.


	v0.5.9 - 29-Apr-2006/15:02:55
		-fix dirty? state return valur of purify.
		-fixed propagate as a result of above fix


	v0.5.10 - 24-May-2006/17:07:43
		-added category to valve.  helps in classification.
		-removed init as default startup state, easy to forget and invalidates dirtyness by default..
		 better let the user toggle it on knowingly  :-)

	v0.5.11 - 5-Oct-2006/2:27:14
		-renamed plug! to !plug (no clash with real types)
		-officially added !node alias to !plug (to ease adoption)
		-liquify/link properly support single plug! spec (it used to support only a block of plugs)
		-added linked-container attribute to !plug
		-fill now creates a container (simple pipe) rather than a pipe (linked pipe) by default.
		-added word! clash protection on link labels, so that instigate code can separate labels from actual word! type data (not 100% fault tolerant, but with documentation, it becomes easy to prevent).

	v0.5.12 - 17-Oct-2006/11:58:09
		-license switch to MIT

	v0.5.13 - 20-Oct-2006/5:31:44
		-attach() pipe linking method
		-detach() pipe unlinking method
		-added support for a block! of subordinates in link utility func.

	v0.6.0 - 1-Nov-2006/11:19:29 (MOA)
		-quick release cleanup.
		-version major

	v$bump-version - $bump-date/$bump-time ($bump-user)


	$bump-source[v$bump-v - $bump-d/$bump-t ($bump-u)]
		
	}
]

;----
; use following line to determine real code size without comments.
;-----
; save %/c/dev/stripped-liquid.r load %/C/dev/projects/liquid/libs/liquid.r



slim/register [

	verbose: false

	; next sid to assign to any liquid plug.
	; and also tells you how many plugs have been registered so far.
	liquid-sid-count: 0


	;-----------------------------------------
	;-     alloc-sid
	;-----------------------------------------
	; currently the sid is a simple number, but
	; could become something a bit stronger in time,
	; so this allows us to eventually change the system without
	; need to change any plug generating code.
	;-----------------------------------------
	alloc-sid: func [][
		liquid-sid-count: liquid-sid-count + 1
	]





	;-
	;-----------------------
	;- FUNCTIONS!
	;-----------------------
	;-----------------------
	;-     liquify
	;-----------------------
	liquify: func [
		type "Plug class object."
		/with spec "Attributes you wish to add to the new plug ctx."
		/as valve-type "shorthand to derive valve as an indepent from supplied type, this sets type/valve/type"
		/fill data "shortcut, will immediately fill the liquid right after its initialisation"
		/link plugs [block! object!]
		/label lbl [word!] "specify label to link to (no use unless /link is also provided)"
		/local plug
	][
		spec: either none? spec [[]][spec]
		
		; unify plugs datatype
		plugs: compose [(plugs)]

		unless none? plugs [
			plugs: reduce plugs
		]
		
		if as [
			spec: append copy spec compose/deep [valve: make valve [type: (to-lit-word valve-type)]]
		]
		plug: make type spec
		plug/valve/init plug
		
		if fill [
			plug/valve/fill plug data
		]
		if link [
			forall plugs [
				either lbl [
					plug/valve/link/label plug first plugs lbl
				][
					plug/valve/link plug first plugs
				]
			]
		]
		
		return first reduce [plug plug: plugs: data: none] ; clean GC return
	]

	;-----------------------------------------
	;-     true?
	;-----------------------------------------
	true?: func [value][value = true]


	;------------------------------
	;-     count 
	;---
	while*: get in system/words 'while
	count: func [;
		series [series!]
		value
		/while wend
		/until uend
		/within min "we must find at least one value before hitting this index, or else we return 0"
		/local counter i item
	][
		counter: 0
		i: 0
		while* [ 
			(not tail? series)
		][
			i: i + 1
			if find item: copy/part series 1 value [
				counter: counter + 1
			]
			; check if we hit the end condition once we started counting value
			if all [while counter > 0] [
				if not find item wend [
					series: tail series
				]
			]
			; check if we hit the end condition once we started counting value
			if all [until counter > 0] [
				if find item uend [
					series: tail series
				]
			]
			
			; are we past minimum search success range?
			if all [
				within
				counter = 0
				i >= min
			][
				series: tail series
			]
				
			
			series: next series
		]
		
		counter
	];

	
	;-----------------------------------------
	;-     fill
	;-----------------------------------------
	fill: func [
		"shortcut for a plug's fill method"
		plug [object!]
		value
	][
		plug/valve/fill plug value
	]
	

	;-----------------------------------------
	;-     content
	;-----------------------------------------
	content: func [
		"shortcut for a plug's content method"
		plug [object!]
	][
		plug/valve/cleanup plug
	]
	


	;-----------------------------------------
	;-     link
	;-----------------------------------------
	link: func [
		"shortcut for a plug's link method"
		observer [object!]
		subordinate [object! block!]
		/label lbl 
		/local blk
	][
		blk: compose [(subordinate)]
		foreach subordinate blk [
			either label [
				observer/valve/link/label observer subordinate lbl
			][
				observer/valve/link observer subordinate
			]
		]
	]
	




	;-  
	;-----------------------
	;- !PLUG
	;-----------------------
	!node: !plug: make object! [
		;------------------------------------------------------
		;-    VALUES
		;------------------------------------------------------
		
		;-----------------------------------------
		;-       sid:
		;-----------------------------------------
		; a unique serial number which will never change
		;-----------------------------------------
		sid: 0	; (integer!)
		
		
		
		;-----------------------------------------
		;-       observers:
		;-----------------------------------------
		; who is using ME (none or a block)
		;-----------------------------------------
		observers: none
		
		
		;-----------------------------------------
		;-       subordinates:
		;-----------------------------------------
		; who am I using  (none or a block)
		;-----------------------------------------
		subordinates: none
		
		
		;-----------------------------------------
		;-       dirty?:
		;-----------------------------------------
		; has any item above me in the chain changed?
		; some systems will always have this set to false,
		; when they process at each change instead of deffering eval.
		;
		; when plugs are new, they are obviously dirty.
		dirty?: True
		
		
		;-----------------------------------------
		;-       stainless?:
		;-----------------------------------------
		; This forces the container to automatically regenerate content when set to dirty!
		; thus it can never be dirty...
		;
		; used sparingly this is very powerfull, cause it allows the end of a procedural
		; tree to be made "live".  its automatically refreshed, without your intervention :-)
		;-----------------------------------------
		stainless?: False
		
		
		;-----------------------------------------
		;-       pipe?:
		;-----------------------------------------
		;
		; pipe? is used to either determine if this liquid IS a pipe or if it is connected to one.
		;
		; v0.5.1 change: now support 'simple  as an alternative plug mode, which allows us to fill data
		; in a plug without actually generating/handling a pipe connection.  The value is simply dumped
		; in plug/liquid and purify may adapt it as usual
		;
		; This new behaviour is called containing, and like piping, allows liquids to store data
		; values instead of only depending on external inputs.
		;
		; This property will also change how various functions react, so be sure not to play around
		; with this, unless you are sure of what you are doing.
		;
		; by setting pipe? to True, you will tell liquid that this IS a pipe plug.  This means that the plug
		; is responsible for notifying all the subordinates that its value has changed.
		; it uses standard liquid procedures to alert piped plugs that its dirty, and whatnot.
		;
		; By setting this to a plug object, you are telling liquid that you are CONNECTED to a 
		; pipe, thus, our fill method will send the data to IT.
		;
		; note that you can call fill directly on a pipe, in which case it will fill its pipe clients
		; normally.
		;
		; also, because the pipe IS a plug, you can theoretically link it to another plug, but this 
		; creates issues which are not designed yet, so this useage is not encouraged, further 
		; versions might specifically handle this situation by design.
		;
		;-----------------------------------------
		pipe?: none
		
		;-----------------------------------------
		;-       mud:
		;-----------------------------------------
		; stores manually filled values
		mud: none
		
		;-----------------------------------------
		;-       liquid:
		;-----------------------------------------
		; stores processing results (cached process) makes all the network lightyears faster.
		; this is set by the content method using the return value of process
		liquid: none
		
		
		;-----------------------------------------
		;-       shared-states:
		;-----------------------------------------
		; this is a very special block, which must NOT be replaced arbitrarily.
		; basically, it allows ALL nodes in a liquid session to extremely 
		; efficiently share states.
		;
		; typical use is to prevent processing in specific network states
		; where we know processing is useless, like on network init.
		;
		; add  'init to the shared-states block to prevent propagation whenever you are
		; creating massive amounts of nodes. then remove the init and call dirty on all input nodes
		;
		; the instigate func and clear func still work.  they are just
		; not called in some circumstances.
		;
		; making new !plugs with alternate shared-states blocks, means you can separate your
		; networks, even if they share the same base clases.
		;-----------------------------------------
		shared-states: []
		
		
		;-----------------------------------------
		;-       linked-container:
		;-----------------------------------------
		; if set to true, this tells the processing mechanisms that you wish to have both 
		; the linked data AND mud, which will be filtered, processed and whatever 
		; the mud will always be the last item on the list.
		linked-container: false
		
		
		
		
		
		;------------------------------------------------------
		;-    VALVE (class)
		;------------------------------------------------------
		valve: make object! [
			;--------------
			; class name (should be word)
			;-        type:
			type: '!plug
			
			;--------------
			; used to classify types of liquid nodes.
			;-        category:
			category: '!plug
	
			
			;-      miscelaneous methods

			;---------------------
			;-        cycle?()
			;---------------------
			; check if a plug is part of any of its subordinates
			;---------------------
			cycle?: func [
				"checks if a plug is part of its potential subordinates, and returns true if a link cycle was detected. ^/^-^-If you wish to detect a cycle BEFORE a connection is made, supply observer as ref plug and subordinate as plug."
				plug "the plug to start looking for in tree of subordinates" [object!]
				/with "supply reference plug directly"
					refplug "the plug which will be passed along to all the subordinates, to compare.  If not set, will be set to plug" [block!]
				/debug "step by step traversal of tree for debug purposes, should only be used when prototyping code"
				/local cycle? index len
			][
				vin ["liquid/"  type  "[" plug/sid "]/cycle?" ]
				cycle?: false
				if debug [
					if refplug [
						vprint ["refplug/sid: " refplug/sid ]
					]
				]

				; is this a cycle?
				either (same? plug refplug) [
					vprint/always "liquid data flow engine Detected a connection cycle!"
					cycle?: true
				][

					if none? refplug [
						refplug: plug
					]

					;does this plug have subordinates
					if plug/valve/linked? plug [
						if debug [
							ask "press enter to move on cycle check to next subordinate"
						]
						index: 1
						len: length? plug/subordinates

						until [
							cycle?: plug/subordinates/:index/valve/cycle?/with plug/subordinates/:index refplug
							index: index + 1
							any [
								cycle?
								index > len
							]
						]
					]
				]

				refplug: plug: none

				vout

				cycle?
			]

			;---------------------
			;-        stats()
			;---------------------
			stats: func [
				"standardized function which print data about a plug"
				plug "plug to display stats about" [object!]
				/local lbls item vbz labels
			][
				vin/tags  ["liquid/"  type  "[" plug/sid "]/stats" ] [!plug stats]
				vprint/tags "================" [!plug stats]
				vprint/tags "PLUG STATISTICS:" [!plug stats]
				vprint/tags "================" [!plug stats]
				vprint/tags ["LABELING:"] [!plug stats]
				vprint/tags "---" [!plug stats]
				vprint/tags [ "type:      " plug/valve/type ] [!plug stats]
				vprint/tags [ "serial id: " plug/sid] [!plug stats]
				vprint/tags "" [!plug stats]
				vprint/tags ["LINKEAGE:"] [!plug stats]
				vprint/tags "---" [!plug stats]
				vprint/tags ["total links: " count plug/subordinates object! ] [!plug stats]
				if find plug/subordinates word! [
					vbz: verbose
					verbose: false
					lbls: plug/valve/links/labels plug
					labels: copy []
					foreach item lbls [
						append labels item
						append labels rejoin ["("  plug/valve/links/labeled plug item ")"]
					]
					verbose: vbz
					vprint/tags ["labeled links:  (" labels ")"] [!plug stats]
				]
				vprint/tags "================" [!plug stats]
				vout/tags [!plug stats]
			]


			;-      construction methods

			;---------------------
			;-        init()
			;---------------------
			; called on every new !plug, of any type.
			;
			;  See also:  SETUP, CLEANSE, DESTROY
			;---------------------
			init: func [
				plug "plug to initialize" [object!]
			][
				plug/sid: alloc-sid
				vin ["liquid/"  type  "[" plug/sid "]/init" ]
				plug/observers: copy []
				plug/subordinates: copy []

				setup plug
				cleanse plug

				; allow per instance init, if that plug type needs it.  Use as SPARINGLY as possible.
				if in plug 'init [
					plug/init
				]
				vout
			]
			

			;---------------------
			;-        setup()
			;---------------------
			;  IT IS ILLEGAL TO CALL SETUP IN YOUR CODE.
			;
			; called on every NEW plug of THIS class when plug is created.
			; for any recyclable attributes, also implement them in cleanse.
			; This function is called by valve/init directly.
			;
			; At this point, the object is valid wrt liquid, so we can already
			; call valve methods on the plug (link, for example)
			;
			;  See also:  INIT, CLEANSE, DESTROY
			;---------------------
			setup: func [
				plug [object!]
			][
				vin ["liquid/"  type  "[" plug/sid "]/setup" ]
				vout
			]


			;---------------------
			;-        cleanse()
			;---------------------
			; use this to reset the plug to a neutral and default value. could also be called reset.
			; this should be filled appropriately for plugs which contain other plugs, in such a case,
			; you should cleanse each of those members if appropriate.
			;
			; This is the complement to the setup function, except that it can be called manually
			; by the user within his code, whenever he wishes to reset the plug.
			;
			; init calls cleanse just after setup, so you can put setup code here too or instead. remember that cleanse can
			; be called at any moment whereas setup will only ever be called ONCE.
			;
			; optionally, you might want to unlink the plug or its members.
			;
			;  See also:  SETUP, INIT, DESTROY
			;---------------------
			cleanse: func [
				plug [object!]
			][
				vin ["liquid/"  type  "[" plug/sid "]/cleanse" ]

				plug/mud: none
				plug/liquid: none

				; cleanup pointers
				plug: none
				vout
			]



			;------------------------
			;-        destroy()
			;------------------------
			; use this whenever you must destroy a plug.
			; destroy is mainly used to ensure that any internal liquid is unreferenced in order for the garbage collector
			; to be able to properly recuperate any latent liquid.
			;
			; after using destroy, the plug is UNUSABLE. it is completely broken and nothing is expected to be usable within.
			; nothing short of calling init back on the plug is expected to work (usually completely rebuilding it from scratch) .
			;
			;  See also:  INIT SETUP CLEANSE
			;------------------------
			destroy: func [
				plug [object!]
			][
				plug/valve/unlink plug
				plug/mud: none
				plug/liquid: none
				plug/subordinates: none
				plug/observers: none
			]



			;-      plug connection methods
			;---------------------
			;-        link?()
			;---------------------
			; validate if plug about to be linked is valid.
			; default method simply refuses if its already in our subordinates block.
			;---------------------
			link?: func [
				observer [object!] "plug about to perform link"
				subordinate [object!] "plug which wants to be linked to"
			][
				vin ["liquid/"  type  "(" observer/sid ")/link?" ]

				; basic plugs accepts all connection which are not the same plug
				; BE CARFULL, THIS MEANS THAT INFINITE CYCLES ARE ALLOWED
				
				;(not found? find observer/subordinates subordinate)
				vout/return vprobe
				(observer <> subordinate)
			]




			;---------------------
			;-        link()
			;---------------------
			; link to a plug (of any type)
			;
			; v0.5
			; if subordinate is a pipe, we only do one side of the link.  This is because 
			; the oberver connects to its pipe (subordinate) via the pipe? attribute.
			;
			; v0.5.4
			; we now explicitely allow labeled links and even allow them to be orphaned.
			; so we support  0-n number of links per label
			;---------------------
			link: func [
				observer [object!] "plug which depends on another plug, expecting liquid"
				subordinate [object! none!] "plug which is providing the liquid. none is only supported if label is specified."
				/label lbl [word! string!] "the label you wish to use if needing to reference plugs by name. labels are always exclusive, meaning you can only have any label only once within your subordinates."
				/exclusive  "Is the connection exclusive (will disconnect already linked plugs), cooperates with /label refinement"
				/limit max [integer!] limit-mode [word!] "<FIXME> NOT DONE YET !!! maximum number of connections to perform and how to react when limit is breached"
				/local subordinates labeled? plug
			][
				vin ["liquid/"  type  "(" observer/sid ")/link" ]
				vout/return 
				
				either link? observer subordinate [
					
					
					; in exclusive or labeled mode, only connect one thing at a time 
					; (this should eventually be expanded to support /limit count.
					any [
						all [ exclusive label (unlink/only observer lbl true)]
						all [ exclusive (unlink observer true)]
					]
					
					either true? subordinate/pipe? [
						vprint "==================================="
						vprint ["ATTEMPTING TO LINK A !PLUG [" observer/sid "] TO A PIPE SERVER[" subordinate/sid"]"]
						if label [to-error "liquid/link(): CANNOT LINK PIPE SERVERS USING /label REFINEMENT"]
							
						; we don't link anything here, since the pipe? attribute is where we connect
						; our pipe.  but we use the pipe? attribute to remember who we are listening to.
						; this setup allows us to keep our connections intact while using piped data
						; temporarily, automatically reverting to a linked setup if we disconnect from
						; the pipe!
						observer/pipe?: subordinate ; plug that it is connected to a pipe

					][
						either label [
							subordinates: any [
								all [subordinates: labeled?: find/tail observer/subordinates lbl
									find subordinates word!]
							 	tail observer/subordinates
							]
							
							unless labeled? [
								insert subordinates lbl
								subordinates: next subordinates
							]
							
							insert subordinates subordinate
							subordinates: labeled?: none
						][
							append observer/subordinates subordinate
						]
					]
					
					append subordinate/observers observer

					
					;unless find observer/shared-states 'init [
						; getting linked should force an observer refresh
						dirty observer
					;]

					true
				][
					false
				]
			]


			;---------------------
			;-        linked?
			;---------------------
			; is a plug observing another plug? (is it dependent on a plug? other)
			; 
			;---------------------
			linked?: func [
				plug "plug to verify" [object!]
			][
				vin ["liquid/"  type  "[" plug/sid "]/linked?" ]
				vout/return	vprobe true? any [
					not empty? plug/subordinates
					object? plug/pipe?
				]
			]


			;---------------------
			;-        sub
			;---------------------
			; returns specific links from our subordinates
			;---------------------
			sub: func [
				plug [object! block!]
				/labeled label [word!]
				;/start sindex
				;/end eindex
				;/part amount
				/local amount blk src-blk
			][
				src-blk: any [
					all [block? plug plug]
					plug/subordinates
				]	
				
				either labeled [
					either labeled: find/tail src-blk label [
						unless amount: find labeled word! [ ; till next label or none (till end).
							amount: tail labeled
						]
						blk: copy/part labeled amount ; if they are the same, nothing is copied
					][
						blk: none
					]
				][
					blk: none
				]
				return first reduce [blk src-blk: labeled: amount: blk: none]
			]


			;---------------------
			;-        links
			;---------------------
			; returns the number of plugs we are observing
			;---------------------
			links: func [
				plug [object!] "the plug you wish to scan"
				/labeled lbl [word!] "return only the number of links for specified label"
				/labels "returns linked plug labels instead of link count"
				/local at lbls
			][
				vin ["liquid/"  type  "(" plug/sid ")/links" ]
				vout/return either labels [
					either find plug/subordinates word! [
						foreach item plug/subordinates [
							if word! = (type? item) [
								lbls: any [lbls copy []]
								append lbls item
							]
						]
						lbls
					][none]
				][
					either labeled [
						either (at: find plug/subordinates lbl) [
							; count all objects until we hit something else than an object if and only if we find an object just past the label
							count/while/within at object! object! 2
						][
							; none is returned if the label is not in list
							none
						]	
					][
						count plug/subordnates object!
					]
				]
			]





			;---------------------
			;-        unlink
			;---------------------
			; unlink myself
			; by default,  we will be unlinked from ALL our subordinates.
			;
			; note that as of v5.4 we support orphaned labels. This means we can have labels
			; with a count of 0 as their number of plugs.  This is in order to keep evaluation
			; and plug ordering intact even when replacing plugs.  many tools will need this, 
			; since order of connections can influence processing order in some setups.
			;
			; v.0.5.5 now returns the plugs it unlinked, makes it easy to unlink data, filter plugs
			;         and reconnect those you really wanted to keep.
			;---------------------
			unlink: func [
				plug [object!]
				/only oplug [object! integer! word!] "unlink a specifc plug... not all of them.  Specifying a word! will switch to label mode!"
				/part amount [integer!] "Unlink these many plugs, default is all.  /part is only handled along with /only,  the /only acts as a start point (if object! or integer!) or bounds (when word! label is given)."
				/label "actually delete the label itself if /only 'label is selected and we end up removing all plugs."
				/local blk subordinate count rval
			][
				vin ["liquid/"  type  "(" plug/sid ")/unlink" ]
				
				
				if linked? plug [
					rval: copy []
					if not part [
						amount: 1
					]
					either only [
						switch type?/word oplug [
							object! [
								if found? blk: find plug/subordinates oplug [
									rval: disregard/part plug blk amount
								]
							]

							integer! [
								; oplug is an integer
								; we should not be using labels in this case.
								rval: disregard/part plug (at plug/subordinates oplug) amount
							]

							word! [
								if subordinate: find plug/subordinates oplug [
									vprint ["UNLINKING LABEL!:" oplug]
									lblcount: links/labeled plug oplug
									either part [
										; cannot remove more plugs than there are, can we :-)
										amount: min amount lblcount
									][
										; remove all links 
										amount: lblcount
									]
									
									; in any case, we can only remove the label if all links would be removed
									either all [
										label
										amount >= lblcount
									][
										; we must remove label and all its links
										remove subordinate
										rval: disregard/part plug subordinate amount
									][
										; remove all links but keep the label.
										; amount could be zero, in which case nothing happens.
										rval: disregard/part plug next subordinate amount
									]
								]
							]

						]
					][
						; tell all subordinates to stop observing us
						foreach subordinate plug/subordinates [
							if object? subordinate [
								if (found? blk: find subordinate/observers plug) [
									remove blk
								]
								vprint ["Unlinked from plug (" subordinate/sid ")"]
							]
							append rval subordinate
						]
						; unlink ourself from all those subordinates
						clear head plug/subordinates
					]

					dirty plug
				]
				oplug: none
				plug: none
				vout
				rval
			]





			;---------------------
			;-        disregard
			;---------------------
			; this is a complement to unlink.  we ask the engine to remove the observer from
			; the subordinate's observer list, if its present.
			;
			; as an added feature, if the supplied subordinate is within a block, we
			; remove it from that block.
			;---------------------
			disregard: func [
				observer [object!]
				subordinates [object! block!]
				/part amount [integer!] "Only if subordinate is a block!, if amount is 0, nothing happends."
				/local blk iblk subordinate
			][
				vin/tags ["liquid/"  type  "(" observer/sid ")/disregard" ] [liquid !plug disregard]
				either block? subordinates [
					subordinates: copy/part iblk: subordinates any [amount 1]
					remove/part iblk length? subordinates
				][
					subordinates: reduce [subordinates]
				]
				
				foreach subordinate subordinates [
					either object? subordinate [
						vprint ["plug " subordinate/sid " disregarding " observer/sid ]
						either (found? blk: find subordinate/observers observer) [
							remove blk
						][
							to-error rejoin ["liquid/"  type  "[" plug/sid "]/disregard: not observing specified subordinate ( " subordinate/sid ")" ]
						]
					][
						to-error rejoin ["liquid/"  type  "[" plug/sid "]/disregard: supplied subordinates must be or contain objects." ]
					]
				]
				blk: observer: subordinate: iblk: none
				vout/tags [liquid disregard !plug]
				subordinates
			]








			;-      piping methods



			;---------------------
			;-        new-pipe()
			;---------------------
			; create a new pipe plug.
			; This is a method, simply because we can easily change what kind of 
			; plug is generated in derived liquid classes.
			;---------------------
			new-pipe: func [
				plug [object!]
				/local newplug
			][
				vin/tags ["liquid/"  type  "(" plug/sid ")/new-pipe" ] [!plug new-pipe]
				; unlink plug ; we keep our connections but don't react to them anymore
				newplug: make !plug [self/valve/init self]
				newplug/pipe?: true ; tells new plug that IT is a pipe server
				link plug newplug ; we want to be aware of pipe changes. (this will also connect the pipe in our pipe? attribute)
				vout/tags [!plug new-pipe]
				return first reduce [newplug newplug: none]
			]




			;---------------------
			;-        pipe()
			;---------------------
			;---------------------
			pipe: func [
				"return pipe which should be filled (if any)"
				plug [object!] ; plug to get pipe plug from
				/always "Creates a pipe plug if we are not connected to one"
			][
				vin/tags ["liquid/"  type  "(" plug/sid ")/pipe" ] [!plug pipe]
				vout/tags/return [!plug pipe] any [
					all [(object? plug/pipe?) plug/pipe?]
					all [(plug/pipe? = true) plug]
					all [(plug/pipe? = 'simple) plug]
					all [always new-pipe plug]
				]
			]


			;---------------------
			;-        attach()
			;---------------------
			; this is the complement to link, but specifically for piping.
			;---------------------
			attach: func [
				""
				observer [object!] "The plug we wish to start being piped, can be currently piped or not"
				subordinate [object!] "The plug which will be providing the pipe.  If it currently has one, it will be asked to create one, per its current pipe callback"
				/local plug
			][
				vin/tags ["liquid/"  type  "[" observer/sid "]/attach() to: [" subordinate/sid "]"] [attach]
				
				;check if observer isn't currently piped into something
				observer/valve/detach observer
				
				; get the pipe we should be attaching to
				plug: subordinate/valve/pipe/always subordinate
				
				; actually do the connection between them
				observer/valve/link observer plug
				vout/tags [attach]
			]


			;---------------------
			;-        detach()
			;---------------------
			;--------------------
			detach: func [
				"Unlink ourself from a pipe, causing it to stop messaging us (propagating)."
				plug [object!]
				/local pipe
			][
				vin/tags ["liquid/"  type  "[" plug/sid "]/detach()"] [detach]
				if object? plug/pipe? [
					if pipe: find plug/pipe?/observers plug [
						remove pipe
					]
					plug/pipe?: none
				]
				vout/tags [detach]
				pipe: plug: none
			]

			;---------------------
			;-        fill()
			;---------------------
			; If plug is not linked to a pipe, then it 
			; automatically connects itself to a new pipe.
			;---------------------
			fill: func [
				"Fills a plug with liquid directly. (stored as mud until it gets cleaned.)"
				plug [object!]
				mud ; data you wish to fill within plug's pipe
				/pipe "tells the engine to make sure this is a pipe, only needs to be called once.  Once called, it will automatically react as such."
				/local newplug fplug changed?
			][
				vin ["liquid/"  type  "(" plug/sid ")/fill" ]

				; revised default method creates a container type plug, instead of a pipe.
				; useage indicates that piping is not always needed, and creates a processing overhead
				; which is noticeable, in that by default, two nodes are created and filling data needs
				; to pass through the pipe.  in most filling ops, this is not usefull, as all the
				; plus is used for is storing a value.
				;
				; a second reason is that from now on a new switch is being added to the plug,
				; so that plugs can be containers and still be linked.  this can simply many types
				; of networks, since networks, often are refinements of prior nodes.  so in that optic,
				; allowing us to use data and then modifying it according to local data makes
				; a lot of sense.
				either any [
					pipe 
					plug/pipe?
				][
					; get the plug we need to fill... current or new
					plug: self/pipe/always plug
				][
					; convert this plug into a container
					plug/pipe?: 'simple
				]
				plug/mud: mud
				dirty plug
				vout/return mud
			]







			;-      computing methods

			;---------------------
			;-        dirty
			;---------------------
			; react to our link being set to dirty.
			; if the special shared-state contains init, no propagation occurs.
			;---------------------
			dirty: func [
				plug "plug to set dirty" [object!]
				/always "do not follow stainless? as dirty is being called within a processing operation.  prevent double process, deadlocks"
			][
				vin/tags ["liquid/"  type  "[" plug/sid "]/dirty" ] [!plug dirty]
				plug/dirty?: true

				; being stainless? forces a cleanup call right after being set dirty...
				; use this sparingly as it increases average processing and will slow
				; down your code by forcing every plug to process all the time which
				; is not needed when using cleanup method smartly.
				;
				; it can be usefull to set a user observed plug so that any
				; changes to the plugs, gets refreshed in an interactive UI..
				unless find plug/shared-states 'init [
					if plug/stainless? [
						if not always [
							cleanup plug
						]
					]
					propagate plug
				]
				; clean up
				plug: none
				vout/tags [!plug dirty]
			]





			;---------------------
			;-        instigate
			;---------------------
			; following method does not cause subordinate processing if they are clean :-)
			; very computationaly eFishAnt (tm)Steve Shireman
			;---------------------
			instigate: func [
				"Force each subordinate to clean itself, return block of values of all connections or pipe."
				plug [object!]
				/local subordinate blk
			][
				vin/tags ["liquid/"  type  "[" plug/sid "]/instigate" ] [!plug instigate]
				blk: copy []
				if linked? plug [
					;-------------
					; piped plug
					either object? plug/pipe? [
						; ask pipe server to process itself
						append/only blk (plug/pipe?/valve/cleanup plug/pipe?)
					][
						;-------------
						; linked plug
						; force each input to process itself.
						foreach subordinate plug/subordinates [
							either object? subordinate [
								append/only blk  subordinate/valve/cleanup subordinate
							][
								either word? subordinate [
									; here we make the word pretty hard to clash with. Just to make instigation safe.  otherwise non-obvious word clashes might occur, when actual data returned by links are words
									append/only blk to-word rejoin ['! subordinate '!] 
								][
									to-error rejoin ["liquid sid: [" plug/sid "] subordinates block cannot contain data of type: " type? subordinate]
								]
							]
						]
					]
					
					; clean up
					subordinate: none
					plug: none
				]
				; clean return
				vout/tags [!plug instigate]
					
				first reduce [blk blk: none]
			]





			;---------------------
			;-        propagate
			;---------------------
			; cause observers to become dirty
			;---------------------
			propagate: func [
				plug [object!]
				/local tmpplug
			][
				vin/tags ["liquid/"  type  "[" plug/sid "]/propagate" ] [ !plug propagate]
				; tell our observers that we have changed
				; some plugs will then process (stainless), other will
				; just acknowledge their dirtyness and return.
				;
				; v0.5 change
				; do not dirty the node if it is piped and we are not its pipe.
				foreach tmpplug plug/observers [
					either tmpplug/pipe? [
						either (same? tmpplug/pipe? plug) [
							tmpplug/valve/dirty tmpplug
						][
							vprint/tags ["ignoring piped observer["tmpplug/sid"], we are not observer's pipe"] [ !plug propagate]
						]
					][
						tmpplug/valve/dirty tmpplug
					]
				]
				plug:none
				tmpplug: none
				vout/tags [!plug propagate]
			]


			;---------------------
			;-        filter
			;---------------------
			; this is a very handy function which influences how a plug processes.
			;
			; basically, the filter analyses any expectations about input connection(s).  by looking at the 
			; instigated values block it receives.
			;
			; it will then return a block of values, if expectations are met. Otherwise, 
			; it returns none and computing does not occur afterwards.
			;
			; note that you are allowed to change the content of the block, by adding values, removing,
			; changing them, whatever.  The only requirement is that process must use the filtered values as-is.
			;
			; note that if a plug is piped, this function is never called.
			;
			; eventually, returning none might force purify to propagate the stale state to all dependent plugs
			;---------------------
			filter: func [
				plug [object!] "plug we wish to handle."
				values [block!] "values we wish to filter."
				/local tmpplug
			][
				vin/tags ["liquid/"  type  "(" plug/sid ")/filter" ] [!plug filter]
				if plug/pipe? [to-error "FILTER() CANNOT BE CALLED ON A PIPED NODE!"]
					
				; Do not forget that we must return a block, or we wont process.
				;
				; <FIXME>:  add process cancelation in this case (propagate stale?) .
				vout/return/tags values [!plug filter]
			]




			;---------------------
			;-        process
			;---------------------
			; process the plug's liquid
			;---------------------
			process: func [
				plug [object!]
				values [block!] "filtered and ultimately valid data"
			][
				vin/tags ["liquid/"  type  "(" plug/sid ")/process" ] [!plug process]

				vprint "LOADING VALUE FROM SUBORDINATE"
				; get our subordinate's liquid
				plug/liquid: values/1

				vout/tags [!plug process]
				plug/liquid
			]





			;---------------------
			;-        purify
			;---------------------
			; purify is a handy way to fix the filled mud, piped data, or recover from a failed process.
			; basically, this is the equivalent to a filter, but AFTER all processing occurs.
			;
			; we can expect plug/liquid to be processed or in an error state, if anything failed.
			;
			; when the plug is a pipe server, then its a chance to stabilise the value before propagating it 
			; to the pipe clients.  This way you can even nullify the fill and reset yourself 
			; to the previous (or any other value).
			;
			; eventually, purify will propagate the stale status to all dependent plugs if it is not
			; able to recover from an error, like an unfiltered node or erronous piped value for this plug.
			;
			; Note that the stale state can be generated within purify if its not happy with the current value
			; of liquid, even if it was called without the /stale refinement.
			;
			; we RETURN if this plug can be considered dirty or not at this point. 
			;---------------------
			purify: func [
				plug [object!]
				/stale "Tells the purify method that the current liquid is stale and must be recovered or an error propagated"
			][
				vin/tags ["liquid/"  type  "(" plug/sid ")/purify" ] [!plug purify]
				if stale [
					vprint "plug is stale!:"
					; <FIXME> propagate stale state !!!
				]
					
				vout/return/tags false [!plug purify]
			]



			;---------------------
			;-        cleanup
			;---------------------
			; processing manager, instigates our subjects to clean themselves and causes a process
			; ONLY if we are dirty. no point in reprocessing our liquid, if we are already clean.
			;---------------------
			cleanup: func [
				plug [object!]
				/local data oops!
			][
				vin/tags ["liquid/"  type  "[" plug/sid "]/cleanup" ] [!plug cleanup]
				if plug/dirty? [
					;------
					; if plug is a pipe server, not much to do except accept fill data.
					;------
					either any [
						true? plug/pipe?
						all [
							plug/pipe? = 'simple
							plug/linked-container = false
						]
					][
						data: plug/liquid:  plug/mud
						oops: false
					][
						;------
						; at this point we know the plug is supposed to observe data (or eventually will).
						;------
						; refresh dependencies
						data: instigate plug
						
						if all [
							plug/pipe? = 'simple
							plug/linked-container = true
						][
							vprint "WE ADD MUD SINCE THIS IS A LINKED-CONTAINER"
							append/only data plug/mud
						]
						
						either object? plug/pipe? [
							;------
							; a piped client simply uses its pipe server's data (which might have been purified at the pipe itelf)
							;------
							plug/liquid: data/1
						][
							;------
							; only process if filter allows it
							;------
							unless oops!: not block? data: plug/valve/filter plug data [
								process plug data
		
								; simple trick which allows singular plugs to adapt after the standard
								; plug has processed...
								if in plug 'process [
									plug/process
								]
							]
						]
					]
					;------
					; allow a node to fix the value within plug/liquid to make sure its always within 
					; specs, no matter how its origin (or lack thereoff)
					;------
					plug/dirty?: either oops! [
						purify/stale plug
					][
						purify plug
					]
				]
				vout/return/tags plug/liquid [!plug cleanup]
			]



			;---------------------
			;-        content
			;---------------------
			; method to get plug's processed value, just a more logical semantic value
			; when accessing a liquid from the outside.
			;
			; liquid-using code should always use content, whereas the liquid code itself
			; should always use cleanup.
			;
			; optionally you could redefine the function to make internal/external
			; plug access explicit... maybe for data hidding purposes, for example.
			;---------------------
			content: :cleanup
		]
	]
]



