REBOL[
    Library: [
        level: 'intermediate
        platform: 'all
        type: [tutorial tool]
        domain: [ftp game]
        tested-under: none
        support: 'yes
        license: none
        see-also: none
        ]

   Title: "Style Scrollable scroll-pane & table avec gestion de la roullette"
   File: %style-scrollable.r
   Author: "Claude RAMIER"
   Email: ram.cla@laposte.net
   Date: 14-05-2004
   Purpose: { Essai de gestion des scrolls & de tables }
   Comment: {
   	**** SCROLL-PANE ****
   	
   	**** TABLE ****
   	La table permet:
   		- le tri de ses éléments avec le bouton de droit de la sourie
   		- la modification de champ s'il le style du champ est modifiable
   		- le renvoie de la ligne selectionnée
   		- de cacher des données (qui n'apparaise pas lors de la visualisation) mais qui sont renvoyé par la selection
   		- de changer la longueur des colonnes avec un drag & drop sur l'entête des colonnes.
   		- de gerer les styles suivants :
   			° TEXT
   			° FIELD
   			° IMAGE
   			° CHECK
   			° INFO
   	
   	
   	*	description => la description de la table doit être un block de la forme suivante:
		[set name word! set title string! set length integer! set style_vid word! set choice-texts block! set custom-layout block!]
   		exemple :
   		des: [
					[image "Image" 100 image]
					[nom "Nom" 200 field]
					[date-creation "Creation" 100 text]
					[date-modification "Modification" 100 text]
					[data-chk "Check data" 100 check]
		]
	*	data => Les données doivent être un block d'objet :
		exemple :
		donnee: reduce [
		    make object! [
		        image: %./images/dossier.gif
		        nom: "employé sans titre"
		        date-creation: 01-Nov-2003
		        date-modification: 16-Nov-2003
		        data-chk: 1
    			]
    		]
    		ou
    		donnee: reduce[
    			context [
			        image: %./images/dossier.gif
			        nom: "employé sans titre"
			        date-creation: 01-Nov-2003
			        date-modification: 16-Nov-2003
			        data-chk: 1
    			]
    		]
    	* 	Heigth => hauteur de la ligne détail
    	*	action-selection => permet d'indiquer l'action à faire lors de la selection
    		exemple :
    				action-selection [
					result-text-area/text: mold record-selected
		 			show result-text-area
				] 
    	*	table-colors => permet d'indiquer 3 couleurs :
    			1: couleur ligne impaire
    			2: couleur ligne paire
    			3: couleur de selection
    		si les couleurs sont a none alors la face devient transparente
    	*	table-field-edge => permet d'indiquer le edge de chaque field du detail 
    	
   }
   Version: 0.0.0.1
   History: [ 
      0.0.0.1 {Toujours en construction} 
      ] 
]



;fonction pour capter le scroll-line a partir de screen-face
evt-scroll: func [
	face event
	/local
	face-x
][    
	either (event/type == 'scroll-line) [
		if not  empty?  face-waiting-scroll-line[
				face-x: first face-waiting-scroll-line	
					if (face-x/scroll/y == 1)[
						face-x/sld-ver/data: face-x/sld-ver/data + (event/offset/y * 0.01)
						if (face-x/sld-ver/data < 0) [face-x/sld-ver/data: 0]
						if (face-x/sld-ver/data > 1) [face-x/sld-ver/data: 1]
						show  face-x/sld-ver
						face-x/scroll-ver
						show face-x
					]
		]
		event    
	][        
		; allow other events to pass through        
		event    
	]
] 

evt-resize: func [
	face event
][    
;	print event/type
	either event/type = 'resize [
;print event/offset
		event
	][        
		; allow other events to pass through        
		event    
	]
]

insert-event-func :evt-resize
;insertion de la fonction dans le feel/detect de screen-face
insert-event-func :evt-scroll

;initialisation du block contenant la face à "scroller"
face-waiting-scroll-line: copy []

;styles contenant divers outils pour le scrolling
style-scrollable: stylize [	



	; scroll-pane avec le possibilité de scroller en X ou Y ou les deux suivant parametre scroll
	scroll-pane: face with [ 
		init: copy []
		scroll: none
		sld-ver: none
		sld-hor: none
		old-resize: none
		sub-area: none
		sub-color: none
		center: false
		
	

		words: [          ; nouveaux mots pour VID
	            data [new/data: second args next args] ; fournir le block d'un layout
	            scroll [new/scroll: second args next args] ; indique si le panel est scrollable et x et/ou y
	            center [new/center: second args next args] ; indique s'il faut center le tout
	        ]
	

		feel/detect: func [face event] [
			if event/type = 'down [
				if (face/type == 'scroll-pane) [
					face-waiting-scroll-line: copy []
					append face-waiting-scroll-line face
				]
			]
			return event
		]
	        
	        append init [
	        	sub-color: color
	        	size: any [size 200x200]
	        	old-resize: size
	        	scroll: any [scroll 1x1]
	        	pane-block: copy []
	        	append pane-block [
	        		origin 0x0 space 0x0
	        		sub-area: box (size - (0x16 * scroll/x) - (16x0 * scroll/y)) with [color: sub-color]

	        	]
	        	if (scroll/y == 1)[
				append pane-block [
					at (size * 1x0 - 16x0) 
					sld-ver: scroller ((size - (0x16 * scroll/x)) * 0x1 + 16x0)  [scroll-ver] with [show?: false]
				]
	        	]
	        	if (scroll/x == 1)[
				append pane-block [
					at (size * 0x1 - 0x16) 
					sld-hor: scroller ((size - (16x0 * scroll/y)) * 1x0 + 0x16)  [scroll-hor] with [show?: false]   				
				]
	        	]
	        	type: 'scrollable
	        	pane: layout/size pane-block size
	        	if (not none? data) [
                		sub-area/pane: layout data
                		sub-area/pane/color: none
				recenter
                	]
                	pane/offset: 0x0
	               	pane/color: none
	               	color: none
	           	update-scroll
	        ]
	        
	        scroll-ver: func[][
	        	scroll-panel-ver sub-area sld-ver
	        ]
	        
	        scroll-hor: func[][
	        	scroll-panel-hor sub-area sld-hor
	        ]	        
        
	        update-scroll: func [][
                	either (none? sub-area/pane) [
                		if (scroll/y == 1)[sld-ver/redrag 1 sld-ver/show?: false]
                		if (scroll/x == 1)[sld-hor/redrag 1 sld-hor/show?: false]
                	][
                		if (scroll/y == 1)[
                			either (sub-area/pane/size/y == 0) [ 
						sld-ver/redrag 1
						sld-ver/show?: false
					][
						sld-ver/redrag sub-area/size/y / sub-area/pane/size/y
						either (sub-area/size/y < sub-area/pane/size/y) [
							sld-ver/show?: true
						][
							sld-ver/show?: false
						]					
					]
				]
                		if (scroll/x == 1)[
                			either (sub-area/pane/size/x == 0) [ 
						sld-hor/redrag 1
						sld-hor/show?: false
					][
						sld-hor/redrag sub-area/size/x / sub-area/pane/size/x					
						either (sub-area/size/x < sub-area/pane/size/x) [
							sld-hor/show?: true
						][
							sld-hor/show?: false
						]
					]
				]
			]

	        ]
		scroll-panel-ver: func [sub-area sld-ver][
			if not none? sub-area/pane [
				sub-area/pane/offset/y: negate sld-ver/data *
				(max 0 sub-area/pane/size/y - sub-area/size/y)
			]
			show sub-area
		]  
		
		scroll-panel-hor: func [sub-area sld-hor][
			if not none? sub-area/pane [
				sub-area/pane/offset/x: negate sld-hor/data *
				(max 0 sub-area/pane/size/x - sub-area/size/x)
			]
			show sub-area
		]
		
	        recenter: func [][
                		if not empty? data [
                			sub-area/pane/offset: 0x0
                			if center [
                				if (sub-area/size/x > sub-area/pane/size/x)[
                					sub-area/pane/offset/x: (sub-area/size/x - sub-area/pane/size/x) / 2 
                				]
                				if (sub-area/size/y > sub-area/pane/size/y)[
                					sub-area/pane/offset/y: (sub-area/size/y - sub-area/pane/size/y) / 2 
                				]   
                			]
                		]
   
	        ]
	        
                resize: func [offset-delta [pair! none!]] [
               		 print "coucou"
                    reset 
                    if offset-delta [size: size + offset-delta] 
                    size: min size 32x24 
			show ignore 
                ] 		
	] 
	
	; styles qui affiche une table 
	table: face with [ 
;	   	Initialisation des variables temporaire utilisé
		init: copy []
		record-selected: none
		scroll: none
		pane-block: none
		table-header-area: none
		table-detail-area: none
		sld-ver: none
		sld-hor: none
		table-header-area-field-start: none
		table-header-area-field-oldpos: none
		table-detail-field-edge: none
		table-detail-color: none
		table-detail-colors: none
		;	   	Initialisation des nouveau mots du style		
		header-description: none
		detail-data: none
		line-detail-heigth: none
		action-selection: []
	        words: [          ; nouveaux mots pour VID
	            description [new/header-description: second args next args] ; description de l'entête de la table
	            data [new/detail-data: second args next args] ; donnée pour remplir la table
	            heigth [new/line-detail-heigth: second args next args] ; hauteur de ligne du detail
	            action-selection [new/action-selection: second args next args] ;action lors de la selection d'un ligne
	            table-colors [new/table-detail-colors: second args next args] ;colors utilisés 1,2 pour les interlignes 3 pour la selection
	            table-field-edge [new/table-detail-field-edge: second args next args] ; modification du edge des champs
	        ]
	        
		feel/detect: func [face event] [
			if event/type = 'down [
				if (face/type == 'scrollable) [
					face-waiting-scroll-line: copy []
					append face-waiting-scroll-line face
				]
			]
			return event
		]
		
	        append init [
	        	table-detail-color: color
	        	if none? table-detail-colors [
	        		table-detail-colors: copy []
	        		append table-detail-colors table-detail-color
	        		append table-detail-colors table-detail-color
	        		append table-detail-colors cyan
	        	]
			do build			
		]
		
		build: func[][
	        	line-detail-heigth: any [line-detail-heigth 20]
	        	size: any [size 200x200]
	        	scroll: 1x1
	        	pane-block: copy []
	        	append pane-block [
	        		styles style-scrollable
				origin 0x0 space 0x0 
				table-header-area: table-header  
					(size * 1x0 + 0x20 - 16x0) 
					description header-description 
					with [color: none]
				table-detail-area: table-detail 
					(size - 0x20 - 16x16) 
					description header-description 
					data detail-data
					heigth line-detail-heigth
					detail-colors table-detail-colors
					field-edge table-detail-field-edge
					with [color: table-detail-color]
	        	]
	        	if (scroll/y == 1)[
				append pane-block [
					at (size * 1x0 - 16x0 + 0x20) 
					sld-ver: scroller ((size - (0x16 * scroll/x) - 0x20) * 0x1 + 16x0)  [scroll-ver show ignore]	                				
				]
	        	]
	        	if (scroll/x == 1)[
				append pane-block [
					at (size * 0x1 - 0x16) 
					sld-hor: scroller ((size - (16x0 * scroll/y)) * 1x0 + 0x16)  [scroll-hor show ignore]	                				
				]
	        	]
	        	type: 'scrollable
	        	pane: none
	        	pane: layout/size pane-block size
	        	pane/offset: 0x0
	        	;pane: pane/pane
	        	update-scroll
                	color: none
                	pane/color: none	        	
		
		]
		
		rebuild-detail: func[new-data][
			detail-data: new-data
			table-detail-area/data: detail-data 
			table-detail-area/build
		]
		
		new-data: func[new-data][
			detail-data: new-data
			do build
		]

	        scroll-ver: func[][
	        	scroll-panel-ver table-detail-area sld-ver
	        ]
	        
	        scroll-hor: func[][
	        	scroll-panel-hor table-header-area table-detail-area sld-hor
	        ]
	        
	        update-scroll: func[][
                	either (none? table-detail-area/pane) [
                		if (scroll/y == 1)[sld-ver/redrag 1 sld-ver/show?: false]
                		if (scroll/x == 1)[sld-hor/redrag 1 sld-hor/show?: false]
                	][
                		if (scroll/y == 1)[
                			either (table-detail-area/pane/size/y == 0) [ 
						sld-ver/redrag 1
						sld-ver/show?: false
					][
						sld-ver/redrag table-detail-area/size/y / table-detail-area/pane/size/y
						either (table-detail-area/size/y < table-detail-area/pane/size/y) [
							sld-hor/show?: true
						][
							sld-hor/show?: false
						]						
					]
				]
                		if (scroll/x == 1)[
                			either (table-header-area/pane/size/x == 0) [ 
						sld-hor/redrag 1
						sld-hor/show?: false
					][
						sld-hor/redrag table-header-area/size/x / table-header-area/pane/size/x					
						either (table-header-area/size/x < table-header-area/pane/size/x) [
							sld-hor/show?: true
						][
							sld-hor/show?: false
						]						
					]
				]
			]	        
	        ]
		scroll-panel-ver: func [tda ver][
			if not none? tda/pane [
				tda/pane/offset/y: negate ver/data *
				(max 0 tda/pane/size/y - tda/size/y)
			]
		] 	        
		scroll-panel-hor: func [tha tda hor][
			tda/pane/offset/x: negate hor/data *
			(max 0 tda/pane/size/x - tda/size/x)
			tha/pane/offset/x: negate hor/data *
			(max 0 tha/pane/size/x - tha/size/x)
		]

		get-num-sel: func[field-offset /local numsel][
			numsel: (field-offset/y / (line-detail-heigth + 1)) + 1
		]
		
		set-record-selected: func[field-offset /local numsel][
			numsel: get-num-sel field-offset
			record-selected: table-detail-area/data/:numsel
			if not empty? action-selection [
				do bind action-selection 'record-selected
			]
		]

	] 
	
	; sous style de table
	table-header: face with [
		init: copy []
;	   	Initialisation des variables temporaire utilisé
		head-layout: none
;	   	Initialisation des nouveau mots du style		
		description: none
	        words: [         
	        	description [new/description: second args next args]
	        ]
	        append init [
	        	head-layout: copy []
			append head-layout [styles style-scrollable origin 0x0 space 1x0 across]
			foreach [des] description [
				parse des [set name word! set title string! set length integer! set look word! set choice-texts block! set custom-layout block!]
				append head-layout compose/deep[
					th-btn (length)  (title) field-word (load join "'" name)
				]
			]
			
			;append head-layout [return]
	        	pane: layout head-layout  
	        	;pane: pane/pane
                	pane/offset: 0x0
                	pane/color: none
                	color: none
	        ]
	]

	th-btn: button 195.167.255 with [
		notri: false
		status: none
		field-word: none
		words: [         
			field-word [new/field-word: second args next args]
	        ]
		feel: make feel [engage: func [face action event /local delta newpos table-face field-word status new-data] [
						table-face: face/parent-face/parent-face/parent-face/parent-face
			        		if action = 'down [
			        			face/notri: true
			        			table-face/table-header-area-field-start: event/offset 
			        			table-face/table-header-area-field-oldpos: 0
			        		]
			        		if face/notri [
			        			if action = 'up [
			        				table-face/table-header-area-field-oldpos: 0
			        			]
			       				if (find [over away] action)  [
								newpos: event/offset/x - table-face/table-header-area-field-start/x
								delta: newpos - table-face/table-header-area-field-oldpos
								if ((face/size/x + delta) < 20)[
									newpos: table-face/table-header-area-field-oldpos
									delta: newpos - table-face/table-header-area-field-oldpos
								] 
								foreach obj face/parent-face/pane [
									either (obj/offset/x == face/offset/x) [
										obj/size/x: obj/size/x + delta
									][
										if (obj/offset/x > face/offset/x) [
											obj/offset/x: obj/offset/x + delta
										]
									]									
					    			] 
					    			foreach obj table-face/table-detail-area/pane/pane [
									either (obj/offset/x == face/offset/x) [
										;obj/size/x: obj/size/x + delta
										obj/resize to-pair reduce [delta 0]
									][
										if (obj/offset/x > face/offset/x) [
											obj/offset/x: obj/offset/x + delta
										]
									]									
					    			] 	
					    			foreach des table-face/header-description [
					    				if (des/1 == face/field-word) [
					    					des/3: des/3 + delta
					    				]
					    			]
					    			table-face/table-detail-area/description: table-face/header-description
					    			table-face/table-header-area-field-oldpos: newpos
				    				table-face/table-header-area/pane/size/x: table-face/table-header-area/pane/size/x + delta
				    				table-face/table-detail-area/pane/size/x: table-face/table-detail-area/pane/size/x + delta
				    				table-face/update-scroll
				    				show table-face
			       				]
			       			]
			       			if action = 'alt-down [	
			       				face/notri: false
			       				status:  face/status
							if none? status [status: true]
							field-word: face/field-word
							new-data: copy []
							either status [
								status: false
								new-data: sort/compare table-face/table-detail-area/data func [a b] [
									if a/:field-word = b/:field-word [return 0]
									either a/:field-word > b/:field-word [1][-1]
								]
							][
						    		status: true
							        new-data: sort/compare  table-face/table-detail-area/data func [a b] [
									if a/:field-word = b/:field-word [return 0]
								        either a/:field-word < b/:field-word [1][-1]
							        ]
							]
							table-face/show?: false
							current-pos-sld-ver: table-face/sld-ver/data
							current-pos-sld-hor: table-face/sld-hor/data
							table-face/rebuild-detail table-face/detail-data
							face/status: status
							table-face/sld-ver/data: current-pos-sld-ver
							table-face/sld-hor/data: current-pos-sld-hor
							table-face/scroll-ver
							table-face/scroll-hor
							table-face/show?: true
							show table-face
						]
		]
		]
	

                resize: func [offset-delta [pair! none!]] [
                	reset 
                	if offset-delta [size: size + offset-delta] 
                	size: max size 20x20  
		]		
	]

	; sous style de table
	table-detail: face with [ 
		init: copy []
;	   	Initialisation des variables temporaire utilisé
		detail-layout: none
		check-block: none
		detail-color: none
;	   	Initialisation des nouveau mots du style	
		description: none
		heigth: none
		detail-colors: copy []
		detail-field-edge: none
	        words: [         
	        	description [new/description: second args next args]
	        	data [new/data: second args next args]
	        	heigth [new/heigth: second args next args]
	        	detail-colors [new/detail-colors: second args next args]
	        	field-edge [new/detail-field-edge: second args next args]
	        ]
	        append init [
			detail-color: color
			do build
	        ]
	        build: func[ /local y x][
			detail-layout: copy [] 		
			append detail-layout [styles style-scrollable origin 0x0 space 1x1 across]
			y: 0
			if not none? data[
				foreach rcd data [
					y: y + 1
					x: 0
					foreach [des] description [
						parse des [set name word! set title string! set length integer! set look word! set choice-texts block! set custom-layout block!]
						x: x + 1
						append detail-layout compose/deep [
							styles style-scrollable
							table-detail-field 
							(to-pair reduce[length heigth]) 
						]
						switch/default look [
								image [
									use [image-img image-size-coef image-img-size][
										image-img: to-image load rcd/:name
										image-size-coef: heigth / image-img/size/y
										image-img-size: image-img/size * image-size-coef
										append detail-layout compose/deep [
											data [
												origin 0x0 space 0x0  
												image
												(image-img)
												with [
													size: image-img-size
												]		
											] 
										]
									]
								]
								check [
									append detail-layout compose/deep [
										data [
											origin 0x0 space 0x0 
											check
											(to-logic rcd/:name) 
											[
												use [table-face nbr sel-data toto new-data][
													table-face: face/parent-face/parent-face/parent-face/parent-face/parent-face/parent-face
													nbr: (y)
													sel-data: table-face/table-detail-area/data/:nbr
													toto: to-set-path [sel-data (name)]
													new-data: to-integer face/data
													reduce reduce [toto new-data]
												]
											]											
										] 
									]
								]
								field [
									append detail-layout compose/deep [
										data [
											origin 0x0 space 0x0 
											field
											(to-string rcd/:name) 
											[
												use [table-face nbr sel-data toto][
													table-face: face/parent-face/parent-face/parent-face/parent-face/parent-face/parent-face
													nbr: (y)
													sel-data: table-face/table-detail-area/data/:nbr
													toto: to-set-path [sel-data (name)]
													reduce reduce [toto face/text]
												]
											]
										] 
									]
								]								
								info [
									append detail-layout compose/deep [
										data [
											origin 0x0 space 0x0 
											info
											(to-string rcd/:name) 
										] 
									]
								]
							][
								append detail-layout compose/deep [
									data [
										
										origin 0x0 space 0x0  
										text
										(to-string  rcd/:name) 
									] 

								]
							]
						append detail-layout compose/deep [
							edge [(detail-field-edge)]
							center true
							with [
								face-detail-color: none
								face-detail-color-sel: (detail-colors/3)
								append init [
									either integer? ((y) / 2 )[
										face-detail-color: (detail-colors/1)
									][
										face-detail-color: (detail-colors/2)
									]							
									color: face-detail-color									
								]
							]					
						]							
					]
					append detail-layout [return]
				]
	        	]
	        	pane: layout detail-layout
                	pane/offset: 0x0
                	pane/color: detail-color
                	color: none
	        ]
	] 

	; scroll-pane avec le possibilité de scroller en X ou Y ou les deux suivant parametre scroll
	table-detail-field: box with [ 
		init: copy []
		sub-area: none
		center: false
		tableau: none
		field-color: none
	

		words: [          ; nouveaux mots pour VID
	            data [new/data: second args next args]
	            center [new/center: second args next args]
	            tableau [new/tableau: second args next args]
	        ]
	      
		feel/detect: func [face event /local table-face] [
			if event/type = 'down [
				if (face/type == 'table-detail-field)[
					table-face: face/parent-face/parent-face/parent-face/parent-face
					foreach obj face/parent-face/pane [						
						either (obj/offset/y == face/offset/y) [
							obj/color: obj/face-detail-color-sel
							table-face/set-record-selected face/offset
						][
							;obj/color: face/field-color
							obj/color: obj/face-detail-color
						]
	    				] 
	    				;show face
					show face/parent-face
				]
			]
			return event
				
					
		]
		
	        append init [
	        	field-color: color
	        	size: any [size 200x200]
	        	pane-block: copy []
	        	append pane-block [
	        		origin 0x0 space 0x0
	        		sub-area: box (size) with [color: field-color]
	        	]
	        	pane: layout/size pane-block size
	        	if (not none? data) [
                		sub-area/pane: layout data
                		sub-area/pane/color: none
                		recenter
             		]
                	type: 'table-detail-field
                	pane: sub-area/pane
                	;pane/offset: 0x0
                	color:none
	        ]
	        
	        recenter: func [][
                		if not empty? data [
                			sub-area/pane/offset: 0x0
                			if center [
                				if (sub-area/size/x > sub-area/pane/size/x)[
                					sub-area/pane/offset/x: (sub-area/size/x - sub-area/pane/size/x) / 2 
                				]
                				if (sub-area/size/y > sub-area/pane/size/y)[
                					sub-area/pane/offset/y: (sub-area/size/y - sub-area/pane/size/y) / 2 
                				]   
                			]
                		]
   
	        ]
	        
                resize: func [offset-delta [pair! none!]] [
                	reset 
                	if offset-delta [size: size + offset-delta] 
                	size: max size 20x20  
                	sub-area/size: size
			recenter
		]	        
	]
]

