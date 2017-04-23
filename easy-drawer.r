 REBOl [
        Title: "Easy Drawer"
        Author: "Guest2"
        Date: 11-Feb-2007
        Version: 1.0.0
        File: %easy-drawer.r
        Purpose: "Easy way to test draw commands"
        Library: [
                Level: 'intermediate
                Type: [tool demo]
                Domain: [vid dialects]
                Tested-under: [Win]
                Platform: [all]
                Support: none
                License: none
                See-also: none
        ]
        History: [
                [1.0.0 11-Feb-2007 "First version"]
        ]

]
    
num: charset "0123456789"
pair: [opt "-" some num "x" opt "-" some num ]
integer: [opt "-" some num ]
error: none
err?: func [blk /local arg1 arg2 arg3 message err][
        error: none
        if not error? set/any 'err try blk [return :err]
        err: disarm err
        set [arg1 arg2 arg3][err/arg1 err/arg2 err/arg3]
        message: get in get in system/error err/type err/id
        if block? message[bind message 'arg1]
        message: reform reduce message
        error: reduce [
                make get-style 'text [
                        text: message
                        font: make font [color: red]
                        color: yellow
                        offset: as-pair 0 src/size/y - 20
                        size: offset + as-pair src/size/x 20
                ]
                make face [
                        offset: either err/near [
                                any [
                                        attempt [0x14 + caret-to-offset src find src/text find/tail err/near ") "]
                                        as-pair 0 src/size/y
                                ]
                        ][
                                as-pair 0 src/size/y
                        ]
                        size: as-pair src/size/x 1
                        effect: compose/deep [draw [pen red line 0x0 (as-pair src/size/x 0)]]
                ]
        ]
        []
]
board: []
view/new/title layout [
        origin 0x0 space 5x0 across
        label "rate" rate: field 30 form 40 [f-board/rate: load rate/text]
        label "size" size: field 60 form 300x450 [
                f-board/size: load size/text
                f-board/parent-face/size: 0x20 + load size/text
                show f-board/parent-face
        ]
        below f-board: box 300x450 white rate 40 effect [draw []] feel [
                engage: func [face action event][
                        poke face/effect 2 err? [compose/deep board]
                        show face
                ]
        ]
] "Draw Board"
box: make get-style 'box [
        sv-scroll: 0x0
        sv-event: none
        sv-data: none
        ;edge: make edge [color: yellow size: 1x1 effect: 'bevel]
        feel: make feel [
          redraw: func [f a][if a = 'show [
                f/offset: f/offset - f/sv-scroll + f/sv-scroll: f/parent-face/para/scroll
          ]]
          engage: func [f action event][
                switch event/type [
                        down [sv-event: event  sv-data: f/data]
                        move [
                                f/data:  sv-data + either pair? f/data [
                                        event/offset - sv-event/offset
                                ][
                                        event/offset/y - sv-event/offset/y
                                ]
                                remove/part f/caret f/len
                                insert f/caret form f/data
                                f/len: length? form f/data
                                board: err? [load src/text]
                                refresh src
                        ]
                        up [
                                system/view/focal-face: src
                                system/view/caret: offset-to-caret src f/offset + sv-event/offset
                                show src
                        ]
                ]
          ]
        ]
]
cross: make get-style 'image [
        reference: none
        feel: make feel [
                engage: func [f a e][
                        f/reference/feel/engage f/reference a context [offset: e/offset + f/offset type: e/type]
                        f/offset: f/reference/data
                        show f
                ]
        ]
]
refresh: func [f][
        f/pane: clear []
        f-board/pane: clear []
        parse/all f/text [
                any [
                        start: 
                        copy val [pair | integer]
                        fin: (  val: load val
                                append f/pane ref: make box [
                                        offset: (caret-to-offset f start) - 2x1
                                        size: (caret-to-offset f fin) - offset + 0x12
                                        data: val
                                        caret: start
                                        len: offset? start fin
                                        paren-face: f
                                        sv-scroll: f/para/scroll
                                        effect: compose/deep [draw [pen orange line (as-pair 0 size/y - 1) (as-pair size/x size/y - 1)]]
                                ]
                                if pair? val [
                                        append f-board/pane make cross [
                                                offset: val - 2x2
                                                size: 4x4
                                                effect: [cross red]
                                                reference: ref 
                                        ]
                                ]
                        )
                        | skip
                ]
        ]
        if error [append f/pane error ]
        sav-text: cp f/text
        show src

]
ask-refresh: make get-style 'btn [
        text: "Refresh" do init size: size - 0x5
        action: [
                
                err? [draw load system/words/size/text compose/deep load src/text]
                refresh src
                unless error [board: load src/text]
        ]
]

editor search: join ";Enter your draw code" newline
; hack editor: find the face where the text is pasted
edit: system/view/screen-face/pane/2
repeat face edit/pane [if face/text = search [src: face break]]

src/feel/engage: func [f a e] compose [(get in src/feel 'engage) f a e 
        if f/text <> sav-text [
                f-board/pane: clear []  
                f/pane: clear []
                ask-refresh/offset: 20x-15 + caret-to-offset f system/view/caret
                append f/pane ask-refresh
        ]
]

sav-text: cp src/text: {
(
        unless value? 'font [
                font: reduce [
                        make face/font [size: 11]
                        make face/font [size: 33]       
                ]
        ]
        unless value? 'iter [
                iter: func [idx start end step  /local stack][
                        stack: head []
                        while [tail? stack: at head stack idx] [insert tail stack none]
                        if stack/1 = none [stack/1: end ]
                        stack/1: stack/1 + step
                        if stack/1 > end [stack/1: start]
                        stack/1
                ]
        ] 
        [] ;don't forget to return an empty block (for compose/deep usage)
)

pen (255.0.0 + (0.255.255 * sine iter 1 0 360 10)) font font/2
line-width 1
fill-pen radial 200x200 0 100 0 1 1 blue green red yellow
        text vectorial 18x-4 {Easy Drawer} 
                
pen blue font font/1 line-width 1 fill-pen none
        text 44x36 { - or a way thru the killer application}

pen black
        text 20x56 {
Easy drawer is an editor which gives an easy way 
to test draw commands.

The source editor is an enhanced version of the native
rebol editor.

 - If you modify the source then you need to refresh
   the Draw board by pushing the flying button
   "Refresh". 
 
 - All pair! and integer! values can directly be modified
   by dragging them with the mouse. It is a quick way to
   see in the Draw Board the effects of any source
   modification. 
}

pen blue
        text 97x217 "circle 70x70" 
        text 166x218 (form siz: iter 5 1 25 1)
        circle 249x232 siz 
        arrow 1x0 line 
                (181x238 + pos: iter 6 1 10 0.7)
                (169x224 + pos)
        text (183x235 + pos)  "drag" 

pen black arrow 0x0   
        text 21x251 {
 - If you use a wrong syntax then it does not crash
   but the incorrect line is underlined 
   (depending ON the error).

The Draw board shows you what you expect to see,
at least...

Sometimes, You can see some small red crosses
allowing you to move the corresponding graphic items. 
The "awesome" feature is that you can see in real 
time the effect of those updates on the source.
}

pen red 
        text 21x390 {
I know, there are some explanations to give about how 
I perform these funny animations, but i let you inspect
the source, it is easy to understand 
}
pen blue rotate 25 
        text vectorial "D e m o" 
                (93x-42 + (1x10 * sine iter 3 0 180 10))

pen black translate 243x-75 
rotate (rot: iter 7 0 360 5) 
        image logo.gif -27x-2 30x10 red 
        text vectorial -26x-16 "Powered by"
}

show src
board: err? [load src/text]
refresh src 
do-events

