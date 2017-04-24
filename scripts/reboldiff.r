REBOL [
    Title: "REBOL Diff and Patch functions"
    Purpose: {
        Implements diff and patch in REBOL. Allows you to see
        differences between text files.
    }
    Author: "Gabriele Santilli"
    EMail: giesse@rebol.it
    File: %reboldiff.r
    License: {
Copyright (c) 2005, Gabriele Santilli
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer. 
  
* Redistributions in binary form must reproduce the above
  copyright notice, this list of conditions and the following
  disclaimer in the documentation and/or other materials provided
  with the distribution. 

* The name of Gabriele Santilli may not be used to endorse or
  promote products derived from this software without specific
  prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
    }
    Date: 29-Jul-2005
    Version: 1.1.1 ; majorv.minorv.status
                   ; status: 0: unfinished; 1: testing; 2: stable
    History: [
        29-Jul-2005 1.1.0 "History start"
    ]
    Library: [
        level: 'intermediate
        platform: 'all
        type: [function tool]
        domain: [files text text-processing]
        tested-under: none
        support: none
        license: 'bsd
        see-also: none
    ]
]

; the one built in lacks port!
offset?: func [
    "Returns the offset between two series positions."
    series1 [series! port!]
    series2 [series! port!]
][
    subtract index? series2 index? series1
]

; find, ignoring whitespace differences.
find-trim:
    func [
        series
        value
        /case
        /local eq?
    ] [
        value: trim/lines value
        eq?: either case [:strict-equal?] [:equal?]
        while [not tail? series] [
            if eq? value trim/lines pick series 1 [
                return series
            ]
            series: next series
        ]
        none
    ]

diff:
    func [
        "Find differences between two text files"
        orig [file! block! port!] "File, block of lines or port (in /lines mode)"
        new [file! block! port!]
        /case "Characters are case-sensitive"
        /trim "Ignore differences in white space"
        ; returns: block of differences
        /local diffs replace? ins del find' eq? tmp num cas
    ] [
        if file? orig [orig: open/lines orig]
        if file? new [new: open/lines new]

        find': make path! either trim [[find-trim]] [[find]]
        if case [insert tail find' 'case]
        eq?: either case [:strict-equal?] [:equal?]
        trim: either trim [func [val] [system/words/trim/lines val]] [func [val] [:val]]
        
        diffs: make block! 256

        replace?: no
        cas: get in system/words 'case
        while [not all [tail? orig tail? new]] [
            cas [
                all [tail? orig not tail? new] [
                    ; insertion at end
                    ; need copy because it can be a port!
                    insert insert tmp: tail diffs index? new copy new
                    new-line tmp yes
                    new-line/all next tmp no
                    new: tail new
                    ;replace?: no
                ]
                all [tail? new not tail? orig] [
                    ; deletion at end
                    insert insert tmp: tail diffs negate index? new length? orig
                    new-line tmp yes
                    new-line/all next tmp no
                    orig: tail orig
                    ;replace?: no
                ]
                eq? trim pick orig 1 trim pick new 1 [
                    ; line matches
                    orig: next orig
                    new: next new
                    replace?: no
                ]
                (ins: do find' new pick orig 1 ; insertion?
                del: do find' orig pick new 1 ; deletion?
                all [ins any [not del greater? offset? orig del offset? new ins]]) [
                    ; insertion
                    ; not insert/part because does not work on port!
                    insert insert tmp: tail diffs index? new copy/part new ins
                    new-line tmp yes
                    new-line/all next tmp no
                    new: next ins
                    orig: next orig
                    replace?: no
                ]
                del [
                    ; deletion
                    insert insert tmp: tail diffs negate index? new offset? orig del
                    new-line tmp yes
                    new-line/all next tmp no
                    orig: next del
                    new: next new
                    replace?: no
                ]
                true [
                    ; replacement
                    either replace? [
                        num/1: num/1 + 1
                        insert tmp: tail diffs pick new 1
                        new-line tmp no
                    ] [
                        replace?: yes
                        insert num: insert tmp: tail diffs negate index? new 1
                        new-line tmp yes
                        new-line/all next tmp no
                        insert insert tmp: tail diffs index? new new/1
                        new-line tmp yes
                        new-line/all next tmp no
                    ]
                    new: next new
                    orig: next orig
                ]
            ]
        ]
        diffs
    ]

patch:
    func [
        "Patch a text file with a block of diffs as returned by the DIFF function"
        file [file! block! port!] "File (changed!), block of lines or port (in /lines mode)"
        diffs [block!] "Diffs block as returned by the DIFF function"
        ; returns: file; if you pass a file!, the file is CHANGED.
        /local lines pos mark1 mark2 check
    ] [
        lines: file
        if file? lines [lines: open/lines lines]
        check: does [if negative? pos [make error! "Corrupt diff"]]
        parse diffs [
            any [
                set pos integer! (pos: negate pos) integer! pos mark1: some string! mark2:
                    (check  change/part at lines pos mark1 mark2)
                |
                set pos integer! mark1: some string! mark2:
                    (check  insert/part at lines pos mark1 mark2)
                |
                set pos integer! (pos: negate pos) set mark1 integer!
                    (check  remove/part at lines pos mark1)
            ]
        ]
        if file? file [close lines]
        file
    ]
    
comment [
    ;print "Files"
    ;write %test1.txt detab read %/C/REBOL/Link/Alliance/Projects/System/Services/rebser-test.r
    ;write %test2.txt read %/C/REBOL/Source/Services/rebser-test.r
    ;probe d: diff %test1.txt %test2.txt
    ;patch %test1.txt d
    ;probe equal? read %test1.txt read %test2.txt

    print "No diffs"
    test1: [
        "This is a test"
        "block of lines"
        "used for diff"
    ]
    test2: [
        "This is a test"
        "block of lines"
        "used for diff"
    ]
    probe d: diff test1 test2
    patch test1 d
    probe equal? test1 test2

    print "Insertion at top"
    test1: [
        "This is a test"
        "block of lines"
        "used for diff"
    ]
    test2: [
        "Added lines"
        "at the beginning of the file"
        ""
        "This is a test"
        "block of lines"
        "used for diff"
    ]
    probe d: diff test1 test2
    patch test1 d
    probe equal? test1 test2
    
    print "Insertion at bottom"
    test1: [
        "This is a test"
        "block of lines"
        "used for diff"
    ]
    test2: [
        "This is a test"
        "block of lines"
        "used for diff"
        ""
        "Added lines"
        "at the end of the file"
    ]
    probe d: diff test1 test2
    patch test1 d
    probe equal? test1 test2
    
    print "Insertion in the middle"
    test1: [
        "This is a test"
        "block of lines"
        "used for diff"
    ]
    test2: [
        "This is a test"
        "block of lines"
        "with some modifications"
        "to check out what happens when"
        "used for diff"
    ]
    probe d: diff test1 test2
    patch test1 d
    probe equal? test1 test2
    
    print "Deletion at top"
    test1: [
        "This is a test"
        "block of lines"
        "used for diff"
    ]
    test2: [
        "used for diff"
    ]
    probe d: diff test1 test2
    patch test1 d
    probe equal? test1 test2
    
    print "Deletion at bottom"
    test1: [
        "This is a test"
        "block of lines"
        "used for diff"
    ]
    test2: [
        "This is a test"
    ]
    probe d: diff test1 test2
    patch test1 d
    probe equal? test1 test2
    
    print "Deletion in the middle"
    test1: [
        "This is a test"
        "block of lines"
        "used for diff"
    ]
    test2: [
        "This is a test"
        "used for diff"
    ]
    probe d: diff test1 test2
    patch test1 d
    probe equal? test1 test2
    
    print "Changes at top"
    test1: [
        "This is a test"
        "block of lines"
        "used for diff"
    ]
    test2: [
        "This is a new test"
        "block of lines"
        "used for diff"
    ]
    probe d: diff test1 test2
    patch test1 d
    probe equal? test1 test2
    
    print "Change at bottom"
    test1: [
        "This is a test"
        "block of lines"
        "used for diff"
    ]
    test2: [
        "This is a test"
        "block of lines"
        "used with diff"
    ]
    probe d: diff test1 test2
    patch test1 d
    probe equal? test1 test2
    
    print "Change in the middle"
    test1: [
        "This is a test"
        "block of lines"
        "used for diff"
    ]
    test2: [
        "This is a test"
        "block containing lines"
        "used for diff"
    ]
    probe d: diff test1 test2
    patch test1 d
    probe equal? test1 test2
    
    print "Completely different"
    test1: [
        "This is a test"
        "block of lines"
        "used for diff"
    ]
    test2: [
        "This block has nothing"
        "to do with the"
        "original one;"
        "yet diff and patch should work."
    ]
    probe d: diff test1 test2
    patch test1 d
    probe equal? test1 test2

    print "Change + insert"
    test1: [
        "This is a test"
        "block of lines"
        "used for diff"
    ]
    test2: [
        "This is a test"
        "block containing lines"
        "added line"
        "used for diff"
    ]
    probe d: diff test1 test2
    patch test1 d
    probe equal? test1 test2
    
    print "Insert + change"
    test1: [
        "This is a test"
        "block of lines"
        "used for diff"
    ]
    test2: [
        "This is a test"
        "added line"
        "block containing lines"
        "used for diff"
    ]
    probe d: diff test1 test2
    patch test1 d
    probe equal? test1 test2
    
    halt
]
