REBOL [
    title: "Herd The Sheep Game"
    date: 9-feb-2013
    file: %herd-the-sheep.r
    author:  "Nick Antonaccio"
    purpose: {

        Inspired by the LiveCode "Sheep Herder" game (advertised because it
        was conceived and completed within 3 hours, 18 minutes).  This quick
        implementation took 17 minutes to create, using REBOL :)  Also available
        at:

        http://re-bol.com/examples.txt

    }
]
sheep: load to-binary decompress 64#{
eJwB/gMB/P/Y/+AAEEpGSUYAAQEBAGAAYAAA/9sAQwAGBAUGBQQGBgUGBwcGCAoQ
CgoJCQoUDg8MEBcUGBgXFBYWGh0lHxobIxwWFiAsICMmJykqKRkfLTAtKDAlKCko
/8AACwgAMgAyAQERAP/EABwAAAICAwEBAAAAAAAAAAAAAAUGBAcAAQgCA//EAC8Q
AAEDAgUDAwIGAwAAAAAAAAECAwQFEQAGEiExB0FREyJxFGEygZGhweEWkrH/2gAI
AQEAAD8A6oxAl1BKFBLTjQFiVOK3SkgXtyN7b89sA1zj9Qn1Fo1lStlfiUEi90m4
sbC9hc2OPnHzVGFado65raJg0qQl4WUsEX9l9lflfv4weZqgsEvtrC990gWI8jf4
/XBBpxLraVtkFKhcHG74FylrMl4BTp0FGnQqwANrg/z9iMVj1yeq6aDCpFBiyXmp
ai28plBWRa2lJtwDc/64X+rVYn5faplMpk1UVCmTrQwNPtACAL8jYdvGFqgVGNnd
uPluvSDEqzatcCppTdS7coVuPdtcG4vYd+b9Z1QoDQddW8tlsBThHuWQN1fJx7od
cjtl1mSsIRrugge0D+B/eGe+A6XbtKdd3U97rDm3b9rYikdwDp8nFZ9VsjTsyzo8
+mSGEusshpbbyigEBRIIIB39x2thFyV06zExnqJLqkZlmDDX6gfS8FJWQLiw55ty
O2OhFKSlJUogJHfAOqNtodKWQNRFybnvgu3m+mNNpbcLoWgBKhp4I5xOUNIcba1l
oK0tjwBsR8XvzhH6pCsIy/HmUIul+BKRJW22TdaEhVxYfiFyCR3AOK6yWjOGYa3B
zG4+XI/1CkuI9QpCWSSkjQdrW453GB9QgZ4yxPdq2h1K5inG1COS6VE8EpG3BOnu
LdsWr0zpkih5IhR6q8ovrK3ChZuGtRJ0D7D/ALfE4tlyQhqPqcK1BKbDc+f2vh0F
EpoAH0TJ+5Tc/rjc2M8HS7FQg6gNab2J+/g/1gDMlOxHgl+K6ls8L4F/Hz/WFqVn
mDCr7VJlIeTIft6Ti29KFXvtq87W+SBzjKnnWJErselal/WSPwNobK9rE3JGw2B5
wUL0yYFJbbddA2OhskX22JA+MG8uUaQxIblzA2hQR7UDcgnm/i2GS2Mx4eabebLb
yEuIPKVi4P5YoXrTJoVYr1Iy9Bfgwil4iVPJARHvsU3Hfb9dO43tIrqKZ0/6tRqr
Ulol02fFLJCj6jsa+keoRyR7eR2KvG92Ux6HIgMv0xbLkR1IW2tggoUD3FtsSsZf
GsZjl/OsGJ/mE5v6Vj0zIN0+mLH3eMS+sjLQzzSUBtGkxGgRpFiLcYvPp8wzGyhT
mozTbTSUGyG0hKRcknYffDFjMf/Z5+qx2f4DAAA=
}
movestyle: [
    engage: func [f a e] [
        if a = 'down [
            initial-position: e/offset
            remove find f/parent-face/pane f
            append f/parent-face/pane f
        ]
        if find [over away] a [
            f/offset: f/offset + (e/offset - initial-position)
            if overlap? home f [
                if find f/parent-face/pane f [
                    score: score + 1
                    scoreboard/text: rejoin ["Score: " score]
                    show scoreboard
                    screen-count: screen-count + 1
                ]
                remove find f/parent-face/pane f
                show screen
                if screen-count = count [
                    screen-count: 0  count: count + 2
                    new-screen
                ]
            ]
        ]
        show f
    ]
]
make-screen: func [count] [
    gui: copy [
        size 600x400
        backdrop white
        at 250x0 scoreboard: text bold 100 rejoin ["Score: " score] 
        at 250x150 home: box 100x100 "Home" effect [gradient brown red]
        style animal image sheep feel movestyle
    ]
    repeat i count [
        append gui compose [at (random 550x350) animal]
    ]
    append gui [
        box 0x0 rate 0 feel [engage: func [f a e] [if a = 'time [
            if (now/time - start-time) > timer [
                alert rejoin ["TIME! GAME OVER. Score: " score]
                quit
            ]
        ]]]
    ]
]
check-overlap: does [   
    foreach item1 at screen/pane 5 [
        foreach item2 at screen/pane 5 [
            if ((item1 <> item2) and (overlap? item1 item2)) [
                item1/offset: random 550x350
                check-overlap
            ]
        ]
    ]
]
random/seed now/time/precise
score: 0  count: 1  screen-count: 0  timer: 00:00:10
new-screen: does [
    unview
    make-screen count
    screen: layout gui
    check-overlap
    start-time: now/time
    view center-face screen
]
new-screen