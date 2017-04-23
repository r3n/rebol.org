Rebol [
	Title: "Magic 8 ball" 
	Author: "Massimiliano Vessi" 
	Email: maxint@tiscali.it 
	Date: 25-Jun-2010 
	version: 2.0.6
	file: %magic8.r 
	Purpose: {It's the old Magic 8 ball game, 
	think your question and ask the game. } 
	;following data are for www.rebol.org library 
	;you can find a lot of rebol script there 
	library: [ level: 'beginner 
	platform: 'all 
	type: [tutorial gui vid] 
	domain: [game ] 
	tested-under: [windows linux] 
	support: none 
	license: [gpl] 
	see-also: none 
	]
	]


random/seed now

sentences: [ 
    "As I see it, yes"
    "It is certain"
    "It is decidedly so"
    "Most likely"
    "Outlook good"
    "Signs point to yes"
    "Without a doubt"
    "Yes"
    "Yes – definitely"
    "You may rely on it"

    "Reply hazy, try again"
    "Ask again later"
    "Better not tell you now"
    "Cannot predict now"
    "Concentrate and ask again"

    "Don't count on it"
    "My reply is no"
    "My sources say no"
    "Outlook not so good"
    "Very doubtful"
    ]
    
view  layout [
    h1 "Ask the magic ball"
    
    button "ASK" [   
	a: pick  sentences (random 20)
	answer/text: a
	answer/color: random 255.255.255
	show answer
	]
    answer: vtext "________________________" 
    ]

