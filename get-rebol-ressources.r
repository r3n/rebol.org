REBOL [
    Name: "GET-REBOL-RESOURCES"
    Title: "Get REBOL resources"
    File: %get-rebol-ressources.r
    Author: Nicolas VERSCHEURE
    Purpose: "Get REBOL resources. Download files on local drive. Use parse with rules REBOL concept. So very easy to add new resources to download."
    Description: {
        Get some important REBOL resources. 
        So anywhere in the world, just download a REBOL Core
        and execute this script in order to get important REBOL resources.
        Download resources for platform.
    }
    Date: 20/11/2010
    Version: 0.3.1
    History: [
        0.3.1   20/11/2010  "(nve) Add more link to download"
        0.3.0   17/11/2010  "(nve) Manage download for platform (test under Windows platform only !)"
        0.2.0   11/11/2010  "(nve) Prepare for publishing on rebol.org"
        0.1.0   31/10/2010  "(nve) Creation of the REBOL program"
    ]
    Library: [ 
        Level: 'intermediate
        Platform: 'all 
        Type: 'Tool 
        Domain: [rebol] 
        Tested-under: REBOL/View 2.7.7.3.1 
        Support: none 
        License: 'freeware
        See-also: none 
    ]
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
    Comments: {
        Test under Windows platform only.
        Someone could test under Linux and MacOS.
    
        For version numbers, see :
        
        http://www.rebol.com/docs/version-numbers.html
    }
    Copyright: (c) 2010, Nicolas VERSCHEURE 
]

;==============================================================================
platform-rebol-resources: []
switch system/version/4 [ 
    ; MacOSX    
    2 [
        append platform-rebol-resources [make-root %/home/REBOL/]
        append platform-rebol-resources [get-resource http://cheyenne-server.org/dl/0919/osx/face/cheyenne.gz "softinnov"]
        switch system/version/5 [
            ; Apple OS X PPC
            4 [
                append platform-rebol-resources [get-resource http://www.rebol.com/downloads/v277/rebol-core-277-2-4.tar.gz "reboltechnology"]
                append platform-rebol-resources [get-resource http://www.rebol.com/downloads/v277/rebol-view-277-2-4.tar.gz "reboltechnology"]
            ]
            ; Apple OS X Intel
            5 [
                append platform-rebol-resources [get-resource http://www.rebol.com/downloads/v277/rebol-core-277-2-5.tar.gz "reboltechnology"]
                append platform-rebol-resources [get-resource http://www.rebol.com/downloads/v277/rebol-view-277-2-5.tar.gz "reboltechnology"]
            ]
        ]
    ] 
    ; Windows
    3 [
        append platform-rebol-resources [make-root %/C/REBOL/]
        append platform-rebol-resources [get-resource http://www.rebol.com/downloads/v277/rebol-view-277-3-1.exe "reboltechnology"]
        append platform-rebol-resources [get-resource http://www.rebol.com/downloads/v277/rebol-core-277-3-1.exe "reboltechnology"]
        append platform-rebol-resources [get-resource http://www.softinnov.org/dl/NTLM-lib-r103.zip "softinnov"]
        append platform-rebol-resources [get-resource http://www.softinnov.org/dl/scm-103.zip "softinnov"]
        append platform-rebol-resources [get-resource http://cheyenne-server.org/dl/0919/win/face/cheyenne.zip "softinnov"]
    ]
    ; Linux
    4 [
        append platform-rebol-resources [make-root %/home/REBOL/]
        append platform-rebol-resources [get-resource http://cheyenne-server.org/dl/0919/linux/face/cheyenne.gz "softinnov"]
        switch system/version/5 [
            ; Linux x86 Libc6
            2 [
                append platform-rebol-resources [get-resource http://www.rebol.com/downloads/v277/rebol-core-277-4-2.tar.gz "reboltechnology"]
                append platform-rebol-resources [get-resource http://www.rebol.com/downloads/v277/rebol-view-277-4-2.tar.gz "reboltechnology"]
            ]
            ; Linux x86 Fedora
            3 [
                append platform-rebol-resources [get-resource http://www.rebol.com/downloads/v277/rebol-core-277-4-3.tar.gz "reboltechnology"]
                append platform-rebol-resources [get-resource http://www.rebol.com/downloads/v277/rebol-view-277-4-3.tar.gz "reboltechnology"]
            ]
        ]
    ]
]
cross-rebol-resources: [
    get-resource http://dobeash.com/RebGUI/RebGUI-b117.zip "dobeash"
    get-resource http://dobeash.com/RebDB/RebDB-203.zip "dobeash"
    get-resource http://dobeash.com/SQLite/sqlite.zip "dobeash"
    get-resource http://www.auverlot.fr/download/magic350.tar "olivierauverlot"
	get-resource http://www.auverlot.fr/download/ipconfig.zip "olivierauverlot"
	get-resource http://www.softinnov.org/sc/getfile.rsp?id=sc-mysql&url=/dl/mysql-121.zip "softinnov"
	get-resource http://www.softinnov.org/dl/pgsql-r090.rip "softinnov"
	get-resource http://www.softinnov.org/dl/ldap-protocol.r "softinnov"
	get-resource http://www.softinnov.org/dl/async-call-r110.zip "softinnov"
	get-resource http://www.softinnov.org/dl/Captcha.zip "softinnov"
	get-resource http://www.softinnov.org/dl/scheduler-r090.zip "softinnov"
	get-resource http://www.softinnov.org/dl/UniServe-r099.zip "softinnov"
	get-resource http://www.softinnov.org/dl/rebox.zip "softinnov"
	get-resource http://www.softinnov.org/dl/rebox222.zip "softinnov"
]
root-dir: none!
;==============================================================================
rule: [
    some [
        'get-resource 
        set url-resource url! 
        set sub-dir string!
        (
            get-dir: rejoin [dirize root-dir dirize sub-dir]
            if not none? sub-dir [
                make-dir/deep get-dir
            ]
            set [path target] split-path url-resource
            print rejoin ["Get resource " target " from " url-resource]         
            if error? try [write/binary join get-dir target read/binary url-resource
            ][print rejoin ["Unable to get resource " target " from " url-resource]]
        )       
        |
        'make-root 
        set root-dir file! 
        (
            root-dir: dirize root-dir
            print root-dir
            print rejoin ["Make root for resource in " root-dir]
            make-dir root-dir
        )
    ]
]
;==============================================================================
; Download platform specific resources
parse platform-rebol-resources rule
; Download cross-platform resources
parse cross-rebol-resources rule
;==============================================================================