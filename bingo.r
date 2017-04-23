REBOL [
    title: "Bingo Board"
    date: 12-Jan-2011
    file: %bingo.r
    author:  Nick Antonaccio
    purpose: {
        Commercial bingo boards cost several thousand dollars.  We hook this up
        to a projector and use it to run Bingo for a non-profit organization :)
    }
]

cur-let: copy ""
view center-face layout/tight [
    size 1024x768 across space 0x0
    style bb button 64x72 red bold font [size: 48] [if ((request/confirm "End game?") = true) [quit]]
    style nn button 64x72 black bold font [size: 14 color: 23.23.23] [
        either face/font/size = 14 [
            ; face/feel: none
            set-font face size 46 
            set-font face color white
            show face
            cur-num: to-integer face/text
            case [
                (cur-num <= 15) [cur-let: "B"]
                ((cur-num > 15) and (cur-num <= 30))  [cur-let: "I"]
                ((cur-num > 30) and (cur-num <= 45))  [cur-let: "N"]
                ((cur-num > 45) and (cur-num <= 60))  [cur-let: "G"]
                ((cur-num > 60) and (cur-num <= 75))  [cur-let: "O"]
            ]
            box1/text: cur-let show box1
            loop 3 [
                box2/text: "" show box2 wait .4
                box2/text: face/text show box2 wait .85
            ]
        ] [
            set-font face size 14 
            set-font face color white
            show face
        ]
    ]
    bb "B" nn "1" nn "2" nn "3" nn "4" nn "5" nn "6" nn "7" nn "8" nn "9" nn "10" nn "11" nn "12" nn "13" nn "14" nn "15" return
    bb "I" nn "16" nn "17" nn "18" nn "19" nn "20" nn "21" nn "22" nn "23" nn "24" nn "25" nn "26" nn "27" nn "28" nn "29" nn "30" return
    bb "N" nn "31" nn "32" nn "33" nn "34" nn "35" nn "36" nn "37" nn "38" nn "39" nn "40" nn "41" nn "42" nn "43" nn "44" nn "45" return
    bb "G" nn "46" nn "47" nn "48" nn "49" nn "50" nn "51" nn "52" nn "53" nn "54" nn "55" nn "56" nn "57" nn "58" nn "59" nn "60" return
    bb "O" nn "61" nn "62" nn "63" nn "64" nn "65" nn "66" nn "67" nn "68" nn "69" nn "70" nn "71" nn "72" nn "73" nn "74" nn "75" return
    box white 512x60 
    box 200.200.255 512x60 font-color blue font-size 52 "Prize: $" [
        face/text: request-text/title/default "Enter Prize Text:" face/text
    ]
    return
    box1: box white 512x80 "" font [size: 50 color: (blue / 2)] 
    box 200.200.255 512x80 font-size 38 font-color black "Current Game:"
    return
    box2: box white 512x240 "" font [size: 200 color: blue] 
    box 200.200.255 136x240
    image1: image 235.235.255 240x240   [
        if true = request/confirm "Create new image?" [
            view/new center-face board-gui: layout/tight [
                size 200x240 across space 0x0
                style b button red 40x40 font-size 28 [
                    alert "Click the quares, then press the 'S' key to save the image."
                ]
                style n button blue 40x40 effect [] [
                    either face/color = blue [
                        face/color: white show face
                    ] [
                        face/color: blue show face
                    ]
                ]
                b "B" b "I" b "N" b "G" b "O" return
                n n n n n return
                n n n n n return
                n n n n n return
                n n n n n return
                n n n n n return
                key keycode #"s" [
                    save/png file-name: to-file request-file/only/save/file %bingo-board_1.png to-image board-gui
                    view/new layout [image load file-name]
                ]
            ]
            do-events
        ]
        if error? try [image1/image: load request-file/only show image1] [alert "Error loading image."]
    ] 
    box 200.200.255 136x240
    return
    box white 512x30 
    box 200.200.255 512x30
]