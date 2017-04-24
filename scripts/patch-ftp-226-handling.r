REBOL [
	Title: {Patch for REBOL FTP protocol 226 response handling.}
	Copyright: {Copyright 2003 Brett Handley}
	Author: {Brett Handley}
	Web: http://www.codeconscious.com
	File: %patch-ftp-226-handling.r
	Date: 3-jul-2005
	Purpose: {To fix FTP protocol 226 response handling.}
	Library: [
		level: 'advanced
		type: [function]
		platform: 'all
		support: none
		domain: [ftp patch]
		tested-under: [
			view 1.2.1.3.1 on [WinNT4] {Patch and resultant FTP behaviour tested.} "Brett"
			core 2.3.0.3.1 on [WinNT4] {Application of patch tested only.} "Brett"
			core 2.5.6.3.1 on [WinNT4] {Application of patch tested only.} "Brett"
			link 1.0.2.3.1 on [WinNT4] {Application of patch tested only.} "Brett"
			command 2.5.6.3.1 on [WinNT4] {Application of patch tested only.} "Brett"
			command/view 1.2.10.3.1 on [WinNT4] {Application of patch tested only.} "Brett"
		]
		license: none
		comment: {
Copyright (C) 2003 Brett Handley All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.  Redistributions
in binary form must reproduce the above copyright notice, this list of
conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.  Neither the name of
the author nor the names of its contributors may be used to
endorse or promote products derived from this software without specific
prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
		}
	]
	Comment: {

---When to use this script

This script is only useful for older versions of REBOL (official releases older than REBOL/View 1.3).

---What this script does

It defines a function to modify REBOL FTP protocol handler functions to
fix a known bug.

It then calls the function on FTP protocol handler functions that are
known to have the bug.

---How to use this script

Just DO it.

If you want to see if changes are made then print the result of the DO, for example:

	PRINT DO %patch-ftp-226-handling.r

If you are an SDK user then you could apply this script, view the changes
and incorporate them into the source of your encapped applications manually.

---When this script might fail

This script makes an assumption that the REBOL FTP protocol code
below is always wrong:

	net-utils/confirm port/locals/cmd-port transfer-check

and that the replacement code is always right:

	net-utils/confirm/multiline port/locals/cmd-port transfer-check

If this assumption is broken the script will not have the intended effect.
}
]

; -----------------------------------------------------------------
; Function to modify FTP handler code in-place.
; -----------------------------------------------------------------

fix-ftp-226-handling: func [
	{Fixes FTP 226 server response handling bug in a FTP handler function.}
	function-name [word!]
	/local bug-occurrence input change-rule log-func value result code
][

	; -----------------------------------------------------------------
	; A parse rule to match an occurrence of the bugged code and to fix it.
	; Only designed and tested for the multiline bug of this script.
	; -----------------------------------------------------------------

	bug-occurrence: [
		path! path! 'transfer-check (
			if find/match input [
				net-utils/confirm port/locals/cmd-port transfer-check
			][
				result: any [result copy {}]
				insert tail input/1 'multiline
				append result rejoin [
					{Fixed occurrence of FTP 226 handling bug in }
					form function-name ".^/"
				]
			]
		)
	]

	; -----------------------------------------------------------------
	; The overall parse rule to recursively process REBOL code.
	; -----------------------------------------------------------------

	change-rule: [
		any [
			input:
			bug-occurrence |
			block! :input into change-rule |
			skip
		]
	]

	; -----------------------------------------------------------------
	; Process the function.
	; -----------------------------------------------------------------

	code: second get in system/schemes/ftp/handler function-name

	either parse code change-rule [
		any [result rejoin [{No changes to } form function-name ".^/"]]
	][
		make error! "FTP 226 server response handling patch failed part way through!"
	]
]


; -----------------------------------------------------------------
; Apply the patch now to the FTP handler functions and emit a log as result.
; -----------------------------------------------------------------

reduce [
	fix-ftp-226-handling 'open
	fix-ftp-226-handling 'close
]
