REBOL [Title:      "Mirror preferences module"
       file:       %mirror-pref.r
       Author:     "Arnold van Hofwegen"
       Disclaimer: "Gebruik van dit programma is voor eigen risico."
       Extra-info: {Preferences support}
       date: 6-july-2012
]

;*******************************************************************************
; Functies
;*******************************************************************************
do-get-preferences: func [][
    either exists? %mirror.ini [
        load %mirror.ini
    ][
        initial-preferences
    ]
]

;********************************
; setting 
;********************************
initial-preferences: func [] [
    grid-line-width: mirror-line-width: user-mirror-line-width: 1
    pen-user-mirror: Blue
    ;init-language: "nl"
    ;init-language: "en"
]

do-show-mirror-pref: func [] [
    show pref-window
]

do-set-mirror-line-width: func [] [
    either chk-grid-bold/data [
        grid-line-width: 3
    ][
        grid-line-width: 1
    ]
    mirror-line-width: 1
    user-mirror-line-width: 1
    if  chk-mirrors-bold/data [
        if  any [rdo-mirror-type-0/data
                 rdo-mirror-type-1/data][
            mirror-line-width: 3
        ]
        if  any [rdo-mirror-type-0/data
                 rdo-mirror-type-2/data][
            user-mirror-line-width: 3
        ]
    ]    
]
do-actions-apply: func [] [
    ; set line width
    do-set-mirror-line-width
    ; set mirror color
    pen-user-mirror: to-word chc-mirror-color/text
    ;redraw the boxes 
    init-draw-grid-box
    grid-box/effect: reduce ['draw draw-grid-box]
    make-draw-mirror-box
    mirror-box/effect: reduce ['draw draw-mirror-box]
    make-draw-free-mirror-box
    free-mirror-box/effect:  reduce ['draw draw-free-mirror-box]
    ;set the chosen language
    switch chc-taal/text [
        "Nederlands" [do-set-lang "nl"]
        "English"    [do-set-lang "en"]
        "Deutsch"    [do-set-lang "de"]
        "FranÁais"   [do-set-lang "fr"]
        "EspaÒol"    [do-set-lang "es"]
        "Italiano"   [do-set-lang "it"]
        "PortuguÍs"  [do-set-lang "pt"]
     ]
     show pref-window
]

;*******************************************************************************
; Layout preferences window
;*******************************************************************************
pref-window: layout [
    across
    chc-taal:          choice "English" "Nederlands" "Deutsch" 
                       "FranÁais" "EspaÒol" "Italiano" "PortuguÍs" 
    lbl-language:      label lbl-language-text 
    return
    chc-mirror-color:  choice "Blue" "Yellow" "Red" "Green" 
                              "Purple" "Forest" "Maroon" "Navy"
    lbl-mirror-color:  label lbl-mirror-color-text 
    return
    chk-grid-bold:     check false 
    lbl-grid-bold:     label 100 lbl-grid-bold-text
    return             
    chk-mirrors-bold:  check false 
    lbl-mirrors-bold:  label 100 lbl-mirrors-bold-text
    rdo-mirror-type-0: radio true 'mirrortype rmt0: label 70 radio-mirrortype-all
    rdo-mirror-type-1: radio false 'mirrortype rmt1: label 70 radio-mirrortype-solid 
    rdo-mirror-type-2: radio false 'mirrortype rmt2: label 70 radio-mirrortype-user
    return             
    btn-apply:         button btn-apply-text [do-actions-apply]
    btn-save-pref:     button btn-save-pref-text [alert "Sorry does not function yet."]
    return             
    btn-close-pref:    button btn-close-pref-text [unview pref-window]
    btn-debug:         button "Debug radio" [print rdo-mirror-type-0/data
    print rdo-mirror-type-1/data
    print rdo-mirror-type-2/data]
    return             
    ;btn-herstart:      button "Herstart" [unview/all do %mirror-pref.r]
]
;rdo-mirror-type-1/data: true
;rdo-mirror-type-1/data: rdo-mirror-type-2/data: false
;view pref-window
;*******************************************************************************
; Einde mirror-pref.r
;*******************************************************************************