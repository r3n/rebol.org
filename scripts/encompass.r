rebol [
	; -- basic rebol header --
	file:		%encompass.r
	version:	1.0.3
	date:		25-Nov-2003
	author:		"Maxim Olivier-Adlhoch"
	title:		"encompass function"
	purpose: 	"Patch/Extend/Restrict any function by transparently enclosing it within another."


	; -- rebol.org header --
	library: [
	        level: 'advanced
	        platform: 'all
	        type: 'function
	        domain: [extension patch]
	        tested-under: [view 1.2.10 w2k]
	        support: none
	        license: [lgpl]
	        see-also: none
	    ]
	

	
	; -- extended rebol header --
	notes: "Remove example at the end when using it in your code"
	copyright:	"Copyright (c) 2003 Maxim Olivier-Adlhoch"
	web: "http://www.rebol.it/~steel"
	e-mail: "moliad@aei.ca"
	original-author: "Maxim Olivier-Adlhoch"
	history: {
		v1.0.0:
			-basic functionality works
		v1.0.1:
			-encompassing function now always returns a value.
			-/silent prevents enclosed function from assigning a value to rval
			-/args can now add your own parameters and refinements to spec of enclosed function
			-/rval always added to spec
			-/local will now be removed from enclosed function's spec along with all local variables it defines.
				use /args to add your own.
		v1.0.2:
			-totally rewritten code.  integrated all 3 loops into 1
			-fixed a bug with /local handling
			-changed debug output
			-changed example code, to make it more obvious
		v1.0.3:
			-added missing local words in function!'s locals block

	}
	license:   {This tool is free software; you can redistribute it and/or
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
This tool is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.
}
]


;--------------------------
;- encompass
;------
; enclose a specified function within a new function with optional leading and trailing processing.
; it will safely carry over only refinements which are really used and you can even supply your own (which
; stay local to the encompassing function).
; note that in any case, a refinement called rval is always added to template, in order to create a local variable used by returns.
encompass: function [
	func-name [word!] "the name of a function to encompass, specified as a word. Must exist in global namespace."
	/args opt-args [block!] "a block of optional args which your pre or post processing will use.  These are, of couse, not sent to enclosed function."
	/pre pre-process "code you want to execute BEFORE the enclosed function. context is kept, so it is safe with objects."
	/post post-process "code you want to execute AFTER the enclosed function. context is kept, so it is safe with objects."
	/silent "notify that the enclosed function DOES NOT return a value (like print). Rval is still returned and will be none by default, unless your post process plays with it."
	/debug "prints out various data and makes enclosed function print itself before execution"
][
	; local variables
	blk dt func-args func-ptr func-body last-ref item params-blk refinements word arguments args-blk][
	if debug [
		print "^/^/----------------------------------------------------------------------"
		print "encompass()^/"
	]
	
	;----------------
	; find function to override
	;----------------
		func-ptr: get in system/words func-name
	
	;----------------
	; make sure we really have a function to work with
	;----------------
		if not any-function? :func-ptr [print "  error... funcptr is not a function value or word" return none]
	
	;----------------
	; reconstruct args block
	;----------------
		arguments: third :func-ptr ; get enclosed function's arg block
		func-args: copy []   ; the actual block which will be used for sub-func
		last-ref: none
		
		; prepare function...
		args-blk: copy compose [
			([('system)])
			([('words)])
			(to paren! to-lit-word func-name)
		]
		params-blk: copy [] ; stores all info about the params
		
		; prepare datablocks to construct path
		FOREACH item arguments [
			; block values in arguments are always datatype casting specifications
			SWITCH/default TYPE?/word item [
				block! [
					; change all datatype values into word values.
					blk: copy []
					FOREACH dt item [
						word: MOLD dt
						APPEND blk TO-WORD word
					]
					APPEND/only func-args blk
				]
			
				refinement! [
					last-ref: item
					; never include local word setup, this is local to enclosed function...
					if last-ref <> /local [
						APPEND func-args item
						append/only args-blk to paren! compose/deep [either (to-word item) [(to-lit-word item)][]]
					]
				]
			
				word! [
				
					either last-ref [
						; never include local word setup, this is local to enclosed function...
						if last-ref <> /local [
							append/only params-blk to paren! copy compose/deep [either (to-word last-ref) [(item)][]]
							append func-args item
						]
					][
						append/only params-blk to paren! item
						append func-args item
					]
					
				]
			][
				; default block
				append func-args item
			]
		]


	;----------------
	; actually create function body
	;----------------
		; currently only supports global namespace words. 
		; using this  system/words/ notation, prevents circular references when using methods
		; in objects which have the same name as the one which is in global namespace :-)
		
		; nest refinement and parameters into various paren and blocks to create actual function call
		blk: append append/only copy [] to paren! compose/deep [ to-path compose [(args-blk)]] params-blk
		
		;func-body: insert copy [] 
		
		;create outer body block,
		func-body: append copy [] compose [
			;include pre-process (if any)
			(either pre [pre-process][])
			; in debug mode this prints the final internal function call, just before calling it
			enclosed-func: (either debug ['probe][])
			; add main function body, created above
			compose (append/only copy [] blk)
			; user wants the internal command's returned value (rval:)
			(either silent [][to-set-word 'rval])
			; call the dynamically generated command.
			do enclosed-func
			; insert post-process (if any)
			(either post [post-process][])
			; add the return statement
			return rval
		]
		
	;----------------
	; add optional arguments which your pre or post processing might need...
	;----------------
		if args [
			; find point where parameters end and refinements start
			refinements: find func-args refinement!
			either refinements[
				func-args: refinements
			][
				; there are no refinements, so we add to the end
				func-args: tail func-args
			]
			insert func-args opt-args
		]
		
		append func-args [/rval]
		func-args: head func-args
		
	;----------------
	; debug information
	;----------------
		if debug [
			print "^/FUNCTION ARGUMENT SPEC:"
			probe func-args
			
			print "^/FINAL FUNCTION BODY:"
			probe func-body
			print "----------------------------------------------------------------------^/^/"
		]
		return func func-args func-body
]



;----------------
;--- examples ---
;----------------

; patches 'READ function so that it warns you of all file reads and asks confirmation.
old-read: :read
read: encompass/args/pre 'old-read [/safe] [
	if not safe [
		print "----------------- WARNING! --------------------"
		print "--                                           --"
		print "--         FILE READ ABOUT TO OCCUR          --"
		print "--                                           --"
		print "-----------------------------------------------"
		print ["-- path:" clean-path source]
		print "-----------------------------------------------"
		answer: ask "authorize (Y/N)?"
		if answer <> "Y" [
			ask "APPLICATION ABORTING, USER DID NOT ACCEPT FILE READ^/^/press enter to quit!^/^/"
			quit
		]
	]
]


; this shows that you do not have to know about any refinement or argument from source function
; in order to patch it.
print read/part %encompass.r 126

ask ""


