REBOL [
    Title: "Keyboard Trener"
    Date: 25-Mar-2006
    Version: 1.0.0
    File: %keyboar-trener.r
    Author: "Karol Gozlinski"
    Purpose: "Learn to write rebol words faster without looking at keyboard."
    Email: hali_tonic@o2.pl
    library: [
        level: 'intermediate 
        type: 'game 
        domain: [game graphics] 
        license: public-domain 
        platform: 'all
        tested-under: "View 1.3.2.3.1 on WinXP"
        support: none
    ]
]

random/seed now

dictionary: make block! 1000
foreach word first system/words [
   if all [
      value? to-word word
      not found? find to-string word "~"
      not block? word
      not object? word
      not image? word
   ][
      append dictionary to-string word
   ]
]

draw-dialect-block: [] 
screen-size: 400x128
movement-rate: 0:0:0.05
safty-area: 160
probability-adjustment: 2
if error? try [ highscore: to-integer load %keyboard-trener-highscore][
   highscore: 0
]

set-starting-parameters: does [ 
   probability: 1000
   score: 0
   stopped: false
   clear draw-dialect-block
   append draw-dialect-block [text 350x96 "Hello"]
   highscore-banner/font/color: yellow
]

view/title center-face layout [
   backdrop effect [ gradient 0x1 main-color linen ]
   across
   score-banner: vh2 left (screen-size/x / 2) bold yellow ""
   highscore-banner: vh2 right (screen-size/x / 2 - 10) bold yellow ""  
   below
   screen: image linen screen-size effect [draw draw-dialect-block] rate movement-rate feel [ 
      engage: func [face action event][
         if any [ stopped action <> 'time] [ return]
         score-banner/text: join "Score : " next form 10000000 + score
         show score-banner
         if score > highscore [
            highscore: score
            highscore-banner/font/color: green
         ]
         highscore-banner/text: join "Highscore : " next form 10000000 + highscore
         show highscore-banner
         forskip draw-dialect-block 3 [
            if (draw-dialect-block/2/x: draw-dialect-block/2/x - 1) < 0 [
               clear draw-dialect-block
               append draw-dialect-block compose [
                  text ( screen-size / 2 - 40x10) "GAME OVER"
               ]
               stopped: true
               save %keyboard-trener-highscore highscore
            ]
         ]
         show screen
         if stopped [ return]
         probability: probability + probability-adjustment
         if all [ not empty? draw-dialect-block probability < random 100000] [ return]
         empty-slots: make block! 20
         for y 0 screen-size/y 16 [ append empty-slots y]
         remove back tail empty-slots
         foreach [ feat pos word] draw-dialect-block [
            if (screen-size/x - pos/x) < safty-area [
               remove-each s empty-slots [ s = pos/y]
            ]
         ]
         if empty? empty-slots [ return]
         append draw-dialect-block compose [
            text 
            ( as-pair screen-size/x random/only empty-slots) 
            ( lotto: random/only dictionary)
         ]
         probability: probability - power length? lotto 3
      ]
   ]
   text navy "INSTRUCTION : Write flying words before they hit left margin !!!"
   across
   input-field: field 225 [
      if all [ stopped empty? input-field/text][ set-starting-parameters]
      remove-each [ feat pos word] draw-dialect-block [
         either word = input-field/text [
            probability: probability + power length? input-field/text 3
            score: score + length? input-field/text
            true
         ][ false]
      ]
      clear input-field/text
      focus input-field
   ]
   btn 80 linen "Restart" [ set-starting-parameters]
   btn 80 linen "Quit" [ quit]
   return
   text "(c) 2006 Karol Gozlinski"
   do [ 
      score-banner/saved-area: true
      highscore-banner/saved-area: true
      set-starting-parameters
      focus input-field
   ]
] {Keyboard Trener}
