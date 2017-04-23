REBOL [Title:   "Mirrorgame"
       File:    %mirror.r
       Auteur:  "Arnold van Hofwegen"
       Version: "1.07" 
       date: 18-jul-2012
       Purpose: {A nice logical puzzle game.}
       level: 'intermediate
       platform: 'all
       type: [game tutorial]
       domain: [game]
       tested-under: "Mac OSX, Windows" 
       support: none
       see-also: {You also need scripts %mirror-pref.r and %mirror-lang.r 
                  to run the game.}
]

History: [ 1.00 Initial released version
           1.01 Fixed bug init aantal-spiegels 
           1.02 01-07-2012 Added coloring of the labels on the side
           1.03 02-07-2012 Improved on coloring and turn it on from start
           1.04 02-07-2012 Bugfix removed labelfont 
           1.05 04-07-2012 Added support for Languages and preferences
           1.06 05-07-2012 Another init problem with both window-texts main and pref
           1.07 11-07-2012 Fun with extra box for flash-effect
]

;**********************************************************
; Hulpvelden
;**********************************************************
;***********
; Constanten
;***********
grootte: 30
block-open: "["
block-close: "]"
;***********
; Variabelen
;***********
grid-line-width: mirror-line-width: user-mirror-line-width: flash-line-width: 1
flash-line-width: 3
pen-user-mirror: Blue
pen-flash: Red
init-language: "en"
;*******************************************************************************
; Functies
;*******************************************************************************
do %mirror-lang.r
do-init-lang init-language
do %mirror-pref.r
do-activate-GUI-pref-lang
;***********************
; Initialiseren schermen
;***********************
init-draw-grid-box: func [/local n] [
    draw-grid-box: copy []
    draw-grid-box: append draw-grid-box reduce ['pen 'black 'line-width grid-line-width]
    for n 0 8 1 [
        ; Horizontale gridlijnen
        draw-grid-box: append draw-grid-box compose [line (to-pair reduce [0 n * grootte]) (to-pair reduce [8 * grootte n * grootte])] 
        ; Verticale gridlijnen
        draw-grid-box: append draw-grid-box compose [line (to-pair reduce [n * grootte 0]) (to-pair reduce [n * grootte 8 * grootte])] 
    ]
]

make-draw-mirror-box: func [/local n m] [
    draw-mirror-box: copy []
    draw-mirror-box: append draw-mirror-box reduce ['pen 'black 'line-width mirror-line-width]
    for n 1 8 1 [
        for m 1 8 1 [
            switch lees-veld m n [
                4   [draw-mirror-box: append draw-mirror-box compose [line (to-pair reduce [(n - 1) * grootte m * grootte]) (to-pair reduce [n * grootte (m - 1) * grootte])] 
                     ] 
                5   [draw-mirror-box: append draw-mirror-box compose [line (to-pair reduce [(n - 1) * grootte (m - 1) * grootte]) (to-pair reduce [n * grootte m * grootte])] 
                     ]
]   ]   ]   ]

init-draw-free-mirror-box: func [/local n m] [
    ; schonen van de opgave
    for n 1 8 1 [
        for m 1 8 1 [
            switch lees-veld m n [
                1 2 [bewaar-veld m n 0]
            ]
        ]
    ]
    make-draw-free-mirror-box
]

make-draw-free-mirror-box: func [/local n m] [
    draw-free-mirror-box: copy []
    draw-free-mirror-box: append draw-free-mirror-box reduce ['pen pen-user-mirror 'line-width user-mirror-line-width]
    for n 1 8 1 [
        for m 1 8 1 [
            switch lees-veld m n [
                2   [draw-free-mirror-box: append draw-free-mirror-box compose [line (to-pair reduce [(n - 1) * grootte m * grootte]) 
                      (to-pair reduce [n * grootte (m - 1) * grootte])] 
                     ] 
                1   [draw-free-mirror-box: append draw-free-mirror-box compose [line (to-pair reduce [(n - 1) * grootte (m - 1) * grootte]) 
                      (to-pair reduce [n * grootte m * grootte])] 
                     ]
]   ]   ]   ]
;************FLITS!*****
make-draw-flash-box: func [n /local x y richting midden kant rij kolom m] [
    draw-flash-box: copy []
    m: doorloop-doolhof n
    either equal? pick randwaarden n pick randwaarden m [pen-flash: Green][pen-flash: Red]
    draw-flash-box: append draw-flash-box reduce ['pen pen-flash 'line-width flash-line-width]
    kant: midden: grootte / 2
    ; bepaal startpunt en richting
    switch n [
        1 2 3 4 5 6 7 8         [x: n - 1 * grootte + midden 
                                 y: 0 
                                 rij: 1
                                 kolom: n
                                 richting: 2]
        9 10 11 12 13 14 15 16  [x: 8 * grootte
                                 y: n - 9 * grootte + midden
                                 rij: n - 8
                                 kolom: 8
                                 richting: 3]
        17 18 19 20 21 22 23 24 [x: 24 - n * grootte + midden
                                 y: 8 * grootte
                                 rij: 8
                                 kolom: 25 - n
                                 richting: 0]
        25 26 27 28 29 30 31 32 [x: 0 
                                 y: 32 - n * grootte + midden
                                 rij: 33 - n
                                 kolom: 1
                                 richting: 1]
    ]
    draw-flash-box: append draw-flash-box compose [shape]
    ;debugging
    ;draw-flash-box: append draw-flash-box compose [line (to-pair reduce [x y]) (to-pair reduce [x y + midden])] 
    ;draw-flash-box: append draw-flash-box compose ['hline 30 'vline 80] 
    flash-shape: copy []
    flash-shape: append flash-shape compose [move (as-pair x y)]
    ; doe tot we de kant bereiken
    until [
        ;  trek lijn naar midden of halve lijn in de huidige richting
        draw-flash-line richting midden    
        ; lees spiegelwaarde van het veld
        ;  bepaal de nieuwe richting x, y naar rij kolom 
        spiegel: lees-veld rij kolom
        if  found? find [2 4] lees-veld rij kolom [ ;slash-spiegel
            richting: richting xor 1
        ]
        if  found? find [1 5] lees-veld rij kolom [ ;backslash-spiegel
            richting: richting xor 3
        ]
        ;  trek een halve lijn naar de kant in deze richting
        draw-flash-line richting kant    
        ; neem een stap 
        switch richting [
            0 [rij: rij - 1]
            1 [kolom: kolom + 1]
            2 [rij: rij + 1]
            3 [kolom: kolom - 1]
        ]
        any [rij = 0 rij = 9 kolom = 0 kolom = 9]
    ]
    ; Voorkomen dat de polygon zich sluit
    flash-shape: append flash-shape compose [move (as-pair x y)]
    draw-flash-box: append/only draw-flash-box flash-shape
]

draw-flash-line: func [richting midden] [
    switch richting [
        0 [flash-shape: append flash-shape compose ['vline (- midden)]]
        1 [flash-shape: append flash-shape compose ['hline (midden)]]
        2 [flash-shape: append flash-shape compose ['vline (midden)]]
        3 [flash-shape: append flash-shape compose ['hline (- midden)]]
    ]
]
;*******************
; Initialiseren veld
;*******************
bepaal-random-veld: func [/local spel flip randspel tussenblok n m] [
    veld: copy []
    randspel: spel: copy ""
    aantal-spiegels: 0
    lbl-spiegelinfo/text: aantal-spiegels
    show lbl-spiegelinfo
    random/seed
    loop 10 [flip: random true
             either flip [spel: append spel "5"][spel: append spel "4"]
            ]
    loop 7  [flip: random true
             either flip [spel: append spel "1"][spel: append spel "2"]
            ]
    loop 47 [spel: append spel "0"]
    randspel: random spel
    for n 0 7 1 [tussenblok: copy []
        for m 1 8 1 [append tussenblok to-block substr randspel (n * 8 + m) 1]
        veld: append/only veld tussenblok
    ]
]

doorloop-doolhof: func [n /local stapr stapk richting m op-bord] [
    switch n [
        1 2 3 4 5 6 7 8         [stapr: 1 
                                 stapk: n 
                                 richting: 2]
        9 10 11 12 13 14 15 16  [stapr: n - 8 
                                 stapk: 8 
                                 richting: 3]
        17 18 19 20 21 22 23 24 [stapr: 8 
                                 stapk: 25 - n 
                                 richting: 0]
        25 26 27 28 29 30 31 32 [stapr: 33 - n 
                                 stapk: 1 
                                 richting: 1]
    ]
    op-bord: true
    while [op-bord] [
        if  found? find [2 4] lees-veld stapr stapk [ ;slash-spiegel
            richting: richting xor 1
        ]
        if  found? find [1 5] lees-veld stapr stapk [ ;backslash-spiegel
            richting: richting xor 3
        ]
        switch richting [
            2 [stapr: stapr + 1]
            3 [stapk: stapk - 1]
            0 [stapr: stapr - 1]
            1 [stapk: stapk + 1]
        ]
        if any [stapr < 1
             stapr > 8
             stapk < 1
             stapk > 8][op-bord: false]
    ]
    either stapr = 0 [
        m: stapk 
    ][ 
        either stapr = 9 [
            m: 25 - stapk
        ][
            either stapk = 0 [
                m: 33 - stapr
            ][ ; stapk is nu 9
                m: 8 + stapr
            ]
        ]
    ]
    return m
]

bepaal-labels: func [/local idx volgorde] [
    randwaarden: copy [0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0]
    volgorde: random [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]
    idx: 1
    for n 1 32 1 [ 
        if  0 = pick randwaarden n [
            poke randwaarden n pick volgorde idx 
            m: doorloop-doolhof n
            poke randwaarden m pick volgorde idx
            idx: idx + 1
        ]
    ]
]

vul-labels: func [/local n waarde] [
    for n 1 8 1 [
      waarde: to-string pick randwaarden n
      panel-boven/pane/:n/text: waarde
      waarde: to-string pick randwaarden 8 + n
      panel-rechts/pane/:n/text: waarde
      waarde: to-string pick randwaarden 25 - n
      panel-onder/pane/:n/text: waarde
      waarde: to-string pick randwaarden 33 - n
      panel-links/pane/:n/text: waarde
    ]
]

zet-label-kleur: func [n onoff /local p] [
    either n < 9 [
        either onoff [panel-boven/pane/:n/font: lbl-bo/font]
                     [panel-boven/pane/:n/font: txt-bo/font]
        show panel-boven/pane/:n
    ][  either n < 17 [
            p: n - 8
            either onoff [panel-rechts/pane/:p/font: lbl-r/font]
                         [panel-rechts/pane/:p/font: txt-r/font]
            show panel-rechts/pane/:p
        ][  either n < 25 [
                p: 25 - n
                either onoff [panel-onder/pane/:p/font: lbl-bo/font]
                             [panel-onder/pane/:p/font: txt-bo/font]
                show panel-onder/pane/:p
            ][
                p: 33 - n
                either onoff [panel-links/pane/:p/font: lbl-l/font]
                             [panel-links/pane/:p/font: txt-l/font]
                show panel-links/pane/:p
]   ]   ]   ]

;*************
; Hulpfuncties
;*************
substr: func [string start length] [
        copy/part at string start length
]

lees-veld: func [x y /local temparr] [
    temparr: pick veld x
    return pick temparr y
]

bewaar-veld: func [x y waarde /local temparr] [
    temparr: pick veld x
    poke temparr y waarde
]

bereken-veld: func [xypair] [
    rij: 1 + to-integer xypair/2 / grootte
    kolom: 1 + to-integer xypair/1 / grootte
]

;******************************************
; Belangrijkste functies voor de verwerking
;******************************************
check-oplossing: func [/local m n opgelost] [
    opgelost: true 
    for n 1 32 1 [
        m: doorloop-doolhof n
        either equal? pick randwaarden n pick randwaarden m [
            zet-label-kleur n on
        ][
            zet-label-kleur n off
            opgelost: false
    ]   ]
    return opgelost
]

zet-spiegel: func [rij kolom 
                   /local veld-waarde 
                   nieuwe-waarde 
                   teveel-spiegels
                   is-opgelost] [
    veld-waarde: lees-veld rij kolom
    nieuwe-waarde: 99
    teveel-spiegels: false
    lbl-spelbericht/text: ""
    lbl-spelbericht/color: none
    switch veld-waarde [
        0   [ nieuwe-waarde: 2
              either aantal-spiegels < 7 [
                 aantal-spiegels: aantal-spiegels + 1
              ][ 
                 nieuwe-waarde: 99
                 teveel-spiegels: true
            ] ]
        1   [ nieuwe-waarde: 0
              aantal-spiegels: aantal-spiegels - 1]
        2   [ nieuwe-waarde: 1]
        4 5 [ lbl-spelbericht/text: lbl-spelbericht-solid
              lbl-spelbericht/color: red
            ]
    ]
    if  all [nieuwe-waarde < 3 
             not teveel-spiegels][
        bewaar-veld rij kolom nieuwe-waarde
    ]
    lbl-spiegelinfo/text: aantal-spiegels
    show lbl-spiegelinfo
    if  teveel-spiegels [ 
        lbl-spelbericht/text: lbl-spelbericht-seven
        lbl-spelbericht/color: red
    ]
    ; check-opgelost
    is-opgelost: check-oplossing
    if  is-opgelost [
        either aantal-spiegels = 7 [
            lbl-spelbericht/text: lbl-spelbericht-solved
            lbl-spelbericht/color: green 
        ][
            lbl-spelbericht/text: lbl-spelbericht-exact
            lbl-spelbericht/color: yellow
        ]
    ]
    show lbl-spelbericht
    make-draw-free-mirror-box
    show free-mirror-box
]

;**************
; Button acties
;**************
action-nieuw-spel: func [] [
    bepaal-random-veld
    bepaal-labels
    vul-labels
    make-draw-mirror-box
    mirror-box/effect: reduce ['draw draw-mirror-box]
    init-draw-free-mirror-box
    free-mirror-box/effect:  reduce ['draw draw-free-mirror-box]
    show mirror-box
    show free-mirror-box
    unflash
    check-oplossing
]

action-help-spel: func [] [
    inform layout [backdrop ivory
        text bold game-name-text 
        text " "
        text 350 game-rules-text
        text " "
        text good-luck-text
    ]
]
;*************
; Label acties
;*************
flash: func [startfrom] [
    flash-box/offset: 68x20 ; moet later 'hier worden 
    make-draw-flash-box startfrom
    flash-box/effect: reduce ['draw draw-flash-box]
    show flash-box
]

unflash: func [] [
    flash-box/offset: -300x0
    show flash-box
]

;*******************
; Stijlen voor faces
;*******************
spiegel-styles: stylize [
    horleftlab: text to-pair reduce [40 grootte] 
    horrightlab: text right to-pair reduce [40 grootte] 
    vertlab: text center to-pair reduce [grootte 40]
]
;**********************************************************
; Layout applicatiescherm
;**********************************************************
main: layout [
    size 400x400
    styles spiegel-styles
    across
    panel-links: panel [below
        space 0x0
        horrightlab "_" [flash 32][unflash] horrightlab "_" [flash 31][unflash]
        horrightlab "_" [flash 30][unflash] horrightlab "_" [flash 29][unflash]
        horrightlab "_" [flash 28][unflash] horrightlab "_" [flash 27][unflash]
        horrightlab "_" [flash 26][unflash] horrightlab "_" [flash 25][unflash]
    ]
    hier: at
    at hier + 0x-22
    panel-boven: panel [across
        space 0x0
        vertlab "_" [flash 1][unflash] vertlab "_" [flash 2][unflash]
        vertlab "_" [flash 3][unflash] vertlab "_" [flash 4][unflash]
        vertlab "_" [flash 5][unflash] vertlab "_" [flash 6][unflash]
        vertlab "_" [flash 7][unflash] vertlab "_" [flash 8][unflash]
    ]
    at hier
    grid-box: box " " 1x1 white 
    at hier
    mirror-box: box " " 1x1 white
    at hier 
    free-mirror-box: box " " 1x1 white feel [
        engage: func [face action event] [
            if  action = 'down [
                bereken-veld event/offset
                ;wat: lees-veld rij kolom
                zet-spiegel rij kolom 
                free-mirror-box/effect:  reduce ['draw draw-free-mirror-box]
                show free-mirror-box
    ]   ]   ]
    at hier 
    flash-box: box " " 1x1 white feel [
        engage: func [face action event] [
            if  action = 'over [
                unflash
            ]
            if  action = 'down [
                bereken-veld event/offset
                unflash
                zet-spiegel rij kolom 
                free-mirror-box/effect:  reduce ['draw draw-free-mirror-box]
                show free-mirror-box
    ]   ]   ]
    at hier + 240x0
    panel-rechts: panel [below
        space 0x0
        horleftlab "_" [flash  9][unflash] horleftlab "_" [flash 10][unflash]
        horleftlab "_" [flash 11][unflash] horleftlab "_" [flash 12][unflash]
        horleftlab "_" [flash 13][unflash] horleftlab "_" [flash 14][unflash] 
        horleftlab "_" [flash 15][unflash] horleftlab "_" [flash 16][unflash]
    ]
    return
    across
    at hier + 0x240
    panel-onder: panel [across
        space 0x0
        vertlab "_" [flash 24][unflash] vertlab "_" [flash 23][unflash] 
        vertlab "_" [flash 22][unflash] vertlab "_" [flash 21][unflash]
        vertlab "_" [flash 20][unflash] vertlab "_" [flash 19][unflash] 
        vertlab "_" [flash 18][unflash] vertlab "_" [flash 17][unflash]
    ]
    at hier + 0x260
    lbl-no-mirrors: text 200 ""
    lbl-spiegelinfo: text "" 20
    return
    lbl-spelbericht: text "" 300
    return
    btn-rules: button btn-rules-text [action-help-spel]
    btn-new-game: button btn-new-game-text [action-nieuw-spel]
    btn-quit: button btn-quit-text [unview/all]
    lbl-bo: label top    center 0 "" 
    txt-bo: text  top    center 0 "" 
    lbl-l:  label middle right  0 "" 
    txt-l:  text  middle right  0 "" 
    lbl-r:  label middle left   0 "" 
    txt-r:  text  middle left   0 "" 
    return
    btn-preferences: button btn-preferences-text [view/new pref-window]
    ;btn-debug:         button "Debug draw" []
    ;btn-redraw: button "Redraw" []
    ;btn-inform:         button "Info" [print to-string draw-flash-box]
    ;btn-herstart: button "Herstart" [unview/all do %mirror.r]
]

;**********************************************************
; Uiteindelijke programma
;**********************************************************
do-set-lang to-string init-language
do-activate-GUI-main-lang
do-activate-GUI-pref-lang
do-get-preferences
box-size: to-pair reduce [ 8 * grootte + 1 8 * grootte + 1]
grid-box/size: box-size
mirror-box/size: box-size
free-mirror-box/size: box-size
flash-box/size: box-size
mirror-box/color: none
free-mirror-box/color: none
;flash-box/color: black
flash-box/color: none
flash-box/offset: -300x0

init-draw-grid-box
grid-box/effect: reduce ['draw draw-grid-box]

action-nieuw-spel

view main