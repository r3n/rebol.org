REBOL [
    Title: "Simple Rich Text renderer"
    Purpose: {
        Defines the render-rich-text function, that is able to render
        simple rich text in a face.
    }
    Author: "Gabriele Santilli"
    EMail: giesse@rebol.it
    File: %render-rich-text.r
    License: {
Copyright (c) 2004, Gabriele Santilli
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
    Date: 16-Jan-2004
    Version: 1.3.0 ; majorv.minorv.status
                   ; status: 0: unfinished; 1: testing; 2: stable
    History: [
        15-Jan-2004 1.1.0 "History start"
        15-Jan-2004 1.2.0 "First working version with *bold*, /italic/, _underline_ and link->url"
        16-Jan-2004 1.3.0 "No more needs to make face twice, it wasn't resetting pane."
    ]
    Library: [
        level: 'intermediate
        platform: 'all
        type: 'function
        domain: [text gui vid]
        tested-under: [view 1.2.8.3.1 on "WindowsXP"]
        support: none
        license: 'bsd
        see-also: none
    ]
]

set-face-style:
    func [face style' /colors c] [
        face/font: make face/font [
            style: either block? style [union style style'] [style']
            if c [
                color: first colors: reduce c
            ]
        ]
    ]
render-rich-text:
    func [
        "Render rich text in a face"
        face [object!]

        /local text pane pos space word' url kind
    ] [
        text: parse/all face/text " "
        face/text: none
        pane: face/pane: make block! 2 + length? text
        pos: face/para/origin
        space: -3x-3 + size-text make face [para: make para [origin: margin: 0x0] text: " "]
        foreach word text [
            url: kind: none
            parse word [
                copy word' to "->" 2 skip copy url to end (if all [word' url] [kind: 'link word: word' url: to url! url])
              | "*" copy word' to "*" skip end (if word' [word: word' kind: 'bold])
              | "/" copy word' to "/" skip end (if word' [word: word' kind: 'italic])
              | "_" copy word' to "_" skip end (if word' [word: word' kind: 'underline])
            ]
            insert tail pane make face [
                pane: none
                offset: pos
                text: word
                switch kind [
                    link [
                        set-face-style/colors self [underline] [blue blue + 96]
                        feel: svv/vid-feel/hot
                        action:
                            func [face value] compose [
                                browse (url)
                            ]
                    ]
                    bold [set-face-style self [bold]]
                    italic [set-face-style self [italic]]
                    underline [set-face-style self [underline]]
                ]
                para: make para [
                    origin: margin: 0x0
                ]
                size: size-text self
                if pos/x + size/x > (face/size/x - face/para/origin/x - face/para/margin/x) [
                    pos/y: pos/y + size/y
                    pos/x: face/para/origin/x
                    offset: pos
                ]
                pos/x: pos/x + size/x + space/x
            ]
        ]
        face/size: face/para/margin + second span? pane
    ]
    
example: [
    view layout [
        Style Text+ Text with [
            append init [
                render-rich-text self
            ]
        ]
        Text+ "_Simple_ *text* with /link/ to Rebol.it->http://www.rebol.it/"
    ]
]
