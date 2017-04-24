REBOL [
    Title: "MenuBar"
    Date: 11-Jul-2001
    Version: 1.0.3
    File: %menubar.r
    Author: "Gilbert Robitaille"
    Purpose: {A simple Bar Menu with
the Choose Function and
much more.
}
    History: [
    1.0.0 2-Jul-2001 "Original version." 
    1.0.1 7-Jul-2001 "Add the auto size popup-menu." 
    1.0.2 8-Jul-2001 "Add some comment."
]
    Email: g2mil@sympatico.ca
    library: [
        level: [intermediate] 
        platform: none 
        type: none 
        domain: [GUI x-file] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

;-----------    Some variables

extraOn: false
mainList: ["File" "Edit" "Extras"]
subList: [
    ["Add" "Hello" "---------" "Quit"]
    ["Undo" "---------" "Cut" "Copy" "Paste" "Clear"]   ; change those word and the
    ["Menu" "On" "The" "---------" "Flight"]            ; menu will change.
]

aStyle: stylize [
    bck: backdrop effect [gradient 2x2 gray]
    txt: text green bold font-size 14 shadow 3x3
    dbx: box 215x2 effect [gradient 1x0 200.0.0]
    inf: info 180x25 font-color green bold shadow 3x3 edge none
    chc: inf font-size 14 center middle effect [gradient 1x0 200.0.0]
    inf: info 140x25 bold middle left edge none effect [gradient 240.200.200 200.200.240]
]

;-----------    Main Menu

menuBar: layout [
    styles aStyle   styl: chc       ; that field is hidden, bck erase it
    bck at 0x10 indent 20
    banner "A MENU BAR"
    dbx across  pos1: at
    txt mainList/1 bold [pos1/y: mpos/y doChoose pos1 styl 1]  pos2: at
    txt mainList/2 bold [pos2/y: mpos/y doChoose pos2 styl 2]  pos3: at
    extra: txt mainList/3 bold [pos3/y: mpos/y doChoose pos3 styl 3] return
    mpos: at    dbx below
    txt yellow "Click on File subMenu Add"
    txt yellow "and you get an extra Menu."
    txt yellow "Click again and that extra"
    txt yellow "Menu is gone."
    label       infSpace: inf
]

;-----------    Popup Menu Function

doChoose: func [pos styl ref /local sref] [         ; make your choice ;-)
    if empty? head subList/:ref [return]
    styl/size: getSize subList/:ref styl
    choose/window/offset/style subList/:ref
    func [face btn] [
        hide-popup
        either face/text = "---------" [sref: none] [
        sref: index? find subList/:ref face/text]
    ]
    menuBar pos styl
    if sref [
        showInfo ref sref
        doAction ref sref
        show menuBar
    ]
]

;-----------    Switch Function

; if you replace add/remove for ajouter/enlever in french the switch still work,
; with out changing any things.

doAction: func [ref sref] [     
    switch ref [
        1 [                     ; the Files menu
            switch sref [
                1 [newList]     ; the Add/remove
                2 []            ; the Hello
                4 [quit]        ; the quit
            ]
        ]
        2 [                     ; The Edit menu
            switch sref [
                1 []            ; the undo
                3 []            ; the cut
                4 []            ; the copy
                5 []            ; the clear
            ]
        ]
    ]
]

;-----------    Helper Functions

getSize: func [theList styl /local size xy num] [   
    num: 0                                  
    foreach val theList [               ; longer is the word larger is the menu
        styl/text: val                  ; just look the add/remove subMenu.
        xy: size-text styl
        if xy/x > num [size: xy num: xy/x]
    ]
    size: size + 10x6
    return size
]

showInfo: func [ref sref] [
    infSpace/text: rejoin [mainList/:ref " menu at " subList/:ref/:sref]
]

newList: does [                             ; add an extra menu.
    either extraOn [remList] [
        extraOn: true
        append menuBar/pane extra
        replace subList/1/1 "Add" "Remove"
    ]
]

remList: does [                             ; remove the extra menu.
    extraOn: false
    remove find menuBar/pane extra
    replace subList/1/1 "Remove" "Add"
]

;-----------    Where every thing start

do [
    remove find menuBar/pane extra          ; remove the extra menu at start.
    view/options menuBar [no-title]
]

                                                                                                                                          