REBOL [
    Title: "Eat"
    Date: 6-Jul-2002
    Version: 1.0.3
    File: %eat.r
    Author: {Italian Connection (Gabriele Santilli - Romano Paolo Tenca)}
    Purpose: "Experimental Event filtering --- speeds up view!"
    History: [
        1.0.3 6-Jul-2002 "added some tests" 
        1.0.2 6-Jul-2002 "added eat-deleted" 
        1.0.1 5-Jul-2002 "clear bug corrected"
    ]
    Email: rotenca@libero.it
    library: [
        level: 'advanced 
        platform: none 
        type: 'module 
        domain: 'VID 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
context [
    ;the words of this context are the event/type to compress
    no-queue: context []
    wake-event: func [event /local no-btn] bind [
        either not pop-face [
            do event 
            empty? screen-face/pane
        ][
            either any [
                pop-face = event/face
                within? event/offset win-offset? pop-face pop-face/size
            ][
                no-btn: false 
                if block? get in pop-face 'pane [
                    no-btn: foreach item pop-face/pane [
                        if get in item 'action [
                            break/return false
                        ]
                        true
                    ]
                ] 
                if any [
                    all [event/type = 'up no-btn] event/type = 'close
                ][
                    hide-popup
                ] 
                do event
            ][
                if pop-face/action [
                    if not find [move time] event/type [
                        hide-popup
                    ] 
                    do event
                ]
            ] 
            none? find pop-list pop-face
        ]
    ] in system/view 'self
    awake: func [port no-queue /local event events lasttype] [
        events: copy [] 
        while [event: pick port 1] [
            either all [
                in no-queue event/type
                lasttype = event/type
            ][
                change back tail events event
            ][
                lasttype: event/type 
                insert tail events event
            ]
        ]
        foreach event events [
            if wake-event event [return true]
        ]
        false
    ]
    system/ports/wait-list/1/awake: func [port][
        awake port no-queue
    ]
    to-ob: func [blk [block!]][
        blk: copy blk
        forall blk [change blk to-set-word first blk]
        context insert blk none
    ]
    default: [move key offset scroll-line scroll-page]
    free: true
    set 'eat func [
        /forever for [block!]
        /only blk [block!]
    ][
        either forever [
            no-queue: to-ob for
        ][
            if not only [
                blk: default
            ]
            if all [free not empty? blk][
                free: false
                awake system/view/event-port to-ob blk
                free: true
            ]
        ]
    ]
    free-delete: true
    set 'eat-delete func [
        /forever for [block!]
        /only blk [block!]
        /local tmp
    ][
        if free-delete [
            free-delete: false
            if not only [
                blk: default
            ]
            until [
                tmp: pick system/view/event-port 1
                any [
                    not tmp
                    not find blk tmp/type
                ]
            ]
            if tmp [wake-event tmp]
            free-delete: true
        ]
    ]
]
print {
    Example:

        to compress all the events of type 'offset and 'move:
            eat/forever [offset move]

        to remove all events compression:
            eat/forever []

        to compress only once (at the end of a VID action for example)
        the events of type [move key offset scroll-line scroll-page]:
            eat

        to compress only once the events of type 'move 'scroll-line 'scroll-page:
            eat/only [move scroll-line scroll-page]

        to delete incoming events (at the end of a VID action for example)
        of type [move key offset scroll-line scroll-page]:
            eat-delete

        to delete incoming events of type 'move 'scroll-line 'scroll-page:
            eat-delete/only [move scroll-line scroll-page]

}
e: ne: ed: 1
delay: 500000
lyb: [
    area 200x50 wrap "Try to move the slider up and down keeping the left button pressed and see the difference"
    button no-wrap "Test Inform" [inform ly2]
    button no-wrap "Test Alert" [alert "OK OK"]
    toggle "forever off" "forever on" effects [[][colorize 255.0.0]] [either value [eat/forever [move offset]][eat/forever []]]

    guide
    text white "Standard"
    slider [print ["standard     n." ne] ne: ne + 1 loop delay []]
    return
    pad 25x0
    return
    text white "Eated"
    slider [print ["eated        n." e] e: e + 1 loop delay [] eat/only [move]]
    return
    pad 25x0
    return
    text white "Eated-deleted"
    slider [print ["eated-deleted n." ed] ed: ed + 1 loop delay [] eat-delete/only [move]]
]
ly2: layout copy/deep lyb
view layout lyb
halt                                                                                                                                                                                                                                                                 