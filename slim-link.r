rebol [
	; -- basic rebol header --
	file:		%slim-link.r
	version:	0.1.1 
	date:		2004-08-01
	title:		"slim-link - steel library module linker"
	author:		"Maxim Olivier-Adlhoch"
	copyright:	"(c)2004, Maxim Olivier-Adlhoch"

	; -- remark stuff --
	status:     'stable-alpha

	;-- slim parameters --
	slim-name: 	'slim-link
	;slim-requires: none
	slim-id: 0
	slim-prefix: 'slk
	slim-version: 0.9.5
	
	; -- extended rebol header --
	purpose:	"link apps which have references to slim libs inside"
	notes:		"You need to install slim to use this library (get it at www.rebol.org)."
	web:		http://www.rebol.it/~steel/glayout/index.html
	e-mail:     "moliad@aei.ca"
	original-author: "Maxim Olivier-Adlhoch"
	
   
	library: [
		level:			'advanced
		platform:		'all
		type:			[ dialect module ]
		domain:			[ external-library ]
		tested-under:	[win view 1.2.1 view 1.2.10]
		support:		"same as author"
		license:		'lgpl
		see-also:		none
	]


	history: {
		v0.1 - 2004-04-22
			- first release
			- NO NEED FOR ANY KIND OF MAKE FILES.
			- is capable of finding slim/open calls in a file and generate a stand-alone application out of it.
			- repack.r was used to confirm that it works (this includes glayout and lds-local available at rebol.org).
			- does NOT support nested library calls yet.
			- /link allows file! string! and block! datatypes... make it very flexible
			- script-header returns only the header part of an application
			- script-body returns only the body (code) part of an application
			- ALL comments are kept, in both libraries and code.
			
		v0.1.1 - 2004-08-01
			-fixed little issues in /link where it had retained some internal (author related) debug code...
	}
	
	license:   {This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation;
version 2.1 of the License.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

you can also get a complete copy of this license at
http://www.opensource.org/licenses/lgpl-license.php
}
	disclaimer: {
This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.
}
]



slim/register [
	;----------------
	;- UTILITIES
	;----

	;----------------
	;-    find-first()
	;----------------
	find-first: func [
		serie [series!] "the series to check"
		cases [block!] "the case which could match"
		/local case matches match tmp
	][
		matches: copy []
		forall cases [
			case: first cases
			append matches tmp: find serie case
		]
		
		match: power 2 31
		forall matches [
			if matches/1 [
				 match: min match index? matches/1
			]
		]
		matches: none ;clear memory
		either match = (power 2 31) [
			none
		][
			at head serie match
		]
	]
		




	;----------------
	;-    script-body()
	;----------------
	script-body: func [source [ string!] /local data ][
		data: script-header source
		if data [
			data: find/tail source data
		]
	]
	

	;----------------
	;-    script-header()
	;----------------
	script-header: func [source  [ string!] /local data blk][
		until [
			blk: load/next source
			source: blk/2
			((pick blk 1) = ('rebol))
		]
		
		blk: load/next source
		either block? blk/1 [
			data: find source blk/2
			data: copy/part source data
		][
			none
		]
		
	]



	;----------------
	;-    LINK()
	;----
	; experimental tool, use with caution, and always verify script before sending to peers.
	;----
	link: func [
		source [string! block! file!] "Source code to link with slim modules."
		/local
			outsource ; the processed output file
			slim-call ; the text which represent each instance of a call to open/slim (to parse refinements)
			end
			tokens
			blk
			data
			slim-lib
			lib
			code
	][
		
		;-----------------
		; PARSE ARGUMENT BY TYPE
		;-----------------
		switch type?/word source [
			block! [
				source: mold/only source 
			]
			file! [
				either exists? source [
					source: read source
				][
					ask rejoin ["file: " source " does not exist, aborting"]
					quit
				]
			]
			string! [
				source: copy source
			]
		]

		data: copy source
		data: script-body data

		;-----------------
		; INCLUDE SLIM
		;-----------------
		slim-lib: script-body read  slim/slim-path/slim.r
		
		data: insert data "^/^/^/"
		data: insert data ";--------------------------------------------------------------------------------^/"
		data: insert data ";--------------------------- LINKED WITH SLIM-LINK.r ----------------------------^/"
		data: insert data ";--------------------------------------------------------------------------------^/^/"
		data: insert data slim-lib
		data: insert data "^/^/slim/linked-libs: []"
		data: insert data "^/^/^/"
		
		
		;write %/p/rnd/applications/SLIM-LINK-TEST/SLIM-LINK-TEST.r head data	
		
		
		
		;-----------------
		; INCLUDE MODULES
		;-----------------
		;probe source
		
		source: mold load/all script-body  source
		
		while [ source: find source {slim/open} ] [
			code: load  form copy/part parse/all source " " 3
			print ["linked: " code/2]
			
			lib: slim/open to-word code/2 code/3
						
			lib: read to-file rejoin [lib/dir-path code/2 ".r"]
			
			data: insert data ";-  ^/"
			data: insert data ";- ----------- ^/"
			data: insert data ";--------------------------------------------------------------------------------^/"
			data: insert data rejoin [";- ---> START: " uppercase to-string code/2 "^/"]
			data: insert data ";--------------------------------------------------------------------------------^/^/"
			
		
			; append to slim linked-libs
			data: insert data rejoin [			
			"append slim/linked-libs '" code/2  "^/"
			"append/only slim/linked-libs [^/"]
			
			
			lib: script-body lib
			
			replace/all lib "slim/register" "slim/register/header"
			
			data: insert data "^/^/;--------^/;MODULE CODE^/"
			data: insert data lib
			
			
			data: insert data "^/^/;--------^/;HEADER CODE^/"
			data: insert data script-header head lib
			
			data: insert data "]^/^/"

			data: insert data ";--------------------------------------------------------------------------------^/"
			data: insert data rejoin [";- <--- END: " uppercase to-string code/2 "^/"]
			data: insert data ";--------------------------------------------------------------------------------^/^/"
			data: insert data "^/^/^/"
			
			
			source: next source
		]
		
		
		print "done"
		return head data
	]
]	



comment {

;-----------------------------------------------------------------------------------------
; The following shows how easy it is to link an application with slim libraries in it.
;

 slk: slim/open 'slim-link 0.1.1				; slim-link is a module itself.  This allows us to find slim.
 data: slk/link %/path/to/reblet.r			; actually create the linked file
 write %/path/to/linked/application.r data	; save it out !
 
 
 notes:
 -------
 slk/link supports file!, block!, and string! types, so you can build the application code on the fly and link it dynamically...
 
 slim-link is not yet capable of tracing slim calls within libraries, so if your libraries are loading libs... then the resulting app will not work.
 expect this for the next version. it will be the main feature of v0.2 (no ETA, user-demand will help make it sooner rather than later).
 
 slim-link will make any feature available in slim available in your linked app including the resources directories.  The difference being that the context
 of the lib is now the application itself, so you must transport the resource dirs relatively to the application.
 
}








	