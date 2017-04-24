Rebol [
title: "RebCannon"
author: "Massimiliano Vessi"
date: 17-12-2012
file: %rebcannon.r
;following data are for www.rebol.org library 
;you can find a lot of rebol script there 
	library: [ 
		level: 'beginner 
		platform: 'all 
		type: [tutorial game] 
		domain: [scientific ] 
		tested-under: [windows linux] 
		support: none 
		license: [gpl] 
		see-also: none 
		] 
]
;starting parameters
n: 0
either not exists? %rebcannon.score [score-list: copy [] ] [score-list: load %rebcannon.score]
if not exists? %cloud.png [request-download/to   http://www.maxvessi.net/rebsite/cloud.png   %cloud.png   ]
cloud: load %cloud.png
vx: 5 + (100 * 0.5 * cosine 45)
vy: 5 + ( 100 * 0.5 * sine 45 )
g: 9.8
an: 45
cannon: 10x10
wind:   0
wa: 100x10
random/seed now
tt: 0
ber: 180
;this scroll clouds when there is wind
clouds-moving: func [] [
    tt: tt + (wind / 5)
    if tt < -1100 [tt: 1100]
    if tt > 1100 [tt: -1100]
    compose/deep
        [draw[
            translate (as-pair tt 0)
            image cloud -700x10   -650x50  
            image cloud -400x20   -360x70  
            image cloud 200x10   240x50  
            image cloud 400x25   470x90
            image cloud 700x15   770x80
            ]]
       
    ]
;this trace the parabolic arc of the projectile and check if you centered the target
percorso: func [vx vy /local temp a b m q] [
    sx: sy: 0
    temp: copy select camp/effect 'draw
    color: random 255.255.255
    append temp reduce ['pen color 'line 0x0 ]  
    t: 0
    while [sy >= 0 ]   [
        ++ t
        sx: ( vx * t ) + (wind * t )
        sy:   ( -1 / 2 * g * (t ** 2) ) + (vy * t)
        append temp as-pair sx sy
        camp/effect: compose/only   [ draw   (temp) flip 0x1]
        show camp
        wait 0.1
        ]
    ;let's calculate the intercpet in Y=0
    ; Y = m x + q
    reverse temp    
    a: first temp
    b: second temp      
    m:   (b/y - a/y) / (b/x - a/x)
    q:   a/y - ( (a/y - b/y ) / ( a/x - b/x) * a/x )
    arrivo: (-1 * q / m)
    ;check target with a +/-5 px of approximation
    if all [arrivo < (ber + 5)
        (ber - 5) < arrivo
        ] [alert   "Good, try next level"
            new-level
            ]
    reverse temp
    ]
;this recreate the random target arrow
crea-bersaglio: func [ber][
    compose/deep [draw [pen red arrow 1x2   line (as-pair ber   30 ) (as-pair ber 0 )     ] flip 0x1]
    ]
;new level recreation  
new-level: func [/reset ] [
    until [ber: random 399  
        ber > 20
        ]
    bersaglio/effect:   crea-bersaglio ber
    camp/effect: copy [draw [] ]  
    wind: (random/only [-1 1] ) * ((random 30) - 1)
    wa: 100x10 + ( as-pair (10 + wind)   0 )
    if reset [
        score: reduce [hits/text   stats/text   request-text/title "Type your name" ]
        append/only score-list score        
        sort score-list
        reverse score-list
        save %rebcannon.score   score-list
        hits/text: "-1" ;since it's always added 1 add the end of this function
        stats/text: "0 %"
        shots/text: "0"
        show [stats shots]
        ]
    hits/text:   to-string ((to-integer hits/text) + 1)  
    show [camp cielo bersaglio hits]
    ]
;main layout
view layout [
cielo: box 400x200 effect [gradient 0x1 135.203.255 white draw [arrow 1x2   line 100x10 wa   ] ]
panel [
label "Power:"
label "Angle:"
return
powcan: slider 100x15   0.5 [ ;power
    vx: 5 + (100 * value * cosine an)
    vy: 5 + ( 100 * value * sine an )
    ]
ancan: slider 100x15 0.5 [
    an: 90 *   value
    vx: 5 + (100 * powcan/data * cosine an)
    vy: 5 +   (100 * powcan/data * sine an)
    cannon: as-pair (1.412 * 10 * cosine an )   (1.412 * 10 * sine an)
    show carro
    ] ;angle
return  
text "Hits:"    
text "Shots:"
text "Statistic:"
return
hits: text "0" 100
shots: text "0" 100
stats: text "0 %" 100
]
across
button "Shot"   [
    percorso vx vy
    shots/text: to-string ((to-integer shots/text) + 1)
    stats/text:   reform [(   to-integer (to-integer hits/text) / (to-integer shots/text) * 100 ) "%" ]
    show [shots stats]
    ]
button "New game" [new-level/reset ]
aaa: button "Score list" [view/new/title layout [
        title "Score list"
        panel [
            across
            text bold "Hits" 40
            text bold "Stats" 40            
            text bold "Name" 100
            return
            sl: list 180x200 [text 40 return text 40 return text 100 ] supply [
                count: count + n
                ;just to avoid errors on path! I added this check:
                either   score-list/:count [ face/text:   score-list/:count/:index ] [face/text:   none]
                ]              
            scroller 16x200 [
                n:   to-integer (face/data * (length? score-list) )          
                show sl
                ]
            ]                  
        ] "Score list"]
button 24x24 pink "?" [notify {Try to hit the ground where point the red arrow. Contact: maxint@tiscali.it} ]      
at cielo/offset
camp: box   400x200 effect [draw [] ]
at cielo/offset
clouds: box 400x200 rate 9 effect clouds-moving   feel [engage: func [f a e][f/effect:   clouds-moving   show f]]
at cielo/offset
carro: box 400x200 effect [draw [fill-pen black pen black box 0x0 5x5 line 0x0 cannon] flip 0x1]
at cielo/offset
bersaglio: box 400x200 effect crea-bersaglio ber
]