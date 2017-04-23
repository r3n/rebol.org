REBOL [
    Title: "Parse Analysis Toolset /View"
    Date: 19-Dec-2004
    File: %parse-analysis-view.r
    Purpose: "Some REBOL/View tools to help learn/analyse parse rules."
    Version: 1.1.0
    Author: "Brett Handley"
    Web: http://www.codeconscious.com
    Comment: "Companion script to parse-analysis.r"
    Library: [
        level: 'intermediate
        platform: 'all
        type: 'tool
        domain: [parse text-processing]
        tested-under: [
            view 1.2.8.3.1 on [WinNT4] {Basic tests.} "Brett"
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
        see-also: "parse-analsyis.r"
    ]
]

stylize/master [

    HIGHLIGHTED-TEXT: text with [
        highlights: sizing-face: none
        highlight: has [
            offset highlight-tail part-tail line-tail
            drw-blk highlight-size tmp
        ] [
            append clear drw-blk: effect/draw [pen yellow]
            if any [not highlights empty? highlights] [return]
            foreach [caret length colour] head reverse copy highlights [
                caret: at text caret
                highlight-tail: skip caret length
                copy/part caret highlight-tail
                while [lesser? index? caret index? highlight-tail] [
                    offset: caret-to-offset self caret
                    line-tail: next offset-to-caret self to pair! reduce [first size second offset]
                    part-tail: either lesser? index? line-tail index? highlight-tail [line-tail] [highlight-tail]
                    if lesser-or-equal? index? part-tail index? caret [break]
                    if newline = last tmp: copy/part caret part-tail [remove back tail tmp]
                    if not empty? tmp [
                        if edge [offset: offset - edge/size]
                        sizing-face/text: tmp
                        highlight-size: size-text sizing-face
                        insert tail drw-blk reduce ['fill-pen colour 'box offset offset + highlight-size]
                    ]
                    caret: part-tail
                ]
            ]
        ]
        words: [highlights [new/highlights: second args next args]]
        append init [
            effect: append/only copy [draw] make block! multiply 5 divide length? any [highlights []] 3
            sizing-face: make-face/styles/spec 'text copy self/styles compose [size: (size)]
            highlight
        ]
    ]

    SCROLL-PANEL: FACE edge [size: 2x2 effect: 'ibevel] with [
        data: cropbox: sliders: none

        ; returns unit-vector for an axis
        uv?: func [w] [either w = 'x [1x0] [0x1]]

        ; calculates canvas size
        sz?: func [f] [either f/edge [f/size - (2 * f/edge/size)] [f/size]]

        ; slider widths for both directions as a pair
        sldw: 15x15

        ; Manages the pane.
        layout-pane: function [/resize child-face] [sz dsz v v1 v2 lyo] [
            if none? data [data: copy []]

            ; Convert VID to a face.
            if block? data [data: layout/offset/styles data 0x0 copy self/styles]

            ; On initial layout create the crop-box and sliders.
            if not resize [
                if not size [size: data/size if edge [size: 2 * edge/size + size]]
                lyo: layout compose/deep [origin 0x0 cropbox: box
                    slider 5x1 * sldw [face/parent-face/scroll uv? face/axis value]
                    slider 1x5 * sldw [face/parent-face/scroll uv? face/axis value]]
                sliders: copy/part next lyo/pane 2
                pane: lyo/pane
            ]

            cropbox/pane: data
            sz: sz? self
            cropbox/size: sz dsz: data/size

            ; Determine the size of the content plus any required sliders.
            repeat i 2 [
                repeat v [x y] [
                    if dsz/:v > sz/:v [dsz: sldw * (reverse uv? v) + dsz]
                ]
            ]
            dsz: min dsz sldw + data/size

            ; Size the cropbox to accomodate sliders.
            repeat v [x y] [
                if (dsz/:v > sz/:v) [
                    cropbox/size: cropbox/size - (sldw * (reverse uv? v))
                ]
            ]

            ; Size and position the sliders - non-required slider(s) is/are off stage.
            repeat sl sliders [
                v2: reverse v1: uv? v: sl/axis
                sl/offset: cropbox/size * v2
                sl/size: add 2 * sl/edge/size + cropbox/size * v1 sldw * v2
                sl/redrag min 1.0 divide cropbox/size/:v data/size/:v
                if resize [svvf/drag-off sl sl/pane/1 0x0]
            ]
            if resize [do-face self data/offset]
            self
        ]

        ; Method to scroll the content with performance hinting.
        scroll: function [v value] [extra] [
            extra: min 0x0 (sz? cropbox) - data/size
            data/offset: add extra * v * value data/offset * reverse v
            cropbox/changes: 'offset
            show cropbox
            do-face self data/offset
            self
        ]

        ; Method to change the content
        modify: func [spec] [data: spec layout-pane/resize self]
        resize: func [new /x /y] [
            either any [x y] [
                if x [size/x: new]
                if y [size/y: new]
            ] [size: any [new size]]
            layout-pane/resize self
        ]
        init: [feel: none layout-pane]
        words: [data [new/data: second args next args]
            action [new/action: func [face value] second args next args]]
        multi: make multi [
            image: file: text: none
            block: func [face blk] [if blk/1 [face/data: blk/1]]
        ]
    ]
]

make-token-highlighter: func [
    {Returns a face which highlights tokens.}
    input "The input the tokens are based on."
    tokens [block!] "Block of tokens as returned from the tokenise-parse function."
    /local highlighter-face sz-main sz-input names name-area
] [

    sz-main: system/view/screen-face/size - 150x150
    sz-input: sz-main
    ctx-text/unlight-text

    use [token-lyo colours set-highlight rule? trace-term btns] [

        ; Build colours and bind token words to them.
        use [name-count set-highlight] [
            name-count: length? names: unique extract tokens 3
            colours: make block! 1 + name-count
            foreach name names [insert tail colours reduce [to set-word! name silver]]
            colours: context colours
            tokens: bind/copy tokens in colours 'self
        ]

        ; Helper functions
        rule?: func [
            "Returns the rules that are satisfied at the given input position."
            tokens "As returned from tokenise-parse."
            position [integer!] "The index position to check."
            /local result
        ] [
            if empty? tokens [return copy []]
            result: make block! 100
            forskip tokens 3 [
                if all [
                    get in colours tokens/1 ; Make sure only highlighted terms are selected
                    position >= tokens/3 tokens/3 + tokens/2 > position] [
                    insert tail result copy/part tokens 3
                ]
            ]
            result
        ]
        all-highlights: has [btn] [
            repeat word next first colours [
                set in colours word sky
                btn: get in btns word
                btn/edge/color: sky
            ]
        ]
        clear-highlights: has [btn] [
            repeat word next first colours [
                set in colours word none
                btn: get in btns word
                btn/edge/color: silver
            ]
        ]
        set-highlight: func [name /local clr btn] [
            clr: 110.110.110 + random 120.120.120
            set in colours name clr ; Set the highlighted token.
            btn: get in btns name
            btn/edge/color: clr
        ]

        ; Build name area
        btns: make colours []
        name-area: append make block! 2 * length? names [
            origin 0x0 space 0x0 across
            btn "[Clear]" [
                ctx-text/unlight-text clear trace-term/text
                clear-highlights show token-lyo
            ]
            btn "[All]" [
                ctx-text/unlight-text clear trace-term/text
                all-highlights show token-lyo
            ]
        ]
        foreach name names [
            insert tail name-area append reduce [
                (first bind reduce [to set-word! name] in btns 'self) 'btn
                form name get in colours name
                compose [set-highlight (to lit-word! name) show token-lyo]
            ] [edge [size: 3x3]]
        ]

        ; Build main layout
        token-lyo: layout [

            origin 0x0 space 0x0

            scroll-panel to pair! reduce [sz-input/1 45] name-area
            scroll-panel sz-input [
                origin 0x0 space 0x0
                highlighter-face: highlighted-text black input as-is highlights tokens feel [
                    engage: func [face act event /local rules pos] [
                        switch act [
                            down [
                                either not-equal? face system/view/focal-face [
                                    focus face
                                    system/view/caret: offset-to-caret face event/offset
                                ] [
                                    system/view/highlight-start:
                                    system/view/highlight-end: none
                                    system/view/caret: offset-to-caret face event/offset
                                ]
                                pos: index? system/view/caret
                                rules: rule? tokens pos
                                if not empty? rules [
                                    system/view/highlight-start: at face/text rules/3
                                    system/view/highlight-end: skip system/view/highlight-start rules/2
                                ]
                                insert clear trace-term/text form head reverse extract rules 3
                                show face show trace-term
                            ]
                        ]
                    ]
                ]

            ]
            trace-term: area wrap to pair! reduce [sz-main/1 40]

        ]
        token-lyo/text: "Token Highlighter"
        all-highlights
        token-lyo
    ]
]
