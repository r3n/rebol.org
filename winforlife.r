Rebol [ 
title: "Win for Life!"
 Author: "Massimiliano Vessi"
 Email: maxint@tiscali.it
 Date: 01-01-2011
 version: 1.4.9
 file: %winforlife.r
 Purpose: {"Win for life" is an italian lotery. You have to guess 10 number over 20, plus a number over 20. The probability is about 1/3000000.
This is a simply random numbers generator between 1 and 20. }
 
 ;following data are for www.rebol.org library
 ;you can find a lot of rebol script there
 library: [ 
           level: 'beginner 
           platform: 'all 
           type: [tutorial tool] 
           domain: [ vid gui] 
           tested-under: [windows linux] 
           support: none 
           license: [gpl] 
           see-also: none 
          ] 
]
	

random/seed now

view layout [
	title "Win for life!"
	across
	a1: text "xxx"
	a2: text "xxx"
	a3: text "xxx"
	a4: text "xxx"
	a5: text "xxx"
	return
	a6: text "xxx"
	a7: text "xxx"
	a8: text "xxx"
	a9: text "xxx"
	a10: text "xxx"
	
	return
	button "Estrai!" [
	
			estrazione: copy/part  (random [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20])  10
			sort estrazione
			a1/text: to-string estrazione/1
			a2/text: to-string estrazione/2
			a3/text: to-string estrazione/3
			a4/text: to-string estrazione/4
			a5/text: to-string estrazione/5
			a6/text: to-string estrazione/6
			a7/text: to-string estrazione/7
			a8/text: to-string estrazione/8
			a9/text: to-string estrazione/9
			a10/text: to-string estrazione/10
			show [a1 a2 a3 a4 a5 a6 a7 a8 a9 a10]
			
			
		]
	]