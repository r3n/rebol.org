Rebol [
    Title: "read-below"
    Date: 17-May-2004
    File: %read-below.r
    Purpose: {Reads all files and directories below specified directory}
    Version: 1.0.0
    Author: "Brett Handley"
    Library: [
        level: 'intermediate
        platform: 'all
        type: 'tool
        domain: 'file-handling
        tested-under: [
            view 1.2.1.3.1 on [WinNT4] {Basic directory tests and /foreach test.} "Brett"
            view 1.2.46.3.1 on [WinNT4] {Basic directory tests and /foreach test.} "Brett"
        ]
        support: none
        license: none
        comment: {
Copyright (C) 2004 Brett Handley All rights reserved.

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

        see-also: none
    ]
]

; -----------------------------------------------------------------
; Would have used list! for file-list but there is a bug...
; This fails on some version of REBOL:
;   to block! make list! [1]
; -----------------------------------------------------------------

read-below: func [
    {Read all directories below and including a given file path.}
    [catch throw]
    path [file! url!] "Must be a directory (ending in a trailing slash)."
    /foreach "Evaluates a block for each file or directory found."
    'word [word!] "Word set to each file or directory."
    body [block!] "Block to evaluate for each file or directory."
    /local queue file-list result file do-func
] [

    if #"/" <> last path [
        throw make error! "read-below expected path to have trailing slash."
    ]

    ; Initialise parameters
    if not foreach [
        word: 'file
        file-list: make block! 10000
        body: [insert tail file-list file]
    ]

    ; Create process function
    do-func: func reduce [[throw] word] body

    ; Initialise queue
    queue: append make list! 10 read path

    ; Process queue
    set/any 'result if not empty? queue [
        until [
            do-func file: first queue
            queue: remove queue
            if #"/" = last file [
                repeat f read join path file [insert queue join file f]
                queue: head queue
            ]
            tail? queue
        ]
    ]

    ; Return result.
    if not foreach [result: file-list]
    get/any 'result
]
