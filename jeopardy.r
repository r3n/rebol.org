REBOL [
    title: "Jeopardy"
    date: 3-oct-2009
    file: %jeopardy.r
    purpose: {
        A GUI game reminiscent of the popular TV show.  Click on the header image
        to create and save config files which contain questions and answers to
        separate games.  Change the "sizer" variable to resize the entire layout to
        fit different screens.
        Taken from the tutorial at http://musiclessonz.com/rebol.html
    }
] 

config: {

    REBOL []

	;________________________________________________________________
	
	sizer: 4
	
	Category-1: "Category 1" 
	Category-2: "Category 2" 
	Category-3: "Category 3" 
	Category-4: "Category 4" 
	Category-5: "Category 5"
	
	answers: [
	    "$100 Answer, Category 1" 
	    "$100 Answer, Category 2" 
	    "$100 Answer, Category 3" 
	    "$100 Answer, Category 4" 
	    "$100 Answer, Category 5" 
	    "$200 Answer, Category 1" 
	    "$200 Answer, Category 2" 
	    "$200 Answer, Category 3" 
	    "$200 Answer, Category 4" 
	    "$200 Answer, Category 5" 
	    "$300 Answer, Category 1" 
	    "$300 Answer, Category 2" 
	    "$300 Answer, Category 3" 
	    "$300 Answer, Category 4" 
	    "$300 Answer, Category 5" 
	    "$400 Answer, Category 1" 
	    "$400 Answer, Category 2" 
	    "$400 Answer, Category 3" 
	    "$400 Answer, Category 4" 
	    "$400 Answer, Category 5" 
	    "$500 Answer, Category 1" 
	    "$500 Answer, Category 2" 
	    "$500 Answer, Category 3" 
	    "$500 Answer, Category 4" 
	    "$500 Answer, Category 5" 
	]
	questions: [
	    "$100 Question, Category 1" 
	    "$100 Question, Category 2" 
	    "$100 Question, Category 3" 
	    "$100 Question, Category 4" 
	    "$100 Question, Category 5" 
	    "$200 Question, Category 1" 
	    "$200 Question, Category 2" 
	    "$200 Question, Category 3" 
	    "$200 Question, Category 4" 
	    "$200 Question, Category 5" 
	    "$300 Question, Category 1" 
	    "$300 Question, Category 2" 
	    "$300 Question, Category 3" 
	    "$300 Question, Category 4" 
	    "$300 Question, Category 5" 
	    "$400 Question, Category 1" 
	    "$400 Question, Category 2" 
	    "$400 Question, Category 3" 
	    "$400 Question, Category 4" 
	    "$400 Question, Category 5" 
	    "$500 Question, Category 1" 
	    "$500 Question, Category 2" 
	    "$500 Question, Category 3" 
	    "$500 Question, Category 4" 
	    "$500 Question, Category 5" 
	]
	
	;________________________________________________________________
	
}

do config

header: load to-binary decompress 64#{
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
klBmXUi9Lf8PNy+uUY8gAAA=
}

do-button: func [num] [
    alert pick answers num 
    alert pick questions num
    if find [1 2 3 4 5] num [val: $100]
    if find [6 7 8 9 10] num [val: $200]
    if find [11 12 13 14 15] num [val: $300]
    if find [16 17 18 19 20] num [val: $400]
    if find [21 22 23 24 25] num [val: $500]
    correct: request-list "Select:" ["Player 1 answered correctly" 
        "Player 1 answered incorrectly" "Player 2 answered correctly"
        "Player 2 answered incorrectly" "Player 3 answered correctly"
        "Player 3 answered incorrectly" "Player 4 answered correctly"
        "Player 4 answered incorrectly"
    ] 
    switch correct  [
        "Player 1 answered correctly" [
            player1/text: to-string ((to-money player1/text) + val)
            show player1
        ] 
        "Player 1 answered incorrectly" [
            player1/text: to-string ((to-money player1/text) - val)
            show player1
        ] 
        "Player 2 answered correctly" [
            player2/text: to-string ((to-money player2/text) + val)
            show player2
        ]
        "Player 2 answered incorrectly"[
            player2/text: to-string ((to-money player2/text) - val)
            show player2
        ]
        "Player 3 answered correctly" [
            player3/text: to-string ((to-money player3/text) + val)
            show player3
        ] 
        "Player 3 answered incorrectly" [
            player3/text: to-string ((to-money player3/text) - val)
            show player3
        ] 
        "Player 4 answered incorrectly"[
            player4/text: to-string ((to-money player4/text) - val)
            show player4
        ]
        "Player 4 answered correctly" [
            player4/text: to-string ((to-money player4/text) + val)
            show player4
        ]
    ]
]

view center-face layout gui: [
    tabs (sizer * 20)
    backdrop effect [gradient 1x1 tan brown]
    style button button effect [gradient blue blue/2] (
        to-pair rejoin [(20 * sizer) "x" (13 * sizer)]
    ) font [size: (sizer * 6)]
    style box box brown (to-pair rejoin [(20 * sizer) "x" (7 * sizer
        )]) font [size: (sizer * 3)]
    image header (to-pair rejoin [(132 * sizer) "x" (8 * sizer)]) [
        contin: request/confirm {
            This will end the current game.  Continue?}
        if contin = false [break]
        loadoredit:  request/confirm "Load previously edited config file?"
        if loadoredit = true [
            do to-file request-file/title/file {
                Choose config file to use:} "File" %default_config.txt
            unview
            view center-face layout gui
            break
        ]
        alert {Edit carefully, maintaining all quotation marks.  
            You can open a previously saved file if needed.
            When done, click SAVE-AS and then QUIT.  
            Be sure choose a filename/folder
            location that you'll be able to find later.
        }
        write %default_config.txt config
        unview
        editor %default_config.txt
        alert {Now choose a config file to use (most likely the file
            you just edited).}
        do to-file request-file/title/file {
            Choose config file to use:} "File" %default_config.txt
        view center-face layout gui
    ]
    space (to-pair rejoin [(8 * sizer) "x" (2 * sizer)])
    pad (sizer * 2)
    across
    box (to-pair rejoin [(132 * sizer) "x" (2 * sizer)]
        ) effect [gradient 1x0 brown black] 
    return
    box Category-1 
    box Category-2 
    box Category-3 
    box Category-4 
    box Category-5
    return
    box (to-pair rejoin [(132 * sizer) "x" (2 * sizer)]
        ) effect [gradient 1x0 brown black] 
	return
    button "$100" [face/feel: none face/text: "" do-button 1]
    button "$100" [face/feel: none face/text: "" do-button 2]
    button "$100" [face/feel: none face/text: "" do-button 3]
    button "$100" [face/feel: none face/text: "" do-button 4]
    button "$100" [face/feel: none face/text: "" do-button 5]
    return
    button "$200" [face/feel: none face/text: "" do-button 6]
    button "$200" [face/feel: none face/text: "" do-button 7]
    button "$200" [face/feel: none face/text: "" do-button 8]
    button "$200" [face/feel: none face/text: "" do-button 9]
    button "$200" [face/feel: none face/text: "" do-button 10]
    return
    button "$300" [face/feel: none face/text: "" do-button 11]
    button "$300" [face/feel: none face/text: "" do-button 12]
    button "$300" [face/feel: none face/text: "" do-button 13]
    button "$300" [face/feel: none face/text: "" do-button 14]
    button "$300" [face/feel: none face/text: "" do-button 15]
    return
    button "$400" [face/feel: none face/text: "" do-button 16]
    button "$400" [face/feel: none face/text: "" do-button 17]
    button "$400" [face/feel: none face/text: "" do-button 18]
    button "$400" [face/feel: none face/text: "" do-button 19]
    button "$400" [face/feel: none face/text: "" do-button 20]
    return
    button "$500" [face/feel: none face/text: "" do-button 21]
    button "$500" [face/feel: none face/text: "" do-button 22]
    button "$500" [face/feel: none face/text: "" do-button 23]
    button "$500" [face/feel: none face/text: "" do-button 24]
    button "$500" [face/feel: none face/text: "" do-button 25]
    return 
    box (to-pair rejoin [(132 * sizer) "x" (2 * sizer)]
        ) effect [gradient 1x0 brown black] 
    return tab
    box "Player 1:" effect [gradient 1x1 tan brown]
    player1: box white "$0" font [color: black size: (sizer * 4)] [
        face/text: request-text/title/default "Enter Score:" face/text
    ]
    box "Player 2:" effect [gradient 1x1 tan brown]
    player2: box white "$0" font [color: black size: (sizer * 4)] [
        face/text: request-text/title/default "Enter Score:" face/text
    ]
    return tab
    box "Player 3:" effect [gradient 1x1 tan brown]
    player3: box white "$0" font [color: black size: (sizer * 4)] [
        face/text: request-text/title/default "Enter Score:" face/text
    ]
    box "Player 4:" effect [gradient 1x1 tan brown]
    player4: box white "$0" font [color: black size: (sizer * 4)] [
        face/text: request-text/title/default "Enter Score:" face/text
    ]
]
