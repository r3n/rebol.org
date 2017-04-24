REBOL [
    	File: %guess-the-number.r
    	Date: 25-9-2014
    	Title: "Guess the number"
    	Purpose: {
                       This game will ask you to enter a number
                       and will then say if it is more or less than a predefined random number
                       with best ability and worst luck
                       you will need (log in base 2 of MAX) tries to guess the number
                       (if you are interested in this google "Binary search")
                       As default MAX: 100
                      }
       Author: "Caridorc"
       Known-bugs: {
                            The programme works flawlessly,
                            there are no bugs
                            }
       Potential-improvment: {
                                         100 should be put in a constant
                                         declared at the start of the script
                                         }
        library: [
                       level: 'beginner
                       platform: 'all
                       type: [tutorial]
                       domain: [game]
                       tested-under: 'Windows
                       support: riki100024 AT gmail DOT com
                       license: CC 3.0 Attribution only
                       see-also: none
    ]


]

random/seed now/precise

view layout [
    text "Number guessing game"
    slider 800x32 [
        guess: to-integer value * 100
    ]
    button "Start/Reset" [n: random 100]
    button "Check" [alert to-string guess
                            case [
	                    (guess = n) [alert "Right!"] 
                            (guess < n) [alert "Too small"]
                            (guess > n) [alert "Too big"]
                            ]
                    ]
]
