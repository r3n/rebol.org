REBOL [ Title: "Clausius Clapeyron" 
	Author: "Massimiliano Vessi" 
	Email: maxint@tiscali.it 
	Date: 25-Jun-2010 
	version: 1.0.6
	file: %cla-cla.r 
	Purpose: {"Given the data, check if it's steam or water, 
	and give the temperature for boiling water.
	It usese the Clausius-Clapeyron equation and give the flow in the tube to reach the atmosfere."} 
	
	;following data are for www.rebol.org library 
	;you can find a lot of rebol script there 
	library: [ 
		level: 'beginner 
		platform: 'all 
		type: [tutorial tool] 
		domain: [scientific ] 
		tested-under: [windows linux] 
		support: none 
		license: [gpl] 
		see-also: none ] ] 

print "***Check phase using Clausius-Clapeyron****"		
t: ask "Temperature? (°C) " 
t: to-decimal t
p: ask "Pressure? (bar) " 
p: to-decimal p


cla: func [temperatura] [
		;Clausius-Clapeyron equation, result in millibar!
        pressione_vap: 6.11 * (10 ** ( ( 7.5 * temperatura) / (237.7 + temperatura)))
        pressione_vap: pressione_vap / 1000
        pressione_vap: round/to pressione_vap 0.01
        return pressione_vap
    ]
    
 p_vap: cla t       
 
 
 print reform ["Vapor pressure is: "  p_vap " bar"]
 
 either p < p_vap [ print "It's STEAM."
 	Q: 24 * ( square-root (  p / 2.5 ) )
 	Q: round/to Q 0.01
 	print rejoin ["STEAM flow is: " Q " kg/h"]
 	] [print "It's WATER,"
 	 while [p >= p_vap] [
 	    t: t + 1
 	    p_vap: cla t
 	   	]
 	 print reform ["to obtain steam, you need to reach al least " t "°C"]
	 ]
	 
 
print rejoin [
"********************************^/"
"*if you need to contact author:*^/"
"*maxint" "@" "tiscali.it             *^/"
"********************************^/"]

do %cla-cla.r 
