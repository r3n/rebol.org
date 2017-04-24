REBOL [
    Title: "Color Match"
    Date: 21-May-2001
    Version: 1.0.0
    File: %colormatch.r
    Author: "Scot M. Sutherland"
    Purpose: {To illustrate the three basic principles of educational objects.
1.^-objective: a target outcome, task or pattern.
2.^-experience: an interface that allows students to build relationships to the concept.
3.  evaluation: integrated data collector and organizer for evaluation.
This EO was first introduced in 1987 to students building scripts to animate graphics over video.
}
    Email: ssutherl@westmont.edu
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [GUI game] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
points: 101
color: ""

rank?: func [score /local rank] [
    rank: "Drop Out!"
    if (points > 79) [rank: "Nerd"]
    if (points > 84) [rank: "Geek"]
    if (points > 89) [rank: "Expert"]
    if (points > 94) [rank: "ACE!"]
    return rank
]

match?: func [target [tuple!] test [tuple!] /local match] [
    match: false
    if ((test >= (target - 3.3.3)) and (test <= (target + 3.3.3))) [
        match: true
    ]
    return match
]

seed?: func [/local seed] [
    seed: (to-integer (pick (parse form now/time ":") 3)) * (to-integer (pick (parse form now/time ":") 2))
    return seed
]

random-color: func [][
    for x 0 length? color 1 [remove color]
    loop 2 [append color join form (random ((seed? // 120) + 135)) "."] append color form (random ((seed? // 120) + 135))
    return to-tuple color print color
]

text-val: func [value] [
    value: form (to-integer ((1 - value) * 255))
    return value
]

interface: [
    backdrop mint
    vh1 "Color Match" gold
        feel [over: func [f a o] [
            prompt/text: either a ["Educational Object"] ["Move sliders...Click Test."] show prompt]
        ] 
    at 10x55 prompt: txt 146 "Move sliders...Click Test." white
    at 33x78 button 94x104   
    at 35x80 target: box 90x50 "Target" random-color 
                        feel [over: func [f a o] [
                            prompt/text: either a ["Starts over..."] ["Move sliders...Click Test."]
                            show prompt
                            ]
                        ] 
             [  points: 101 
                target/color: random-color test/color: black
                redval/text: grnval/text: bluval/text: "0"
                score/text: "100"
                redslide/color: grnslide/color: bluslide/color: black
                redslide/data: grnslide/data: bluslide/data: 1.0
                test/text: "Test" target/text: "Target"
                show [target test redval grnval bluval score redslide grnslide bluslide]
             ] 
    at 35x130 test: box 90x50 "Test" black 
                        feel [over: func [f a o] [
                            prompt/text: either a ["Test for match..."] ["Move sliders...Click Test."]
                            show prompt
                            ]
                        ] 
            [   test/color: redslide/color + grnslide/color + bluslide/color 
                score/text: points: points - 1
                if match? target/color test/color [
                    test/text: "MATCH!"
                    target/text: rank? points
            ] 
                show [target test score]
            ]
    at 30x190 redval: vh4 "0" 30 center  
    at 65x190 grnval: vh4 "0" 30 center 
    at 100x190 bluval: vh4 "0" 30 center
    at 37x220 redslide: slider 15x130 black 
        feel [over: func [f a o] [
            prompt/text: either a ["Red slider..."] ["Move sliders...Click Test."] show prompt]
        ] 
        [redslide/color: to-tuple join (redval/text: text-val value) ".0.0" show [redval redslide]]
    at 72x220 grnslide: slider 15x130 black 
        feel [over: func [f a o] [
            prompt/text: either a ["Green slider..."] ["Move sliders...Click Test."] show prompt]
        ] 
        [grnslide/color: to-tuple join "0." join (grnval/text: text-val value) ".0" show [grnval grnslide]] 
    at 107x220 bluslide: slider 15x130 black 
        feel [over: func [f a o] [
            prompt/text: either a ["Blue slider..."] ["Move sliders...Click Test."] show prompt]
        ] 
        [bluslide/color: to-tuple join "0.0." (bluval/text: text-val value) show [bluval bluslide]] 
    at 55x360 vh2 "Score" gold
        feel [over: func [f a o] [
            prompt/text: either a ["Minus 1 for each Test"] ["Move sliders...Click Test."] show prompt]
        ] 
    at 57x380 score: title "100" white
        feel [over: func [f a o] [
            prompt/text: either a ["ACE Expert Geek or Nerd!"] ["Move sliders...Click Test."] show prompt]
        ] 
    redslide/data: bluslide/data: grnslide/data: 1.0
]

view layout interface
