REBOL [
    Title: "Enhanced field"
    Date: 8-Jul-2001
    Version: 0.1.0
    File: %s-field.r
    Author: "oldes"
    Purpose: {To get a field where is possible to switch between normal and secure mode and which is able to remember the history (if not in secure mode)}
    Email: oldes@bigfoot.com
    library: [
        level: 'advanced 
        platform: none 
        type: none 
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
EnhancedField: func [/local f1 f2 f h def-style][
    def-style: [
        offset: 0x0
        size: 570x24
        color: none
        colors: [0.48.0 0.75.0]
        font: make font [color: 0.200.0 style: 'bold]
        edge: make edge [size: 1x1 color: 51.0.0]
    ]
    layout [ h: field 'hide]
    f1: make get-style 'field copy append def-style [flags: [field return]]
    f2: make h copy append def-style [flags: [hide field return] ]
    f: make face [
        offset: 0x0
        size:   f1/size
        text:   ""
        hidden?: false
        edge: none
        hidden: func[state [logic!]][
            if (state <> hidden?) [
                insert head pane pane/2
                remove back tail pane
                either state = true [
                    pane/2/text: copy ""
                    if string? pane/1/text [
                        insert/dup pane/2/text "*" length? pane/1/text
                        pane/2/data: copy pane/1/text
                    ]
                    
                ][
                    pane/2/text: copy pane/1/data
                    pane/2/data: copy ""
                ]
                show self
                focus pane/2
                hidden?: state
            ]
        ]
        submit: func[t][
            text: copy trim t
            history/add
            do onsubmit
        ]
        onsubmit:   [
            ;enter your action here
        ]
        history: make object! [
            data: make block! 100
            i: 1
            add: does[
                if any [
                    (data/1 = text)
                    (empty? text)
                    (hidden? = true)
                ][return false]
                i: 0
                insert head data copy text
            ]
            move: func[step face][
                if (not empty? data) and (not hidden?) [
                    i: (i + step)
                    either i > length? data [i: length? data][if i < 1 [i: 1]]
                    setText face copy pick data i
                ]
            ]
        ]
        setText: func[face new /local f][
            face/text: new
            system/view/highlight-start:
                system/view/caret: either found? f: find/tail new " " [f][head new]
            system/view/highlight-end: tail new
            show face
            new
        ]
        pane:   make block! []
    ]
    my-engage: [
        engage: func [f a e /local view* pf][
        view*: ctx-text/view*
        switch a [
            down [
                either not-equal? f view*/focal-face [
                    focus f
                    view*/caret: offset-to-caret f e/offset
                ] [
                    view*/highlight-start:
                    view*/highlight-end: none
                    view*/caret: offset-to-caret f e/offset
                ]
                show f
            ]
            over [
                if not-equal? view*/caret offset-to-caret f e/offset [
                    if not view*/highlight-start [view*/highlight-start: view*/caret]
                    view*/highlight-end: view*/caret: offset-to-caret f e/offset
                    show f
                ]
            ]
            key [
                pf: f/parent-face
                switch/default e/key [
                    #"^M" [
                        pf/submit either any [none? f/data empty? f/data] [trim f/text][f/data]
                        f/text: copy ""
                        f/data: either pf/hidden? = false [f/text][copy ""]
                        view*/highlight-start: view*/highlight-end: none
                        view*/caret: f/text
                        show f
                    ]
                    up   [pf/history/move 1 f]
                    down [pf/history/move -1 f]
                ][  ctx-text/edit-text f e get in f 'action]
            ]
        ]
        ]
    ]
    
    f1/feel: make ctx-text/edit my-engage
    f2/feel: make ctx-text/edit my-engage
    repend f/pane [f2 f1]
    f
]

;And now one example, how to use it:
myField: EnhancedField
myField/onsubmit: [
    prin "HISTORY: " probe myField/history/data
    print rejoin ["COMMAND: " myField/text]
]

l: layout/size [
    across
    at 0x24 r: rotary data ["Normal" "Secure"][myField/hidden (index? r/data) = 2]
    h4 500 "enhanced (switchable) field with history for R-Mud coded by Oldes@bigfoot.com"
] 570x48

repend l/pane myField
view/title center-face l "Enhanced field example"