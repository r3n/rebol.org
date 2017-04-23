REBOL[
   Title: "Test de %style-scrollable.r"
   File: %test-style-scrollable.r
   Author: "Claude RAMIER"
   Email: ram.cla@laposte.net
   Date: 14-05-2004
   Purpose: { Essai de gestion des scrolls & de tables }
    library: [
        level: 'intermediate
        platform: 'all
        type: [tutorial tool]
        domain: [GUI]
        tested-under: none
        support: none
        license: none
        see-also: %style-scrollable.r
    ]
   Comment: {
   to run this script you need %style-scrollable.r
   this is a exemple of use of %style-scrollable.r
   }
]

do %style-scrollable.r





donnee: reduce [
    make object! [
 
        nom: "employé sans titre"
        date-creation: 01-Nov-2003
        date-modification: 16-Nov-2003
        data-chk: 1
    ]
    make object! [
 
        nom: "Chef de Service"
        date-creation: 02-Nov-2003
        date-modification: 18-Nov-2003
        data-chk: 1
    ]
    make object! [
 
        nom: "Chef de Service"
        date-creation: 03-Nov-2003
        date-modification: 18-Nov-2003
        data-chk: 1
    ] 
    make object! [
 
        nom: "employé sans titre"
        date-creation: 04-Nov-2003
        date-modification: 16-Nov-2003
        data-chk: 1
    ]
    make object! [
 
        nom: "Chef de Service"
        date-creation: 18-Nov-2003
        date-modification: 18-Nov-2003
        data-chk: 1
    ]
    make object! [
 
        nom: "Chef de Service"
        date-creation: 18-Nov-2003
        date-modification: 18-Nov-2003
        data-chk: 1
    ] 
    make object! [
 
        nom: "employé sans titre"
        date-creation: 16-Nov-2003
        date-modification: 16-Nov-2003
        data-chk: 1
    ]
    make object! [
 
        nom: "Chef de Service"
        date-creation: 18-Nov-2003
        date-modification: 18-Nov-2003
        data-chk: 1
    ]
    make object! [
 
        nom: "Chef de Service"
        date-creation: 18-Nov-2003
        date-modification: 18-Nov-2003
        data-chk: 1
    ] 
    make object! [
 
        nom: "employé sans titre"
        date-creation: 16-Nov-2003
        date-modification: 16-Nov-2003
        data-chk: 1
    ]
    make object! [
 
        nom: "Chef de Service"
        date-creation: 18-Nov-2003
        date-modification: 18-Nov-2003
        data-chk: 1
    ]
    make object! [
 
        nom: "Chef de Service"
        date-creation: 18-Nov-2003
        date-modification: 18-Nov-2003
        data-chk: 1
    ]     
    make object! [
 
        nom: "employé sans titre"
        date-creation: 16-Nov-2003
        date-modification: 16-Nov-2003
        data-chk: 1
    ]
    make object! [
 
        nom: "Chef de Service"
        date-creation: 18-Nov-2003
        date-modification: 18-Nov-2003
        data-chk: 1
    ]
    make object! [
 
        nom: "Chef de Service"
        date-creation: 18-Nov-2003
        date-modification: 18-Nov-2003
        data-chk: 1
    ] 
    make object! [
 
        nom: "employé sans titre"
        date-creation: 16-Nov-2003
        date-modification: 16-Nov-2003
        data-chk: 1
    ]
    make object! [
 
        nom: "Chef de Service"
        date-creation: 18-Nov-2003
        date-modification: 18-Nov-2003
        data-chk: 1
    ]
    make object! [
 
        nom: "Chef de Service"
        date-creation: 18-Nov-2003
        date-modification: 18-Nov-2003
        data-chk: 1
    ]    
]
    
des: [
			[data-chk "Check data" 100 check]
			[nom "Nom" 200 field]
			[date-creation "Creation" 100 text]
			[date-modification "Modification" 100 text]			
]
 
 
 img: load %./images/x.jpg

main-screen: layout [

	
	backdrop white
	image logo.gif
	
	
	styles style-scrollable  
	origin 0x0 space 0x0
	
	
	scroll-pane (system/view/screen-face/size * 3 / 4)  data [

		styles style-scrollable  
		origin 0x0 space 0x0
		
		scroll-pane  800x600 data [

			styles style-scrollable 
			origin 0x0 space 1x1
			
			label green "Ligne selectionnée :"
			result-text-area: area 300x200 "pas de selection"
			
			t: table 500x300  white
				description des 
				data donnee
				heigth 22 
				action-selection [
					result-text-area/text: mold record-selected
					show result-text-area
				] 
				table-colors [yellow red purple]
				table-field-edge [size: 1x1 color: green] 
				;effect [gradient 1x1 200.90.0 90.0.100]
				with [color: none]
			
		] center 1 scroll 0x0 with [color: none]
  		
	] with [color: none]
	
] 

view/options center-face main-screen 'resize