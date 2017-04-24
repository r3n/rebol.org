    REBOL [
    	File: %number-buttons-game.r
    	Date: 23-Sep-2014
    	Title: "The number-memory buttons"
    	Purpose: {
                       In this game you will have to click the buttons
                       and memorize the numebers, at the end you will
                       be asked to write the bigger or the smaller.
                       This is a race against your memory.
                       } 
        Know-bugs: {
                            When you enter the number the game will
                            always say that it is wrong, even if it is rigth.
                            
                            Buttons when moving on the screen may overlap
                            thus becoming hard to see
                            
                            If you know how to fix these bugs just tell me
                            and I will add you in the credits
                            }
        Credits: {
                            The Stack Overflow REBOL chat that gave me
                            some technical hints about rebol.
                            "Noone (now)" that solved one/any bug/s
                    }

         Author: "Caridorc"
                           library: [
                                        level: 'beginner
                                        platform: 'all
                                        type: [game]
                                        domain: [game]
                                        tested-under: "Windows"
                                        support: riki100024 AT gmail DOT com
                                        license: {
                                                     This simple game is licensed under the
                                                     CC 3.0 Attribution only license.

                                                     You can use and/or distribute
                                                     and/or modify and/or make money from
                                                     this programme but you should put my name
                                                     in the credits
                                                     }
                                        see-also: none
    ]


    	]


random/seed now/precise

heigth: 600 
length: 800

view layout [

    size as-pair length heigth
    jumper1: button to-string 1 [
	    a: random 100
	    alert [to-string a]
		b1pressed: True
		jumper1/offset: random as-pair length - 50 heigth - 50
]
	jumper2: button to-string 2 [
	    b: random 100
		alert [to-string b]
		b2pressed: True
        jumper2/offset: random as-pair length - 50 heigth - 50]
		
	jumper3: button to-string 3 [
	    c: random 100
		alert [to-string c]
		b3pressed: True
        jumper3/offset: random as-pair length - 50 heigth - 50
        ]
		
	jumper4: button to-string 4 [
	    d: random 100
        alert [to-string d]
		b4pressed: True
        jumper4/offset: random as-pair length - 50 heigth - 50]
		
	jumper5: button to-string 5 [
	    e: random 100
		alert [to-string e]
		b5pressed: True
        jumper5/offset: random as-pair length - 50 heigth - 50
        either ((random 2) = 1)
		    [user-bigger: request-text/title "Which one was bigger?"
            real-bigger: maximum-of reduce [a b c d e]
		    either ((to-integer user-bigger) = real-bigger)
		         [alert "Rigth"]
		         [alert "Wrong"]
		    ]
			
			[
		    user-smaller: request-text/title "Which one was smaller?"
            real-smaller: minimum-of reduce [a b c d e]
		    either ((to-integer user-smaller) = real-smaller)
		        [alert "Rigth"]
		        [alert "Wrong"]
			]
		]
	
]
