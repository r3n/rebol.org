REBOL [
	File: %rebsvs.r
	Name: rebSVS
	Title: "REBOL SVS"
	Author: Nicolas VERSCHEURE (nve)
	Purpose: "Source version system for REBOL"
	Description: {
		REBOL source version system, provide :
		- Version handling.
		- Save whole file (do not store differences for the moment like CVS).
		- Work only with FTP for the moment.
		- Compress data.
		- Manage a independant log file for each file.
		- Manage a global log file.
		
		ROADMAP:
		- work with HTTP (need to make the server part)
		- nice VID
		- enhanced compare-file function
		- store all versions files in a unique file
		- must be one component of file version system provided 
		  in a most wanted REBOL IDE !
		- lock
		
		Configuration file looks like :
		+----------------------------------------------------------------------+
		| REBOL []                                                             |
		| url-ftp: "your ftp"                                                  |
		| username-ftp: "your ftp username"                                    |
		| password-ftp: "your password"                                        |
		+----------------------------------------------------------------------+
		
		Publish all files in rebsvs subdirectory.
	}
	Date: 11/12/2010
	Version: 0.7.2
	History: [
		0.7.2 11/12/2010 "(nve): Prepare publish on rebol.org"
		0.7.1 11/11/2010 "(nve): Add licence part"
		0.7.0 01/11/2010 "(nve): Correct little mistake in file header with history part and version number"
		0.7.0 01/11/2010 "(nve): Reorganize code"
		0.7.0 01/11/2010 "(nve): Reorganize code"
		0.6.6 01/11/2010 "(nve): Make it work with subdirectory"
		0.6.5 01/11/2010 "(nve): Independant configuration file"
		0.6.4 01/11/2010 "(nve): Log when retreiving file"
		0.6.3 01/11/2010 "(nve): Ask comments if not provided"
		0.6.2 01/11/2010 "(nve): Correct file comments log"
		0.6.1 01/11/2010 "(nve): Correct comments refinement for publish-file function"
		0.6.0 01/11/2010 "(nve): Add comments refinement for publish-file function"
		0.5.0 01/11/2010 "(nve): Prepare for first release on rebol.org !"
		0.4.0 01/11/2010 "(nve): Add compare-file function (basic file comparison)"
		0.3.0 01/11/2010 "(nve): Add version management"
		0.2.0 01/11/2010 "(nve): Compress data, Add logger"
		0.1.0 31/10/2010 "(nve): Creation of the REBOL program"
	]
	Library: [ 
		Level: 'intermediate
		Platform: 'all 
		Type: 'Tool 
		Domain: [file-handling version-system] 
		Tested-under: REBOL/View 2.7.7.3.1 
		Support: none 
		License: none 
		See-also: none 
	]
	Usage: {
		>> rsvs: make rebsvs []
		>> rsvs/init-svs
		>> rsvs/retrieve-file %rebsvs.r %rebsvs-retrieve.r
		>> rsvs/publish-file/version/comments %rebsvs.r 0.7.1 {(nve) save}
	}
	License: {
		Copyright 2010 Nicolas Verscheure. All rights reserved.

		Redistribution and use in source and binary forms, with or without modification, are
		permitted provided that the following conditions are met:

		   1. Redistributions of source code must retain the above copyright notice, this list of
			  conditions and the following disclaimer.

		   2. Redistributions in binary form must reproduce the above copyright notice, this list
			  of conditions and the following disclaimer in the documentation and/or other materials
			  provided with the distribution.

		THIS SOFTWARE IS PROVIDED BY NICOLAS VERSCHEURE ``AS IS'' AND ANY EXPRESS OR IMPLIED
		WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
		FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL NICOLAS VERSCHEURE OR
		CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
		CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
		SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
		ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
		NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
		ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

		The views and conclusions contained in the software and documentation are those of the
		authors and should not be interpreted as representing official policies, either expressed
		or implied, of Nicolas Verscheure.
	}
	Copyright: (c) 2010, Nicolas VERSCHEURE
]
;============================ REBSVS ===========================================
rebsvs: make object! [
	svs-ftp: url!
	svs-ftp-log: url!
	rebsvs-conf-file: %rebsvs-conf.r
	init-svs: does [
		if error? try [
			do rebsvs-conf-file
			log/console rejoin ["Loading " rebsvs-conf-file " file."]		
		] [
			log/console rejoin ["No " rebsvs-conf-file " file !"]
			url-ftp: ask "FTP ? "
			username-ftp: ask "Username ? "
			password-ftp: ask "Password ? "
			log/console rejoin ["Write " rebsvs-conf-file " file !"]
			write rebsvs-conf-file rejoin [
				"REBOL [] " newline 
				"url-ftp: " reform url-ftp newline
				"username-ftp: " reform username-ftp newline
				"password-ftp: " reform password-ftp newline
			]
		]
		svs-ftp: rejoin [ftp:// username-ftp ":" password-ftp "@" url-ftp "/rebsvs/"]
		svs-ftp-log: join svs-ftp "rebsvs.log"
		make-dir svs-ftp
		if not exists? svs-ftp-log [
			write svs-ftp-log rejoin ["[" now "] init rebsvs.log file" newline]
		]
	]
	log: func [message [string!] /console] [
		if console [
			print rejoin ["[rebsvs - " now "] " message]
		]	
	]
	publish-file: func [
		file-source [file!]
		/version
			version-number [tuple!]
		/comments 
			message-comments [string!]
		/local 
			file-dest [file!]
			message-version [string!]
			file-comments-log [file!]
	] [
		set [path target] split-path file-source
		file-comments-log: rejoin [svs-ftp path target ".log"]
		; Versionning
		message-version: "no version !"
		if version [
			message-version: rejoin ["version " version-number]
			target: rejoin [target "-v" version-number]
		]
		; Publish file on the REBSVS
		log/console rejoin ["Publishing file " file-source " " message-version]
		if not none? path [make-dir/deep rejoin [svs-ftp path]]
		write rejoin [svs-ftp path target] mold compress read file-source
		; rebSVS Logger
		data-log: read svs-ftp-log
		data-log: rejoin ["[" now "] publish-file " file-source " by " system/network/host " " system/network/host-address " " message-version newline data-log]
		write svs-ftp-log data-log
		; Publish comments
		if comments [
			if none? message-comments [
				message-comments: ask "Comments ? "
			]
			data-log: copy ""
			attempt [data-log: read file-comments-log]
			data-log: rejoin [
				"[" now "] PUBLISH by " system/network/host " " system/network/host-address " " message-version newline
				"[" now "] COMMENT " message-version " {" newline
				message-comments newline "}" newline data-log
			]
			write file-comments-log data-log
		]
	]
	retrieve-file: func [
		file-source [file!]
		file-dest [file!]
		/version 
			version-number [tuple!]
		/local 
			message-version [string!]
	] [
		message-version: "no version !"
		if version [
			if none? version-number [
				log/console "Must set a version number"
				return false
			]
			message-version: rejoin ["version " version-number]
			file-source: rejoin [file-source "-v" version-number]
		]
		;if error? err: try [
			log/console rejoin ["Retrieving file " file-source " as " file-dest " " message-version]
			data: load rejoin [svs-ftp file-source]
			set [path target] split-path file-dest
			if not none? path [make-dir/deep path]
			write file-dest decompress data
			data-log: read svs-ftp-log
			data-log: rejoin ["[" now "] retrieve-file " file-source " by " system/network/host " " system/network/host-address " " message-version newline data-log]
			write svs-ftp-log data-log
		;] [
		;	err: disarm err
		;	print err
		;	log/console rejoin ["Could not retrieve file " file-source " " message-version " !"]
		;]
	]
	compare-file: func [
		file1 [file!]
		file2 [file!]
		/version 
			version-number1 [tuple!]
			version-number2 [tuple!]
		/local 
			message-version1 [string!]
			message-version2 [string!]
	] [
		message-version1: "no version !"
		message-version2: "no version !"
		if version [
			message-version1: rejoin ["version " version-number1]
			message-version2: rejoin ["version " version-number2]
		]
		either version [
			retrieve-file/version file1 %tmp1.r version-number1
			retrieve-file/version file2 %tmp2.r version-number2
		] [
			retrieve-file reduce file1 %tmp1.r
			retrieve-file reduce file2 %tmp2.r
		]
		lines1: read/lines %tmp1.r
		lines2: read/lines %tmp2.r
		write %diff.r ""
		i: 1
		foreach line1 lines1 [
			line2: first lines2
			if line1 <> line2 [
				write/append %diff.r rejoin ["line " i " 1=> " line1 newline]
				write/append %diff.r rejoin ["line " index? lines2 " 2<= " line2 newline]
			]
			lines2: next lines2
			i: i + 1
		]
	]
]
;============================ END OF PROGRAM ===================================
