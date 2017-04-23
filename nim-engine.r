rebol [
        title: "Nim engine"
      purpose: "Calculate the best move in a game of NIM"
       author: "Sunanda"
         date:  1-sep-2004
      version:  0.0.0
         file:  %nim-engine.r
 Library: [
           level: 'intermediate
        platform: 'all
            type: [game tool]
          domain: [game]
    tested-under: 'win
         support: none
         license: 'bsd
        see-also: none
        ]

       history: [
                  [0.0.0 1-sep-2004 "written"]
                ]
       credits: {Analysis and terminology taken from
                 "The Mathematics of Games"
                 John D. Beasley
                 Oxford University Press, 1989
                }
 ]

;; --------------------------------------------------------------------------
;; See documentation:
;;  http://www.rebol.org/cgi-bin/cgiwrap/rebol/documentation.r?nim-engine.r
;; --------------------------------------------------------------------------


nim-engine: make object!
[

;; Game types:
;; **  Common:  take last and lose
;; ** Straight: take last and win

 res: none            ;; make available to whole nim-move object
 piles-copy: none     ;; caller's original piles
 player-names: none   ;; name of the two players

 test-trace: none   ;; test driver output

 game-types: ["common"   "lose if you take the last counter"
              "straight" "win if you take the last counter"
             ]

;; =====
   move: func [
;; =====
              game-type [string!]   "Common or Straight"
              piles [block!]        "1 or more piles"
              /names names-block [block!] ;; [this player + other player]
  /local
   cp          ;; count of piles
   temp
][
 if 0 = length? piles [make error! "nim-move: need at least 1 pile"]

 if not any [
             game-type = "common"
             game-type = "straight"
            ]
            [make error! "nim-move: game type must be common or straight"]

 if all [names 2 <> length? names-block]
         [make error! "nim-move: name refinement -- 2 names needed"]

 either names
    [player-names: copy names-block]
    [player-names: copy ["nim-engine" "human"]]

 res: make object!
     [game-type: none
      game-over?: false
      winner?: none
      move: none
      piles: copy []
      winning?: none
     ]


 res/game-type: game-type




;; Make the piles make sense
;; -------------------------
;; * Set any negative ones to
;;   zero
;; * Make sure they are all
;; * integers (reduce [2 ** 5]
;;   would be a decimal, and
;;   that breaks the find in
;;   check-for-win

 res/piles: copy []
 foreach p piles
    [append res/piles maximum 0 to-integer p]




 ;; ------------------------------------------------
 ;; Check for game over already (all piles are zero)
 ;; ------------------------------------------------

 if all [res/piles/1 = 0
         (skip res/piles 1) = copy/part res/piles -1 + length? res/piles
        ]
        [
         res/game-over?: true
         res/winner?: either res/game-type = "common" [player-names/1] [player-names/2]
         res/winning?: res/winner?
         return res
        ]



;; ------------------------
;; check for common end game
;; -------------------------


  if all[game-type = "common"
         common-end-game-reached?
        ]
       [
        make-common-end-game-move
        check-for-win
        return res
       ]



;; ----------------------
;; Handle all other cases
;; ----------------------
;; This is for all straight
;; games, and non-end game
;; common games


 cp: find-balance piles

 res/winning?: cp <> 0

 either res/winning?
   [make-winning-move cp]
   [make-random-move]
 check-for-win
 return res
]





;; ==============
   check-for-win: func [
;; ==============
   /local
    target-size
][

 if pair? res/move
    [
     target-size: pick res/piles res/move/1
     res/move/1: random-entry res/piles target-size
     poke res/piles res/move/1 (pick res/piles res/move/1) - res/move/2
    ]



;; Check for game over
;; -------------------

 if all [res/piles/1 = 0
         (skip res/piles 1) = copy/part res/piles -1 + length? res/piles
        ]
        [
         res/game-over?: true
         res/winner?:  either  res/game-type = "common"
              [player-names/2]
              [player-names/1]
         res/winning?: res/winner?
        ]
 return true

]


;; =============
   random-entry: func [piles [block!]  target [integer!]
;; =============
    /local
     target-positions

][
;; -------------------------
;; We've got a set of piles,
;; eg:
;; [1 3 0 0 11 3 7 5 9]
;; and a target, eg:
;; 6
;;
;; We now want to return the
;; index of a pile with at
;; least 6 counters in it --
;; eg
;; 5 or 7 or 9
;; in the example

 target-positions: copy []
 repeat n length? piles
     [if piles/:n = target
        [append target-positions n]
     ]
 return random/secure/only target-positions

]


;; ============
   find-balance: func [piles [block!]
;; ============
   /local
    bal
][
 bal: 0
 foreach p piles [bal: xor bal p]
 return bal
]





;; =========================
   common-end-game-reached?: func [
;; =========================
   /local
    count
][
 ;; The end game is when either:
 ;; * all non-empty piles have 1 counter; or
 ;; * all non-empty piles but 1 have 1 counter.
 ;; eg:
 ;; [1 0 0 1 1 1 0 0 ]  ;; all have 1 counter
 ;; [1 1 0  1 0 0 88]   ;; all but 1 have one counter


 count: 0
 foreach p res/piles
  [
   if p > 1 [count: count + 1]
  ]

 return any [count = 0 count = 1]

]



;; ==========================
   make-common-end-game-move: func [
;; ==========================
    /local
     pi
     move
     take
     piles-count
][

;; ================================
;; Precisely one non-zero pile has
;; one or more counters.
;; And it is a common game
;; ================================
;;
;; We have a win if:
;; a) we can reduce the piles to an
;;    odd number, all with 1 in them

piles-count: 0
foreach p res/piles
     [if p <> 0
       [piles-count: piles-count + 1]
     ]

if  0 = (piles-count // 2)
 [
  ;; even piles: reduce the largest to zero
  ;; --------------------------------------

  move: index? find res/piles max-element res/piles
  take: res/piles/:move
  res/move: to-pair reduce [move take]

  res/winning?: player-names/1
  return true
  ]



;; Deal with odd number of piles
;; ------------------------------

if 1 <> max-element res/piles
 [
  res/winning?: player-names/1
  move: index? find res/piles max-element res/piles
  take: res/piles/:move - 1

  res/move: to-pair reduce [move take]
  return true
 ]


;; -----------------------
;; We're losing: and all
;; piles have one in them,
;; except the empty piles
;; -----------------------

 res/winning?: player-names/2
 take: 1
 move: index? find res/piles take
 res/move: to-pair reduce [move take]

 return true
]



;; ==================
   make-winning-move: func [cp [integer!]
;; ==================
   /local
    h-un
    target-pile
    piles-reduced
    move
    take
    h-un-rem
][
  ;; cp contains the binary of the highest unbalanced
  ;; pile contents, eg
  ;; cp: 12  =  8 + 4
  ;; therefore the 8s and the 4s are unbalanced --
  ;; perhaps the original piles were:
  ;; [17 24 8 12 8 4]  = [16+1 16+8 8 8+4 4+1]

  ;; set h-un to the bit value of the
  ;; highest unbalance number


 target-pile: find-highest-unbalanced-pile cp res/piles


;; Now, ignore that pile
;; ---------------------

  piles-reduced: copy res/piles
  alter piles-reduced target-pile


;; Now find highest unbalanced of what remains
;; -------------------------------------------

 h-un-rem: find-balance piles-reduced piles-reduced


 move: index? find res/piles target-pile
 take: res/piles/:move - h-un-rem

 res/winning?: player-names/1
 res/move: to-pair reduce [move take]

 return true

]




;; =============================
   find-highest-unbalanced-pile: func [cp [integer!] piles [block!]
;; =============================
   /local
    h-un
][

 if cp = 0 [return 0]
 h-un: to integer! 2 ** (to integer! log-2 cp)

 foreach p sort/reverse copy piles
   [
    if 0 <> and h-un p [return p]
   ]

 return 0  ;; there isn't one
]




;; =================
   make-random-move: func [
;; =================
   /local
    move
    take
][
;; -------------------------------------------
;; We're losing, so do something impressive:
;; Ideally, do not remove a pile completely --
;; that simplifies the game too much.
;;
;; And remember to ignore the empty piles
;; -------------------------------------------


;; attempt to find a random pile with 2 or more counters
;; -----------------------------------------------------

 take: 0
 foreach p random/secure copy res/piles
    [if p > 1 [take: p break]]

 if take = 0  [take: 1]    ;; have to play a one

 move: index? find res/piles take ;; find the first pile of that size

 If take > 3 [take: take - 1]  ;; avoid taking them all
 take: random/secure take

 res/move: to-pair reduce [move take]
 res/winning?: player-names/2

 return true

]



;; ==========
   max-element: func [blk [block!]
;; ==========
][

;; maximim-of is useless for our purposes
;; as it can return a block, eg:
;; maximum-of [1 1 9 9 9]
;; returns [9 9 9]

 return first maximum-of blk

]


;; ===========
   test-driver: func [
;; ===========
   /local
    games-played
    moves-made
    piles
    game-type
    res
    winning?
    win-names
    diff-piles
    temp
;;  -------------------------
;;  Runs 1000s of games and
;;  checks that the results
;;  are right...or at least
;;  credible.
;;  ------------------------
][


 win-names: ["human" "nim-engine" "human"]
 games-played: 0
 moves-made: 0

forever
 [test-trace: copy []
  games-played: games-played + 1

  piles: copy []
  loop 5 + random/secure 5 [append piles random/secure 20]
  game-type: random/secure/only ["common" "straight"]

 ;; get who is supposed to be winning
 ;; ---------------------------------

   res: move game-type piles

   winning?: select win-names res/winning?


 forever
    [
     moves-made: moves-made + 1

     res: move game-type piles
     append test-trace res

     if not find win-names res/winning?
         [print "bad winner name" halt]

     if res/game-over? [break]

     if res/winning? = winning?
         [print ["didn't rotate winner names" mold res] halt]


     ;; exactly 1 pile should be different
     ;; ----------------------------------
     diff-piles: copy []
     diff-all: copy []
     if (length? piles) <> length? res/piles
          [print "bad pile length" halt]
     repeat n length? piles
           [
           if res/piles/:n < 0
              [print ["result is negative!!" mold res] halt]
            if (temp: piles/:n - res/piles/:n ) <> 0
                [append diff-piles temp]
            append diff-all temp
           ]
     if 1 <> length? diff-piles
          [print ["piles are wrong" mold piles "--" mold res "--" mold diff-piles mold diff-all] halt]
     if diff-piles/1 < 1
          [print ["changed result is negative!!" mold piles "-" mold res "--" mold diff-piles mold diff-all] halt]

     piles: copy res/piles
     winning?: copy res/winning?

    ] ;; forever
 if 0 = (games-played // 100)
   [
 print [now/precise "Played:" games-played  "Total moves:" moves-made "Average:" moves-made / games-played]
   ]
] ;; forever

]




;; =========
   play-game: func [
;; =========
     /type game-type
     /opponent-starts
     /position starting-position [block!]
     /local
      piles
      res
      human-move
][

 if not type [game-type: "common"]


 print "Enter moves as a pair!"
 print "eg 3x7 means take from pile 3. The number of counters taken is 7"
 forever [
 piles: copy []
 either position
        [piles: copy starting-position]
        [loop 2 + random/secure 3  [append piles random/secure 8]]
 loop 2 [print ""]
 print [" game type:" game-type " ... " select game-types game-type]
 loop 2 [print ""]
 print [" starting position:" mold piles]
 if opponent-starts
   [ res: move game-type piles
     print ["  nim-engine:" res/move mold res/piles]
     piles: res/piles
   ]
 forever
  [ until
      [human-move: ask "Your move? "
       human-move: load human-move
       either all [pair? human-move

            human-move/1 > 0
            human-move/1 <= length? piles
            human-move/2 > 0
            human-move/2 <= pick piles human-move/1
           ]
          [true]
          [print "----Oops: not possible to do that. Please try again----" false]

      ]
  poke piles human-move/1 (pick piles human-move/1) - human-move/2
  print ["You moved:" mold piles]
  print ""
  print "-----------------Thinking------------"
  wait (.01 * random/secure 50)
  print ""
  res: move game-type piles
  print ["  nim-engine moves: " res/move]
  print ["    position now: " mold res/piles]
  piles: res/piles
  if res/game-over?
     [print "Game over!!"
      print ["Winner: " res/winner?]
      break
      ]

  ] ;; forever
 if not (trim/lines ask "play-again? (y for yes) ") = "y" [break]
 ] ;; foever
]



] ;; nim-engine object

















